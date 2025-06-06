import Foundation
import MCP
import Testing

@testable import TarotMCPCore

struct TarotServerErrorTests {
  @Test("TarotServer returns proper error message for invalid card count")
  func testCallToolInvalidCountErrorMessage() async throws {
    let mockTransport = MockTransport()
    let tarotServer = TarotServer()

    // Create MCP initialization sequence
    let initializeRequest = """
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05",\
      "capabilities":{"tools":{}},"clientInfo":{"name":"TestClient","version":"1.0.0"}}}
      """

    let initializedNotification = """
      {"jsonrpc":"2.0","method":"initialized","params":{}}
      """

    let callToolRequest = """
      {"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"draw_multiple_cards",\
      "arguments":{"count":0}}}
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

    // Verify at least one response contains the expected error message
    let responseStrings = sendCalls.map { String(data: $0, encoding: .utf8) ?? "" }

    // Check that we received a JSON-RPC error response for the invalid count
    let hasErrorResponse = responseStrings.contains { response in
      response.contains("Invalid card count")
        && response.contains("\"id\":2")  // This is our CallTool request ID
    }

    #expect(hasErrorResponse, "Expected to find JSON-RPC error response for TarotCardError")

    serverTask.cancel()
  }
}
