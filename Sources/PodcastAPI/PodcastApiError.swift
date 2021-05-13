//
//  File.swift
//  
//
//  Created by Wenbin Fang on 5/13/21.
//

import Foundation

public enum PodcastApiError: Error {
    case authenticationError
    case apiConnectionError
    case tooManyRequestsError
    case invalidRequestError
    case notFoundError
    case serverError
}
