// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "Logger",
  platforms: [
    .iOS(.v10),
    .macOS(.v10_12),
    .watchOS(.v3),
    .tvOS(.v10),
  ],
  products: [
    .library(
      name: "Logger",
      targets: ["Logger"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/binaryscraping/swift-json", branch: "main"),
    .package(url: "https://github.com/binaryscraping/swift-sqlite", branch: "main"),
  ],
  targets: [
    .target(
      name: "Logger",
      dependencies: [
        .product(name: "JSON", package: "swift-json"),
        .product(name: "Sqlite", package: "swift-sqlite"),
      ]
    ),
    .testTarget(
      name: "LoggerTests",
      dependencies: ["Logger"]
    ),
  ]
)
