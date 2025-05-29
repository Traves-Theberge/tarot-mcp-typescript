import Foundation
import MCP

struct TarotServer {
  private let handler = TarotServerHandler()
  
  func run() async throws {
    let server = Server(
      name: "Tarot MCP Server",
      version: "1.0.0",
      capabilities: Server.Capabilities(
        tools: Server.Capabilities.Tools()
      )
    )

    // Register tools/list method
    await server.withMethodHandler(ListTools.self) { _ in
      ListTools.Result(tools: TarotServerHandler.getAvailableTools())
    }

    // Register tools/call method
    await server.withMethodHandler(CallTool.self) { params in
      try self.handler.handleToolCall(name: params.name, arguments: params.arguments)
    }

    // Start the server with stdio transport
    let transport = StdioTransport()
    try await server.start(transport: transport)
    await server.waitUntilCompleted()
  }
}
