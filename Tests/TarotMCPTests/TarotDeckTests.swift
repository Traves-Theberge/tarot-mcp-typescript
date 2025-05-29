import Testing
@testable import TarotMCP

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

    // Check that all combinations of suits and values are present
    for suit in MinorArcana.Suit.allCases {
      for value in MinorArcana.Value.allCases {
        let expectedCard = MinorArcana(suit: suit, value: value)
        let found = minorCards.contains { card in
          card.suit == expectedCard.suit && card.value == expectedCard.value
        }
        #expect(found, "Missing \(expectedCard.name)")
      }
    }
  }

  @Test("drawRandomCard returns a valid card from the deck")
  func drawRandomCard() {
    let card = TarotDeck.drawRandomCard()
    #expect(TarotDeck.fullDeck.contains { deckCard in
      deckCard.name == card.name
    })
  }

  @Test("drawCards returns correct number of cards")
  func drawCardsCount() {
    let oneCard = TarotDeck.drawCards(count: 1)
    #expect(oneCard.count == 1)

    let threeCards = TarotDeck.drawCards(count: 3)
    #expect(threeCards.count == 3)

    let tenCards = TarotDeck.drawCards(count: 10)
    #expect(tenCards.count == 10)
  }

  @Test("drawCards returns valid cards from the deck")
  func drawCardsValid() {
    let cards = TarotDeck.drawCards(count: 5)

    for card in cards {
      #expect(TarotDeck.fullDeck.contains { deckCard in
        deckCard.name == card.name
      })
    }
  }

  @Test("drawCards with count larger than deck returns all cards")
  func drawCardsLargeCount() {
    let allCards = TarotDeck.drawCards(count: 100)
    #expect(allCards.count == 78)
  }

  @Test("drawCards with zero count returns empty array")
  func drawCardsZeroCount() {
    let noCards = TarotDeck.drawCards(count: 0)
    #expect(noCards.isEmpty)
  }

  @Test("drawRandomCard with seeded RNG is deterministic")
  func drawRandomCardDeterministic() {
    var rng1 = SeedablePseudoRNG(seed: 42)
    var rng2 = SeedablePseudoRNG(seed: 42)

    let card1 = TarotDeck.drawRandomCard(using: &rng1)
    let card2 = TarotDeck.drawRandomCard(using: &rng2)

    #expect(card1.name == card2.name)
  }

  @Test("drawCards with seeded RNG is deterministic")
  func drawCardsDeterministic() {
    var rng1 = SeedablePseudoRNG(seed: 123)
    var rng2 = SeedablePseudoRNG(seed: 123)

    let cards1 = TarotDeck.drawCards(count: 5, using: &rng1)
    let cards2 = TarotDeck.drawCards(count: 5, using: &rng2)

    #expect(cards1.count == cards2.count)

    for (card1, card2) in zip(cards1, cards2) {
      #expect(card1.name == card2.name)
    }
  }

  @Test("Different seeds produce different results")
  func differentSeedsProduceDifferentResults() {
    var rng1 = SeedablePseudoRNG(seed: 12345)
    var rng2 = SeedablePseudoRNG(seed: 67890)

    // Test multiple draws to increase probability of finding a difference
    var foundDifference = false
    for _ in 0..<10 {
      let card1 = TarotDeck.drawRandomCard(using: &rng1)
      let card2 = TarotDeck.drawRandomCard(using: &rng2)

      if card1.name != card2.name {
        foundDifference = true
        break
      }
    }

    #expect(foundDifference, "Different seeds should eventually produce different cards")
  }

  @Test("Seeded RNG produces consistent sequences")
  func seedConsistentSequences() {
    var rng1 = SeedablePseudoRNG(seed: 999)
    var rng2 = SeedablePseudoRNG(seed: 999)

    let sequence1 = (0..<10).map { _ in TarotDeck.drawRandomCard(using: &rng1) }
    let sequence2 = (0..<10).map { _ in TarotDeck.drawRandomCard(using: &rng2) }

    for (card1, card2) in zip(sequence1, sequence2) {
      #expect(card1.name == card2.name)
    }
  }

}
