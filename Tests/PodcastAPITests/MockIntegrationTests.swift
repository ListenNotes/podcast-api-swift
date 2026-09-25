import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
@testable import PodcastAPI

final class MockIntegrationTests: XCTestCase, @unchecked Sendable {
    func mockClient() throws -> Client {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["LISTEN_API_SWIFT_INTEGRATION"] == "1",
                          "Public mock requests require explicit opt-in")
        let config = URLSessionConfiguration.ephemeral
        #if canImport(Darwin)
        config.connectionProxyDictionary = [:]
        #endif
        return Client(apiKey: "", configuration: config)
    }

    func testAllPublicMethodsAgainstFixedMock() async throws {
        let client = try mockClient()
        for op in try contract() {
            // Check the same request builder used by the method before opening a connection.
            let request = try client.makeRequest(path: op.path, method: op.method,
                pathNames: op.parameters.filter { $0.location == "path" }.map(\.name),
                queryNames: op.parameters.filter { $0.location == "query" }.map(\.name), parameters: op.example)
            guard request.url?.scheme == "https", request.url?.host == "listen-api-test.listennotes.com",
                  request.url?.port == nil, request.url?.path.hasPrefix("/api/v2/") == true,
                  request.value(forHTTPHeaderField: "X-ListenAPI-Key") == nil else {
                XCTFail("Integration requests must use the mock without credentials"); return
            }
            let response = try await callMethod(op.id, client: client, parameters: op.example)
            XCTAssertTrue((200..<300).contains(response.statusCode ?? 0), op.id)
            XCTAssertNotNil(response.toJson(), op.id)
            if op.id == "deletePlaylist" {
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertEqual(response.toJson()?["id"].string, op.example["id"])
                XCTAssertEqual(response.toJson()?["deleted"].bool, true)
                XCTAssertEqual(response.request?.httpMethod, "DELETE")
                XCTAssertEqual(response.request?.url?.path, "/api/v2/playlists/m1pe7z60bsw")
                XCTAssertNil(response.request?.url?.query)
                XCTAssertNil(response.request?.httpBody)
                XCTAssertNil(response.request?.value(forHTTPHeaderField: "Content-Type"))
            }
        }
    }

    func testEncodingAndEmptyValuesAgainstMock() async throws {
        let client = try mockClient()
        let results = [
            try await client.search(parameters: ["q": "café + science & tech"]),
            try await client.updatePlaylist(parameters: ["id": "m1pe7z60bsw", "description": ""]),
            try await client.addPlaylistItem(parameters: ["id": "m1pe7z60bsw", "podcast_id": "4d3fe717742d4963a85562e9f84d8c79", "notes": ""]),
            try await client.updatePlaylistItemNotes(parameters: ["id": "m1pe7z60bsw", "item_id": "23", "notes": ""])
        ]
        for response in results { XCTAssertNil(response.error); XCTAssertNotNil(response.toJson()) }
    }
}
