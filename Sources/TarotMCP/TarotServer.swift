import Foundation
import Logging
import MCP

struct TarotServer {
  private let handler = TarotServerHandler()
  
  func run() async throws {
//    LoggingSystem.bootstrap { label in
//      StreamLogHandler.standardError(label: label)
//    }

    let server = Server(
      name: "Tarot MCP Server",
      version: "1.0.0",
      capabilities: Server.Capabilities(
        tools: Server.Capabilities.Tools()
      ),
      configuration: .strict
    )

    // Register tools/list method
    await server.withMethodHandler(ListTools.self) { _ in
      ListTools.Result(tools: TarotServerHandler.getAvailableTools())
    }

    // Register tools/call method
    await server.withMethodHandler(CallTool.self) { params in
      try self.handler.handleToolCall(name: params.name, arguments: params.arguments)
    }
    
    // Register resources/list method (empty response since we don't provide resources)
    await server.withMethodHandler(ListResources.self) { _ in
      ListResources.Result(resources: []) // No resources available
    }
    
    // Register prompts/list method (empty response since we don't provide prompts)
    await server.withMethodHandler(ListPrompts.self) { x in
      return ListPrompts.Result.init(prompts: [])
    }

    // Start the server with stdio transport
    let transport = StdioTransport()
    try await server.start(transport: transport)
    await server.waitUntilCompleted()
  }
}
