// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BabyMind",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BabyMind",
            targets: ["BabyMind"]),
    ],
    dependencies: [
        // AI entegrasyonu için gerekli paketler buraya eklenecek
        // Örnek: OpenAI SDK, Anthropic SDK, vb.
    ],
    targets: [
        .target(
            name: "BabyMind",
            dependencies: []),
        .testTarget(
            name: "BabyMindTests",
            dependencies: ["BabyMind"]),
    ]
)









