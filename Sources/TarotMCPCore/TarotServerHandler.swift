import Foundation
import Logging
import MCP

enum TarotToolRequest {
  case drawCards(count: Int)
  case getFullDeck

  init(name: String, arguments: [String: Value]?) throws {
    guard let kind = Kind(rawValue: name) else {
      throw MCPError.methodNotFound("Unknown tool: \(name)")
    }
    switch kind {
    case .drawCards:
      let count = arguments?["count"]?.intValue ?? 1
      guard count >= 1 && count <= 78 else {
        throw TarotCardError.invalidCardCount(count)
      }
      self = .drawCards(count: count)
    case .getFullDeck:
      self = .getFullDeck
    }
  }

  func result(rng: inout some RandomNumberGenerator) throws -> CallTool.Result {
    switch self {
    case .drawCards(let count):
      return try .cardsResponse(cards: TarotDeck.drawCards(count: count, using: &rng))
    case .getFullDeck:
      return try .cardsResponse(cards: TarotDeck.fullDeck)
    }
  }
}

extension TarotToolRequest {
  enum Kind: String, CaseIterable {
    case drawCards = "draw_cards"
    case getFullDeck = "get_full_deck"

    var toolDescription: Tool {
      switch self {
      case .drawCards:
        return Tool(
          name: self.rawValue,
          description: "Draw one or more tarot cards",
          inputSchema: .object([
            "type": .string("object"),
            "properties": .object([
              "count": .object([
                "type": .string("integer"),
                "description": .string("Number of cards to draw (1-78)"),
                "minimum": .int(1),
                "maximum": .int(78),
                "default": .int(1),
              ])
            ])
          ])
        )
      case .getFullDeck:
        return Tool(
          name: self.rawValue,
          description: "Get all 78 tarot cards in the deck",
          inputSchema: .object([
            "type": .string("object"),
            "properties": .object([:])
          ])
        )
      }
    }
  }
}

extension CallTool.Result {
  static func cardsResponse(cards: some Sequence<TarotCard>) throws -> CallTool.Result {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder
      .encode(cards.map { CardResponse(name: $0.name, image: $0.imageResourceURI) })
    let jsonString = String(decoding: data, as: UTF8.self)
    return CallTool.Result(content: [.text(jsonString)])
  }

}

/// Handles MCP tool calls for the Tarot server
actor TarotServerHandler {
  var rng: any RandomNumberGenerator & Sendable
  private let logger = Logger(label: "TarotServerHandler")

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

  /// Returns the list of available resources (card images)
  static func getAvailableResources() -> [Resource] {
    let logger = Logger(label: "TarotServerHandler.getAvailableResources")
    
    // Only return resources if we can actually access the bundle
    guard Bundle.module.path(forResource: "Resources/images", ofType: nil) != nil else {
      logger.error("Could not find Resources/images directory in bundle")
      return []
    }
    
    return TarotDeck.fullDeck.map { card in
      Resource(
        name: "\(card.name) Image",
        uri: card.imageResourceURI,
        description: "Image of the \(card.name) tarot card",
        mimeType: "image/png"
      )
    }
  }

  /// Reads a resource (card image) by URI
  func readResource(uri: String) throws -> ReadResource.Result {
    // Parse the URI to find the corresponding card
    guard let card = cardFromURI(uri) else {
      throw MCPError.invalidRequest("Unknown resource URI: \(uri)")
    }

    // Get the resource directory path once
    guard let resourcePath = Bundle.module.path(forResource: "Resources/images", ofType: nil) else {
      throw MCPError.invalidRequest("Resource directory not found")
    }

    // Get the filename for this specific card
    let fileName = imageFileNameForCard(card)
    let fullPath = "\(resourcePath)/\(fileName)"
    // Try to load the image file
    guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: fullPath)) else {
      throw MCPError.invalidRequest("Image file not found for card: \(card.name)")
    }

    return ReadResource.Result(
      contents: [
        Resource.Content.binary(imageData, uri: uri, mimeType: "image/png")
      ]
    )
  }

  private func cardFromURI(_ uri: String) -> TarotCard? {
    // Parse URIs like "tarot://card/major/0" or "tarot://card/minor/wands/1"
    let components = uri.components(separatedBy: "/")
    guard components.count >= 4, components[0] == "tarot:", components[2] == "card" else {
      return nil
    }

    let cardType = components[3]

    if cardType == "major" {
      guard
        components.count == 5,
        let rawValue = Int(components[4]),
        let majorArcana = MajorArcana(rawValue: rawValue)
      else { return nil }
      return .major(majorArcana)
    } else if cardType == "minor" {
      guard
        components.count == 6,
        let suit = MinorArcana.Suit(rawValue: components[4].capitalized),
        let value = Int(components[5]),
        let minorValue = MinorArcana.Value(rawValue: value)
      else { return nil }
      return .minor(MinorArcana(suit: suit, value: minorValue))
    }

    return nil
  }

  private func imageFileNameForCard(_ card: TarotCard) -> String {
    switch card {
    case .major(let arcana):
      let fileName = majorArcanaFileName(for: arcana)
      return "\(fileName).png"
    case .minor(let minorArcana):
      let fileName = minorArcanaFileName(for: minorArcana)
      return "\(fileName).png"
    }
  }

  // swiftlint:disable:next cyclomatic_complexity
  private func majorArcanaFileName(for arcana: MajorArcana) -> String {
    switch arcana {
    case .fool: return "major_arcana_fool"
    case .magician: return "major_arcana_magician"
    case .highPriestess: return "major_arcana_priestess"
    case .empress: return "major_arcana_empress"
    case .emperor: return "major_arcana_emperor"
    case .hierophant: return "major_arcana_hierophant"
    case .lovers: return "major_arcana_lovers"
    case .chariot: return "major_arcana_chariot"
    case .strength: return "major_arcana_strength"
    case .hermit: return "major_arcana_hermit"
    case .wheelOfFortune: return "major_arcana_fortune"
    case .justice: return "major_arcana_justice"
    case .hangedMan: return "major_arcana_hanged"
    case .death: return "major_arcana_death"
    case .temperance: return "major_arcana_temperance"
    case .devil: return "major_arcana_devil"
    case .tower: return "major_arcana_tower"
    case .star: return "major_arcana_star"
    case .moon: return "major_arcana_moon"
    case .sun: return "major_arcana_sun"
    case .judgement: return "major_arcana_judgement"
    case .world: return "major_arcana_world"
    }
  }

  // swiftlint:disable:next cyclomatic_complexity
  private func minorArcanaFileName(for minorArcana: MinorArcana) -> String {
    let suitName = minorArcana.suit.rawValue.lowercased()
    let valueName: String

    switch minorArcana.value {
    case .ace: valueName = "ace"
    case .two: valueName = "2"
    case .three: valueName = "3"
    case .four: valueName = "4"
    case .five: valueName = "5"
    case .six: valueName = "6"
    case .seven: valueName = "7"
    case .eight: valueName = "8"
    case .nine: valueName = "9"
    case .ten: valueName = "10"
    case .page: valueName = "page"
    case .knight: valueName = "knight"
    case .queen: valueName = "queen"
    case .king: valueName = "king"
    }

    return "minor_arcana_\(suitName)_\(valueName)"
  }
}
