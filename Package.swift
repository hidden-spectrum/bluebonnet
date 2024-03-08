// swift-tools-version:5.9
//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import PackageDescription


let package = Package(
    name: "Bluebonnet",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "Bluebonnet",
            targets: ["Bluebonnet"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Bluebonnet"
        )
    ]
)
