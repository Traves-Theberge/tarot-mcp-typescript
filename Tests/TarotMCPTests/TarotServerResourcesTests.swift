import Foundation
import InlineSnapshotTesting
import MCP
import Testing

@testable import TarotMCPCore

@Suite("TarotServer Resources Tests", .snapshots(record: .failed))
struct TarotServerResourcesTests { // swiftlint:disable:this type_body_length
  @Test("TarotServer responds to ListResources MCP request with tarot card resources")
  func testListResourcesEndToEnd() async throws { // swiftlint:disable:this function_body_length
    let mockTransport = MockTransport()
    let tarotServer = TarotServer(handler: TarotServerHandler(rng: SeedablePseudoRNG(seed: 42)))

    // Create MCP initialization sequence
    let initializeRequest = """
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05",\
      "capabilities":{"resources":{}},"clientInfo":{"name":"TestClient","version":"1.0.0"}}}
      """

    let initializedNotification = """
      {"jsonrpc":"2.0","method":"initialized","params":{}}
      """

    let listResourcesRequest = """
      {"jsonrpc":"2.0","id":2,"method":"resources/list","params":{}}
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

    continuation.yield(try #require(listResourcesRequest.data(using: .utf8)))
    await Task.megaYield()

    continuation.finish()

    // Give the server extra time to process resources/list
    await Task.megaYield()
    await Task.megaYield()
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

    // Check the exact resources list response (id: 2)
    let responseStrings = sendCalls.map { String(data: $0, encoding: .utf8) ?? "" }
    let resourcesResponse = try #require(
      responseStrings.first { $0.contains(#""id":2"#) }
    )
    let data = Data(resourcesResponse.utf8)
    let decoded = try JSONSerialization.jsonObject(with: data, options: [])
    let reEncodedData = try JSONSerialization.data(
      withJSONObject: decoded,
      options: [.prettyPrinted, .sortedKeys]
    )
    let reEncodedString = String(decoding: reEncodedData, as: UTF8.self)

    assertInlineSnapshot(of: reEncodedString, as: .lines) {
      #"""
      {
        "id" : 2,
        "jsonrpc" : "2.0",
        "result" : {
          "resources" : [
            {
              "description" : "Image of the The Fool tarot card",
              "mimeType" : "image\/png",
              "name" : "The Fool Image",
              "uri" : "tarot:\/\/card\/major\/0"
            },
            {
              "description" : "Image of the The Magician tarot card",
              "mimeType" : "image\/png",
              "name" : "The Magician Image",
              "uri" : "tarot:\/\/card\/major\/1"
            },
            {
              "description" : "Image of the The High Priestess tarot card",
              "mimeType" : "image\/png",
              "name" : "The High Priestess Image",
              "uri" : "tarot:\/\/card\/major\/2"
            },
            {
              "description" : "Image of the The Empress tarot card",
              "mimeType" : "image\/png",
              "name" : "The Empress Image",
              "uri" : "tarot:\/\/card\/major\/3"
            },
            {
              "description" : "Image of the The Emperor tarot card",
              "mimeType" : "image\/png",
              "name" : "The Emperor Image",
              "uri" : "tarot:\/\/card\/major\/4"
            },
            {
              "description" : "Image of the The Hierophant tarot card",
              "mimeType" : "image\/png",
              "name" : "The Hierophant Image",
              "uri" : "tarot:\/\/card\/major\/5"
            },
            {
              "description" : "Image of the The Lovers tarot card",
              "mimeType" : "image\/png",
              "name" : "The Lovers Image",
              "uri" : "tarot:\/\/card\/major\/6"
            },
            {
              "description" : "Image of the The Chariot tarot card",
              "mimeType" : "image\/png",
              "name" : "The Chariot Image",
              "uri" : "tarot:\/\/card\/major\/7"
            },
            {
              "description" : "Image of the Strength tarot card",
              "mimeType" : "image\/png",
              "name" : "Strength Image",
              "uri" : "tarot:\/\/card\/major\/8"
            },
            {
              "description" : "Image of the The Hermit tarot card",
              "mimeType" : "image\/png",
              "name" : "The Hermit Image",
              "uri" : "tarot:\/\/card\/major\/9"
            },
            {
              "description" : "Image of the Wheel of Fortune tarot card",
              "mimeType" : "image\/png",
              "name" : "Wheel of Fortune Image",
              "uri" : "tarot:\/\/card\/major\/10"
            },
            {
              "description" : "Image of the Justice tarot card",
              "mimeType" : "image\/png",
              "name" : "Justice Image",
              "uri" : "tarot:\/\/card\/major\/11"
            },
            {
              "description" : "Image of the The Hanged Man tarot card",
              "mimeType" : "image\/png",
              "name" : "The Hanged Man Image",
              "uri" : "tarot:\/\/card\/major\/12"
            },
            {
              "description" : "Image of the Death tarot card",
              "mimeType" : "image\/png",
              "name" : "Death Image",
              "uri" : "tarot:\/\/card\/major\/13"
            },
            {
              "description" : "Image of the Temperance tarot card",
              "mimeType" : "image\/png",
              "name" : "Temperance Image",
              "uri" : "tarot:\/\/card\/major\/14"
            },
            {
              "description" : "Image of the The Devil tarot card",
              "mimeType" : "image\/png",
              "name" : "The Devil Image",
              "uri" : "tarot:\/\/card\/major\/15"
            },
            {
              "description" : "Image of the The Tower tarot card",
              "mimeType" : "image\/png",
              "name" : "The Tower Image",
              "uri" : "tarot:\/\/card\/major\/16"
            },
            {
              "description" : "Image of the The Star tarot card",
              "mimeType" : "image\/png",
              "name" : "The Star Image",
              "uri" : "tarot:\/\/card\/major\/17"
            },
            {
              "description" : "Image of the The Moon tarot card",
              "mimeType" : "image\/png",
              "name" : "The Moon Image",
              "uri" : "tarot:\/\/card\/major\/18"
            },
            {
              "description" : "Image of the The Sun tarot card",
              "mimeType" : "image\/png",
              "name" : "The Sun Image",
              "uri" : "tarot:\/\/card\/major\/19"
            },
            {
              "description" : "Image of the Judgement tarot card",
              "mimeType" : "image\/png",
              "name" : "Judgement Image",
              "uri" : "tarot:\/\/card\/major\/20"
            },
            {
              "description" : "Image of the The World tarot card",
              "mimeType" : "image\/png",
              "name" : "The World Image",
              "uri" : "tarot:\/\/card\/major\/21"
            },
            {
              "description" : "Image of the Ace of Wands tarot card",
              "mimeType" : "image\/png",
              "name" : "Ace of Wands Image",
              "uri" : "tarot:\/\/card\/minor\/wands\/1"
            },
            {
              "description" : "Image of the Two of Wands tarot card",
              "mimeType" : "image\/png",
              "name" : "Two of Wands Image",
              "uri" : "tarot:\/\/card\/minor\/wands\/2"
            },
            {
              "description" : "Image of the Three of Wands tarot card",
              "mimeType" : "image\/png",
              "name" : "Three of Wands Image",
              "uri" : "tarot:\/\/card\/minor\/wands\/3"
            },
            {
              "description" : "Image of the Four of Wands tarot card",
              "mimeType" : "image\/png",
              "name" : "Four of Wands Image",
              "uri" : "tarot:\/\/card\/minor\/wands\/4"
            },
            {
              "description" : "Image of the Five of Wands tarot card",
              "mimeType" : "image\/png",
              "name" : "Five of Wands Image",
              "uri" : "tarot:\/\/card\/minor\/wands\/5"
            },
            {
              "description" : "Image of the Six of Wands tarot card",
              "mimeType" : "image\/png",
              "name" : "Six of Wands Image",
              "uri" : "tarot:\/\/card\/minor\/wands\/6"
            },
            {
              "description" : "Image of the Seven of Wands tarot card",
              "mimeType" : "image\/png",
              "name" : "Seven of Wands Image",
              "uri" : "tarot:\/\/card\/minor\/wands\/7"
            },
            {
              "description" : "Image of the Eight of Wands tarot card",
              "mimeType" : "image\/png",
              "name" : "Eight of Wands Image",
              "uri" : "tarot:\/\/card\/minor\/wands\/8"
            },
            {
              "description" : "Image of the Nine of Wands tarot card",
              "mimeType" : "image\/png",
              "name" : "Nine of Wands Image",
              "uri" : "tarot:\/\/card\/minor\/wands\/9"
            },
            {
              "description" : "Image of the Ten of Wands tarot card",
              "mimeType" : "image\/png",
              "name" : "Ten of Wands Image",
              "uri" : "tarot:\/\/card\/minor\/wands\/10"
            },
            {
              "description" : "Image of the Page of Wands tarot card",
              "mimeType" : "image\/png",
              "name" : "Page of Wands Image",
              "uri" : "tarot:\/\/card\/minor\/wands\/11"
            },
            {
              "description" : "Image of the Knight of Wands tarot card",
              "mimeType" : "image\/png",
              "name" : "Knight of Wands Image",
              "uri" : "tarot:\/\/card\/minor\/wands\/12"
            },
            {
              "description" : "Image of the Queen of Wands tarot card",
              "mimeType" : "image\/png",
              "name" : "Queen of Wands Image",
              "uri" : "tarot:\/\/card\/minor\/wands\/13"
            },
            {
              "description" : "Image of the King of Wands tarot card",
              "mimeType" : "image\/png",
              "name" : "King of Wands Image",
              "uri" : "tarot:\/\/card\/minor\/wands\/14"
            },
            {
              "description" : "Image of the Ace of Pentacles tarot card",
              "mimeType" : "image\/png",
              "name" : "Ace of Pentacles Image",
              "uri" : "tarot:\/\/card\/minor\/pentacles\/1"
            },
            {
              "description" : "Image of the Two of Pentacles tarot card",
              "mimeType" : "image\/png",
              "name" : "Two of Pentacles Image",
              "uri" : "tarot:\/\/card\/minor\/pentacles\/2"
            },
            {
              "description" : "Image of the Three of Pentacles tarot card",
              "mimeType" : "image\/png",
              "name" : "Three of Pentacles Image",
              "uri" : "tarot:\/\/card\/minor\/pentacles\/3"
            },
            {
              "description" : "Image of the Four of Pentacles tarot card",
              "mimeType" : "image\/png",
              "name" : "Four of Pentacles Image",
              "uri" : "tarot:\/\/card\/minor\/pentacles\/4"
            },
            {
              "description" : "Image of the Five of Pentacles tarot card",
              "mimeType" : "image\/png",
              "name" : "Five of Pentacles Image",
              "uri" : "tarot:\/\/card\/minor\/pentacles\/5"
            },
            {
              "description" : "Image of the Six of Pentacles tarot card",
              "mimeType" : "image\/png",
              "name" : "Six of Pentacles Image",
              "uri" : "tarot:\/\/card\/minor\/pentacles\/6"
            },
            {
              "description" : "Image of the Seven of Pentacles tarot card",
              "mimeType" : "image\/png",
              "name" : "Seven of Pentacles Image",
              "uri" : "tarot:\/\/card\/minor\/pentacles\/7"
            },
            {
              "description" : "Image of the Eight of Pentacles tarot card",
              "mimeType" : "image\/png",
              "name" : "Eight of Pentacles Image",
              "uri" : "tarot:\/\/card\/minor\/pentacles\/8"
            },
            {
              "description" : "Image of the Nine of Pentacles tarot card",
              "mimeType" : "image\/png",
              "name" : "Nine of Pentacles Image",
              "uri" : "tarot:\/\/card\/minor\/pentacles\/9"
            },
            {
              "description" : "Image of the Ten of Pentacles tarot card",
              "mimeType" : "image\/png",
              "name" : "Ten of Pentacles Image",
              "uri" : "tarot:\/\/card\/minor\/pentacles\/10"
            },
            {
              "description" : "Image of the Page of Pentacles tarot card",
              "mimeType" : "image\/png",
              "name" : "Page of Pentacles Image",
              "uri" : "tarot:\/\/card\/minor\/pentacles\/11"
            },
            {
              "description" : "Image of the Knight of Pentacles tarot card",
              "mimeType" : "image\/png",
              "name" : "Knight of Pentacles Image",
              "uri" : "tarot:\/\/card\/minor\/pentacles\/12"
            },
            {
              "description" : "Image of the Queen of Pentacles tarot card",
              "mimeType" : "image\/png",
              "name" : "Queen of Pentacles Image",
              "uri" : "tarot:\/\/card\/minor\/pentacles\/13"
            },
            {
              "description" : "Image of the King of Pentacles tarot card",
              "mimeType" : "image\/png",
              "name" : "King of Pentacles Image",
              "uri" : "tarot:\/\/card\/minor\/pentacles\/14"
            },
            {
              "description" : "Image of the Ace of Swords tarot card",
              "mimeType" : "image\/png",
              "name" : "Ace of Swords Image",
              "uri" : "tarot:\/\/card\/minor\/swords\/1"
            },
            {
              "description" : "Image of the Two of Swords tarot card",
              "mimeType" : "image\/png",
              "name" : "Two of Swords Image",
              "uri" : "tarot:\/\/card\/minor\/swords\/2"
            },
            {
              "description" : "Image of the Three of Swords tarot card",
              "mimeType" : "image\/png",
              "name" : "Three of Swords Image",
              "uri" : "tarot:\/\/card\/minor\/swords\/3"
            },
            {
              "description" : "Image of the Four of Swords tarot card",
              "mimeType" : "image\/png",
              "name" : "Four of Swords Image",
              "uri" : "tarot:\/\/card\/minor\/swords\/4"
            },
            {
              "description" : "Image of the Five of Swords tarot card",
              "mimeType" : "image\/png",
              "name" : "Five of Swords Image",
              "uri" : "tarot:\/\/card\/minor\/swords\/5"
            },
            {
              "description" : "Image of the Six of Swords tarot card",
              "mimeType" : "image\/png",
              "name" : "Six of Swords Image",
              "uri" : "tarot:\/\/card\/minor\/swords\/6"
            },
            {
              "description" : "Image of the Seven of Swords tarot card",
              "mimeType" : "image\/png",
              "name" : "Seven of Swords Image",
              "uri" : "tarot:\/\/card\/minor\/swords\/7"
            },
            {
              "description" : "Image of the Eight of Swords tarot card",
              "mimeType" : "image\/png",
              "name" : "Eight of Swords Image",
              "uri" : "tarot:\/\/card\/minor\/swords\/8"
            },
            {
              "description" : "Image of the Nine of Swords tarot card",
              "mimeType" : "image\/png",
              "name" : "Nine of Swords Image",
              "uri" : "tarot:\/\/card\/minor\/swords\/9"
            },
            {
              "description" : "Image of the Ten of Swords tarot card",
              "mimeType" : "image\/png",
              "name" : "Ten of Swords Image",
              "uri" : "tarot:\/\/card\/minor\/swords\/10"
            },
            {
              "description" : "Image of the Page of Swords tarot card",
              "mimeType" : "image\/png",
              "name" : "Page of Swords Image",
              "uri" : "tarot:\/\/card\/minor\/swords\/11"
            },
            {
              "description" : "Image of the Knight of Swords tarot card",
              "mimeType" : "image\/png",
              "name" : "Knight of Swords Image",
              "uri" : "tarot:\/\/card\/minor\/swords\/12"
            },
            {
              "description" : "Image of the Queen of Swords tarot card",
              "mimeType" : "image\/png",
              "name" : "Queen of Swords Image",
              "uri" : "tarot:\/\/card\/minor\/swords\/13"
            },
            {
              "description" : "Image of the King of Swords tarot card",
              "mimeType" : "image\/png",
              "name" : "King of Swords Image",
              "uri" : "tarot:\/\/card\/minor\/swords\/14"
            },
            {
              "description" : "Image of the Ace of Cups tarot card",
              "mimeType" : "image\/png",
              "name" : "Ace of Cups Image",
              "uri" : "tarot:\/\/card\/minor\/cups\/1"
            },
            {
              "description" : "Image of the Two of Cups tarot card",
              "mimeType" : "image\/png",
              "name" : "Two of Cups Image",
              "uri" : "tarot:\/\/card\/minor\/cups\/2"
            },
            {
              "description" : "Image of the Three of Cups tarot card",
              "mimeType" : "image\/png",
              "name" : "Three of Cups Image",
              "uri" : "tarot:\/\/card\/minor\/cups\/3"
            },
            {
              "description" : "Image of the Four of Cups tarot card",
              "mimeType" : "image\/png",
              "name" : "Four of Cups Image",
              "uri" : "tarot:\/\/card\/minor\/cups\/4"
            },
            {
              "description" : "Image of the Five of Cups tarot card",
              "mimeType" : "image\/png",
              "name" : "Five of Cups Image",
              "uri" : "tarot:\/\/card\/minor\/cups\/5"
            },
            {
              "description" : "Image of the Six of Cups tarot card",
              "mimeType" : "image\/png",
              "name" : "Six of Cups Image",
              "uri" : "tarot:\/\/card\/minor\/cups\/6"
            },
            {
              "description" : "Image of the Seven of Cups tarot card",
              "mimeType" : "image\/png",
              "name" : "Seven of Cups Image",
              "uri" : "tarot:\/\/card\/minor\/cups\/7"
            },
            {
              "description" : "Image of the Eight of Cups tarot card",
              "mimeType" : "image\/png",
              "name" : "Eight of Cups Image",
              "uri" : "tarot:\/\/card\/minor\/cups\/8"
            },
            {
              "description" : "Image of the Nine of Cups tarot card",
              "mimeType" : "image\/png",
              "name" : "Nine of Cups Image",
              "uri" : "tarot:\/\/card\/minor\/cups\/9"
            },
            {
              "description" : "Image of the Ten of Cups tarot card",
              "mimeType" : "image\/png",
              "name" : "Ten of Cups Image",
              "uri" : "tarot:\/\/card\/minor\/cups\/10"
            },
            {
              "description" : "Image of the Page of Cups tarot card",
              "mimeType" : "image\/png",
              "name" : "Page of Cups Image",
              "uri" : "tarot:\/\/card\/minor\/cups\/11"
            },
            {
              "description" : "Image of the Knight of Cups tarot card",
              "mimeType" : "image\/png",
              "name" : "Knight of Cups Image",
              "uri" : "tarot:\/\/card\/minor\/cups\/12"
            },
            {
              "description" : "Image of the Queen of Cups tarot card",
              "mimeType" : "image\/png",
              "name" : "Queen of Cups Image",
              "uri" : "tarot:\/\/card\/minor\/cups\/13"
            },
            {
              "description" : "Image of the King of Cups tarot card",
              "mimeType" : "image\/png",
              "name" : "King of Cups Image",
              "uri" : "tarot:\/\/card\/minor\/cups\/14"
            }
          ]
        }
      }
      """#
    }

    serverTask.cancel()
  }
}
