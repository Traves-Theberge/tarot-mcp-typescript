import Foundation
import Logging
import TarotMCPCore

@main
struct TarotMCPMain {
  static func main() async throws {
    let logger = Logger(label: "TarotMCPMain")
    
    do {
      logger.info("Starting Tarot MCP Server...")
      let server = TarotServer()
      logger.info("Server created, starting run...")
      try await server.run()
    } catch {
      logger.error("Server failed with error: \(error)")
      fputs("Error: \(error)\n", stderr)
      throw error
    }
  }
}
