import Foundation
import TarotMCPCore

@main
struct TarotMCPMain {
  static func main() async throws {
    do {
      let server = TarotServer()
      try await server.run()
    } catch {
      fputs("Error: \(error)\n", stderr)
      throw error
    }
  }
}
