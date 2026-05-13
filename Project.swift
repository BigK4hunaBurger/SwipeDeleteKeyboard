import ProjectDescription

let bundleBase = "com.bigk4huna.swipedelete"

let project = Project(
    name: "SwipeDeleteKeyboard",
    targets: [
        .target(
            name: "SwipeDeleteKeyboard",
            destinations: .iOS,
            product: .app,
            bundleId: bundleBase,
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": "LaunchScreen",
                "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
            ]),
            sources: ["App/**"],
            dependencies: [
                .target(name: "KeyboardExtension"),
            ]
        ),
        .target(
            name: "KeyboardExtension",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "\(bundleBase).keyboard",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(with: [
                "NSExtension": .dictionary([
                    "NSExtensionAttributes": .dictionary([
                        "IsASCIICapable": .boolean(false),
                        "PrefersRightToLeft": .boolean(false),
                        "PrimaryLanguage": .string("en-US"),
                        "RequestsOpenAccess": .boolean(false),
                    ]),
                    "NSExtensionPointIdentifier": .string("com.apple.keyboard-input-mode"),
                    "NSExtensionPrincipalClass": .string("$(PRODUCT_MODULE_NAME).KeyboardViewController"),
                ]),
            ]),
            sources: ["KeyboardExtension/**"],
            dependencies: []
        ),
    ]
)
