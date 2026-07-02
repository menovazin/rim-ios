import ProjectDescription

let bundlePrefix = "com.rim.ios"
let deploymentTargets: DeploymentTargets = .iOS("17.0")
let destinations: Destinations = .iOS

func module(
    name: String,
    product: Product,
    hasResources: Bool = false,
    dependencies: [TargetDependency] = []
) -> Target {
    .target(
        name: name,
        destinations: destinations,
        product: product,
        bundleId: "\(bundlePrefix).\(name.lowercased())",
        deploymentTargets: deploymentTargets,
        sources: ["Targets/\(name)/Sources/**"],
        resources: hasResources ? ["Targets/\(name)/Resources/**"] : [],
        dependencies: dependencies
    )
}

func testTarget(for name: String) -> Target {
    .target(
        name: "\(name)Tests",
        destinations: destinations,
        product: .unitTests,
        bundleId: "\(bundlePrefix).\(name.lowercased()).tests",
        deploymentTargets: deploymentTargets,
        sources: ["Targets/\(name)/Tests/**"],
        dependencies: [.target(name: name)]
    )
}

let project = Project(
    name: "rim_ios",
    targets: [
        // MARK: - App
        .target(
            name: "App",
            destinations: destinations,
            product: .app,
            bundleId: bundlePrefix,
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Targets/App/Sources/**"],
            resources: ["Targets/App/Resources/**"],
            dependencies: [
                .target(name: "Features"),
                .target(name: "DesignSystem"),
            ]
        ),
        testTarget(for: "App"),

        // MARK: - DesignSystem
        module(
            name: "DesignSystem",
            product: .framework,
            hasResources: true
        ),
        testTarget(for: "DesignSystem"),

        // MARK: - Features
        module(
            name: "Features",
            product: .framework,
            dependencies: [
                .target(name: "DesignSystem"),
                .target(name: "Networking"),
                .target(name: "Models"),
                .external(name: "ComposableArchitecture"),
                .external(name: "Kingfisher"),
            ]
        ),
        testTarget(for: "Features"),

        // MARK: - Networking
        module(
            name: "Networking",
            product: .framework,
            dependencies: [
                .target(name: "Models"),
            ]
        ),
        testTarget(for: "Networking"),

        // MARK: - Models
        module(
            name: "Models",
            product: .framework
        ),
        testTarget(for: "Models"),
    ]
)
