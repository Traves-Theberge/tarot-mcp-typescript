/**
 * Tests for URI parsing utilities
 */

import { MajorArcana, Suit, CardValue, TarotCard } from '../../core/index.js';
import { generateCardURI, parseCardURI } from '../../utils/uri-parser.js';
import { createFullDeck } from '../../core/deck-factory.js';

describe('URI Parser Tests', () => {
  let fullDeck: readonly TarotCard[];

  beforeAll(() => {
    fullDeck = createFullDeck();
  });

  describe('generateCardURI', () => {
    test('generates correct URI for major arcana cards', () => {
      const foolCard = fullDeck.find(card => card.type === 'major' && card.arcana === MajorArcana.Fool);
      const worldCard = fullDeck.find(card => card.type === 'major' && card.arcana === MajorArcana.World);
      
      expect(foolCard).toBeDefined();
      expect(worldCard).toBeDefined();
      expect(generateCardURI(foolCard!)).toBe('tarot://card/major/0');
      expect(generateCardURI(worldCard!)).toBe('tarot://card/major/21');
    });

    test('generates correct URI for minor arcana cards', () => {
      const aceOfCups = fullDeck.find(card => {
        if (card.type === 'minor') {
          const arcana = card.arcana as { suit: Suit; value: CardValue };
          return arcana.suit === Suit.Cups && arcana.value === CardValue.Ace;
        }
        return false;
      });
      const kingOfSwords = fullDeck.find(card => {
        if (card.type === 'minor') {
          const arcana = card.arcana as { suit: Suit; value: CardValue };
          return arcana.suit === Suit.Swords && arcana.value === CardValue.King;
        }
        return false;
      });
      
      expect(aceOfCups).toBeDefined();
      expect(kingOfSwords).toBeDefined();
      expect(generateCardURI(aceOfCups!)).toBe('tarot://card/minor/cups/ace');
      expect(generateCardURI(kingOfSwords!)).toBe('tarot://card/minor/swords/king');
    });
  });

  describe('parseCardURI', () => {
    test('parses major arcana URIs correctly', () => {
      const foolCard = parseCardURI('tarot://card/major/0');
      expect(foolCard?.type).toBe('major');
      expect(foolCard?.arcana).toBe(MajorArcana.Fool);

      const worldCard = parseCardURI('tarot://card/major/21');
      expect(worldCard?.type).toBe('major');
      expect(worldCard?.arcana).toBe(MajorArcana.World);
    });

    test('parses minor arcana URIs correctly', () => {
      const aceOfCups = parseCardURI('tarot://card/minor/cups/ace');
      expect(aceOfCups?.type).toBe('minor');
      if (aceOfCups?.type === 'minor') {
        const arcana = aceOfCups.arcana as { suit: Suit; value: CardValue };
        expect(arcana.suit).toBe(Suit.Cups);
        expect(arcana.value).toBe(CardValue.Ace);
      }

      const kingOfSwords = parseCardURI('tarot://card/minor/swords/king');
      expect(kingOfSwords?.type).toBe('minor');
      if (kingOfSwords?.type === 'minor') {
        const arcana = kingOfSwords.arcana as { suit: Suit; value: CardValue };
        expect(arcana.suit).toBe(Suit.Swords);
        expect(arcana.value).toBe(CardValue.King);
      }
    });

    test('returns null for invalid URIs', () => {
      expect(parseCardURI('invalid://uri')).toBeNull();
      expect(parseCardURI('tarot://card/invalid/0')).toBeNull();
      expect(parseCardURI('tarot://card/major/22')).toBeNull(); // Out of range
      expect(parseCardURI('tarot://card/minor/invalid/1')).toBeNull();
      expect(parseCardURI('tarot://card/minor/cups/15')).toBeNull(); // Out of range
    });

    test('round-trip conversion works correctly', () => {
      const originalCard = fullDeck.find(card => {
        if (card.type === 'minor') {
          const arcana = card.arcana as { suit: Suit; value: CardValue };
          return arcana.suit === Suit.Pentacles && arcana.value === CardValue.Queen;
        }
        return false;
      });
      
      expect(originalCard).toBeDefined();
      const uri = generateCardURI(originalCard!);
      const parsedCard = parseCardURI(uri);
      
      expect(parsedCard?.type).toBe(originalCard!.type);
      if (parsedCard?.type === 'minor' && originalCard!.type === 'minor') {
        const originalArcana = originalCard!.arcana as { suit: Suit; value: CardValue };
        const parsedArcana = parsedCard.arcana as { suit: Suit; value: CardValue };
        expect(parsedArcana.suit).toBe(originalArcana.suit);
        expect(parsedArcana.value).toBe(originalArcana.value);
      }
    });
  });
}); 