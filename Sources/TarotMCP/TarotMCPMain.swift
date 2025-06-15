import Foundation
import TarotMCPCore

@main
struct TarotMCPMain {
  static func main() async throws {
    let server = TarotServer()
    try await server.run()
  }
}
