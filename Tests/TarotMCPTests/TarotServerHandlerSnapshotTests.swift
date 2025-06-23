import Foundation
import InlineSnapshotTesting
import MCP
import Testing

@testable import TarotMCPCore

@Suite("Tarot Server Handler Snapshot Tests", .snapshots(record: .failed))
struct TarotServerHandlerSnapshotTests { // swiftlint:disable:this type_body_length

  @Test("get_full_deck tool produces deterministic results")
  func getFullDeckDeterministic() async throws { // swiftlint:disable:this function_body_length
    let deckResult = try await TarotServerHandler().handleToolCall(
      name: "get_full_deck",
      arguments: nil
    )
    let content = try #require(deckResult.content.first)
    guard case .text(let text) = content else {
      Issue.record("Expected text content")
      return
    }
    assertInlineSnapshot(of: text, as: .lines) {
      #"""
      [
        {
          "imageURI" : "tarot:\/\/card\/major\/0",
          "name" : "The Fool"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/1",
          "name" : "The Magician"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/2",
          "name" : "The High Priestess"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/3",
          "name" : "The Empress"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/4",
          "name" : "The Emperor"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/5",
          "name" : "The Hierophant"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/6",
          "name" : "The Lovers"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/7",
          "name" : "The Chariot"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/8",
          "name" : "Strength"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/9",
          "name" : "The Hermit"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/10",
          "name" : "Wheel of Fortune"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/11",
          "name" : "Justice"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/12",
          "name" : "The Hanged Man"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/13",
          "name" : "Death"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/14",
          "name" : "Temperance"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/15",
          "name" : "The Devil"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/16",
          "name" : "The Tower"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/17",
          "name" : "The Star"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/18",
          "name" : "The Moon"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/19",
          "name" : "The Sun"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/20",
          "name" : "Judgement"
        },
        {
          "imageURI" : "tarot:\/\/card\/major\/21",
          "name" : "The World"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/wands\/1",
          "name" : "Ace of Wands"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/wands\/2",
          "name" : "Two of Wands"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/wands\/3",
          "name" : "Three of Wands"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/wands\/4",
          "name" : "Four of Wands"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/wands\/5",
          "name" : "Five of Wands"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/wands\/6",
          "name" : "Six of Wands"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/wands\/7",
          "name" : "Seven of Wands"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/wands\/8",
          "name" : "Eight of Wands"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/wands\/9",
          "name" : "Nine of Wands"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/wands\/10",
          "name" : "Ten of Wands"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/wands\/11",
          "name" : "Page of Wands"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/wands\/12",
          "name" : "Knight of Wands"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/wands\/13",
          "name" : "Queen of Wands"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/wands\/14",
          "name" : "King of Wands"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/1",
          "name" : "Ace of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/2",
          "name" : "Two of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/3",
          "name" : "Three of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/4",
          "name" : "Four of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/5",
          "name" : "Five of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/6",
          "name" : "Six of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/7",
          "name" : "Seven of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/8",
          "name" : "Eight of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/9",
          "name" : "Nine of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/10",
          "name" : "Ten of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/11",
          "name" : "Page of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/12",
          "name" : "Knight of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/13",
          "name" : "Queen of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/14",
          "name" : "King of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/1",
          "name" : "Ace of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/2",
          "name" : "Two of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/3",
          "name" : "Three of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/4",
          "name" : "Four of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/5",
          "name" : "Five of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/6",
          "name" : "Six of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/7",
          "name" : "Seven of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/8",
          "name" : "Eight of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/9",
          "name" : "Nine of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/10",
          "name" : "Ten of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/11",
          "name" : "Page of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/12",
          "name" : "Knight of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/13",
          "name" : "Queen of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/14",
          "name" : "King of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/1",
          "name" : "Ace of Cups"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/2",
          "name" : "Two of Cups"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/3",
          "name" : "Three of Cups"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/4",
          "name" : "Four of Cups"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/5",
          "name" : "Five of Cups"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/6",
          "name" : "Six of Cups"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/7",
          "name" : "Seven of Cups"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/8",
          "name" : "Eight of Cups"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/9",
          "name" : "Nine of Cups"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/10",
          "name" : "Ten of Cups"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/11",
          "name" : "Page of Cups"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/12",
          "name" : "Knight of Cups"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/13",
          "name" : "Queen of Cups"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/14",
          "name" : "King of Cups"
        }
      ]
      """#
    }
  }

  @Test("draw_cards tool produces deterministic results")
  func drawCardsDeterministic() async throws {
    let handler = TarotServerHandler(rng: SeedablePseudoRNG(seed: 33333))

    let result = try await handler.handleToolCall(
      name: "draw_cards",
      arguments: ["count": Value.int(5)]
    )
    #expect(result.content.count == 1)
    guard case .text(let text) = result.content.first else {
      Issue.record("Expected text content")
      return
    }
    assertInlineSnapshot(of: text, as: .lines) {
      #"""
      [
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/2",
          "name" : "Two of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/pentacles\/12",
          "name" : "Knight of Pentacles"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/cups\/1",
          "name" : "Ace of Cups"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/9",
          "name" : "Nine of Swords"
        },
        {
          "imageURI" : "tarot:\/\/card\/minor\/swords\/7",
          "name" : "Seven of Swords"
        }
      ]
      """#
    }
  }
}
