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
let client = PodcastAPI.Client(apiKey: apiKey, synchronousRequest: true)
//let client = PodcastAPI.Client(apiKey: apiKey)

var parameters: [String: String] = [:]
//parameters["q"] = "startup"
//parameters["sort_by_date"] = "1"
//client.search(parameters: parameters) { response in
//    if let error = response.error {
//        switch (error) {
//        case PodcastApiError.apiConnectionError:
//            print("Can't connect to Listen API server")
//        case PodcastApiError.authenticationError:
//            print("wrong api key")
//        default:
//            print("unknown error")
//        }
//    } else {
//        if let json = response.toJson() {
//            print(json)
//        }
//    }
//}

//parameters["ids"] = "3302bc71139541baa46ecb27dbf6071a,68faf62be97149c280ebcc25178aa731,37589a3e121e40debe4cef3d9638932a,9cf19c590ff0484d97b18b329fed0c6a"
//parameters["rsses"] = "https://rss.art19.com/recode-decode,https://rss.art19.com/the-daily,https://www.npr.org/rss/podcast.php?id=510331,https://www.npr.org/rss/podcast.php?id=510331"
//client.batchFetchPodcasts(parameters: parameters) { response in
//    if let error = response.error {
//        switch (error) {
//        case PodcastApiError.apiConnectionError:
//            print("Can't connect to Listen API server")
//        case PodcastApiError.authenticationError:
//            print("wrong api key")
//        default:
//            print("unknown error")
//        }
//    } else {
//        if let json = response.toJson() {
//            print(json["podcasts"].count)
//        }
//    }
//}

parameters["id"] = "4d3fe717742d4963a85562e9f84d8c79"
parameters["reason"] = "the podcaster wants to delete it"
client.deletePodcast(parameters: parameters) { response in
    if let error = response.error {
        switch (error) {
        case PodcastApiError.apiConnectionError:
            print("Can't connect to Listen API server")
        case PodcastApiError.authenticationError:
            print("wrong api key")
        case PodcastApiError.notFoundError:
            print("not found")
        default:
            print("unknown error")
        }
    } else {
        if let json = response.toJson() {
            print(json)
        }
    }
}

