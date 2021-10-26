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

// For command line executables, we have to use synchronous requests, otherwise
// the program would exit before requests return any response
let client = PodcastAPI.Client(apiKey: apiKey, synchronousRequest: true)

// By default, we do asynchronous requests.
//let client = PodcastAPI.Client(apiKey: apiKey)

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
        // It's a SwiftyJSON object
        if let json = response.toJson() {
            print(json)
        }

        // Some account stats
        print("Your free quota this month: \(response.getFreeQuota()) requests")
        print("Your usage this month: \(response.getUsage()) requests")
        print("Your next billing date: \(response.getNextBillingDate())")
    }
}

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

//parameters["id"] = "4d3fe717742d4963a85562e9f84d8c79"
//parameters["reason"] = "the podcaster wants to delete it"
//client.deletePodcast(parameters: parameters) { response in
//    if let error = response.error {
//        switch (error) {
//        case PodcastApiError.apiConnectionError:
//            print("Can't connect to Listen API server")
//        case PodcastApiError.authenticationError:
//            print("wrong api key")
//        case PodcastApiError.notFoundError:
//            print("not found")
//        case PodcastApiError.invalidRequestError:
//            print("invalid request")
//        default:
//            print("unknown error")
//        }
//    } else {
//        if let json = response.toJson() {
//            print(json)
//        }
//    }
//}

// parameters["q"] = "evergrand stok"
// client.spellcheck(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }

//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
// }


// parameters["q"] = "evergrande"
// client.fetchRelatedSearches(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }

//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
// }

// client.fetchTrendingSearches(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }

//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
// }

//parameters["q"] = "startup"
//parameters["show_podcasts"] = "1"
//client.typeahead(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}

//parameters["rss"] = "https://feeds.megaphone.fm/committed"
//client.submitPodcast(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}

//parameters["ids"] = "c577d55b2b2b483c969fae3ceb58e362,0f34a9099579490993eec9e8c8cebb82"
//client.batchFetchEpisodes(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}

//client.fetchMyPlaylists(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}

//parameters["id"] = "m1pe7z60bsw"
//parameters["type"] = "episode_list"
//client.fetchPlaylistById(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}

//parameters["id"] = "254444fa6cf64a43a95292a70eb6869b"
//parameters["safe_mode"] = "0"
//client.fetchRecommendationsForEpisode(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}

//parameters["id"] = "25212ac3c53240a880dd5032e547047b"
//parameters["safe_mode"] = "0"
//client.fetchRecommendationsForPodcast(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}


//client.justListen(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}

//client.fetchPodcastLanguages(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}

//client.fetchPodcastRegions(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}

//client.fetchPodcastGenres(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}

//parameters["id"] = "SDFKduyJ47r"
//client.fetchCuratedPodcastsListById(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}

//parameters["id"] = "6b6d65930c5a4f71b254465871fed370"
//parameters["show_transcript"] = "1"
//client.fetchEpisodeById(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}

//parameters["id"] = "4d3fe717742d4963a85562e9f84d8c79"
//parameters["sort"] = "oldest_first"
//client.fetchPodcastById(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}

//client.fetchCuratedPodcastsLists(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}

//parameters["genre_id"] = "93"
//parameters["page"] = "2"
//client.fetchBestPodcasts(parameters: parameters) { response in
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
//        // It's a SwiftyJSON object
//        if let json = response.toJson() {
//            print(json)
//        }
//
//        // Some account stats
//        print(response.getFreeQuota())
//        print(response.getUsage())
//        print(response.getNextBillingDate())
//    }
//}
