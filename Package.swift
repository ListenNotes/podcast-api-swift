// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PodcastAPI",
    platforms: [
        .macOS(.v10_12),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PodcastAPI",
            targets: ["PodcastAPI"]),
        .executable(
            name: "Example",
            targets: ["Example"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.2.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PodcastAPI",
            dependencies: ["Alamofire"]),
        .testTarget(
            name: "PodcastAPITests",
            dependencies: ["PodcastAPI"]),
        .target(
            name: "Example",
            dependencies: ["PodcastAPI"]),
    ]
)
