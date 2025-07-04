/**
 * Tests for TarotCard core functionality
 * TypeScript equivalent of Swift TarotCardTests
 */

import { MajorArcana, Suit, CardValue, MinorArcana, TarotCard } from '../../core/index.js';
import { getCardName } from '../../core/card-names.js';
import { createFullDeck } from '../../core/deck-factory.js';

describe('Tarot Card Tests', () => {
  let fullDeck: readonly TarotCard[];

  beforeAll(() => {
    fullDeck = createFullDeck();
  });

  describe('Major Arcana', () => {
    test('has exactly 22 cards', () => {
      const majorArcanaValues = Object.values(MajorArcana).filter(v => typeof v === 'number');
      expect(majorArcanaValues).toHaveLength(22);
    });

    test('card names are correct', () => {
      const foolCard = fullDeck.find(card => card.type === 'major' && card.arcana === MajorArcana.Fool);
      const magicianCard = fullDeck.find(card => card.type === 'major' && card.arcana === MajorArcana.Magician);
      
      expect(foolCard).toBeDefined();
      expect(magicianCard).toBeDefined();
      expect(getCardName(foolCard!)).toBe('The Fool');
      expect(getCardName(magicianCard!)).toBe('The Magician');
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
      const aceOfCups = fullDeck.find(card => {
        if (card.type === 'minor') {
          const arcana = card.arcana as MinorArcana;
          return arcana.suit === Suit.Cups && arcana.value === CardValue.Ace;
        }
        return false;
      });
      const kingOfSwords = fullDeck.find(card => {
        if (card.type === 'minor') {
          const arcana = card.arcana as MinorArcana;
          return arcana.suit === Suit.Swords && arcana.value === CardValue.King;
        }
        return false;
      });
      
      expect(aceOfCups).toBeDefined();
      expect(kingOfSwords).toBeDefined();
      expect(getCardName(aceOfCups!)).toBe('Ace of Cups');
      expect(getCardName(kingOfSwords!)).toBe('King of Swords');
    });

    test('TarotCard minor arcana names are correct', () => {
      const aceOfWands = fullDeck.find(card => {
        if (card.type === 'minor') {
          const arcana = card.arcana as MinorArcana;
          return arcana.suit === Suit.Wands && arcana.value === CardValue.Ace;
        }
        return false;
      });
      const queenOfPentacles = fullDeck.find(card => {
        if (card.type === 'minor') {
          const arcana = card.arcana as MinorArcana;
          return arcana.suit === Suit.Pentacles && arcana.value === CardValue.Queen;
        }
        return false;
      });
      
      expect(aceOfWands).toBeDefined();
      expect(queenOfPentacles).toBeDefined();
      expect(getCardName(aceOfWands!)).toBe('Ace of Wands');
      expect(getCardName(queenOfPentacles!)).toBe('Queen of Pentacles');
    });
  });
}); 