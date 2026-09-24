import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Immutable response context, shared by callback and async/await methods.
public final class ApiResponse: Sendable {
    public let data: Data?
    public let response: HTTPURLResponse?
    public let request: URLRequest?
    public let httpError: (any Error)?
    public let error: PodcastApiError?
    public var statusCode: Int? { response?.statusCode }

    public init(request: URLRequest?, data: Data?, response: URLResponse?, httpError: (any Error)?, apiError: PodcastApiError?) {
        self.request = request
        self.data = data
        self.response = response as? HTTPURLResponse
        self.httpError = httpError
        // A body read can fail after receiving HTTP 200; retain the connection error.
        if let apiError { self.error = apiError }
        else if httpError != nil { self.error = .apiConnectionError }
        else {
            switch self.response?.statusCode ?? 0 {
            case 200..<300: self.error = nil
            case 401: self.error = .authenticationError
            case 403: self.error = .permissionDeniedError
            case 404: self.error = .notFoundError
            case 429: self.error = .tooManyRequestsError
            case 400..<500: self.error = .invalidRequestError
            case 500..<600: self.error = .serverError
            default: self.error = .unexpectedResponseError
            }
        }
    }

    /// The existing SwiftyJSON-compatible response interface.
    public func toJson() -> JSON? {
        guard let data else { return nil }
        return try? JSON(data: data)
    }

    /// Decode a response into an application-defined Codable model.
    public func decode<T: Decodable>(_ type: T.Type, using decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(type, from: data ?? Data())
    }

    public func header(_ name: String) -> String? { response?.value(forHTTPHeaderField: name) }
    public func getFreeQuota() -> Int { header("X-ListenAPI-FreeQuota").flatMap(Int.init) ?? -1 }
    public func getUsage() -> Int { header("X-ListenAPI-Usage").flatMap(Int.init) ?? -1 }
    public func getNextBillingDate() -> String { header("X-ListenAPI-NextBillingDate") ?? "" }
    public func getLatencySeconds() -> Double? { header("X-ListenAPI-Latency-Seconds").flatMap(Double.init) }
}
