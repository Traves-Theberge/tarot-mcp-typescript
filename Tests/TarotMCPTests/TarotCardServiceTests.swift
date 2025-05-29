import Testing
@testable import TarotMCP

@Suite("Tarot Card Service Tests")
struct TarotCardServiceTests {
  
  @Test("drawSingleCard returns valid result")
  func drawSingleCardValid() {
    let service = TarotCardService()
    let result = service.drawSingleCard()
    
    #expect(result.cards.count == 1)
    #expect(result.message.contains(result.cards[0].name))
    #expect(result.message.contains("🔮"))
  }
  
  @Test("drawSingleCard with seeded RNG is deterministic")
  func drawSingleCardDeterministic() {
    let service = TarotCardService()
    var rng1 = SeedablePseudoRNG(seed: 42)
    var rng2 = SeedablePseudoRNG(seed: 42)
    
    let result1 = service.drawSingleCard(using: &rng1)
    let result2 = service.drawSingleCard(using: &rng2)
    
    #expect(result1.cards.count == result2.cards.count)
    #expect(result1.cards[0].name == result2.cards[0].name)
    #expect(result1.message == result2.message)
  }
  
  @Test("drawMultipleCards returns correct count")
  func drawMultipleCardsCount() {
    let service = TarotCardService()
    
    let result3 = service.drawMultipleCards(count: 3)
    #expect(result3.cards.count == 3)
    
    let result5 = service.drawMultipleCards(count: 5)
    #expect(result5.cards.count == 5)
    
    let result10 = service.drawMultipleCards(count: 10)
    #expect(result10.cards.count == 10)
  }
  
  @Test("drawMultipleCards clamps count properly")
  func drawMultipleCardsClamps() {
    let service = TarotCardService()
    
    // Test minimum clamping
    let resultZero = service.drawMultipleCards(count: 0)
    #expect(resultZero.cards.count == 1)
    
    let resultNegative = service.drawMultipleCards(count: -5)
    #expect(resultNegative.cards.count == 1)
    
    // Test maximum clamping
    let resultLarge = service.drawMultipleCards(count: 100)
    #expect(resultLarge.cards.count == 20)
  }
  
  @Test("drawMultipleCards with seeded RNG is deterministic")
  func drawMultipleCardsDeterministic() {
    let service = TarotCardService()
    var rng1 = SeedablePseudoRNG(seed: 123)
    var rng2 = SeedablePseudoRNG(seed: 123)
    
    let result1 = service.drawMultipleCards(count: 5, using: &rng1)
    let result2 = service.drawMultipleCards(count: 5, using: &rng2)
    
    #expect(result1.cards.count == result2.cards.count)
    
    for (card1, card2) in zip(result1.cards, result2.cards) {
      #expect(card1.name == card2.name)
    }
    
    #expect(result1.message == result2.message)
  }
  
  @Test("drawMultipleCards message format is correct")
  func drawMultipleCardsMessageFormat() {
    let service = TarotCardService()
    var rng = SeedablePseudoRNG(seed: 456)
    
    let result = service.drawMultipleCards(count: 3, using: &rng)
    
    #expect(result.message.contains("🔮"))
    #expect(result.message.contains("Tarot Reading - 3 Cards"))
    
    for card in result.cards {
      #expect(result.message.contains(card.name))
    }
  }
  
  @Test("getFullDeck returns complete deck info")
  func getFullDeckComplete() {
    let service = TarotCardService()
    let result = service.getFullDeck()
    
    #expect(result.majorArcana.count == 22)
    #expect(result.minorArcana.count == 56)
    #expect(result.message.contains("🃏"))
    #expect(result.message.contains("Complete Tarot Deck (78 cards)"))
    #expect(result.message.contains("Major Arcana (22 cards)"))
    #expect(result.message.contains("Minor Arcana (56 cards)"))
  }
  
  @Test("getFullDeck contains all expected cards")
  func getFullDeckContent() {
    let service = TarotCardService()
    let result = service.getFullDeck()
    
    // Check a few specific Major Arcana cards
    #expect(result.majorArcana.contains("The Fool"))
    #expect(result.majorArcana.contains("The Magician"))
    #expect(result.majorArcana.contains("The World"))
    
    // Check a few specific Minor Arcana cards
    #expect(result.minorArcana.contains("Ace of Wands"))
    #expect(result.minorArcana.contains("King of Cups"))
    #expect(result.minorArcana.contains("Ten of Pentacles"))
  }
  
  @Test("getFullDeck is deterministic")
  func getFullDeckDeterministic() {
    let service = TarotCardService()
    
    let result1 = service.getFullDeck()
    let result2 = service.getFullDeck()
    
    #expect(result1.majorArcana == result2.majorArcana)
    #expect(result1.minorArcana == result2.minorArcana)
    #expect(result1.message == result2.message)
  }
}