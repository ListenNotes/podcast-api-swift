import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

let BASE_URL_PROD = "https://listen-api.listennotes.com/api/v2"
let BASE_URL_TEST = "https://listen-api-test.listennotes.com/api/v2"
let DEFAULT_USER_AGENT = "podcast-api-swift \(Client.version)"

/// A reusable Listen API client. An empty API key selects the public mock service.
/// Configuration setters are synchronized; each request uses a configuration snapshot.
public final class Client: @unchecked Sendable {
    public static let version = "3.0.0"
    private let apiKey: String
    private let baseURL: URL
    private let session: URLSession
    private let synchronousRequest: Bool
    private let lock = NSLock()
    private var userAgent = DEFAULT_USER_AGENT
    private var responseTimeoutSec: TimeInterval = 30

    public convenience init(apiKey: String) {
        self.init(apiKey: apiKey, synchronousRequest: false)
    }

    /// The synchronous option affects callback methods only. Prefer async/await in new code.
    public convenience init(apiKey: String, synchronousRequest: Bool) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        self.init(apiKey: apiKey, synchronousRequest: synchronousRequest,
                  configuration: configuration, baseURL: nil)
    }

    /// Configure sessions or point at a local test server. The selected server receives the API key.
    /// Redirects are rejected, including when a custom configuration is provided.
    public init(apiKey: String, synchronousRequest: Bool = false,
                configuration: URLSessionConfiguration, baseURL: URL? = nil) {
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.baseURL = baseURL ?? URL(string: self.apiKey.isEmpty ? BASE_URL_TEST : BASE_URL_PROD)!
        self.synchronousRequest = synchronousRequest
        let config = configuration.copy() as! URLSessionConfiguration
        self.responseTimeoutSec = config.timeoutIntervalForRequest
        config.httpCookieStorage = nil
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config, delegate: NoRedirectDelegate(), delegateQueue: nil)
    }

    deinit {
        // The last callback may release this client on URLSession's internal queue.
        // Linux Foundation synchronously enters that queue when invalidating a session.
        let session = self.session
        DispatchQueue.global().async { session.invalidateAndCancel() }
    }

    public func setUserAgent(userAgent: String) {
        lock.withLock { self.userAgent = userAgent }
    }

    /// Set the per-request inactivity timeout; the configuration's total resource limit still applies.
    public func setResponseTimeoutSec(timeoutSec: Int) {
        lock.withLock { responseTimeoutSec = TimeInterval(max(1, timeoutSec)) }
    }

    /// Percent-encode one path segment or one form/query component (including literal plus signs).
    static func encode(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters:
            CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"))!
    }

    func makeRequest(path: String, method: String, pathNames: [String], queryNames: [String],
                     parameters: [String: String]) throws -> URLRequest {
        guard ["http", "https"].contains(baseURL.scheme), baseURL.host != nil,
              baseURL.user == nil, baseURL.password == nil, baseURL.query == nil, baseURL.fragment == nil else {
            throw PodcastApiError.invalidRequestError
        }
        var route = path
        var fields = parameters
        for name in pathNames {
            guard let value = fields.removeValue(forKey: name), !value.isEmpty,
                  value != ".", value != ".." else { throw PodcastApiError.invalidRequestError }
            route = route.replacingOccurrences(of: "{\(name)}", with: Self.encode(value))
        }
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.percentEncodedPath = components.percentEncodedPath.trimmingSuffix("/") + route
        let hasBody = method == "POST" || method == "PUT"
        var query: [String: String] = [:]
        var body: [String: String] = [:]
        for (key, value) in fields {
            if !hasBody || queryNames.contains(key) { query[key] = value }
            else { body[key] = value }
        }
        func form(_ values: [String: String]) -> String {
            values.keys.sorted().map { "\(Self.encode($0))=\(Self.encode(values[$0]!))" }.joined(separator: "&")
        }
        components.percentEncodedQuery = query.isEmpty ? nil : form(query)
        guard let url = components.url else { throw PodcastApiError.invalidRequestError }
        var request = URLRequest(url: url)
        request.httpMethod = method
        if !apiKey.isEmpty { request.setValue(apiKey, forHTTPHeaderField: "X-ListenAPI-Key") }
        let settings = lock.withLock { (userAgent, responseTimeoutSec) }
        request.setValue(settings.0, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = settings.1
        if hasBody {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = Data(form(body).utf8)
        }
        return request
    }

    func request(path: String, method: String, pathNames: [String], queryNames: [String],
                 parameters: [String: String]) async throws -> ApiResponse {
        let request = try makeRequest(path: path, method: method, pathNames: pathNames,
                                      queryNames: queryNames, parameters: parameters)
        try Task.checkCancellation()
        let result: ApiResponse
        do {
            let (data, response) = try await session.data(for: request)
            result = ApiResponse(request: request, data: data, response: response, httpError: nil, apiError: nil)
        } catch {
            if Task.isCancelled { throw CancellationError() }
            throw ApiRequestError(response: ApiResponse(request: request, data: nil, response: nil,
                                  httpError: error, apiError: .apiConnectionError))
        }
        if result.error != nil { throw ApiRequestError(response: result) }
        return result
    }

    @discardableResult
    func request(path: String, method: String, pathNames: [String], queryNames: [String],
                 parameters: [String: String], completion: @escaping @Sendable (ApiResponse) -> Void) -> URLSessionDataTask? {
        let request: URLRequest
        do {
            request = try makeRequest(path: path, method: method, pathNames: pathNames,
                                      queryNames: queryNames, parameters: parameters)
        } catch {
            completion(ApiResponse(request: nil, data: nil, response: nil, httpError: error, apiError: .invalidRequestError))
            return nil
        }
        let semaphore = synchronousRequest ? DispatchSemaphore(value: 0) : nil
        let task = session.dataTask(with: request) { [self] data, response, error in
            defer { semaphore?.signal() }
            withExtendedLifetime(self) {
                completion(ApiResponse(request: request, data: data, response: response, httpError: error,
                                       apiError: error == nil ? nil : .apiConnectionError))
            }
        }
        task.resume()
        semaphore?.wait()
        return task
    }
}

private final class NoRedirectDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest,
                    completionHandler: @escaping @Sendable (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}

private extension String {
    func trimmingSuffix(_ suffix: Character) -> String {
        var result = self
        while result.last == suffix { result.removeLast() }
        return result
    }
}
