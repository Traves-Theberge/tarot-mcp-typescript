import InlineSnapshotTesting
import SnapshotTestingCustomDump
import Testing

@testable import TarotMCPCore

@Suite("Tarot Deck Tests")
struct TarotDeckTests {

  @Test("Full deck has exactly 78 cards")
  func fullDeckCount() {
    #expect(TarotDeck.fullDeck.count == 78)
  }

  @Test("Full deck contains all 22 Major Arcana cards")
  func fullDeckMajorArcana() {
    let majorCards = TarotDeck.fullDeck.compactMap { card in
      if case .major(let arcana) = card {
        return arcana
      }
      return nil
    }

    #expect(majorCards.count == 22)
    #expect(MajorArcana.allCases.count == 22)

    // Check that all Major Arcana are present
    for expectedArcana in MajorArcana.allCases {
      #expect(majorCards.contains(expectedArcana))
    }
  }

  @Test("Full deck contains all 56 Minor Arcana cards")
  func fullDeckMinorArcana() {
    let minorCards = TarotDeck.fullDeck.compactMap { card in
      if case .minor(let minorArcana) = card {
        return minorArcana
      }
      return nil
    }

    #expect(minorCards.count == 56)
    #expect(MinorArcana.allCases.count == 56)
    #expect(MinorArcana.Suit.allCases.count == 4)
    #expect(MinorArcana.Value.allCases.count == 14)

    // Check that all combinations of suits and values are present
    for suit in MinorArcana.Suit.allCases {
      for value in MinorArcana.Value.allCases {
        let expectedCard = MinorArcana(suit: suit, value: value)
        #expect(
          minorCards.contains { card in
            card.suit == expectedCard.suit && card.value == expectedCard.value
          },
          "Missing \(expectedCard.name)"
        )
      }
    }
  }

  @Test("drawCards with count=1 returns a valid card from the deck", .repeat(count: 10))
  func drawRandomCard() {
    var rng = SystemRandomNumberGenerator()
    let cards = TarotDeck.drawCards(count: 1, using: &rng)
    #expect(cards.count == 1)
    #expect(TarotDeck.fullDeck.contains(cards[0]))
  }

  @Test("drawCards returns correct number of cards", .repeat(count: 10))
  func drawCardsCount() {
    var rng = SystemRandomNumberGenerator()
    let oneCard = TarotDeck.drawCards(count: 1, using: &rng)
    #expect(oneCard.count == 1)

    let threeCards = TarotDeck.drawCards(count: 3, using: &rng)
    #expect(threeCards.count == 3)

    let tenCards = TarotDeck.drawCards(count: 10, using: &rng)
    #expect(tenCards.count == 10)
  }

  private let fullDeckNames = Set(TarotDeck.fullDeck.lazy.map(\.name))

  @Test("drawCards returns valid cards from the deck", .repeat(count: 10))
  func drawCardsValid() {
    var rng = SystemRandomNumberGenerator()
    let cards = TarotDeck.drawCards(count: 5, using: &rng)

    for card in cards {
      #expect(fullDeckNames.contains(card.name))
    }
  }

  @Test("drawCards with count larger than deck returns all cards")
  func drawCardsLargeCount() {
    var rng = SystemRandomNumberGenerator()
    let allCards = TarotDeck.drawCards(count: 100, using: &rng)
    #expect(allCards.count == 78)
  }

  @Test("drawCards with zero count returns empty array")
  func drawCardsZeroCount() {
    var rng = SystemRandomNumberGenerator()
    let noCards = TarotDeck.drawCards(count: 0, using: &rng)
    #expect(noCards.isEmpty)
  }

  @Test("drawRandomCard with seeded RNG is deterministic")
  func drawRandomCardDeterministic() {
    var rng1 = SeedablePseudoRNG(seed: 42)
    var rng2 = SeedablePseudoRNG(seed: 42)

    let card1 = TarotDeck.drawCards(count: 1, using: &rng1)[0]
    let card2 = TarotDeck.drawCards(count: 1, using: &rng2)[0]

    #expect(card1.name == card2.name)
  }

  @Test("drawCards with seeded RNG is deterministic", .repeat(count: 10))
  func drawCardsDeterministic() {
    let seed = UInt64.random(in: .min ... .max)
    var rng1 = SeedablePseudoRNG(seed: seed)
    var rng2 = SeedablePseudoRNG(seed: seed)

    let cards1 = TarotDeck.drawCards(count: 5, using: &rng1)
    let cards2 = TarotDeck.drawCards(count: 5, using: &rng2)

    #expect(cards1.count == cards2.count)

    for (card1, card2) in zip(cards1, cards2) {
      #expect(card1.name == card2.name)
    }
  }

  @Test("Seeded RNG produces consistent sequences", .repeat(count: 10))
  func seedConsistentSequences() {
    let seed = UInt64.random(in: .min ... .max)
    var rng1 = SeedablePseudoRNG(seed: seed)
    var rng2 = SeedablePseudoRNG(seed: seed)

    let sequence1 = (0..<10).map { _ in TarotDeck.drawCards(count: 1, using: &rng1)[0] }
    let sequence2 = (0..<10).map { _ in TarotDeck.drawCards(count: 1, using: &rng2)[0] }

    for (card1, card2) in zip(sequence1, sequence2) {
      #expect(card1.name == card2.name)
    }
  }

  @Test("drawCards with seeded RNG snapshot")
  func drawCardsSeededSnapshot() {
    var rng = SeedablePseudoRNG(seed: 38474)
    let cards = TarotDeck.drawCards(count: 5, using: &rng)
    assertInlineSnapshot(of: cards, as: .customDump) {
      """
      [
        [0]: .major(.death),
        [1]: .major(.fool),
        [2]: .major(.tower),
        [3]: .minor(
          MinorArcana(
            suit: .pentacles,
            value: .nine
          )
        ),
        [4]: .minor(
          MinorArcana(
            suit: .wands,
            value: .queen
          )
        )
      ]
      """
    }
  }

  @Test("Consecutive single card draws are evenly distributed")
  func evenDistribution() {
    var rng = SystemRandomNumberGenerator()
    let picks = sequence(state: ()) { _ in TarotDeck.drawCards(count: 1, using: &rng)[0] }
      .prefix(78_000)
      .reduce(into: CountedSet<TarotCard>()) { result, card in
        result.insert(card)
      }
    for card in TarotDeck.fullDeck {
      #expect((500...1500).contains(picks.count(of: card)))
    }
  }
}
