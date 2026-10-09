// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "AppStoreConnectBot",
    platforms: [.macOS(.v26)],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            exact: "1.8.2"
        ),
        .package(
            url: "https://github.com/MortenGregersen/Bagbutik.git",
            exact: "24.1.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-custom-dump.git",
            exact: "1.7.3"
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
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ImmutableWeakCaptures"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("InternalImportsByDefault"),
                .enableUpcomingFeature("MemberImportVisibility"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            ]
        ),
    ]
)
