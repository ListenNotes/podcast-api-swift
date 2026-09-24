import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
@testable import PodcastAPI

struct Operation: Sendable {
    let id: String
    let method: String
    let path: String
    let parameters: [(name: String, location: String)]
    let example: [String: String]
}

func contract() throws -> [Operation] {
    let url = Bundle.module.url(forResource: "api-contract", withExtension: "json")!
    let root = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as! [String: Any]
    return (root["operations"] as! [[String: Any]]).map { op in
        let parameters = (op["parameters"] as! [[String: Any]]).map {
            (name: $0["name"] as! String, location: $0["in"] as! String)
        }
        let example = (op["example_params"] as! [String: Any]).mapValues { value -> String in
            if let string = value as? String { return string }
            return String(data: try! JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed), encoding: .utf8)!
        }
        return Operation(id: op["operationId"] as! String, method: op["method"] as! String,
                         path: op["path"] as! String, parameters: parameters, example: example)
    }
}

enum MockResult: Sendable {
    case response(Int, [String: String], Data)
    case failure(URLError)
    case waitForCancellation
}

final class MockProtocol: URLProtocol, @unchecked Sendable {
    final class Handlers: @unchecked Sendable {
        let lock = NSLock()
        var values: [String: @Sendable (URLRequest) -> MockResult] = [:]
        func set(_ host: String, _ value: (@Sendable (URLRequest) -> MockResult)?) {
            lock.withLock { values[host] = value }
        }
        func get(_ host: String) -> (@Sendable (URLRequest) -> MockResult)? { lock.withLock { values[host] } }
    }
    static let handlers = Handlers()
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        // Every request is intercepted. An unexpected host fails locally rather than falling through.
        guard let host = request.url?.host, let handler = Self.handlers.get(host) else {
            client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet)); return
        }
        switch handler(request) {
        case let .response(status, headers, data):
            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        case let .failure(error): client?.urlProtocol(self, didFailWithError: error)
        case .waitForCancellation: break
        }
    }
    override func stopLoading() {}
}

final class Fixture: @unchecked Sendable {
    let host = UUID().uuidString.lowercased() + ".invalid"
    let client: Client
    init(key: String = "", synchronous: Bool = false,
         handler: @escaping @Sendable (URLRequest) -> MockResult = { _ in .response(200, [:], Data("{}".utf8)) }) {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        config.protocolClasses = [MockProtocol.self]
        client = Client(apiKey: key, synchronousRequest: synchronous, configuration: config,
                        baseURL: URL(string: "https://\(host)/api/v2")!)
        MockProtocol.handlers.set(host, handler)
    }
    deinit { MockProtocol.handlers.set(host, nil) }
}

func formValues(_ text: String?) -> [String: String] {
    guard let text, !text.isEmpty else { return [:] }
    return Dictionary(uniqueKeysWithValues: text.split(separator: "&").map { item in
        let parts = item.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
        return (String(parts[0]).removingPercentEncoding!, String(parts[1]).removingPercentEncoding!)
    })
}

func requestBody(_ request: URLRequest) -> Data? {
    if let body = request.httpBody { return body }
    guard let stream = request.httpBodyStream else { return nil }
    stream.open()
    defer { stream.close() }
    var result = Data()
    var buffer = [UInt8](repeating: 0, count: 1024)
    while true {
        let count = stream.read(&buffer, maxLength: buffer.count)
        if count <= 0 { break }
        result.append(contentsOf: buffer.prefix(count))
    }
    return result
}

final class PodcastAPITests: XCTestCase, @unchecked Sendable {
    func testJSONNumberComparisonsKeepBooleansDistinct() {
        XCTAssertTrue(JSON(1) < JSON(2))
        XCTAssertTrue(JSON(2) > JSON(1))
        XCTAssertTrue(JSON(2) <= JSON(2))
        XCTAssertTrue(JSON(2) >= JSON(2))
        XCTAssertEqual(JSON(2), JSON(2.0))
        XCTAssertNotEqual(JSON(true), JSON(1))
        XCTAssertFalse(JSON(false) < JSON(1))
    }

    func testEveryAsyncMethodMatchesContract() async throws {
        let operations = try contract()
        XCTAssertEqual(operations.count, 30)
        for op in operations {
            let fixture = Fixture { request in
                XCTAssertEqual(request.httpMethod, op.method, op.id)
                var path = op.path
                for param in op.parameters where param.location == "path" {
                    path = path.replacingOccurrences(of: "{\(param.name)}", with: Client.encode(op.example[param.name]!))
                }
                let url = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
                XCTAssertEqual(url.percentEncodedPath, "/api/v2" + path, op.id)
                let query = formValues(url.percentEncodedQuery)
                let body = formValues(requestBody(request).flatMap { String(data: $0, encoding: .utf8) })
                for param in op.parameters {
                    guard let value = op.example[param.name] else { continue }
                    switch param.location {
                    case "path": XCTAssertNil(query[param.name]); XCTAssertNil(body[param.name])
                    case "query": XCTAssertEqual(query[param.name], value, op.id); XCTAssertNil(body[param.name])
                    default: XCTAssertEqual(body[param.name], value, op.id); XCTAssertNil(query[param.name])
                    }
                }
                XCTAssertNil(request.value(forHTTPHeaderField: "X-ListenAPI-Key"))
                return .response(op.method == "POST" ? 201 : 200, [:], Data("{\"ok\":true}".utf8))
            }
            let response = try await callMethod(op.id, client: fixture.client, parameters: op.example)
            XCTAssertNil(response.error)
            XCTAssertTrue(response.toJson()!["ok"].boolValue)
        }
    }

    func testEveryCallbackMethodRemainsAvailable() async throws {
        for op in try contract() {
            let fixture = Fixture()
            let response: ApiResponse = await withCheckedContinuation { continuation in
                callMethod(op.id, client: fixture.client, parameters: op.example) { continuation.resume(returning: $0) }
            }
            XCTAssertNil(response.error, op.id)
            XCTAssertEqual(response.request?.httpMethod, op.method, op.id)
        }
    }

    func testNestedIdentifiersAndEmptyFieldsAreEncodedOnce() async throws {
        let fixture = Fixture { request in
            let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            XCTAssertEqual(components.percentEncodedPath, "/api/v2/playlists/a%2Fb%3F%23%25/items/x%2Fy%26%3D")
            XCTAssertNil(components.query)
            XCTAssertEqual(formValues(requestBody(request).flatMap { String(data: $0, encoding: .utf8) }), ["notes": ""])
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")
            return .response(200, [:], Data("{}".utf8))
        }
        _ = try await fixture.client.updatePlaylistItemNotes(parameters: ["id": "a/b?#%", "item_id": "x/y&=", "notes": ""])
    }

    func testFormAndQuerySpecialCharacters() async throws {
        for method in ["GET", "POST", "PUT", "DELETE"] {
            let values = ["q": "café & + = ? # \\ \n", "description": "", "page": "0", "enabled": "false"]
            let fixture = Fixture()
            let request = try fixture.client.makeRequest(path: "/test", method: method, pathNames: [], queryNames: ["page"], parameters: values)
            let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            let query = formValues(components.percentEncodedQuery)
            let body = formValues(request.httpBody.flatMap { String(data: $0, encoding: .utf8) })
            XCTAssertEqual(query.merging(body) { _, new in new }, values)
            if method == "POST" || method == "PUT" {
                XCTAssertEqual(query, ["page": "0"])
                XCTAssertEqual(body["description"], "")
            } else { XCTAssertNil(request.httpBody) }
        }
    }

    func testClientIsolationAndConfiguration() throws {
        let first = Fixture(key: "first")
        let second = Fixture(key: "second")
        first.client.setUserAgent(userAgent: "custom")
        first.client.setResponseTimeoutSec(timeoutSec: 7)
        let a = try first.client.makeRequest(path: "/search", method: "GET", pathNames: [], queryNames: [], parameters: [:])
        let b = try second.client.makeRequest(path: "/search", method: "GET", pathNames: [], queryNames: [], parameters: [:])
        XCTAssertEqual(a.value(forHTTPHeaderField: "X-ListenAPI-Key"), "first")
        XCTAssertEqual(b.value(forHTTPHeaderField: "X-ListenAPI-Key"), "second")
        XCTAssertEqual(a.value(forHTTPHeaderField: "User-Agent"), "custom")
        XCTAssertEqual(b.value(forHTTPHeaderField: "User-Agent"), "podcast-api-swift 3.0.0")
        XCTAssertEqual(a.timeoutInterval, 7)
        XCTAssertEqual(b.timeoutInterval, 30)
        let mock = Client(apiKey: " \n")
        let request = try mock.makeRequest(path: "/search", method: "GET", pathNames: [], queryNames: [], parameters: [:])
        XCTAssertEqual(request.url?.host, "listen-api-test.listennotes.com")
        XCTAssertNil(request.value(forHTTPHeaderField: "X-ListenAPI-Key"))
        XCTAssertEqual(request.timeoutInterval, 30)
        let custom = URLSessionConfiguration.ephemeral
        custom.timeoutIntervalForRequest = 90
        custom.timeoutIntervalForResource = 120
        let configured = Client(apiKey: "", configuration: custom)
        custom.timeoutIntervalForRequest = 3
        XCTAssertEqual(try configured.makeRequest(path: "/search", method: "GET", pathNames: [],
                                                 queryNames: [], parameters: [:]).timeoutInterval, 90)
    }

    func testInvalidIdentifiersFailBeforeNetwork() async throws {
        let fixture = Fixture { _ in XCTFail("Must not send an invalid request"); return .failure(URLError(.badURL)) }
        for values in [[:], ["id": ""], ["id": "."], ["id": ".."], ["id": "ok"]] {
            do {
                _ = try await fixture.client.deletePlaylistItem(parameters: values)
                XCTFail("Expected invalid identifiers")
            } catch { XCTAssertEqual(error as? PodcastApiError, .invalidRequestError) }
        }
        let response: ApiResponse = await withCheckedContinuation { continuation in
            fixture.client.fetchPlaylistById(parameters: [:]) { continuation.resume(returning: $0) }
        }
        XCTAssertEqual(response.error, .invalidRequestError)
        XCTAssertNil(response.request)
    }

    func testHTTPFailuresPreserveStatusHeadersAndBody() async throws {
        let statuses: [(Int, PodcastApiError)] = [(302, .unexpectedResponseError), (400, .invalidRequestError),
            (401, .authenticationError), (403, .permissionDeniedError), (404, .notFoundError),
            (422, .invalidRequestError), (429, .tooManyRequestsError), (500, .serverError), (503, .serverError)]
        for (status, kind) in statuses {
            let fixture = Fixture { _ in .response(status, ["X-ListenAPI-Usage": "123"], Data("{\"error\":\"Exact reason\"}".utf8)) }
            do {
                _ = try await fixture.client.fetchMyPlaylists()
                XCTFail("Expected HTTP error")
            } catch let error as ApiRequestError {
                XCTAssertEqual(error.response.error, kind)
                XCTAssertEqual(error.response.statusCode, status)
                XCTAssertEqual(error.response.getUsage(), 123)
                XCTAssertEqual(error.localizedDescription, "Exact reason")
                XCTAssertNotNil(error.response.data)
            }
        }
    }

    func testHeadersJSONAndDecodable() async throws {
        struct Body: Decodable { let name: String }
        let fixture = Fixture { _ in .response(201, ["X-LISTENAPI-FREEQUOTA": "25000", "x-ListenApi-Usage": "19231",
            "X-ListenAPI-Latency-Seconds": "0.056", "X-ListenAPI-NextBillingDate": "2026-10-01"], Data("{\"name\":\"test\"}".utf8)) }
        let result = try await fixture.client.createPlaylist(parameters: ["name": "test"])
        XCTAssertEqual(result.getFreeQuota(), 25000)
        XCTAssertEqual(result.getUsage(), 19231)
        XCTAssertEqual(result.getLatencySeconds(), 0.056)
        XCTAssertEqual(result.getNextBillingDate(), "2026-10-01")
        XCTAssertEqual(try result.decode(Body.self).name, "test")
        XCTAssertEqual(result.toJson()?["name"].string, "test")
    }

    func testEmptyAndNonJSONSuccessAndTruncatedBody() {
        let request = URLRequest(url: URL(string: "https://fixture.invalid/")!)
        for status in [200, 201, 204, 299] {
            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: [:])!
            let result = ApiResponse(request: request, data: Data("not json".utf8), response: response, httpError: nil, apiError: nil)
            XCTAssertNil(result.error)
            XCTAssertNil(result.toJson())
            XCTAssertEqual(result.getFreeQuota(), -1)
            XCTAssertEqual(result.getNextBillingDate(), "")
        }
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: [:])!
        XCTAssertEqual(ApiResponse(request: request, data: nil, response: response,
                                  httpError: URLError(.networkConnectionLost), apiError: nil).error, .apiConnectionError)
    }

    func testConnectionFailureAndTimeout() async throws {
        for code in [URLError.Code.notConnectedToInternet, .timedOut] {
            let fixture = Fixture { _ in .failure(URLError(code)) }
            do { _ = try await fixture.client.search(); XCTFail("Expected connection error") }
            catch let error as ApiRequestError {
                XCTAssertEqual(error.response.error, .apiConnectionError)
                XCTAssertEqual((error.response.httpError as? URLError)?.code, code)
            }
        }
    }

    func testAsyncCancellation() async throws {
        let started = expectation(description: "started")
        let fixture = Fixture { _ in started.fulfill(); return .waitForCancellation }
        let task = Task { try await fixture.client.search() }
        await fulfillment(of: [started], timeout: 3)
        task.cancel()
        do { _ = try await task.value; XCTFail("Expected cancellation") }
        catch { XCTAssertTrue(error is CancellationError) }
    }

    func testCallbackCancellation() async throws {
        let started = expectation(description: "started")
        let completed = expectation(description: "cancelled")
        let fixture = Fixture { _ in started.fulfill(); return .waitForCancellation }
        let task = fixture.client.search { response in
            XCTAssertEqual((response.httpError as? URLError)?.code, .cancelled)
            completed.fulfill()
        }
        await fulfillment(of: [started], timeout: 3)
        task?.cancel()
        await fulfillment(of: [completed], timeout: 3)
    }

    func testSynchronousCallbackFinishesBeforeReturn() {
        final class Box: @unchecked Sendable { let lock = NSLock(); var called = false }
        let box = Box()
        let fixture = Fixture(synchronous: true)
        fixture.client.search { _ in box.lock.withLock { box.called = true } }
        XCTAssertTrue(box.lock.withLock { box.called })
    }
}
