import Testing
@testable import TarotMCPCore

@Suite("Tarot Card Tests")
struct TarotCardTests {

    @Test("Major Arcana has exactly 22 cards")
    func majorArcanaCount() {
        #expect(MajorArcana.allCases.count == 22)
    }

    @Test("Minor Arcana has exactly 4 suits")
    func minorArcanaSuits() {
        let suits = MinorArcana.Suit.allCases
        #expect(suits.count == 4)
    }

    @Test("Minor Arcana has exactly 14 values per suit")
    func minorArcanaValues() {
        let values = MinorArcana.Value.allCases
        #expect(values.count == 14)

        #expect(MinorArcana.Value.ace.rawValue == 1)
        #expect(MinorArcana.Value.ten.rawValue == 10)
        #expect(MinorArcana.Value.page.rawValue == 11)
        #expect(MinorArcana.Value.knight.rawValue == 12)
        #expect(MinorArcana.Value.queen.rawValue == 13)
        #expect(MinorArcana.Value.king.rawValue == 14)
    }

    @Test("Minor Arcana card names are formatted correctly")
    func minorArcanaCardName() {
        let aceOfCups = MinorArcana(suit: .cups, value: .ace)
        #expect(aceOfCups.name == "Ace of Cups")

        let kingOfSwords = MinorArcana(suit: .swords, value: .king)
        #expect(kingOfSwords.name == "King of Swords")
    }

    @Test("TarotCard major arcana names are correct")
    func tarotCardMajorName() {
        let fool = TarotCard.major(.fool)
        #expect(fool.name == "The Fool")

        let magician = TarotCard.major(.magician)
        #expect(magician.name == "The Magician")
    }

    @Test("TarotCard minor arcana names are correct")
    func tarotCardMinorName() {
        let aceOfWands = TarotCard.minor(MinorArcana(suit: .wands, value: .ace))
        #expect(aceOfWands.name == "Ace of Wands")

        let queenOfPentacles = TarotCard.minor(MinorArcana(suit: .pentacles, value: .queen))
        #expect(queenOfPentacles.name == "Queen of Pentacles")
    }
}
