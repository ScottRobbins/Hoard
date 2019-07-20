// swift-tools-version:5.0
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
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0"),
        .package(url: "https://github.com/JohnSundell/Files.git", from: "3.1.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "Hoard",
            dependencies: ["SPMUtility", "Files", "Yams"]),
    ]
)
