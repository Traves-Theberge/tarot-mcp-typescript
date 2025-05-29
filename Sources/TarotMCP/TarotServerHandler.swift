import Foundation
import MCP

private extension String {
  static let drawSingleCard = "draw_single_card"
  static let drawMultipleCards = "draw_multiple_cards"
  static let getFullDeck = "get_full_deck"
}

/// Handles MCP tool calls for the Tarot server
struct TarotServerHandler {
  private let cardService: TarotCardService

  @TaskLocal static var rng: any RandomNumberGenerator = SystemRandomNumberGenerator()

  init(cardService: TarotCardService = TarotCardService()) {
    self.cardService = cardService
  }
  
  /// Handles a tool call and returns the appropriate result
  func handleToolCall(name: String, arguments: [String: Value]?) throws -> CallTool.Result {
    switch name {
    case .drawSingleCard:
      var rng = Self.rng
      let result = cardService.drawSingleCard(using: &rng)
      return CallTool.Result(content: [.text(result.message)])
      
    case .drawMultipleCards:
      var rng = Self.rng
      let count = arguments?["count"]?.intValue ?? 3
      let result = cardService.drawMultipleCards(count: count, using: &rng)
      return CallTool.Result(content: [.text(result.message)])
      
    case .getFullDeck:
      let result = cardService.getFullDeck()
      return CallTool.Result(content: [.text(result.message)])
      
    default:
      throw MCPError.methodNotFound("Unknown tool: \(name)")
    }
  }
  
  /// Returns the list of available tools
  static func getAvailableTools() -> [Tool] {
    return [
      Tool(
        name: .drawSingleCard,
        description: "Draw a single random tarot card"
      ),
      Tool(
        name: .drawMultipleCards,
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
        name: .getFullDeck,
        description: "Get all 78 tarot cards in the deck"
      )
    ]
  }
}
