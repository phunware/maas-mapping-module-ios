// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "PhunwareMapping",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "PhunwareMapping",
            targets: ["PhunwareMappingWrapper"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/phunware/maas-mapping-ios-sdk.git",
            branch: "release/3.16.3"
        ),
        .package(
            url: "https://github.com/phunware/artifact-permissions-ios.git",
            branch: "release/1.5.3"
        ),
        .package(
            url: "https://github.com/phunware/artifact-networking-ios.git",
            branch: "release/1.3.2"
        ),
        .package(
            url: "https://github.com/phunware/artifact-theming-ios.git",
            branch: "release/1.1.2"
        ),
        .package(
            url: "https://github.com/phunware/artifact-foundation-ios.git",
            branch: "release/1.1.0"
        ),
        .package(
            url: "https://github.com/phunware/artifact-core-plugin-ios.git", 
            branch: "release/1.1.0"
        )
    ],
    targets: [
        .target(
            name: "PhunwareMappingWrapper",
            dependencies: [
                .target(name: "PhunwareMappingBinary"),
                .product(name: "PWMapKit", package: "maas-mapping-ios-sdk"),
                .product(name: "PhunwareLocationPermission", package: "artifact-permissions-ios"),
                .product(name: "PhunwareNetworking", package: "artifact-networking-ios"),
                .product(name: "PhunwareTheming", package: "artifact-theming-ios"),
                .product(name: "PhunwareFoundation", package: "artifact-foundation-ios"),
                .product(name: "PhunwareCorePlugin", package: "artifact-core-plugin-ios")
            ],
            path: "Sources/PhunwareMappingWrapper"
        ),
        .binaryTarget(
            name: "PhunwareMappingBinary",
            path: "Frameworks/PhunwareMapping.xcframework"
        )
    ]
)

