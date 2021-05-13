    import XCTest
    @testable import PodcastAPI

    final class PodcastAPITests: XCTestCase {
        func testExample() {
            let client = PodcastAPI.Client(apiKey: "")
            var parameters: [String: String] = [:]
            parameters["q"] = "startup"
            client.search(parameters: parameters)
        }
    }
