import Foundation
import MCP
import Testing

@testable import TarotMCPCore

@Suite("TarotServer Configuration Tests")
struct TarotServerConfigurationTests {
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
}
