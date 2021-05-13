import Foundation
import SwiftyJSON

public class ApiResponse {
    var data: Data?
    var response: URLResponse?
    var httpError: Error?
    public var error: PodcastApiError?
    
    public init(data: Data?, response: URLResponse?, httpError: Error?, apiError: PodcastApiError? ) {
        self.data = data
        self.response = response
        self.httpError = httpError
        self.error = apiError
        
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
    
    private func checkAndSetApiError() {
        if let httpResponse = self.response as? HTTPURLResponse {
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
            case 500..<600:
                self.error = PodcastApiError.serverError
            default:
                self.error = nil
            }
        }
    }
}
