// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "swift-tarot-MCP",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .executable(
      name: "swift-tarot-MCP",
      targets: ["TarotMCP"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.1.0")
  ],
  targets: [
    .executableTarget(
      name: "TarotMCP",
      dependencies: [
        .product(name: "MCP", package: "swift-sdk")
      ]
    ),
    .testTarget(
      name: "TarotMCPTests",
      dependencies: ["TarotMCP"],
      exclude: [
        "TarotMCP.xctestplan",
      ]
    )
  ]
)
