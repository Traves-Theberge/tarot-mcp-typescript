import Testing
import Foundation
import MCP
@testable import TarotMCP

struct TarotServerHandlerTests {
  
  @Test("draw_single_card tool returns valid response")
  func testDrawSingleCardTool() throws {
    let service = TarotCardService()
    let handler = TarotServerHandler(cardService: service)
    
    let result = try handler.handleToolCall(name: "draw_single_card", arguments: nil)
    
    #expect(result.content.count == 1)
    if case .text(let message) = result.content[0] {
      #expect(message.contains("🔮 **"))
      #expect(message.contains("A tarot card has been drawn for you!"))
    } else {
      Issue.record("Expected text content")
    }
  }
  
  @Test("draw_single_card tool produces deterministic results")
  func testDrawSingleCardDeterministic() throws {
    let service = TarotCardService()
    let handler = TarotServerHandler(cardService: service)
    let seedableRng = SeedablePseudoRNG(seed: 54321)
    
    let result1 = try TarotServerHandler.$rng.withValue(seedableRng) {
      try handler.handleToolCall(name: "draw_single_card", arguments: nil)
    }
    
    let result2 = try TarotServerHandler.$rng.withValue(SeedablePseudoRNG(seed: 54321)) {
      try handler.handleToolCall(name: "draw_single_card", arguments: nil)
    }
    
    // Both should return the same card when using the same seed
    #expect(result1.content.count == 1)
    #expect(result2.content.count == 1)
    
    if case .text(let message1) = result1.content[0],
       case .text(let message2) = result2.content[0] {
      #expect(message1 == message2)
    } else {
      Issue.record("Expected text content from both results")
    }
  }
  
  @Test("draw_multiple_cards tool with default count")
  func testDrawMultipleCardsDefault() throws {
    let service = TarotCardService()
    let handler = TarotServerHandler(cardService: service)
    
    let result = try TarotServerHandler.$rng.withValue(SeedablePseudoRNG(seed: 98765)) {
      try handler.handleToolCall(name: "draw_multiple_cards", arguments: nil)
    }
    
    #expect(result.content.count == 1)
    if case .text(let message) = result.content[0] {
      #expect(message.contains("🔮 **Tarot Reading - 3 Cards**"))
      #expect(message.contains("• "))
      // Should have 3 bullet points for 3 cards
      let bulletCount = message.components(separatedBy: "• ").count - 1
      #expect(bulletCount == 3)
    } else {
      Issue.record("Expected text content")
    }
  }
  
  @Test("draw_multiple_cards tool with custom count")
  func testDrawMultipleCardsCustomCount() throws {
    let service = TarotCardService()
    let handler = TarotServerHandler(cardService: service)
    
    let arguments = ["count": Value.int(7)]
    let result = try TarotServerHandler.$rng.withValue(SeedablePseudoRNG(seed: 11111)) {
      try handler.handleToolCall(name: "draw_multiple_cards", arguments: arguments)
    }
    
    #expect(result.content.count == 1)
    if case .text(let message) = result.content[0] {
      #expect(message.contains("🔮 **Tarot Reading - 7 Cards**"))
      let bulletCount = message.components(separatedBy: "• ").count - 1
      #expect(bulletCount == 7)
    } else {
      Issue.record("Expected text content")
    }
  }
  
  @Test("draw_multiple_cards tool clamps count to valid range")
  func testDrawMultipleCardsCountClamping() throws {
    let service = TarotCardService()
    let handler = TarotServerHandler(cardService: service)
    
    let result = try TarotServerHandler.$rng.withValue(SeedablePseudoRNG(seed: 22222)) {
      // Test upper bound clamping
      let argumentsHigh = ["count": Value.int(25)]
      let resultHigh = try handler.handleToolCall(name: "draw_multiple_cards", arguments: argumentsHigh)
      
      if case .text(let messageHigh) = resultHigh.content[0] {
        #expect(messageHigh.contains("🔮 **Tarot Reading - 20 Cards**"))
      } else {
        Issue.record("Expected text content for high count")
      }
      
      // Test lower bound clamping  
      let argumentsLow = ["count": Value.int(-5)]
      let resultLow = try handler.handleToolCall(name: "draw_multiple_cards", arguments: argumentsLow)
      
      if case .text(let messageLow) = resultLow.content[0] {
        #expect(messageLow.contains("🔮 **Tarot Reading - 1 Cards**"))
      } else {
        Issue.record("Expected text content for low count")
      }
      
      return resultHigh
    }
    
    // Validate the return value
    #expect(result.content.count == 1)
  }
  
  @Test("get_full_deck tool returns complete deck")
  func testGetFullDeckTool() throws {
    let service = TarotCardService()
    let handler = TarotServerHandler(cardService: service)
    
    let result = try handler.handleToolCall(name: "get_full_deck", arguments: nil)
    
    #expect(result.content.count == 1)
    if case .text(let message) = result.content[0] {
      #expect(message.contains("🃏 **Complete Tarot Deck (78 cards)**"))
      #expect(message.contains("**Major Arcana (22 cards):**"))
      #expect(message.contains("**Minor Arcana (56 cards):**"))
      #expect(message.contains("The Fool"))
      #expect(message.contains("Ace of Wands"))
      #expect(message.contains("King of Cups"))
    } else {
      Issue.record("Expected text content")
    }
  }
  
  @Test("unknown tool throws error")
  func testUnknownToolError() throws {
    let service = TarotCardService()
    let handler = TarotServerHandler(cardService: service)
    
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

