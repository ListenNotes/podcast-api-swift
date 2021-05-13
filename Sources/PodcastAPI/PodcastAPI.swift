import Foundation

let BASE_URL_PROD = "https://listen-api.listennotes.com/api/v2"
let BASE_URL_TEST = "https://listen-api-test.listennotes.com/api/v2"


public class Client {
    private var apiKey: String
    private var baseUrl: String = BASE_URL_PROD
    private var userAgent: String = "podcast-api-swift"
    private var responseTimeout: Int = 30000
    private var synchronousRequest: Bool = false
    
    public convenience init(apiKey: String) {
        self.init(apiKey: apiKey, synchronousRequest: false)
    }
    
    public init(apiKey: String, synchronousRequest: Bool) {
        self.apiKey = apiKey
        
        if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.baseUrl = BASE_URL_TEST
        }
        
        self.synchronousRequest = synchronousRequest
    }
    
    public func setUserAgent(userAgent: String) {
        self.userAgent = userAgent;
    }
    
    public func search(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "search", method: "GET", parameters: parameters, completion: completion)

    }
    
    public func batchFetchPodcasts(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "podcasts", method: "POST", parameters: parameters, completion: completion)
    }
    
    public func deletePodcast(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "deletePodcast", method: "DELETE", parameters: parameters, completion: completion)
    }
    
    func sendHttpRequest(path: String, method: String, parameters: [String: String], completion: ((ApiResponse) -> ())?) {
        let urlString = "\(self.baseUrl)/\(path)"

        var request: URLRequest
        
        if method == "POST" {
            request = URLRequest(url: URL(string: urlString)!)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            var data = [String]()
            for(key, value) in parameters {
                data.append(key + "=\(value)")
            }
            let postData = data.map { String($0) }.joined(separator: "&")
            request.httpBody = postData.data(using: .utf8)
        }  else {
            var components = URLComponents(string: urlString)!
            components.queryItems = parameters.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            request = URLRequest(url: components.url!)
        }
        request.httpMethod = method
        request.setValue(self.apiKey, forHTTPHeaderField: "X-ListenAPI-Key")
        
        let sema: DispatchSemaphore? = self.synchronousRequest ? DispatchSemaphore(value: 0) : nil;
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let error = error {
                completion?(ApiResponse(data: data, response: response, httpError: error, apiError: PodcastApiError.apiConnectionError))
                if let sema = sema {
                    sema.signal()
                }
                return
            }
            completion?(ApiResponse(data: data, response: response, httpError: error, apiError: nil))
            if let sema = sema {
                sema.signal()
            }
        }
        
        task.resume()
        if let sema = sema {
            sema.wait()
        }
    }
}
