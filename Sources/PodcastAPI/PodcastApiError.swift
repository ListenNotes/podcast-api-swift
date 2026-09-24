import Foundation

public enum PodcastApiError: String, Error, Sendable {
    case authenticationError
    case apiConnectionError
    case tooManyRequestsError
    case invalidRequestError
    case permissionDeniedError
    case notFoundError
    case serverError
    case unexpectedResponseError
}

/// Async request failure retaining the HTTP status, headers, body, and underlying connection error.
public struct ApiRequestError: Error, LocalizedError, Sendable {
    public let response: ApiResponse
    public init(response: ApiResponse) { self.response = response }
    public var errorDescription: String? {
        if let body = response.toJson() {
            if let message = body["error"].string { return message }
            if let message = body["message"].string { return message }
        }
        return response.httpError?.localizedDescription ?? response.error?.rawValue ?? "Request failed"
    }
}
