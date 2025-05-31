import Testing
import Foundation
import InlineSnapshotTesting
import MCP
@testable import TarotMCPCore

struct TarotServerHandlerTests {

  @Test("draw_single_card tool returns valid response")
  func testDrawSingleCardTool() throws {
    let handler = TarotServerHandler()

    let result = try handler.handleToolCall(name: "draw_single_card", arguments: nil)

    #expect(result.content.count == 1)
    if case .text(let message) = result.content[0] {
      #expect(message.hasPrefix("You drew:\n- "))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test("draw_single_card tool produces deterministic results")
  func testDrawSingleCardDeterministic() throws {
    let handler = TarotServerHandler()

    let result1 = try TarotServerHandler.$rng.withValue(SeedablePseudoRNG(seed: 54321)) {
      try handler.handleToolCall(name: "draw_single_card", arguments: nil)
    }

    let result2 = try TarotServerHandler.$rng.withValue(SeedablePseudoRNG(seed: 54321)) {
      try handler.handleToolCall(name: "draw_single_card", arguments: nil)
    }

    // Both should return the same card when using the same seed
    #expect(result1.content.count == 1)
    #expect(result2.content.count == 1)

    guard case .text(let message1) = result1.content[0],
          case .text(let message2) = result2.content[0] else {
      Issue.record("Expected text content from both results")
      return
    }
    #expect(message1 == message2)
    assertInlineSnapshot(of: message1, as: .lines) {
      """
      You drew:
      - The Fool
      """
    }
  }

  @Test("draw_multiple_cards tool with default count")
  func testDrawMultipleCardsDefault() throws {
    let handler = TarotServerHandler()

    let result = try TarotServerHandler.$rng.withValue(SeedablePseudoRNG(seed: 98765)) {
      try handler.handleToolCall(name: "draw_multiple_cards", arguments: nil)
    }

    #expect(result.content.count == 1)
    if case .text(let message) = result.content[0] {
      #expect(message.hasPrefix("You drew 3 cards:\n"))
      #expect(message.contains("- "))
      // Should have 3 cards (lines starting with "- ")
      let cardLines = message.components(separatedBy: "\n").filter { $0.hasPrefix("- ") }
      #expect(cardLines.count == 3)
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test("draw_multiple_cards tool with custom count")
  func testDrawMultipleCardsCustomCount() throws {
    let handler = TarotServerHandler()

    let arguments = ["count": Value.int(7)]
    let result = try TarotServerHandler.$rng.withValue(SeedablePseudoRNG(seed: 11111)) {
      try handler.handleToolCall(name: "draw_multiple_cards", arguments: arguments)
    }

    #expect(result.content.count == 1)
    if case .text(let message) = result.content[0] {
      #expect(message.hasPrefix("You drew 7 cards:\n"))
      let cardLines = message.components(separatedBy: "\n").filter { $0.hasPrefix("- ") }
      #expect(cardLines.count == 7)
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test("draw_multiple_cards tool throws errors for invalid counts")
  func testDrawMultipleCardsCountValidation() throws {
    let handler = TarotServerHandler()

    TarotServerHandler.$rng.withValue(SeedablePseudoRNG(seed: 22222)) {
      // Test upper bound validation
      let argumentsHigh = ["count": Value.int(79)]
      #expect(throws: TarotCardError.self) {
        try handler.handleToolCall(name: "draw_multiple_cards", arguments: argumentsHigh)
      }

      // Test lower bound validation
      let argumentsLow = ["count": Value.int(0)]
      #expect(throws: TarotCardError.self) {
        try handler.handleToolCall(name: "draw_multiple_cards", arguments: argumentsLow)
      }

      // Test negative values
      let argumentsNegative = ["count": Value.int(-5)]
      #expect(throws: TarotCardError.self) {
        try handler.handleToolCall(name: "draw_multiple_cards", arguments: argumentsNegative)
      }
    }
  }

  @Test(
    "draw_multiple_cards tool produces deterministic results",
    .taskLocal(TarotServerHandler.$rng, value: SeedablePseudoRNG(seed: 33333))
  )
  func drawMultipleCardsDeterministic() throws {
    let handler = TarotServerHandler()

    let result = try handler.handleToolCall(
      name: "draw_multiple_cards",
      arguments: ["count": Value.int(5)]
    )
    #expect(result.content.count == 1)
    guard case .text(let text) = result.content.first else {
      Issue.record("Expected text content")
      return
    }
    assertInlineSnapshot(of: text, as: .lines) {
      """
      You drew 5 cards:
      - The Fool
      - The Magician
      - Ten of Swords
      - The Chariot
      - Five of Pentacles
      """
    }
  }

  @Test("get_full_deck tool returns complete deck")
  func testGetFullDeckTool() throws {
    let handler = TarotServerHandler()

    let result = try handler.handleToolCall(name: "get_full_deck", arguments: nil)

    #expect(result.content.count == 1)
    if case .text(let message) = result.content[0] {
      #expect(message.hasPrefix("Full deck (78 cards):\n"))
      #expect(message.contains("- The Fool"))
      #expect(message.contains("- Ace of Wands"))
      #expect(message.contains("- King of Cups"))
      let cardLines = message.components(separatedBy: "\n").filter { $0.hasPrefix("- ") }
      #expect(cardLines.count == 78)
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test(
    "get_full_deck tool produces deterministic results",
    .repeat(count: 100)
  )
  func getFullDeckDeterministic() throws {
    let deckResult = try TarotServerHandler().handleToolCall(
      name: "get_full_deck",
      arguments: nil
    )
    let content = try #require(deckResult.content.first)
    guard case .text(let text) = content else {
      Issue.record("Expected text content")
      return
    }
    assertInlineSnapshot(of: text, as: .lines) {
      """
      Full deck (78 cards):
      - The Fool
      - The Magician
      - The High Priestess
      - The Empress
      - The Emperor
      - The Hierophant
      - The Lovers
      - The Chariot
      - Strength
      - The Hermit
      - Wheel of Fortune
      - Justice
      - The Hanged Man
      - Death
      - Temperance
      - The Devil
      - The Tower
      - The Star
      - The Moon
      - The Sun
      - Judgement
      - The World
      - Ace of Wands
      - Two of Wands
      - Three of Wands
      - Four of Wands
      - Five of Wands
      - Six of Wands
      - Seven of Wands
      - Eight of Wands
      - Nine of Wands
      - Ten of Wands
      - Page of Wands
      - Knight of Wands
      - Queen of Wands
      - King of Wands
      - Ace of Pentacles
      - Two of Pentacles
      - Three of Pentacles
      - Four of Pentacles
      - Five of Pentacles
      - Six of Pentacles
      - Seven of Pentacles
      - Eight of Pentacles
      - Nine of Pentacles
      - Ten of Pentacles
      - Page of Pentacles
      - Knight of Pentacles
      - Queen of Pentacles
      - King of Pentacles
      - Ace of Swords
      - Two of Swords
      - Three of Swords
      - Four of Swords
      - Five of Swords
      - Six of Swords
      - Seven of Swords
      - Eight of Swords
      - Nine of Swords
      - Ten of Swords
      - Page of Swords
      - Knight of Swords
      - Queen of Swords
      - King of Swords
      - Ace of Cups
      - Two of Cups
      - Three of Cups
      - Four of Cups
      - Five of Cups
      - Six of Cups
      - Seven of Cups
      - Eight of Cups
      - Nine of Cups
      - Ten of Cups
      - Page of Cups
      - Knight of Cups
      - Queen of Cups
      - King of Cups
      """
    }
  }

  @Test("unknown tool throws error")
  func testUnknownToolError() throws {
    let handler = TarotServerHandler()

    #expect(throws: MCPError.self) {
      try handler.handleToolCall(name: "unknown_tool", arguments: nil)
    }
  }

  @Test("getAvailableTools returns correct tool list")
  func testGetAvailableTools() {
    let tools = TarotServerHandler.getAvailableTools()

    #expect(tools.count == 3)

    let toolNames = tools.map { $0.name }
    #expect(toolNames.contains("draw_single_card"))
    #expect(toolNames.contains("draw_multiple_cards"))
    #expect(toolNames.contains("get_full_deck"))

    // Verify draw_multiple_cards has proper schema
    let drawMultipleTool = tools.first { $0.name == "draw_multiple_cards" }
    #expect(drawMultipleTool != nil)
    #expect(drawMultipleTool?.inputSchema != nil)
  }
}
