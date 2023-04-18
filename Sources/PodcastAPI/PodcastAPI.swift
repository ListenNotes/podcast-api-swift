import Foundation

let BASE_URL_PROD = "https://listen-api.listennotes.com/api/v2"
let BASE_URL_TEST = "https://listen-api-test.listennotes.com/api/v2"
let DEFAULT_USER_AGENT = "podcast-api-swift"

public class Client {
    private var apiKey: String
    private var baseUrl: String = BASE_URL_PROD
    private var userAgent: String = DEFAULT_USER_AGENT
    private var responseTimeoutSec: Int = 30
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
        self.userAgent = userAgent
    }
    
    public func setResponseTimeoutSec(timeoutSec: Int) {
        self.responseTimeoutSec = timeoutSec
    }
    
    public func search(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "search", method: "GET", parameters: parameters, completion: completion)

    }
    
    public func typeahead(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "typeahead", method: "GET", parameters: parameters, completion: completion)
    }

    public func spellcheck(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "spellcheck", method: "GET", parameters: parameters, completion: completion)
    }    
    
    public func fetchRelatedSearches(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "related_searches", method: "GET", parameters: parameters, completion: completion)
    }  

    public func fetchTrendingSearches(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "trending_searches", method: "GET", parameters: parameters, completion: completion)
    }  

    public func submitPodcast(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "podcasts/submit", method: "POST", parameters: parameters, completion: completion)
    }
    
    public func batchFetchPodcasts(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "podcasts", method: "POST", parameters: parameters, completion: completion)
    }
    
    public func batchFetchEpisodes(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "episodes", method: "POST", parameters: parameters, completion: completion)
    }
    
    public func fetchMyPlaylists(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "playlists", method: "GET", parameters: parameters, completion: completion)
    }
    
    public func fetchPlaylistById(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        if let id = parameters["id"] {
            self.sendHttpRequest(path: "playlists/\(id)", method: "GET",
                                 parameters: parameters.filter { key, value in
                                    return key != "id"
                                 }, completion: completion)
        } else {
            completion(ApiResponse(request: nil, data: nil, response: nil, httpError: nil, apiError: PodcastApiError.invalidRequestError))
        }
    }
    
    public func fetchRecommendationsForEpisode(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        if let id = parameters["id"] {
            self.sendHttpRequest(path: "episodes/\(id)/recommendations", method: "GET",
                                 parameters: parameters.filter { key, value in
                                    return key != "id"
                                 }, completion: completion)
        } else {
            completion(ApiResponse(request: nil, data: nil, response: nil, httpError: nil, apiError: PodcastApiError.invalidRequestError))
        }
    }
    
    public func fetchRecommendationsForPodcast(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        if let id = parameters["id"] {
            self.sendHttpRequest(path: "podcasts/\(id)/recommendations", method: "GET",
                                 parameters: parameters.filter { key, value in
                                    return key != "id"
                                 }, completion: completion)
        } else {
            completion(ApiResponse(request: nil, data: nil, response: nil, httpError: nil, apiError: PodcastApiError.invalidRequestError))
        }
    }
    
    public func justListen(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "just_listen", method: "GET", parameters: parameters, completion: completion)
    }
    
    public func fetchPodcastLanguages(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "languages", method: "GET", parameters: parameters, completion: completion)
    }
    
    public func fetchPodcastRegions(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "regions", method: "GET", parameters: parameters, completion: completion)
    }
    
    public func fetchPodcastGenres(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "genres", method: "GET", parameters: parameters, completion: completion)
    }
    
    public func fetchCuratedPodcastsListById(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        if let id = parameters["id"] {
            self.sendHttpRequest(path: "curated_podcasts/\(id)", method: "GET",
                                 parameters: parameters.filter { key, value in
                                    return key != "id"
                                 }, completion: completion)
        } else {
            completion(ApiResponse(request: nil, data: nil, response: nil, httpError: nil, apiError: PodcastApiError.invalidRequestError))
        }
    }
    
    public func fetchEpisodeById(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        if let id = parameters["id"] {
            self.sendHttpRequest(path: "episodes/\(id)", method: "GET",
                                 parameters: parameters.filter { key, value in
                                    return key != "id"
                                 }, completion: completion)
        } else {
            completion(ApiResponse(request: nil, data: nil, response: nil, httpError: nil, apiError: PodcastApiError.invalidRequestError))
        }
    }
    
    public func fetchPodcastById(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        if let id = parameters["id"] {
            self.sendHttpRequest(path: "podcasts/\(id)", method: "GET",
                                 parameters: parameters.filter { key, value in
                                    return key != "id"
                                 }, completion: completion)
        } else {
            completion(ApiResponse(request: nil, data: nil, response: nil, httpError: nil, apiError: PodcastApiError.invalidRequestError))
        }
    }
    
    public func fetchCuratedPodcastsLists(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "curated_podcasts", method: "GET", parameters: parameters, completion: completion)
    }
    
    public func fetchBestPodcasts(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        self.sendHttpRequest(path: "best_podcasts", method: "GET", parameters: parameters, completion: completion)
    }
    
    public func deletePodcast(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        if let id = parameters["id"] {
            self.sendHttpRequest(path: "podcasts/\(id)", method: "DELETE",
                                 parameters: parameters.filter { key, value in
                                    return key != "id"
                                 }, completion: completion)
        } else {
            completion(ApiResponse(request: nil, data: nil, response: nil, httpError: nil, apiError: PodcastApiError.invalidRequestError))
        }
    }

    public func fetchAudienceForPodcast(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        if let id = parameters["id"] {
            self.sendHttpRequest(path: "podcasts/\(id)/audience", method: "GET",
                                 parameters: parameters.filter { key, value in
                                    return key != "id"
                                 }, completion: completion)
        } else {
            completion(ApiResponse(request: nil, data: nil, response: nil, httpError: nil, apiError: PodcastApiError.invalidRequestError))
        }
    }

    public func fetchPodcastsByDomain(parameters: [String: String], completion: @escaping (ApiResponse) -> ()) {
        if let domain_name = parameters["domain_name"] {
            self.sendHttpRequest(path: "podcasts/domains/\(domain_name)", method: "GET",
                                 parameters: parameters.filter { key, value in
                                    return key != "domain_name"
                                 }, completion: completion)
        } else {
            completion(ApiResponse(request: nil, data: nil, response: nil, httpError: nil, apiError: PodcastApiError.invalidRequestError))
        }
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
        request.setValue(self.userAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = TimeInterval(self.responseTimeoutSec)
        
        let sema: DispatchSemaphore? = self.synchronousRequest ? DispatchSemaphore(value: 0) : nil;
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let error = error {
                completion?(ApiResponse(request: request, data: data, response: response, httpError: error, apiError: PodcastApiError.apiConnectionError))
                if let sema = sema {
                    sema.signal()
                }
                return
            }
            completion?(ApiResponse(request: request, data: data, response: response, httpError: error, apiError: nil))
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
