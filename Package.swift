// swift-tools-version:5.9
//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import PackageDescription


let package = Package(
    name: "Bluebonnet",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(name: "Bluebonnet", targets: ["Bluebonnet"])
    ],
    targets: [
        .target(
            name: "Bluebonnet"
        )
    ]
)
