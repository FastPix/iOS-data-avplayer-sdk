// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageName = "FastpixVideoDataAVPlayer"

let package = Package(
    name: packageName,
    platforms: [
        .iOS(.v13)  // Specify platform compatibility
    ],
    products: [
        .library(
            name: packageName,
            targets: [packageName]
        ),
    ],
    dependencies: [
        // Add the Git URL package dependency here
        .package(url: "https://github.com/FastPix/iOS-core-data-sdk.git", from: "1.0.3")
    ],
    targets: [
        .target(
            name: packageName,
            dependencies: [
                .product(name: "FastpixiOSVideoDataCore", package: "iOS-core-data-sdk")  // Link the Git package to your local package
            ]
        ),
        .testTarget(
            name: "\(packageName)Tests",
            dependencies: [.target(name: packageName)]
        ),
    ]
)
