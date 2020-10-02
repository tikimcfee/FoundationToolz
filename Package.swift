// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "FoundationToolz",
    products: [
        .library(name: "FoundationToolz",
                 targets: ["FoundationToolz"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/flowtoolz/SwiftyToolz.git",
            .upToNextMajor(from: "1.5.5")
        ),
    ],
    targets: [
        .target(name: "FoundationToolz",
                dependencies: ["SwiftyToolz"],
                path: "Code"),
    ]
)
