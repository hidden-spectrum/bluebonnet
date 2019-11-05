// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Bluebonnet",
    platforms: [.iOS("11.0"), .macOS("10.13")],
    products: [
        .library(name: "Bluebonnet", targets: ["Bluebonnet"])
    ],
    targets: [
        .target(
            name: "Bluebonnet",
            path: "Bluebonnet"
        )
    ]
)
