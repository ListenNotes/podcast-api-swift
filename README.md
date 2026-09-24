# Podcast API Swift Library

[![Swift](https://github.com/ListenNotes/podcast-api-swift/actions/workflows/swift.yml/badge.svg)](https://github.com/ListenNotes/podcast-api-swift/actions/workflows/swift.yml) [![Cocoapods Version](https://img.shields.io/cocoapods/v/PodcastAPI)](https://cocoapods.org/pods/PodcastAPI) [![Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FListenNotes%2Fpodcast-api-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ListenNotes/podcast-api-swift)

The Podcast API Swift library provides convenient access to the [Listen Notes Podcast API](https://www.listennotes.com/api/) from
applications written in the Swift language.

Simple and no-nonsense podcast search & directory API. Search the meta data of all podcasts and episodes by people, places, or topics. It's the same API that powers [the best podcast search engine Listen Notes](https://www.listennotes.com/).

If you have any questions, please contact [hello@listennotes.com](hello@listennotes.com?subject=Questions+about+the+Swift+SDK+of+Listen+API)

<a href="https://www.listennotes.com/api/"><img src="https://raw.githubusercontent.com/ListenNotes/ListenApiDemo/master/web/src/powered_by_listennotes.png" width="300" /></a>

## Installation

PodcastAPI 3.0.0 requires Swift 6.0+, iOS 16+ or macOS 13+. Swift Package Manager
also supports Linux. Both distribution methods expose the same `PodcastAPI` module.
There are no external runtime package dependencies. The bundled SwiftyJSON source
is based on upstream 5.0.2 with a Linux number-comparison compatibility fix and
retains its MIT license; existing `toJson()` users keep the same interface.

### Swift Package Manager

Find releases and compatibility information on
[Swift Package Index](https://swiftpackageindex.com/ListenNotes/podcast-api-swift).

In Xcode, choose **File > Add Package Dependency**, enter
`https://github.com/ListenNotes/podcast-api-swift.git`, and select **Up to Next Major
Version** starting at **3.0.0**. Add the **PodcastAPI** library product to your app target.

For a `Package.swift` manifest, add this to the package's `dependencies`:

```swift
.package(url: "https://github.com/ListenNotes/podcast-api-swift.git", from: "3.0.0")
```

Add `.product(name: "PodcastAPI", package: "podcast-api-swift")` to your target's
`dependencies`, then use `import PodcastAPI` in your Swift files.

### CocoaPods

```ruby
pod 'PodcastAPI', '~> 3.0'
```

## Usage

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.search(parameters: ["q": "startup"])
        print(response.toJson()?.description ?? "")
        print(response.getUsage())
    }
}
```

An empty API key selects the stateless public mock service. A nonempty key selects
production. Calls with a key use your quota; write methods modify your playlists.

All existing method names and `[String: String]` parameters remain available.
Callbacks still receive `ApiResponse` and inspect `response.error`:

```swift
let task = client.search(parameters: ["q": "startup"]) { response in
    if let error = response.error { print(error) }
    else { print(response.toJson()?.description ?? "") }
}
// task?.cancel() cancels this request.
```

Callbacks are `@Sendable` and run on the URLSession callback queue. Use
`Task { @MainActor in ... }` for UI updates. For existing command-line code,
`Client(apiKey: ..., synchronousRequest: true)` still waits for callback completion;
new command-line programs should use an async `@main` entry point. Never block
an application's main thread with synchronous requests.

### Responses and errors

Async methods throw `ApiRequestError` for HTTP or connection failures; its
`response` retains status, headers, raw data, and the underlying error. Task
cancellation propagates as `CancellationError`. Missing or invalid path identifiers
throw `PodcastApiError.invalidRequestError` before any request. Callback methods
report these failures in `response.error`.

Responses support `toJson()`, `decode(MyDecodableType.self)`, `statusCode`,
`header("X-ListenAPI-Usage")`, `getFreeQuota()`, `getUsage()`,
`getNextBillingDate()`, and `getLatencySeconds()`. Header lookup ignores case.
All 2xx statuses succeed; 403 reports `permissionDeniedError`.

The client encodes path, query, and form values separately. Empty strings clear
notes/descriptions. Default request/resource timeouts are 30 seconds; the SDK
rejects redirects and performs no application-level retries. A custom
`URLSessionConfiguration` supports testing and connection configuration.
`setResponseTimeoutSec` changes the per-request inactivity timeout; provide a
configuration with a larger `timeoutIntervalForResource` for longer total requests.
`baseURL:` overrides send the client's key to that chosen server.

### Migrating from 1.x

The minimum compiler is Swift 6.0. Responses are immutable and safe to share
across tasks; callback captures must satisfy Swift's Sendable checks. Update
exhaustive error switches for `permissionDeniedError` and
`unexpectedResponseError`. Existing callback methods, JSON access, and quota
helpers remain available. No API endpoint behavior changes are required.

## Development

```sh
swift package dump-package
swift build
swift test
# Explicit opt-in: public mock only, without an API key.
LISTEN_API_SWIFT_INTEGRATION=1 swift test --filter MockIntegrationTests
# On a Mac with CocoaPods installed:
pod lib lint PodcastAPI.podspec --platforms=ios,osx --skip-tests
```

Default tests intercept every network request with a local URLProtocol fixture;
they never call production or the public mock. Integration tests call only the
fixed public mock host and are skipped unless explicitly enabled. The mock does
not persist writes. The command-line sample runs with `swift run ExampleCommandLineApp`;
its default request goes to the mock.

Endpoint methods, the contract, test dispatcher, and the following marked README
sections are generated from the Listen Notes monorepo's canonical OpenAPI spec
and Swift registry with `sync.py swift`. Do not edit generated sections by hand.
The SDK builds and tests independently of that repository.

## Method index

<!-- BEGIN GENERATED METHOD INDEX -->

- [`search`](#search) — `GET /search`
- [`typeahead`](#typeahead) — `GET /typeahead`
- [`searchEpisodeTitles`](#searchepisodetitles) — `GET /search_episode_titles`
- [`spellcheck`](#spellcheck) — `GET /spellcheck`
- [`fetchRelatedSearches`](#fetchrelatedsearches) — `GET /related_searches`
- [`fetchTrendingSearches`](#fetchtrendingsearches) — `GET /trending_searches`
- [`fetchBestPodcasts`](#fetchbestpodcasts) — `GET /best_podcasts`
- [`fetchPodcastById`](#fetchpodcastbyid) — `GET /podcasts/{id}`
- [`deletePodcast`](#deletepodcast) — `DELETE /podcasts/{id}`
- [`fetchEpisodeById`](#fetchepisodebyid) — `GET /episodes/{id}`
- [`batchFetchEpisodes`](#batchfetchepisodes) — `POST /episodes`
- [`batchFetchPodcasts`](#batchfetchpodcasts) — `POST /podcasts`
- [`fetchCuratedPodcastsListById`](#fetchcuratedpodcastslistbyid) — `GET /curated_podcasts/{id}`
- [`fetchPodcastGenres`](#fetchpodcastgenres) — `GET /genres`
- [`fetchPodcastRegions`](#fetchpodcastregions) — `GET /regions`
- [`fetchPodcastLanguages`](#fetchpodcastlanguages) — `GET /languages`
- [`justListen`](#justlisten) — `GET /just_listen`
- [`fetchCuratedPodcastsLists`](#fetchcuratedpodcastslists) — `GET /curated_podcasts`
- [`fetchRecommendationsForPodcast`](#fetchrecommendationsforpodcast) — `GET /podcasts/{id}/recommendations`
- [`fetchRecommendationsForEpisode`](#fetchrecommendationsforepisode) — `GET /episodes/{id}/recommendations`
- [`submitPodcast`](#submitpodcast) — `POST /podcasts/submit`
- [`fetchPlaylistById`](#fetchplaylistbyid) — `GET /playlists/{id}`
- [`fetchMyPlaylists`](#fetchmyplaylists) — `GET /playlists`
- [`fetchAudienceForPodcast`](#fetchaudienceforpodcast) — `GET /podcasts/{id}/audience`
- [`fetchPodcastsByDomain`](#fetchpodcastsbydomain) — `GET /podcasts/domains/{domain_name}`
- [`createPlaylist`](#createplaylist) — `POST /playlists`
- [`updatePlaylist`](#updateplaylist) — `PUT /playlists/{id}`
- [`addPlaylistItem`](#addplaylistitem) — `POST /playlists/{id}/items`
- [`deletePlaylistItem`](#deleteplaylistitem) — `DELETE /playlists/{id}/items/{item_id}`
- [`updatePlaylistItemNotes`](#updateplaylistitemnotes) — `PUT /playlists/{id}/items/{item_id}`

<!-- END GENERATED METHOD INDEX -->

## API reference

<!-- BEGIN GENERATED API REFERENCE -->

All methods accept `[String: String]` parameters, including path identifiers. Async methods return `ApiResponse` and throw `ApiRequestError` for HTTP/connection failures. Callback overloads retain `completion:` and `response.error`. Set `LISTEN_API_KEY` for real requests; the examples otherwise use the stateless mock server.

### search

Full-text search

`GET /search`

Full-text search on episodes, podcasts, or curated lists of podcasts.
Use the `offset` parameter to paginate through search results.
The FREE plan allows to see up to 30 search results (or `offset` < 30) per query.
The PRO plan allows to see up to 300 search results (or `offset` < 300) per query.
The ENTERPRISE plan allows to see up to 10,000 search results (or `offset` < 10000) per query.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.search(parameters: ["q": "star wars", "sort_by_date": "0", "type": "episode", "offset": "0", "len_min": "10", "len_max": "30", "genre_ids": "68,82", "published_before": "1580172454000", "published_after": "0", "only_in": "title,description", "language": "English", "region": "", "safe_mode": "0", "unique_podcasts": "0", "interviews_only": "0", "sponsored_only": "0", "page_size": "10"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-search)

### typeahead

Typeahead search

`GET /typeahead`

Suggest search terms, podcast genres, and podcasts.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.typeahead(parameters: ["q": "star wars", "show_podcasts": "1", "show_genres": "1", "safe_mode": "0"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-typeahead)

### searchEpisodeTitles

Find individual episodes by searching for their titles

`GET /search_episode_titles`

Conduct targeted searches for individual episodes by title and refine results using the podcast id such as
Listen Notes Podcast ID, Apple Podcasts ID, Spotify ID, or RSS feed URL.
This endpoint is specially designed to streamline the import of specific episodes from platforms
like Apple Podcasts and Spotify into your application.
Compared to the GET /search endpoint, which performs full-text searches across multiple fields,
this endpoint focuses solely on episode titles for enhanced accuracy and performance.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.searchEpisodeTitles(parameters: ["q": "Jerusalem Demsas on The Dispossessed"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-search_episode_titles)

### spellcheck

Spell check on a search term

`GET /spellcheck`

Suggest a list of words that correct the spelling errors of a search term. This endpoint is available only in the PRO/ENTERPRISE plan.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.spellcheck(parameters: ["q": "microsft stock"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-spellcheck)

### fetchRelatedSearches

Fetch related search terms

`GET /related_searches`

Suggest related search terms. The results are more comprehensive than from `GET /typeahead`. This endpoint is available only in the PRO/ENTERPRISE plan.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchRelatedSearches(parameters: ["q": "evergrande"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-related_searches)

### fetchTrendingSearches

Fetch trending search terms

`GET /trending_searches`

Fetch up to 10 most recent trending search terms on the Listen Notes platform.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchTrendingSearches(parameters: [:])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-trending_searches)

### fetchBestPodcasts

Fetch a list of best podcasts by genre

`GET /best_podcasts`

Get a list of curated best podcasts by genre,
which are curated by Listen Notes staffs based on various signals from the Internet, e.g.,
top charts on other podcast platforms, recommendations from mainstream media,
user activities on listennotes.com...
You can get the genre ids from `GET /genres` endpoint.
This endpoint returns same data as https://www.listennotes.com/best-podcasts/

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchBestPodcasts(parameters: ["genre_id": "93", "page": "2", "region": "us", "sort": "listen_score", "safe_mode": "0"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-best_podcasts)

### fetchPodcastById

Fetch detailed meta data and episodes for a podcast by id

`GET /podcasts/{id}`

Fetch detailed meta data and episodes for a specific podcast (up to 10 episodes each time).
You can use the **next_episode_pub_date** parameter to do pagination and fetch more episodes.
During pagination with **next_episode_pub_date**, an empty **episodes** array in the response signals that no more episodes are available.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchPodcastById(parameters: ["id": "4d3fe717742d4963a85562e9f84d8c79", "next_episode_pub_date": "1479154463000", "sort": "recent_first"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-podcasts-id)

### deletePodcast

Request to delete a podcast

`DELETE /podcasts/{id}`

Podcast hosting services can use this endpoint to streamline the process of podcast deletion on behave of their users (podcasters). We will review the deletion request within 12 hours. If the podcast is already deleted, the "status" field in the response will be "deleted". Otherwise, the status field will be "in review". If you want to get a notification once the podcast is deleted, you can configure a webhook url in the dashboard: listennotes.com/api/dashboard/#webhooks

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.deletePodcast(parameters: ["id": "4d3fe717742d4963a85562e9f84d8c79", "reason": "the podcaster wants to delete it"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#delete-api-v2-podcasts-id)

### fetchEpisodeById

Fetch detailed meta data for an episode by id

`GET /episodes/{id}`

Fetch detailed meta data for a specific episode.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchEpisodeById(parameters: ["id": "6b6d65930c5a4f71b254465871fed370", "show_transcript": "1"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-episodes-id)

### batchFetchEpisodes

Batch fetch basic meta data for episodes

`POST /episodes`

Batch fetch basic meta data for up to 10 episodes. This endpoint could be used to implement custom playlists for individual episodes. For detailed meta data of an individual episode, you need to use `GET /episodes/{id}`. This endpoint is available only in the PRO/ENTERPRISE plan.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.batchFetchEpisodes(parameters: ["ids": "c577d55b2b2b483c969fae3ceb58e362,0f34a9099579490993eec9e8c8cebb82"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#post-api-v2-episodes)

### batchFetchPodcasts

Batch fetch basic meta data for podcasts

`POST /podcasts`

Batch fetch basic meta data for up to 10 podcasts.
This endpoint could be used to build something like OPML import,
allowing users to import a bunch of podcasts via rss urls.
For detailed meta data (including episodes) of an individual podcast, you need to use `GET /podcasts/{id}`. This endpoint is available only in the PRO/ENTERPRISE plan.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.batchFetchPodcasts(parameters: ["ids": "3302bc71139541baa46ecb27dbf6071a,68faf62be97149c280ebcc25178aa731,37589a3e121e40debe4cef3d9638932a,9cf19c590ff0484d97b18b329fed0c6a", "rsses": "https://rss.art19.com/recode-decode,https://rss.art19.com/the-daily,https://www.npr.org/rss/podcast.php?id=510331,https://www.npr.org/rss/podcast.php?id=510331", "itunes_ids": "1457514703,1386234384,659155419", "spotify_ids": "3DDfEsKDIDrTlnPOiG4ZF4,4qDNe5Gvl1XxdLinUGEXrC,23NZCM4ik6o3UYkM473Itz", "show_latest_episodes": "1", "next_episode_pub_date": "1557394247000"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#post-api-v2-podcasts)

### fetchCuratedPodcastsListById

Fetch a curated list of podcasts by id

`GET /curated_podcasts/{id}`

Get detailed meta data of all podcasts in a specific curated list.
This endpoint returns same data as https://www.listennotes.com/curated-podcasts/

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchCuratedPodcastsListById(parameters: ["id": "SDFKduyJ47r"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-curated_podcasts-id)

### fetchPodcastGenres

Fetch a list of podcast genres

`GET /genres`

Get a list of podcast genres that are supported in Listen Notes.
The genre id can be passed to other endpoints as a parameter to get podcasts in a specific genre,
e.g., `GET /best_podcasts`, `GET /search`...
You may want to cache the list of genres on the client side.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchPodcastGenres(parameters: ["top_level_only": "1"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-genres)

### fetchPodcastRegions

Fetch a list of supported countries/regions for best podcasts

`GET /regions`

It returns a dictionary of country codes (e.g., us, gb...) & country names (United States, United Kingdom...). The country code is used in the query parameter **region** of `GET /best_podcasts`.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchPodcastRegions(parameters: [:])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-regions)

### fetchPodcastLanguages

Fetch a list of supported languages for podcasts

`GET /languages`

Get a list of languages that are supported in Listen Notes database. You can use the language string as query parameter in `GET /search`.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchPodcastLanguages(parameters: [:])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-languages)

### justListen

Fetch a random podcast episode

`GET /just_listen`

Recently published episodes are more likely to be fetched. Good luck!

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.justListen(parameters: [:])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-just_listen)

### fetchCuratedPodcastsLists

Fetch curated lists of podcasts

`GET /curated_podcasts`

A bunch of curated lists from online media. For each list, you'll get basic info of up to 5 podcasts. To get detailed meta data of all podcasts in a specific list, you need to use `GET /curated_podcasts/{id}`. We add new curated lists to the database on a daily basis.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchCuratedPodcastsLists(parameters: ["page": "2"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-curated_podcasts)

### fetchRecommendationsForPodcast

Fetch recommendations for a podcast

`GET /podcasts/{id}/recommendations`

Fetch up to 8 podcast recommendations based on the given podcast id.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchRecommendationsForPodcast(parameters: ["id": "25212ac3c53240a880dd5032e547047b", "safe_mode": "0"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-podcasts-id-recommendations)

### fetchRecommendationsForEpisode

Fetch recommendations for an episode

`GET /episodes/{id}/recommendations`

Fetch up to 8 episode recommendations based on the given episode id.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchRecommendationsForEpisode(parameters: ["id": "254444fa6cf64a43a95292a70eb6869b", "safe_mode": "0"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-episodes-id-recommendations)

### submitPodcast

Submit a podcast to Listen Notes database

`POST /podcasts/submit`

Podcast hosting services can use this endpoint to help your users directly submit a new podcast to Listen Notes database. If the podcast doesn't exist in the database, "status" in the response will be "in review", and we'll review it within 12 hours. If the podcast exists, "status" in the response will be "found". If this submission is rejected, "status" in the response will be "rejected". You can use `POST /podcasts` to check if multiple podcasts exist in the database. If you want to get a notification once the podcast is accepted, you can either specify the "email" parameter or configure a webhook url in the dashboard: listennotes.com/api/dashboard/#webhooks

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.submitPodcast(parameters: ["rss": "https://feeds.megaphone.fm/committed", "email": "hello@example.com"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#post-api-v2-podcasts-submit)

### fetchPlaylistById

Fetch a playlist's info and items (i.e., episodes or podcasts).

`GET /playlists/{id}`

A playlist can contain both episodes and podcasts, shown in separate views,
just like playlists created via listennotes.com/listen/.
This endpoint fetches items from the saved default view unless **type** is specified.
The response type and listennotes_url describe the selected view.
You can use the **last_pub_date_ms** parameter to do pagination and fetch more items.
A playlist can be **public** (discoverable on ListenNotes.com),
**unlisted** (accessible to anyone who knows the playlist id),
or **private** (accessible when the API admin has active playlist membership).
Public and unlisted playlists can also be fetched by ID regardless of their owner.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchPlaylistById(parameters: ["id": "m1pe7z60bsw", "type": "episode_list", "last_timestamp_ms": "0", "sort": "recent_added_first"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-playlists-id)

### fetchMyPlaylists

Fetch a list of your playlists.

`GET /playlists`

This endpoint lists playlists with an active membership for the API admin, including playlists they created or joined.
Each playlist includes its saved default **type** and a **listennotes_url** for that view.
You can use the **page** parameter to do pagination and fetch more playlists.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchMyPlaylists(parameters: ["sort": "recent_added_first", "page": "1"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-playlists)

### fetchAudienceForPodcast

Fetch audience demographics for a podcast

`GET /podcasts/{id}/audience`

Fetch audience demographics for a podcast - 1) directly measured on the Listen Notes platform; 2) only supports audience breakdown by regions for now; 3) not every podcast has data.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchAudienceForPodcast(parameters: ["id": "25212ac3c53240a880dd5032e547047b"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-podcasts-id-audience)

### fetchPodcastsByDomain

Fetch podcasts by a publisher's domain name

`GET /podcasts/domains/{domain_name}`

Fetch podcasts by a publisher's domain name, e.g., nytimes.com, wondery.com, npr.org...
Each request will return up to 10 podcasts. You can use the `page` parameter to paginate.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.fetchPodcastsByDomain(parameters: ["domain_name": "nytimes.com", "page": "1"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-podcasts-domains-domain_name)

### createPlaylist

Create a playlist.

`POST /playlists`

Create an empty playlist owned by the API admin. Name is required; description defaults to an empty string, visibility defaults to public, and type defaults to episode_list. Set type to podcast_list to make podcasts the default view. The response includes the saved type and its listennotes_url.

Only playlists owned by your admin API account can be modified; contributor membership does not grant write access.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.createPlaylist(parameters: ["name": "My favorite podcasts", "description": "Podcasts and episodes to revisit.", "visibility": "public", "type": "episode_list"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#post-api-v2-playlists)

### updatePlaylist

Update playlist metadata.

`PUT /playlists/{id}`

Update any subset of name, description, visibility, and type. Omitted fields remain unchanged; at least one field is required. Switching to private rotates the playlist RSS secret. Type selects the saved default view (episode_list or podcast_list) and the returned listennotes_url; changing it preserves all existing episodes and podcasts.

Only playlists owned by your admin API account can be modified; contributor membership does not grant write access.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.updatePlaylist(parameters: ["id": "m1pe7z60bsw", "name": "My favorite podcasts", "description": "Podcasts and episodes to revisit.", "visibility": "public", "type": "podcast_list"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#put-api-v2-playlists-id)

### addPlaylistItem

Add an episode or podcast to a playlist.

`POST /playlists/{id}/items`

Provide exactly one non-empty episode_id or podcast_id; an empty unused ID field is ignored. Invalid ID formats return 400 and identify the field. A missing episode or podcast returns 404 with an error such as "Episode not found: {episode_id}." or "Podcast not found: {podcast_id}.". Existing active items are reused (200); new or restored items return 201. Omitted notes preserve existing notes, including when restoring a deleted item; supplied notes replace them.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.addPlaylistItem(parameters: ["id": "m1pe7z60bsw", "episode_id": "e53e6992a5b7492f9ea6fcd85d9ad95f", "notes": "Worth a listen."])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#post-api-v2-playlists-id-items)

### deletePlaylistItem

Remove an item from a playlist.

`DELETE /playlists/{id}/items/{item_id}`

Delete a playlist item. Repeating deletion of the same item succeeds. This does not delete the episode or podcast from the podcast database.

Only playlists owned by your admin API account can be modified; contributor membership does not grant write access.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.deletePlaylistItem(parameters: ["id": "m1pe7z60bsw", "item_id": "23"])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#delete-api-v2-playlists-id-items-item_id)

### updatePlaylistItemNotes

Update notes for a playlist item.

`PUT /playlists/{id}/items/{item_id}`

Replace item notes, or send an empty string to clear them. The item ID and added_at_ms remain unchanged.

Only playlists owned by your admin API account can be modified; contributor membership does not grant write access.

```swift
import Foundation
import PodcastAPI

@main
struct Example {
    static func main() async throws {
        let client = Client(apiKey: ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""])
        let response = try await client.updatePlaylistItemNotes(parameters: ["id": "m1pe7z60bsw", "item_id": "23", "notes": ""])
        print(response.toJson()?.description ?? "")
    }
}
```

[Full API documentation](https://www.listennotes.com/api/docs/#put-api-v2-playlists-id-items-item_id)

<!-- END GENERATED API REFERENCE -->
