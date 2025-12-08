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
            path: "swift-sdk/Sources/GistAdsSDK"
        ),
        .testTarget(
            name: "GistAdsSDKTests",
            dependencies: ["GistAdsSDK"],
            path: "swift-sdk/Tests/GistAdsSDKTests"
        ),
    ]
)

