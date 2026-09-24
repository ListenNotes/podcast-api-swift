import UIKit
import PodcastAPI

class ViewController: UIViewController {
    @IBOutlet weak var displayLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // An empty key uses the public mock. Obtain production credentials through
        // your own service rather than embedding a secret in the app's source.
        let client = PodcastAPI.Client(apiKey: "")
        Task { @MainActor [weak self] in
            do {
                let response = try await client.search(parameters: ["q": "startup", "sort_by_date": "1"])
                self?.displayLabel.text = "Total search results: \(response.toJson()?["total"].intValue ?? 0)"
            } catch {
                self?.displayLabel.text = error.localizedDescription
            }
        }
    }
}
