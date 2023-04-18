import Foundation
// import SwiftyJSON

public class ApiResponse {
    var data: Data?
    var response: HTTPURLResponse?
    var request: URLRequest?
    var httpError: Error?
    public var error: PodcastApiError?
    
    public init(request: URLRequest?, data: Data?, response: URLResponse?, httpError: Error?, apiError: PodcastApiError? ) {
        self.data = data
        self.response = response as? HTTPURLResponse
        self.httpError = httpError
        self.error = apiError
        self.request = request
        
        self.checkAndSetApiError()
    }
    
    public func toJson() -> JSON? {
        if let data = data {
            do {
                let json = try JSON(data: data)
                return json
            } catch {
                return nil
            }
        }
        return nil
    }
    
    public func getFreeQuota() -> Int {
        if let response = response {
            if let quota = response.allHeaderFields["x-listenapi-freequota"] as? String {
                return Int(quota) ?? -1
            }
        }
        return -1
    }
    
    public func getUsage() -> Int {
        if let response = response {
            if let usage = response.allHeaderFields["x-listenapi-usage"] as? String {
                return Int(usage) ?? -1
            }
        }
        return -1
    }
    
    public func getNextBillingDate() -> String {
        if let response = response {
            if let dateString = response.allHeaderFields["x-listenapi-nextbillingdate"] as? String {
                return dateString
            }
        }
        return ""
    }
    
    private func checkAndSetApiError() {
        if let httpResponse = self.response {
            switch httpResponse.statusCode {
            case 200..<300:
                self.error = nil
            case 400:
                self.error = PodcastApiError.invalidRequestError
            case 401:
                self.error = PodcastApiError.authenticationError
            case 404:
                self.error = PodcastApiError.notFoundError
            case 429:
                self.error = PodcastApiError.tooManyRequestsError
            case 400..<500:
                self.error = PodcastApiError.invalidRequestError
            case 500..<600:
                self.error = PodcastApiError.serverError
            default:
                self.error = nil
            }
        }
    }
}
