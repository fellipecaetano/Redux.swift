// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Redux",
    products: [
        .library(name: "Redux", targets: ["Redux"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.5"),
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "Redux", 
            dependencies: ["RxSwift", "RxCocoa"], 
            path: "Source"),
        .testTarget(
            name: "ReduxTests", 
            dependencies: [
                "Redux", 
                "RxSwift",
                "Nimble"
            ], 
            path: "Tests"),
    ]
)
