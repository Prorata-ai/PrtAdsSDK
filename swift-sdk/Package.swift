// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GistAdsSDK",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "GistAdsSDK",
            targets: ["GistAdsSDK"]),
    ],
    targets: [
        .target(
            name: "GistAdsSDK",
            dependencies: [],
            path: "Sources/GistAdsSDK"
        ),
        .testTarget(
            name: "GistAdsSDKTests",
            dependencies: ["GistAdsSDK"],
            path: "Tests/GistAdsSDKTests"
        ),
    ]
)

