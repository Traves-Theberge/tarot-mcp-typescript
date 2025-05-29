import Foundation
import MCP

struct TarotServer {
  private let cardService = TarotCardService()
  
  func run() async throws {
    let server = Server(
      name: "Tarot MCP Server",
      version: "1.0.0",
      capabilities: Server.Capabilities(
        tools: Server.Capabilities.Tools()
      )
    )

    // Register tools/list method
    await server.withMethodHandler(ListTools.self) { _ in
      ListTools.Result(tools: [
        Tool(
          name: "draw_single_card",
          description: "Draw a single random tarot card"
        ),
        Tool(
          name: "draw_multiple_cards",
          description: "Draw multiple tarot cards",
          inputSchema: .object([
            "count": .object([
              "type": .string("integer"),
              "description": .string("Number of cards to draw (1-20)"),
              "minimum": .int(1),
              "maximum": .int(20),
              "default": .int(3)
            ])
          ])
        ),
        Tool(
          name: "get_full_deck",
          description: "Get all 78 tarot cards in the deck"
        )
      ])
    }

    // Register tools/call method
    await server.withMethodHandler(CallTool.self) { params in
      switch params.name {
      case "draw_single_card":
        let result = self.cardService.drawSingleCard()
        return CallTool.Result(content: [.text(result.message)])

      case "draw_multiple_cards":
        let count = params.arguments?["count"]?.intValue ?? 3
        let result = self.cardService.drawMultipleCards(count: count)
        return CallTool.Result(content: [.text(result.message)])

      case "get_full_deck":
        let result = self.cardService.getFullDeck()
        return CallTool.Result(content: [.text(result.message)])

      default:
        throw MCPError.methodNotFound("Unknown tool: \(params.name)")
      }
    }

    // Start the server with stdio transport
    let transport = StdioTransport()
    try await server.start(transport: transport)
    await server.waitUntilCompleted()
  }
}
