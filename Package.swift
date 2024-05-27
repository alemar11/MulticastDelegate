// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MulticastDelegate",
  platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .visionOS(.v1), .watchOS(.v9)],
  products: [
    .library(name: "MulticastDelegate", targets: ["MulticastDelegate"])
  ],
  targets: [
    .target(name: "MulticastDelegate"),
    .testTarget(name: "MulticastDelegateTests", dependencies: ["MulticastDelegate"]),
  ]
)
