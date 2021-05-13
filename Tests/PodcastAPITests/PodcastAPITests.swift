    import XCTest
    @testable import PodcastAPI

    final class PodcastAPITests: XCTestCase {
        func testSetApiKey() {
            let client = PodcastAPI.Client(apiKey: "", synchronousRequest: true)
            var parameters: [String: String] = [:]
            parameters["q"] = "startup"
            client.search(parameters: parameters) { response in
//                print(response.response.url)
            }
        }
    }
