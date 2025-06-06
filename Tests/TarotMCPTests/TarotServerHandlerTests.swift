import Testing
import Foundation
import InlineSnapshotTesting
import MCP
@testable import TarotMCPCore

struct TarotToolRequestTests {
  @Test("init error description is good")
  func goodErrorDescription() throws {
    let error = try #require(throws: (any Swift.Error).self) {
      try TarotToolRequest(name: "draw_multiple_cards", arguments: ["count": .int(0)])
    }
    #expect(error.localizedDescription == "Invalid card count: 0. Count must be between 1 and 78.")
  }
}

struct TarotServerHandlerTests {
  @Test("draw_single_card tool returns valid response")
  func testDrawSingleCardTool() async throws {
    let handler = TarotServerHandler()

    let result = try await handler.handleToolCall(name: "draw_single_card", arguments: nil)

    #expect(result.content.count == 1)
    if case .text(let message) = result.content[0] {
      #expect(message.hasPrefix("You drew:\n- "))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test("draw_single_card tool produces deterministic results")
  func testDrawSingleCardDeterministic() async throws {
    let handler1 = TarotServerHandler(rng: SeedablePseudoRNG(seed: 54321))
    let handler2 = TarotServerHandler(rng: SeedablePseudoRNG(seed: 54321))

    let result1 = try await handler1.handleToolCall(name: "draw_single_card", arguments: nil)
    let result2 = try await handler2.handleToolCall(name: "draw_single_card", arguments: nil)

    // Both should return the same card when using the same seed
    #expect(result1.content.count == 1)
    #expect(result2.content.count == 1)

    guard
      case .text(let message1) = result1.content[0],
      case .text(let message2) = result2.content[0]
    else {
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
  func testDrawMultipleCardsDefault() async throws {
    let handler = TarotServerHandler(rng: SeedablePseudoRNG(seed: 98765))
    let result = try await handler.handleToolCall(name: "draw_multiple_cards", arguments: nil)

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
  func testDrawMultipleCardsCustomCount() async throws {
    let handler = TarotServerHandler(rng: SeedablePseudoRNG(seed: 11111))

    let arguments = ["count": Value.int(7)]
    let result = try await handler.handleToolCall(name: "draw_multiple_cards", arguments: arguments)

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
  func testDrawMultipleCardsCountValidation() async throws {
    let handler = TarotServerHandler(rng: SeedablePseudoRNG(seed: 22222))

    // Test upper bound validation
    let argumentsHigh = ["count": Value.int(79)]
    await #expect(throws: TarotCardError.self) {
      try await handler.handleToolCall(name: "draw_multiple_cards", arguments: argumentsHigh)
    }

    // Test lower bound validation
    let argumentsLow = ["count": Value.int(0)]
    await #expect(throws: TarotCardError.self) {
      try await handler.handleToolCall(name: "draw_multiple_cards", arguments: argumentsLow)
    }

    // Test negative values
    let argumentsNegative = ["count": Value.int(-5)]
    await #expect(throws: TarotCardError.self) {
      try await handler.handleToolCall(name: "draw_multiple_cards", arguments: argumentsNegative)
    }
  }

  @Test("get_full_deck tool returns complete deck")
  func testGetFullDeckTool() async throws {
    let handler = TarotServerHandler()

    let result = try await handler.handleToolCall(name: "get_full_deck", arguments: nil)

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

  @Test("unknown tool throws error")
  func testUnknownToolError() async throws {
    let handler = TarotServerHandler()

    await #expect(throws: MCPError.self) {
      try await handler.handleToolCall(name: "unknown_tool", arguments: nil)
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

  @Test("Server tools are configured correctly")
  func testServerToolsConfiguration() {
    // Test that the handler is properly initialized by checking available tools
    let tools = TarotServerHandler.getAvailableTools()
    #expect(tools.count == 3)
    #expect(tools.contains { $0.name == "draw_single_card" })
    #expect(tools.contains { $0.name == "draw_multiple_cards" })
    #expect(tools.contains { $0.name == "get_full_deck" })
  }

  @Test("Server handlers respond correctly")
  func testServerHandlers() async throws {
    // Test the handler components that TarotServer uses
    let handler = TarotServerHandler(rng: SeedablePseudoRNG(seed: 12345))

    // Test ListTools equivalent
    let tools = TarotServerHandler.getAvailableTools()
    #expect(tools.count == 3)

    // Test CallTool equivalent - single card
    let singleCardResult = try await handler.handleToolCall(name: "draw_single_card", arguments: nil)
    #expect(singleCardResult.content.count == 1)

    // Test CallTool equivalent - multiple cards
    let multipleCardArgs = ["count": Value.int(3)]
    let multipleCardResult = try await handler.handleToolCall(name: "draw_multiple_cards", arguments: multipleCardArgs)
    #expect(multipleCardResult.content.count == 1)

    // Test CallTool equivalent - full deck
    let fullDeckResult = try await handler.handleToolCall(name: "get_full_deck", arguments: nil)
    #expect(fullDeckResult.content.count == 1)
  }

  @Test("Server handles invalid tool calls correctly")
  func testInvalidToolCalls() async throws {
    let handler = TarotServerHandler()

    await #expect(throws: MCPError.self) {
      try await handler.handleToolCall(name: "invalid_tool", arguments: nil)
    }
  }

  @Test("Server handles error propagation correctly")
  func testErrorPropagation() async throws {
    let handler = TarotServerHandler()

    // Test that validation errors are properly propagated
    let invalidArgs = ["count": Value.int(0)]
    await #expect(throws: TarotCardError.self) {
      try await handler.handleToolCall(name: "draw_multiple_cards", arguments: invalidArgs)
    }

    let tooManyArgs = ["count": Value.int(79)]
    await #expect(throws: TarotCardError.self) {
      try await handler.handleToolCall(name: "draw_multiple_cards", arguments: tooManyArgs)
    }
  }

  @Test("Server registration logic works correctly")
  func testServerRegistrationLogic() async throws {
    // Test the registration logic that TarotServer.run() uses
    let handler = TarotServerHandler()

    // Test ListTools registration
    let tools = TarotServerHandler.getAvailableTools()
    #expect(tools.count == 3)

    // Test CallTool registration with various scenarios
    let drawSingleResult = try await handler.handleToolCall(
      name: "draw_single_card",
      arguments: nil
    )
    #expect(drawSingleResult.content.count == 1)

    let drawMultipleResult = try await handler.handleToolCall(
      name: "draw_multiple_cards",
      arguments: ["count": Value.int(5)]
    )
    #expect(drawMultipleResult.content.count == 1)
  }
}
