// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SwiftLogging",
	platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1)],
	products: [
		.library(
			name: "SwiftLogging",
			targets: ["SwiftLogging"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/nalexn/ViewInspector", from: "0.10.0")
	],
	targets: [
		.target(
			name: "SwiftLogging"
		),
		.testTarget(
			name: "SwiftLoggingTests",
			dependencies: [
				"SwiftLogging",
				.product(name: "ViewInspector", package: "ViewInspector")
			]
		)
	]
)
