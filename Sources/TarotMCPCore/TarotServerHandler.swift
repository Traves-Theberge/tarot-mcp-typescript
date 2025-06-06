import Foundation
import MCP

enum TarotToolRequest {
  case drawSingleCard
  case drawMultipleCards(count: Int)
  case getFullDeck

  init(name: String, arguments: [String: Value]?) throws {
    guard let kind = Kind(rawValue: name) else {
      throw MCPError.methodNotFound("Unknown tool: \(name)")
    }
    switch kind {
    case .drawSingleCard:
      self = .drawSingleCard
    case .drawMultipleCards:
      let count = arguments?["count"]?.intValue ?? 3
      guard count >= 1 && count <= 78 else {
        throw TarotCardError.invalidCardCount(count)
      }
      self = .drawMultipleCards(count: count)
    case .getFullDeck:
      self = .getFullDeck
    }
  }

  func result(rng: inout some RandomNumberGenerator) -> CallTool.Result {
    switch self {
    case .drawSingleCard:
      return .singleCard(card: TarotDeck.drawRandomCard(using: &rng))
    case .drawMultipleCards(let count):
      return .multipleCards(cards: TarotDeck.drawCards(count: count, using: &rng))
    case .getFullDeck:
      return .fullDeck(deck: TarotDeck.fullDeck)
    }
  }
}

extension TarotToolRequest {
  enum Kind: String, CaseIterable {
    case drawSingleCard = "draw_single_card"
    case drawMultipleCards = "draw_multiple_cards"
    case getFullDeck = "get_full_deck"

    var toolDescription: Tool {
      switch self {
      case .drawSingleCard:
        return Tool(
          name: self.rawValue,
          description: "Draw a single random tarot card",
          inputSchema: .object([
            "type": .string("object"),
            "properties": .object([:]),
          ])
        )
      case .drawMultipleCards:
        return Tool(
          name: self.rawValue,
          description: "Draw multiple tarot cards",
          inputSchema: .object([
            "type": .string("object"),
            "properties": .object([
              "count": .object([
                "type": .string("integer"),
                "description": .string("Number of cards to draw (1-78)"),
                "minimum": .int(1),
                "maximum": .int(78),
                "default": .int(3),
              ])
            ]),
          ])
        )
      case .getFullDeck:
        return Tool(
          name: self.rawValue,
          description: "Get all 78 tarot cards in the deck",
          inputSchema: .object([
            "type": .string("object"),
            "properties": .object([:]),
          ])
        )
      }
    }
  }
}

extension CallTool.Result {
  static func singleCard(card: TarotCard) -> CallTool.Result {
    return CallTool.Result(content: [.text("You drew:\n- \(card.name)")])
  }

  static func multipleCards(cards: [TarotCard]) -> CallTool.Result {
    let cardList = cards.lazy.map { "- \($0.name)" }.joined(separator: "\n")
    return CallTool.Result(content: [.text("You drew \(cards.count) cards:\n\(cardList)")])
  }

  static func fullDeck(deck: [TarotCard]) -> CallTool.Result {
    let cardList = deck.lazy.map { "- \($0.name)" }.joined(separator: "\n")
    return CallTool.Result(content: [.text("Full deck (\(deck.count) cards):\n\(cardList)")])
  }
}

/// Handles MCP tool calls for the Tarot server
actor TarotServerHandler {
  var rng: any RandomNumberGenerator & Sendable

  init(rng: some RandomNumberGenerator & Sendable = SystemRandomNumberGenerator()) {
    self.rng = rng
  }

  /// Handles a tool call and returns the appropriate result
  func handleToolCall(
    name: String,
    arguments: [String: Value]?
  ) throws -> CallTool.Result {
    try TarotToolRequest(name: name, arguments: arguments)
      .result(rng: &rng)
  }

  /// Returns the list of available tools
  static func getAvailableTools() -> [Tool] {
    TarotToolRequest.Kind.allCases.map(\.toolDescription)
  }
}
