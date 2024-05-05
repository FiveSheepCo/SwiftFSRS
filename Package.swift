// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SwiftFSRS",
    platforms: [
        .macOS(.v10_13), .iOS(.v14),
    ],
    products: [
        .library(name: "SwiftFSRS", targets: ["SwiftFSRS"]),
    ],
    targets: [
      .target(name: "SwiftFSRS"),
      .testTarget(
        name: "SwiftFSRSTests",
        dependencies: ["SwiftFSRS"]
      ),
    ]
)
