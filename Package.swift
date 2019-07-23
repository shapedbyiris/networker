// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Networker",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "Networker",
            targets: ["Networker"])
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
        )
    ]
)
