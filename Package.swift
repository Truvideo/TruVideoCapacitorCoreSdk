// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TruvideoCapacitorCoreSdk",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "TruvideoCapacitorCoreSdk",
            targets: ["AuthenticationPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0"),
        .package(url: "https://github.com/Truvideo/truvideo-sdk-ios-core.git", branch: "main") // Add Truvideo SDK
    ],
    targets: [
        .target(
            name: "AuthenticationPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "TruvideoSdk", package: "truvideo-sdk-ios-core")
            ],
            path: "ios/Sources/AuthenticationPlugin"),
        .testTarget(
            name: "AuthenticationPluginTests",
            dependencies: ["AuthenticationPlugin"],
            path: "ios/Tests/AuthenticationPluginTests")
    ]
)