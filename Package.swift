// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BeerBlindBoxWeb",
    platforms: [
        .macOS(.v13),
        .linux
    ],
    dependencies: [
        .package(url: "https://github.com/TokamakUI/Tokamak", from: "0.11.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "BeerBlindBoxWeb",
            dependencies: [
                .product(name: "TokamakShim", package: "Tokamak")
            ],
            resources: [
                .process("Public")
            ]
        )
    ]
)
