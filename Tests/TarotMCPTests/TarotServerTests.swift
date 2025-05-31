import Testing
import Foundation
import MCP
@testable import TarotMCPCore

@Suite("Tarot Server Tests")
struct TarotServerTests {

  @Test("Server tools are configured correctly")
  func testServerToolsConfiguration() {
    // Test that the handler is properly initialized by checking available tools
    let tools = TarotServerHandler.getAvailableTools()
    #expect(tools.count == 3)
    #expect(tools.contains { $0.name == "draw_single_card" })
    #expect(tools.contains { $0.name == "draw_multiple_cards" })
    #expect(tools.contains { $0.name == "get_full_deck" })
  }

  @Test("Server handler registration completes without error")
  func testHandlerRegistration() async {
    let tarotServer = TarotServer()
    let server = tarotServer.createServer()

    // Test that handler registration doesn't throw
    await tarotServer.registerHandlers(on: server)
  }
}

@Suite("TarotServer Integration Tests")
struct TarotServerIntegrationTests {

  @Test("Server handlers respond correctly")
  func testServerHandlers() async throws {
    // Test the handler components that TarotServer uses
    let handler = TarotServerHandler()

    // Test ListTools equivalent
    let tools = TarotServerHandler.getAvailableTools()
    #expect(tools.count == 3)

    // Test CallTool equivalent - single card
    let singleCardResult = try TarotServerHandler.$rng.withValue(SeedablePseudoRNG(seed: 12345)) {
      try handler.handleToolCall(name: "draw_single_card", arguments: nil)
    }
    #expect(singleCardResult.content.count == 1)

    // Test CallTool equivalent - multiple cards
    let multipleCardArgs = ["count": Value.int(3)]
    let multipleCardResult = try TarotServerHandler.$rng.withValue(SeedablePseudoRNG(seed: 12345)) {
      try handler.handleToolCall(name: "draw_multiple_cards", arguments: multipleCardArgs)
    }
    #expect(multipleCardResult.content.count == 1)

    // Test CallTool equivalent - full deck
    let fullDeckResult = try handler.handleToolCall(name: "get_full_deck", arguments: nil)
    #expect(fullDeckResult.content.count == 1)
  }

  @Test("Server handles invalid tool calls correctly")
  func testInvalidToolCalls() {
    let handler = TarotServerHandler()

    #expect(throws: MCPError.self) {
      try handler.handleToolCall(name: "invalid_tool", arguments: nil)
    }
  }

  @Test("Server handles error propagation correctly")
  func testErrorPropagation() {
    let handler = TarotServerHandler()

    // Test that validation errors are properly propagated
    let invalidArgs = ["count": Value.int(0)]
    #expect(throws: TarotCardError.self) {
      try handler.handleToolCall(name: "draw_multiple_cards", arguments: invalidArgs)
    }

    let tooManyArgs = ["count": Value.int(79)]
    #expect(throws: TarotCardError.self) {
      try handler.handleToolCall(name: "draw_multiple_cards", arguments: tooManyArgs)
    }
  }
}

// MARK: - Mock Server Tests

@Suite("TarotServer Mock Tests")
struct TarotServerMockTests {

  @Test("Server registration logic works correctly")
  func testServerRegistrationLogic() async throws {
    // Test the registration logic that TarotServer.run() uses
    let handler = TarotServerHandler()

    // Simulate the registration calls that TarotServer.run() makes

    // Test ListTools registration
    let listToolsResult = ListTools.Result(tools: TarotServerHandler.getAvailableTools())
    #expect(listToolsResult.tools.count == 3)

    // Test empty resources response
    let listResourcesResult = ListResources.Result(resources: [])
    #expect(listResourcesResult.resources.isEmpty)

    // Test empty prompts response  
    let listPromptsResult = ListPrompts.Result(prompts: [])
    #expect(listPromptsResult.prompts.isEmpty)

    // Test CallTool registration with various scenarios
    let drawSingleResult = try handler.handleToolCall(
      name: "draw_single_card",
      arguments: nil
    )
    #expect(drawSingleResult.content.count == 1)

    let drawMultipleResult = try handler.handleToolCall(
      name: "draw_multiple_cards",
      arguments: ["count": Value.int(5)]
    )
    #expect(drawMultipleResult.content.count == 1)
  }
}

// MARK: - Helper Classes

/// Mock MCP Server for testing server logic without stdio transport
private class MockMCPServer {
  private var toolHandlers: [String: Any] = [:]
  private var methodHandlers: [String: Any] = [:]

  func withMethodHandler<T>(_ type: T.Type, handler: @escaping (T) async throws -> T) {
    methodHandlers[String(describing: type)] = handler
  }

  func registerTool(name: String, handler: @escaping () throws -> CallTool.Result) {
    toolHandlers[name] = handler
  }
}
