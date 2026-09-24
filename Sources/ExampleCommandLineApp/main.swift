import Foundation
import PodcastAPI

@main
struct ExampleCommandLineApp {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.typeahead(parameters: ["q": "startup", "show_podcasts": "1"])
        print(response.toJson()?.description ?? "")
        print("Usage: \(response.getUsage())")
    }
}
