import Foundation
import MCP
import Testing

@testable import TarotMCPCore

struct TarotServerTests {
  @Test("TarotServer creates server with correct configuration")
  func testCreateServer() async {
    let tarotServer = TarotServer()
    let server = await tarotServer.createServer()

    #expect(server.name == "Tarot MCP Server")
    #expect(server.version == "1.0.0")
    #expect(await server.capabilities.tools != nil)
    #expect(await server.configuration == .strict)
  }

  @Test("TarotServer registers all required handlers")
  func testRegisterHandlers() async {
    let tarotServer = TarotServer()
    let server = await tarotServer.createServer()

    await tarotServer.registerHandlers(on: server)

    // The server should have handlers registered, but we can't directly inspect them
    // This test mainly ensures no exceptions are thrown during registration
  }

  @Test("TarotServer run method connects and starts server")
  func testRunWithMockTransport() async throws {
    let mockTransport = MockTransport()
    let tarotServer = TarotServer()

    // Create a stream that immediately ends to allow the server to complete
    let (stream, continuation) = AsyncThrowingStream<Data, Swift.Error>.makeStream()
    await mockTransport.setStream(stream)
    continuation.finish()

    try await tarotServer.run(transport: mockTransport)

    let calls = await mockTransport.calls
    #expect(calls.contains(.connect))
    #expect(calls.contains(.receive))
  }

  @Test("TarotServer handles transport disconnection gracefully")
  func testRunWithTransportError() async throws {
    let mockTransport = MockTransport()
    let tarotServer = TarotServer()

    // Create a stream that throws an error
    let (stream, continuation) = AsyncThrowingStream<Data, Swift.Error>.makeStream()
    await mockTransport.setStream(stream)
    continuation.finish(throwing: MockTransport.Failure.streamNotSet)

    // The server should handle the error gracefully
    try await tarotServer.run(transport: mockTransport)

    let calls = await mockTransport.calls
    #expect(calls.contains(.connect))
    #expect(calls.contains(.receive))
  }

  @Test("TarotServer responds to ListTools MCP request")
  func testListToolsEndToEnd() async throws {
    let mockTransport = MockTransport()
    let tarotServer = TarotServer()

    // Create MCP initialization sequence
    let initializeRequest = """
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05",
      "capabilities":{"tools":{}},"clientInfo":{"name":"TestClient","version":"1.0.0"}}}
      """

    let initializedNotification = """
      {"jsonrpc":"2.0","method":"initialized","params":{}}
      """

    let listToolsRequest = """
      {"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}
      """

    // Create stream that provides the requests and captures responses
    let (stream, continuation) = AsyncThrowingStream<Data, Swift.Error>.makeStream()
    await mockTransport.setStream(stream)

    // Start the server
    let serverTask = Task {
      try await tarotServer.run(transport: mockTransport)
    }

    // Send initialization sequence
    continuation.yield(try #require(initializeRequest.data(using: .utf8)))
    await Task.megaYield()

    continuation.yield(try #require(initializedNotification.data(using: .utf8)))
    await Task.megaYield()

    continuation.yield(try #require(listToolsRequest.data(using: .utf8)))
    await Task.megaYield()

    continuation.finish()

    // Give the server time to process
    await Task.megaYield()

    // Check that the transport received calls
    let calls = await mockTransport.calls
    #expect(calls.contains(.connect))
    #expect(calls.contains(.receive))

    // Check for send calls containing the response
    let sendCalls = calls.compactMap { call in
      if case .send(let data) = call { return data }
      return nil
    }

    #expect(!sendCalls.isEmpty, "Expected at least one response to be sent")

    // Verify at least one response contains the expected tools
    let responseStrings = sendCalls.map { String(data: $0, encoding: .utf8) ?? "" }
    let hasToolsResponse = responseStrings.contains { response in
      response.contains("draw_single_card") && response.contains("draw_multiple_cards")
        && response.contains("get_full_deck")
    }

    #expect(hasToolsResponse, "Expected to find a response containing all three tools")

    serverTask.cancel()
  }

  @Test("TarotServer responds to CallTool MCP request")
  func testCallToolEndToEnd() async throws {
    let mockTransport = MockTransport()
    let tarotServer = TarotServer()

    // Create MCP initialization sequence
    let initializeRequest = """
      {"jsonrpc":"2.0","id":1,"method":"initialize",\
      "params":{"protocolVersion":"2024-11-05","capabilities":{"tools":{}},\
      "clientInfo":{"name":"TestClient","version":"1.0.0"}}}
      """

    let initializedNotification = """
      {"jsonrpc":"2.0","method":"initialized","params":{}}
      """

    let callToolRequest = """
      {"jsonrpc":"2.0","id":2,"method":"tools/call",\
      "params":{"name":"draw_single_card","arguments":{}}}
      """

    // Create stream that provides the requests and captures responses
    let (stream, continuation) = AsyncThrowingStream<Data, Swift.Error>.makeStream()
    await mockTransport.setStream(stream)

    // Start the server
    let serverTask = Task {
      try await tarotServer.run(transport: mockTransport)
    }

    // Send initialization sequence
    continuation.yield(try #require(initializeRequest.data(using: .utf8)))
    await Task.megaYield()

    continuation.yield(try #require(initializedNotification.data(using: .utf8)))
    await Task.megaYield()

    continuation.yield(try #require(callToolRequest.data(using: .utf8)))
    await Task.megaYield()

    continuation.finish()

    // Give the server time to process
    await Task.megaYield()

    // Check that the transport received calls
    let calls = await mockTransport.calls
    #expect(calls.contains(.connect))
    #expect(calls.contains(.receive))

    // Check for send calls containing the response
    let sendCalls = calls.compactMap { call in
      if case .send(let data) = call { return data }
      return nil
    }

    #expect(!sendCalls.isEmpty, "Expected at least one response to be sent")

    // Verify at least one response contains a tarot card draw result
    let responseStrings = sendCalls.map { String(data: $0, encoding: .utf8) ?? "" }
    let hasCardResponse = responseStrings.contains { response in
      response.contains("You drew:") && response.contains("result")
    }

    #expect(hasCardResponse, "Expected to find a response containing tarot card draw result")

    serverTask.cancel()
  }

  @Test("TarotServer responds to ListResources MCP request with empty list")
  func testListResourcesEndToEnd() async throws {
    let mockTransport = MockTransport()
    let tarotServer = TarotServer()

    // Create MCP initialization sequence
    let initializeRequest = """
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05",\
      "capabilities":{"resources":{}},"clientInfo":{"name":"TestClient","version":"1.0.0"}}}
      """

    let initializedNotification = """
      {"jsonrpc":"2.0","method":"initialized","params":{}}
      """

    let listResourcesRequest = """
      {"jsonrpc":"2.0","id":2,"method":"resources/list","params":{}}
      """

    // Create stream that provides the requests and captures responses
    let (stream, continuation) = AsyncThrowingStream<Data, Swift.Error>.makeStream()
    await mockTransport.setStream(stream)

    // Start the server
    let serverTask = Task {
      try await tarotServer.run(transport: mockTransport)
    }

    // Send initialization sequence
    continuation.yield(try #require(initializeRequest.data(using: .utf8)))
    await Task.megaYield()

    continuation.yield(try #require(initializedNotification.data(using: .utf8)))
    await Task.megaYield()

    continuation.yield(try #require(listResourcesRequest.data(using: .utf8)))
    await Task.megaYield()

    continuation.finish()

    // Give the server time to process
    await Task.megaYield()

    // Check that the transport received calls
    let calls = await mockTransport.calls
    #expect(calls.contains(.connect))
    #expect(calls.contains(.receive))

    // Check for send calls containing the response
    let sendCalls = calls.compactMap { call in
      if case .send(let data) = call { return data }
      return nil
    }

    #expect(!sendCalls.isEmpty, "Expected at least one response to be sent")

    // Verify at least one response contains empty resources list
    let responseStrings = sendCalls.map { String(data: $0, encoding: .utf8) ?? "" }
    let hasEmptyResourcesResponse = responseStrings.contains { response in
      response.contains("resources") && response.contains("[]")
    }

    #expect(
      hasEmptyResourcesResponse, "Expected to find a response containing empty resources list")

    serverTask.cancel()
  }

  @Test("TarotServer responds to ListPrompts MCP request with empty list")
  func testListPromptsEndToEnd() async throws {
    let mockTransport = MockTransport()
    let tarotServer = TarotServer()

    // Create MCP initialization sequence
    let initializeRequest = """
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05",\
      "capabilities":{"prompts":{}},"clientInfo":{"name":"TestClient","version":"1.0.0"}}}
      """

    let initializedNotification = """
      {"jsonrpc":"2.0","method":"initialized","params":{}}
      """

    let listPromptsRequest = """
      {"jsonrpc":"2.0","id":2,"method":"prompts/list","params":{}}
      """

    // Create stream that provides the requests and captures responses
    let (stream, continuation) = AsyncThrowingStream<Data, Swift.Error>.makeStream()
    await mockTransport.setStream(stream)

    // Start the server
    let serverTask = Task {
      try await tarotServer.run(transport: mockTransport)
    }

    // Send initialization sequence
    continuation.yield(try #require(initializeRequest.data(using: .utf8)))
    await Task.megaYield()

    continuation.yield(try #require(initializedNotification.data(using: .utf8)))
    await Task.megaYield()

    continuation.yield(try #require(listPromptsRequest.data(using: .utf8)))
    await Task.megaYield()

    continuation.finish()

    // Give the server time to process
    await Task.megaYield()

    // Check that the transport received calls
    let calls = await mockTransport.calls
    #expect(calls.contains(.connect))
    #expect(calls.contains(.receive))

    // Check for send calls containing the response
    let sendCalls = calls.compactMap { call in
      if case .send(let data) = call { return data }
      return nil
    }

    #expect(!sendCalls.isEmpty, "Expected at least one response to be sent")

    // Verify at least one response contains empty prompts list
    let responseStrings = sendCalls.map { String(data: $0, encoding: .utf8) ?? "" }
    let hasEmptyPromptsResponse = responseStrings.contains { response in
      response.contains("prompts") && response.contains("[]")
    }

    #expect(hasEmptyPromptsResponse, "Expected to find a response containing empty prompts list")

    serverTask.cancel()
  }
}
