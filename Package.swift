// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TruvideoCapacitorCoremoduleSdk",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "TruvideoCapacitorCoremoduleSdk",
            targets: ["AuthenticationPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "AuthenticationPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/AuthenticationPlugin"),
        .testTarget(
            name: "AuthenticationPluginTests",
            dependencies: ["AuthenticationPlugin"],
            path: "ios/Tests/AuthenticationPluginTests")
    ]
)