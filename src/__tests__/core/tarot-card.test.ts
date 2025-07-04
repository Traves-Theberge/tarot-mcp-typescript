/**
 * Tests for TarotCard core functionality
 * TypeScript equivalent of Swift TarotCardTests
 */

import { MajorArcana, Suit, CardValue, MinorArcana, TarotCard } from '../../core/index.js';
import { getCardName } from '../../core/card-names.js';

describe('Tarot Card Tests', () => {
  describe('Major Arcana', () => {
    test('has exactly 22 cards', () => {
      const majorArcanaValues = Object.values(MajorArcana).filter(v => typeof v === 'number');
      expect(majorArcanaValues).toHaveLength(22);
    });

    test('card names are correct', () => {
      const foolCard: TarotCard = { type: 'major', arcana: MajorArcana.Fool };
      expect(getCardName(foolCard)).toBe('The Fool');

      const magicianCard: TarotCard = { type: 'major', arcana: MajorArcana.Magician };
      expect(getCardName(magicianCard)).toBe('The Magician');
    });
  });

  describe('Minor Arcana', () => {
    test('has exactly 4 suits', () => {
      const suits = Object.values(Suit);
      expect(suits).toHaveLength(4);
    });

    test('has exactly 14 values per suit', () => {
      const values = Object.values(CardValue).filter(v => typeof v === 'number');
      expect(values).toHaveLength(14);

      expect(CardValue.Ace).toBe(1);
      expect(CardValue.Ten).toBe(10);
      expect(CardValue.Page).toBe(11);
      expect(CardValue.Knight).toBe(12);
      expect(CardValue.Queen).toBe(13);
      expect(CardValue.King).toBe(14);
    });

    test('card names are formatted correctly', () => {
      const aceOfCups: MinorArcana = { suit: Suit.Cups, value: CardValue.Ace };
      const aceOfCupsCard: TarotCard = { type: 'minor', arcana: aceOfCups };
      expect(getCardName(aceOfCupsCard)).toBe('Ace of Cups');

      const kingOfSwords: MinorArcana = { suit: Suit.Swords, value: CardValue.King };
      const kingOfSwordsCard: TarotCard = { type: 'minor', arcana: kingOfSwords };
      expect(getCardName(kingOfSwordsCard)).toBe('King of Swords');
    });

    test('TarotCard minor arcana names are correct', () => {
      const aceOfWands: TarotCard = {
        type: 'minor',
        arcana: { suit: Suit.Wands, value: CardValue.Ace }
      };
      expect(getCardName(aceOfWands)).toBe('Ace of Wands');

      const queenOfPentacles: TarotCard = {
        type: 'minor',
        arcana: { suit: Suit.Pentacles, value: CardValue.Queen }
      };
      expect(getCardName(queenOfPentacles)).toBe('Queen of Pentacles');
    });
  });
}); 