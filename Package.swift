// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Networker",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v10),
        .watchOS(.v3),
    ],
    products: [
        .library(
            name: "Networker",
            targets: ["Networker"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Networker",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "NetworkerTests",
            dependencies: ["Networker"],
            path: "Tests"
        ),
    ]
)
