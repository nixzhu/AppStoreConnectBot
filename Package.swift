// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "AppStoreConnectBot",
    platforms: [.macOS(.v26)],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.7.1"
        ),
        .package(
            url: "https://github.com/MortenGregersen/Bagbutik.git",
            from: "20.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-custom-dump.git",
            from: "1.5.0"
        ),
    ],
    targets: [
        .executableTarget(
            name: "AppStoreConnectBot",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                .product(
                    name: "Bagbutik",
                    package: "Bagbutik"
                ),
                .product(
                    name: "CustomDump",
                    package: "swift-custom-dump"
                ),
            ],
            swiftSettings: [
                .defaultIsolation(nil),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
            ]
        ),
    ]
)
