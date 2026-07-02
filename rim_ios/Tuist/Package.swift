// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        productTypes: [:]
    )
#endif

let package = Package(
    name: "rim_ios",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "8.1.0"),
        // TCA 1.26's macros are written against the swift-syntax 6.3 snapshot API
        // (e.g. `GenericArgumentSyntax.Argument`). Tuist otherwise resolves the
        // 600.0.1 release, which lacks it. Pin the exact revision TCA's own
        // Examples use under Swift 6.3 (tag swift-6.3-DEVELOPMENT-SNAPSHOT-2026-06-07-a).
        .package(
            url: "https://github.com/swiftlang/swift-syntax",
            revision: "79e4b74a295b6eb74a8b585e3a39d29e70c1dbd1"
        ),
    ]
)
