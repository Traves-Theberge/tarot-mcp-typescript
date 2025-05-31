import Foundation
import MCP

private extension String {
  static let drawSingleCard = "draw_single_card"
  static let drawMultipleCards = "draw_multiple_cards"
  static let getFullDeck = "get_full_deck"
}

/// Handles MCP tool calls for the Tarot server
struct TarotServerHandler: Sendable {
  @TaskLocal static var rng: any RandomNumberGenerator & Sendable = SystemRandomNumberGenerator()

  /// Handles a tool call and returns the appropriate result
  func handleToolCall(name: String, arguments: [String: Value]?) throws -> CallTool.Result {
    switch name {
    case .drawSingleCard:
      var rng = Self.rng
      let card = TarotDeck.drawRandomCard(using: &rng)
      return CallTool.Result(content: [.text("You drew:\n- \(card.name)")])

    case .drawMultipleCards:
      var rng = Self.rng
      let count = arguments?["count"]?.intValue ?? 3
      guard count >= 1 && count <= 78 else {
        throw TarotCardError.invalidCardCount(count)
      }
      let cards = TarotDeck.drawCards(count: count, using: &rng)
      let cardList = cards.map { "- \($0.name)" }.joined(separator: "\n")
      return CallTool.Result(content: [.text("You drew \(count) cards:\n\(cardList)")])

    case .getFullDeck:
      let deck = TarotDeck.fullDeck
      let cardList = deck.map { "- \($0.name)" }.joined(separator: "\n")
      return CallTool.Result(content: [.text("Full deck (\(deck.count) cards):\n\(cardList)")])

    default:
      throw MCPError.methodNotFound("Unknown tool: \(name)")
    }
  }

  /// Returns the list of available tools
  static func getAvailableTools() -> [Tool] {
    return [
      Tool(
        name: .drawSingleCard,
        description: "Draw a single random tarot card",
        inputSchema: .object([
          "type": .string("object"),
          "properties": .object([:])
        ])
      ),
      Tool(
        name: .drawMultipleCards,
        description: "Draw multiple tarot cards",
        inputSchema: .object([
          "type": .string("object"),
          "properties": .object([
            "count": .object([
              "type": .string("integer"),
              "description": .string("Number of cards to draw (1-78)"),
              "minimum": .int(1),
              "maximum": .int(78),
              "default": .int(3)
            ])
          ])
        ])
      ),
      Tool(
        name: .getFullDeck,
        description: "Get all 78 tarot cards in the deck",
        inputSchema: .object([
          "type": .string("object"),
          "properties": .object([:])
        ])
      )
    ]
  }
}
