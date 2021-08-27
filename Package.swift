// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "FoundationToolz",
    platforms: [.iOS(.v12), .tvOS(.v12), .macOS(.v10_14)],
    products: [
        .library(
            name: "FoundationToolz",
            targets: ["FoundationToolz"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/flowtoolz/SwiftyToolz.git",
            .branch("master")
        ),
    ],
    targets: [
        .target(
            name: "FoundationToolz",
            dependencies: ["SwiftyToolz"],
            path: "Code"
        ),
    ]
)
