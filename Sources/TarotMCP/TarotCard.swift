import Foundation

enum MajorArcana: Int, CaseIterable {
  case fool = 0
  case magician = 1
  case highPriestess = 2
  case empress = 3
  case emperor = 4
  case hierophant = 5
  case lovers = 6
  case chariot = 7
  case strength = 8
  case hermit = 9
  case wheelOfFortune = 10
  case justice = 11
  case hangedMan = 12
  case death = 13
  case temperance = 14
  case devil = 15
  case tower = 16
  case star = 17
  case moon = 18
  case sun = 19
  case judgement = 20
  case world = 21
  
  var name: String {
    switch self {
    case .fool: return "The Fool"
    case .magician: return "The Magician"
    case .highPriestess: return "The High Priestess"
    case .empress: return "The Empress"
    case .emperor: return "The Emperor"
    case .hierophant: return "The Hierophant"
    case .lovers: return "The Lovers"
    case .chariot: return "The Chariot"
    case .strength: return "Strength"
    case .hermit: return "The Hermit"
    case .wheelOfFortune: return "Wheel of Fortune"
    case .justice: return "Justice"
    case .hangedMan: return "The Hanged Man"
    case .death: return "Death"
    case .temperance: return "Temperance"
    case .devil: return "The Devil"
    case .tower: return "The Tower"
    case .star: return "The Star"
    case .moon: return "The Moon"
    case .sun: return "The Sun"
    case .judgement: return "Judgement"
    case .world: return "The World"
    }
  }
}

struct MinorArcana {
  enum Suit: String, CaseIterable {
    case wands = "Wands"
    case pentacles = "Pentacles" 
    case swords = "Swords"
    case cups = "Cups"
  }
  
  enum Value: Int, CaseIterable {
    case ace = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    case page = 11
    case knight = 12
    case queen = 13
    case king = 14
    
    var name: String {
      switch self {
      case .ace: return "Ace"
      case .two: return "Two"
      case .three: return "Three"
      case .four: return "Four"
      case .five: return "Five"
      case .six: return "Six"
      case .seven: return "Seven"
      case .eight: return "Eight"
      case .nine: return "Nine"
      case .ten: return "Ten"
      case .page: return "Page"
      case .knight: return "Knight"
      case .queen: return "Queen"
      case .king: return "King"
      }
    }
  }
  
  let suit: Suit
  let value: Value
  
  var name: String {
    return "\(value.name) of \(suit.rawValue)"
  }
}

enum TarotCard {
  case major(MajorArcana)
  case minor(MinorArcana)
  
  var name: String {
    switch self {
    case .major(let arcana):
      return arcana.name
    case .minor(let minorArcana):
      return minorArcana.name
    }
  }
}

class TarotDeck {
  static let fullDeck: [TarotCard] = {
    let majorArcana = MajorArcana.allCases
      .lazy
      .map(TarotCard.major(_:))
    let minorArcana = MinorArcana.Suit.allCases
      .lazy
      .flatMap { suit in
        MinorArcana.Value.allCases.lazy.map { value in
          TarotCard.minor(MinorArcana(suit: suit, value: value))
        }
      }
    var output = [TarotCard]()
    output.reserveCapacity(
      MajorArcana.allCases.count + (
        MinorArcana.Suit.allCases.count * MinorArcana.Value.allCases.count
      )
    )
    output.append(contentsOf: majorArcana)
    output.append(contentsOf: minorArcana)
    return output
  }()

  static func drawRandomCard() -> TarotCard {
    var rng = SystemRandomNumberGenerator()
    return drawRandomCard(using: &rng)
  }
  
  static func drawRandomCard(using rng: inout some RandomNumberGenerator) -> TarotCard {
    return fullDeck.randomElement(using: &rng)!
  }
  
  static func drawCards(count: Int) -> [TarotCard] {
    var rng = SystemRandomNumberGenerator()
    return drawCards(count: count, using: &rng)
  }
  
  static func drawCards(count: Int, using rng: inout some RandomNumberGenerator) -> [TarotCard] {
    return Array(fullDeck.shuffled(using: &rng).prefix(count))
  }
}

struct TarotCardService {
  func drawSingleCard() -> DrawResult {
    var rng = SystemRandomNumberGenerator()
    return drawSingleCard(using: &rng)
  }
  
  func drawSingleCard(using rng: inout some RandomNumberGenerator) -> DrawResult {
    let card = TarotDeck.drawRandomCard(using: &rng)
    return DrawResult(
      cards: [card],
      message: "🔮 **\(card.name)**\n\nA tarot card has been drawn for you!"
    )
  }
  
  func drawMultipleCards(count: Int) -> DrawResult {
    var rng = SystemRandomNumberGenerator()
    return drawMultipleCards(count: count, using: &rng)
  }
  
  func drawMultipleCards(count: Int, using rng: inout some RandomNumberGenerator) -> DrawResult {
    let clampedCount = min(max(count, 1), 20)
    let cards = TarotDeck.drawCards(count: clampedCount, using: &rng)
    
    let cardNames = cards.map { "• \($0.name)" }.joined(separator: "\n")
    let message = "🔮 **Tarot Reading - \(cards.count) Cards**\n\n\(cardNames)"
    
    return DrawResult(cards: cards, message: message)
  }
  
  func getFullDeck() -> DeckResult {
    let allCards = TarotDeck.fullDeck
    let majorArcana = allCards.compactMap { card in
      if case .major(let arcana) = card {
        return arcana.name
      }
      return nil
    }
    
    let minorArcana = allCards.compactMap { card in
      if case .minor(let minor) = card {
        return minor.name
      }
      return nil
    }
    
    let majorList = majorArcana.map { "• \($0)" }.joined(separator: "\n")
    let minorList = minorArcana.map { "• \($0)" }.joined(separator: "\n")
    
    let message = "🃏 **Complete Tarot Deck (78 cards)**\n\n**Major Arcana (22 cards):**\n\(majorList)\n\n**Minor Arcana (56 cards):**\n\(minorList)"
    
    return DeckResult(
      majorArcana: majorArcana,
      minorArcana: minorArcana,
      message: message
    )
  }
}

struct DrawResult {
  let cards: [TarotCard]
  let message: String
}

struct DeckResult {
  let majorArcana: [String]
  let minorArcana: [String]
  let message: String
}
