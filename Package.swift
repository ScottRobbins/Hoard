// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Hoard",
    platforms: [
        .macOS(.v10_14)
    ],
    products: [
        .executable(name: "hoard", targets: ["Hoard"])
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files.git", from: "3.1.0"),
        .package(url: "https://github.com/onevcat/Rainbow", .exact("4.0.1")),
        .package(url: "https://github.com/apple/swift-argument-parser", .exact("1.1.3")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "Hoard",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Files",
                "Rainbow",
                "Yams"
            ]),
    ]
)
