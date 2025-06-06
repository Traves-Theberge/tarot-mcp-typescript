import Foundation
import MCP

public struct TarotServer: Sendable {
  private let handler = TarotServerHandler()

  public init() {}

  public func run(transport: any Transport = StdioTransport()) async throws {
    let server = createServer()
    await registerHandlers(on: server)
    try await server.start(transport: transport)
    await server.waitUntilCompleted()
  }

  // MARK: - Internal methods for testing

  internal func createServer() -> Server {
    return Server(
      name: "Tarot MCP Server",
      version: "1.0.0",
      capabilities: Server.Capabilities(
        tools: Server.Capabilities.Tools()
      ),
      configuration: .strict
    )
  }

  internal func registerHandlers(on server: Server) async {
    await server.withMethodHandler(ListTools.self) { _ in
      ListTools.Result(tools: TarotServerHandler.getAvailableTools())
    }

    await server.withMethodHandler(CallTool.self) { params in
      try await handler.handleToolCall(name: params.name, arguments: params.arguments)
    }

    await server.withMethodHandler(ListResources.self) { _ in
      ListResources.Result(resources: [])  // No resources available
    }

    await server.withMethodHandler(ListPrompts.self) { _ in
      ListPrompts.Result(prompts: [])
    }
  }
}
