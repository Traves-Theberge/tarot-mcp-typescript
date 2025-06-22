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
          "image" : "tarot:\/\/card\/major\/0",
          "name" : "The Fool"
        },
        {
          "image" : "tarot:\/\/card\/major\/1",
          "name" : "The Magician"
        },
        {
          "image" : "tarot:\/\/card\/major\/2",
          "name" : "The High Priestess"
        },
        {
          "image" : "tarot:\/\/card\/major\/3",
          "name" : "The Empress"
        },
        {
          "image" : "tarot:\/\/card\/major\/4",
          "name" : "The Emperor"
        },
        {
          "image" : "tarot:\/\/card\/major\/5",
          "name" : "The Hierophant"
        },
        {
          "image" : "tarot:\/\/card\/major\/6",
          "name" : "The Lovers"
        },
        {
          "image" : "tarot:\/\/card\/major\/7",
          "name" : "The Chariot"
        },
        {
          "image" : "tarot:\/\/card\/major\/8",
          "name" : "Strength"
        },
        {
          "image" : "tarot:\/\/card\/major\/9",
          "name" : "The Hermit"
        },
        {
          "image" : "tarot:\/\/card\/major\/10",
          "name" : "Wheel of Fortune"
        },
        {
          "image" : "tarot:\/\/card\/major\/11",
          "name" : "Justice"
        },
        {
          "image" : "tarot:\/\/card\/major\/12",
          "name" : "The Hanged Man"
        },
        {
          "image" : "tarot:\/\/card\/major\/13",
          "name" : "Death"
        },
        {
          "image" : "tarot:\/\/card\/major\/14",
          "name" : "Temperance"
        },
        {
          "image" : "tarot:\/\/card\/major\/15",
          "name" : "The Devil"
        },
        {
          "image" : "tarot:\/\/card\/major\/16",
          "name" : "The Tower"
        },
        {
          "image" : "tarot:\/\/card\/major\/17",
          "name" : "The Star"
        },
        {
          "image" : "tarot:\/\/card\/major\/18",
          "name" : "The Moon"
        },
        {
          "image" : "tarot:\/\/card\/major\/19",
          "name" : "The Sun"
        },
        {
          "image" : "tarot:\/\/card\/major\/20",
          "name" : "Judgement"
        },
        {
          "image" : "tarot:\/\/card\/major\/21",
          "name" : "The World"
        },
        {
          "image" : "tarot:\/\/card\/minor\/wands\/1",
          "name" : "Ace of Wands"
        },
        {
          "image" : "tarot:\/\/card\/minor\/wands\/2",
          "name" : "Two of Wands"
        },
        {
          "image" : "tarot:\/\/card\/minor\/wands\/3",
          "name" : "Three of Wands"
        },
        {
          "image" : "tarot:\/\/card\/minor\/wands\/4",
          "name" : "Four of Wands"
        },
        {
          "image" : "tarot:\/\/card\/minor\/wands\/5",
          "name" : "Five of Wands"
        },
        {
          "image" : "tarot:\/\/card\/minor\/wands\/6",
          "name" : "Six of Wands"
        },
        {
          "image" : "tarot:\/\/card\/minor\/wands\/7",
          "name" : "Seven of Wands"
        },
        {
          "image" : "tarot:\/\/card\/minor\/wands\/8",
          "name" : "Eight of Wands"
        },
        {
          "image" : "tarot:\/\/card\/minor\/wands\/9",
          "name" : "Nine of Wands"
        },
        {
          "image" : "tarot:\/\/card\/minor\/wands\/10",
          "name" : "Ten of Wands"
        },
        {
          "image" : "tarot:\/\/card\/minor\/wands\/11",
          "name" : "Page of Wands"
        },
        {
          "image" : "tarot:\/\/card\/minor\/wands\/12",
          "name" : "Knight of Wands"
        },
        {
          "image" : "tarot:\/\/card\/minor\/wands\/13",
          "name" : "Queen of Wands"
        },
        {
          "image" : "tarot:\/\/card\/minor\/wands\/14",
          "name" : "King of Wands"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/1",
          "name" : "Ace of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/2",
          "name" : "Two of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/3",
          "name" : "Three of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/4",
          "name" : "Four of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/5",
          "name" : "Five of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/6",
          "name" : "Six of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/7",
          "name" : "Seven of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/8",
          "name" : "Eight of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/9",
          "name" : "Nine of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/10",
          "name" : "Ten of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/11",
          "name" : "Page of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/12",
          "name" : "Knight of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/13",
          "name" : "Queen of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/14",
          "name" : "King of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/1",
          "name" : "Ace of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/2",
          "name" : "Two of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/3",
          "name" : "Three of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/4",
          "name" : "Four of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/5",
          "name" : "Five of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/6",
          "name" : "Six of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/7",
          "name" : "Seven of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/8",
          "name" : "Eight of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/9",
          "name" : "Nine of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/10",
          "name" : "Ten of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/11",
          "name" : "Page of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/12",
          "name" : "Knight of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/13",
          "name" : "Queen of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/14",
          "name" : "King of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/1",
          "name" : "Ace of Cups"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/2",
          "name" : "Two of Cups"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/3",
          "name" : "Three of Cups"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/4",
          "name" : "Four of Cups"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/5",
          "name" : "Five of Cups"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/6",
          "name" : "Six of Cups"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/7",
          "name" : "Seven of Cups"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/8",
          "name" : "Eight of Cups"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/9",
          "name" : "Nine of Cups"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/10",
          "name" : "Ten of Cups"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/11",
          "name" : "Page of Cups"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/12",
          "name" : "Knight of Cups"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/13",
          "name" : "Queen of Cups"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/14",
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
          "image" : "tarot:\/\/card\/minor\/pentacles\/2",
          "name" : "Two of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/pentacles\/12",
          "name" : "Knight of Pentacles"
        },
        {
          "image" : "tarot:\/\/card\/minor\/cups\/1",
          "name" : "Ace of Cups"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/9",
          "name" : "Nine of Swords"
        },
        {
          "image" : "tarot:\/\/card\/minor\/swords\/7",
          "name" : "Seven of Swords"
        }
      ]
      """#
    }
  }
}
