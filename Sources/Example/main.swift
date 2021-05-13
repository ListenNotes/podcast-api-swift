//
//  main.swift
//  
//  Sample code to use PodcastAPI
//
//  Created by Wenbin Fang on 5/12/21.
//

import Foundation
import PodcastAPI

let apiKey = ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""]

let client = PodcastAPI.Client(apiKey: apiKey)
var parameters: [String: String] = [:]
parameters["q"] = "startup"
client.search(parameters: parameters)
