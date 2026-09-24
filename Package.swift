// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "PodcastAPI",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(
            name: "PodcastAPI",
            targets: ["PodcastAPI"]),
        .executable(
            name: "ExampleCommandLineApp",
            targets: ["ExampleCommandLineApp"]),
    ],
    targets: [
        .target(
            name: "PodcastAPI",
            dependencies: []),
        .testTarget(
            name: "PodcastAPITests",
            dependencies: ["PodcastAPI"],
            resources: [.copy("api-contract.json")]),
        .executableTarget(
            name: "ExampleCommandLineApp",
            dependencies: ["PodcastAPI"]),
    ]
)
