//
//  ViewController.swift
//  ExampleIOSApp
//
//  Created by Wenbin Fang on 5/14/21.
//

import UIKit
import PodcastAPI

class ViewController: UIViewController {
    @IBOutlet weak var displayLabel: UILabel!
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        // You may want to fetch apiKey from your own server here
        // Don't hard code an api key in the source code, because you can't
        // change the apiKey later once the app is at the hands of your users.
        let apiKey = ""
        let client = PodcastAPI.Client(apiKey: apiKey)

        // All parameters are passed via this Dictionary[String: String]
        // For all parameters, please refer to https://www.listennotes.com/api/docs/
        var parameters: [String: String] = [:]

        parameters["q"] = "startup"
        parameters["sort_by_date"] = "1"
        client.search(parameters: parameters) { response in
            if let error = response.error {
                switch (error) {
                case PodcastApiError.apiConnectionError:
                    print("Can't connect to Listen API server")
                case PodcastApiError.authenticationError:
                    print("wrong api key")
                default:
                    print("unknown error")
                }
            } else {
                var text = ""
                // It's a SwiftyJSON object
                if let json = response.toJson() {
                    text += "Total search results: \(json["total"])"
                }
                
                // Update UI in the main thread
                DispatchQueue.main.async {
                    self.displayLabel.text = text
                }
            }
        }
    }


}

