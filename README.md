# Podcast API Swift Library

[![Swift](https://github.com/ListenNotes/podcast-api-swift/actions/workflows/swift.yml/badge.svg)](https://github.com/ListenNotes/podcast-api-swift/actions/workflows/swift.yml)

The Podcast API Swift library provides convenient access to the [Listen Notes Podcast API](https://www.listennotes.com/api/) from
applications written in the Swift language.

Simple and no-nonsense podcast search & directory API. Search the meta data of all podcasts and episodes by people, places, or topics. It's the same API that powers [the best podcast search engine Listen Notes](https://www.listennotes.com/).

If you have any questions, please contact [hello@listennotes.com](hello@listennotes.com?subject=Questions+about+the+Swift+SDK+of+Listen+API)

<a href="https://www.listennotes.com/api/"><img src="https://raw.githubusercontent.com/ListenNotes/ListenApiDemo/master/web/src/powered_by_listennotes.png" width="300" /></a>

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate PodcastAPI into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'PodcastAPI'
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding PodcastAPI as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/ListenNotes/podcast-api-swift.git", .upToNextMajor(from: "1.0.1"))
]
```

### Requirements

- Swift 5+


## Usage

The library needs to be configured with your account's API key which is
available in your [Listen API Dashboard](https://www.listennotes.com/api/dashboard/#apps). Set `apiKey` to its
value:

```swift
import Foundation
import PodcastAPI

let apiKey = ProcessInfo.processInfo.environment["LISTEN_API_KEY", default: ""]

// For command line executables, we have to use synchronous requests, otherwise
// the program would exit before requests return any response
let client = PodcastAPI.Client(apiKey: apiKey, synchronousRequest: true)

// By default, we do asynchronous requests, for GUI-based applications on iOS or macOS
// let client = PodcastAPI.Client(apiKey: apiKey)

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
        print(response.getFreeQuota())
        print(response.getUsage())
        print(response.getNextBillingDate())
        
        // If you use PodcastAPI library in a GUI app (e.g., iOS/macOS),
        // You need to update UI in the main thread
        // DispatchQueue.main.async {
        //    self.displayLabel.text = "some text here"
        // }
    }
}
```

If `apiKey` is an empty string "", then we'll connect to a [mock server](https://www.listennotes.com/api/tutorials/#faq0) that returns fake data for testing purposes.

### synchronousRequest parameter

A command line executable will exit without wait for http async requests to finish. Therefore, we have to make http requests synchronous. Please set the `synchronousRequest` parameter to true when instantiating a Client object:

```swift
let client = PodcastAPI.Client(apiKey: apiKey, synchronousRequest: true)
```

In GUI Apps (e.g., iOS / macOS), you don't need to pass a `synchronousRequest` parameter. Just do this:

```swift
let client = PodcastAPI.Client(apiKey: apiKey)
```

### Update UI in the main thread

In the completion closure of an API request, you need to update UI in the main thread (`DispatchQueue.main.async`) for GUI apps (e.g., iOS, macOS):

```swift
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
        if let json = response.toJson() {
            print(json)
        }
        
        // If you use PodcastAPI library in a GUI app (e.g., iOS/macOS),
        // You need to update UI in the main thread
        DispatchQueue.main.async {
            self.displayLabel.text = "some text here"
        }
    }
}
```

### Handling errors

Unsuccessful requests return errors.

| Error  | Description |
| ------------- | ------------- |
|  authenticationError | wrong api key or your account is suspended  |
| invalidRequestError  | something wrong on your end (client side errors), e.g., missing required parameters  |
| tooManyRequestsError  | you are using FREE plan and you exceed the quota limit  |
| notFoundError  | endpoint not exist, or podcast / episode not exist  |
| apiConnectionError | failed to connect to Listen API servers | 
| serverError  | something wrong on our end (unexpected server errors)  |

All errors can be found in [this file](https://github.com/ListenNotes/podcast-api-swift/blob/main/Sources/PodcastAPI/PodcastApiError.swift).

### Run example apps

We provide two example apps: one is a command line app, and the other is an iOS app.

#### Run the command line example app

```sh

# From the root directory of podcast-api-swift, where Package.swift is located:

$ swift run
```

You can see the code under [Sources/ExampleCommandLineApp](https://github.com/ListenNotes/podcast-api-swift/tree/main/Sources/ExampleCommandLineApp).

#### Run the iOS example app

Just open ExampleIOSApp.xcworkspace with Xcode, from the directory of [Sources/ExampleIOSApp](https://github.com/ListenNotes/podcast-api-swift/tree/main/Sources/ExampleIOSApp).
