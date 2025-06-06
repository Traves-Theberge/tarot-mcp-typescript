import Foundation

enum TarotCardError: Error, LocalizedError {
  case invalidCardCount(Int)

  var errorDescription: String? {
    switch self {
    case .invalidCardCount(let count):
      return "Invalid card count: \(count). Count must be between 1 and 78."
    }
  }
}

enum MajorArcana: Int, CaseIterable, Sendable {
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

struct MinorArcana: Hashable, Sendable {
  enum Suit: String, CaseIterable, Sendable {
    case wands = "Wands"
    case pentacles = "Pentacles"
    case swords = "Swords"
    case cups = "Cups"
  }

  enum Value: Int, CaseIterable, Sendable {
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

  static let allCases: [MinorArcana] = {
    var cards = [MinorArcana]()
    cards.reserveCapacity(Suit.allCases.count * Value.allCases.count)
    for suit in Suit.allCases {
      for value in Value.allCases {
        cards.append(MinorArcana(suit: suit, value: value))
      }
    }
    return cards
  }()
}

enum TarotCard: Hashable, Sendable {
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

enum TarotDeck {
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
    output.append(contentsOf: majorArcana)
    output.append(contentsOf: minorArcana)
    return output
  }()

  static func drawRandomCard(using rng: inout some RandomNumberGenerator) -> TarotCard {
    // This should never fail since fullDeck is guaranteed to have 78 cards
    fullDeck.randomElement(using: &rng)!  // swiftlint:disable:this force_unwrapping
  }

  static func drawCards(count: Int, using rng: inout some RandomNumberGenerator) -> [TarotCard] {
    Array(fullDeck.shuffled(using: &rng).prefix(count))
  }
}
