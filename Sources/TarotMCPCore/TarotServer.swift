import Foundation
import Logging
import MCP

public actor TarotServer {
  private let handler: TarotServerHandler
  private let logger = Logger(label: "TarotServer")

  public init() {
    self.handler = TarotServerHandler()
  }

  internal init(handler: TarotServerHandler) {
    self.handler = handler
  }

  public func run(transport: any Transport = StdioTransport()) async throws {
    logger.info("Creating server...")
    let server = createServer()
    logger.info("Registering handlers...")
    await registerHandlers(on: server)
    logger.info("Starting server transport...")
    try await server.start(transport: transport)
    logger.info("Server started, waiting for completion...")
    await server.waitUntilCompleted()
  }

  // MARK: - Internal methods for testing

  internal func createServer() -> Server {
    return Server(
      name: "Tarot MCP Server",
      version: "1.0.0",
      capabilities: Server.Capabilities(
        resources: Server.Capabilities.Resources(),
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
      try await self.handler.handleToolCall(name: params.name, arguments: params.arguments)
    }

    await server.withMethodHandler(ListResources.self) { _ in
      ListResources.Result(resources: TarotServerHandler.getAvailableResources())
    }

    await server.withMethodHandler(ReadResource.self) { params in
      try await self.handler.readResource(uri: params.uri)
    }

    await server.withMethodHandler(ListPrompts.self) { _ in
      ListPrompts.Result(prompts: [])
    }
  }
}
