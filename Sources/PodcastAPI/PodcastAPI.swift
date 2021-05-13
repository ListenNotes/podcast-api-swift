import Foundation
import Alamofire

let BASE_URL_PROD = "https://listen-api.listennotes.com/api/v2"
let BASE_URL_TEST = "https://listen-api-test.listennotes.com/api/v2"

//extension Request {
//   public func debugLog() -> Self {
//      #if DEBUG
//         debugPrint(self)
//      #endif
//      return self
//   }
//}

public class Client {
    private var apiKey: String
    private var baseUrl: String = BASE_URL_PROD
    private var userAgent: String = "podcast-api-swift"
    private var responseTimeout: Int = 30000
    
    public init(apiKey: String) {
        self.apiKey = apiKey
        
        if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.baseUrl = BASE_URL_TEST
        }
    }
    
    public func setUserAgent(userAgent: String) {
        self.userAgent = userAgent;
    }
    
    public func search(parameters: [String: String]) {
        let url = "\(self.baseUrl)/search"
        let result = self.query(address: url)
        print(result)
    }
    
    func query(address: String) -> String {
        let url = URL(string: address)
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: String = ""
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            result = String(data: data!, encoding: String.Encoding.utf8)!
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        return result
    }
}
