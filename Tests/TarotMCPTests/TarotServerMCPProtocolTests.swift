import Foundation
import InlineSnapshotTesting
import MCP
import Testing

@testable import TarotMCPCore

@Suite("TarotServer MCP Protocol Tests", .snapshots(record: .failed))
struct TarotServerMCPProtocolTests {
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
      response.contains("draw_cards") && response.contains("get_full_deck")
    }

    #expect(hasToolsResponse, "Expected to find a response containing both tools")

    serverTask.cancel()
  }

  @Test("TarotServer responds to CallTool MCP request")
  func testCallToolEndToEnd() async throws {
    let mockTransport = MockTransport()
    let tarotServer = TarotServer(handler: TarotServerHandler(rng: SeedablePseudoRNG(seed: 42)))

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
      "params":{"name":"draw_cards","arguments":{}}}
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

    // Check the exact tool call response (id: 2) with deterministic output
    let responseStrings = sendCalls.map { String(data: $0, encoding: .utf8) ?? "" }
    let toolCallResponse = try #require(
      responseStrings.first { $0.contains(#""id":2"#) }
    )

    // swiftlint:disable line_length
    assertInlineSnapshot(of: toolCallResponse, as: .lines) {
      #"""
      {"id":2,"jsonrpc":"2.0","result":{"content":[{"text":"[\n  {\n    \"imageURI\" : \"tarot:\\/\\/card\\/major\\/5\",\n    \"name\" : \"The Hierophant\"\n  }\n]","type":"text"}]}}
      """#
    }
    // swiftlint:enable line_length

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
