// swift-tools-version:5.3

import Foundation
import PackageDescription

var sources = ["src/parser.c"]
if FileManager.default.fileExists(atPath: "src/scanner.c") {
    sources.append("src/scanner.c")
}

let package = Package(
    name: "TreeSitterDatastar",
    products: [
        .library(name: "TreeSitterDatastar", targets: ["TreeSitterDatastar"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tree-sitter/swift-tree-sitter", from: "0.8.0"),
    ],
    targets: [
        .target(
            name: "TreeSitterDatastar",
            dependencies: [],
            path: ".",
            sources: sources,
            resources: [
                .copy("queries")
            ],
            publicHeadersPath: "bindings/swift",
            cSettings: [.headerSearchPath("src")]
        ),
        .testTarget(
            name: "TreeSitterDatastarTests",
            dependencies: [
                "SwiftTreeSitter",
                "TreeSitterDatastar",
            ],
            path: "bindings/swift/TreeSitterDatastarTests"
        )
    ],
    cLanguageStandard: .c11
)
