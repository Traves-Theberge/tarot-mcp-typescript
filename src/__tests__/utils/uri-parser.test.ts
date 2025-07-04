/**
 * Tests for URI parsing utilities
 */

import { MajorArcana, Suit, CardValue } from '../../core/index.js';
import { generateCardURI, parseCardURI } from '../../utils/uri-parser.js';

describe('URI Parser Tests', () => {
  describe('generateCardURI', () => {
    test('generates correct URI for major arcana cards', () => {
      const foolCard = { type: 'major' as const, arcana: MajorArcana.Fool };
      expect(generateCardURI(foolCard)).toBe('tarot://card/major/0');

      const worldCard = { type: 'major' as const, arcana: MajorArcana.World };
      expect(generateCardURI(worldCard)).toBe('tarot://card/major/21');
    });

    test('generates correct URI for minor arcana cards', () => {
      const aceOfCups = {
        type: 'minor' as const,
        arcana: { suit: Suit.Cups, value: CardValue.Ace }
      };
      expect(generateCardURI(aceOfCups)).toBe('tarot://card/minor/cups/1');

      const kingOfSwords = {
        type: 'minor' as const,
        arcana: { suit: Suit.Swords, value: CardValue.King }
      };
      expect(generateCardURI(kingOfSwords)).toBe('tarot://card/minor/swords/14');
    });
  });

  describe('parseCardURI', () => {
    test('parses major arcana URIs correctly', () => {
      const foolCard = parseCardURI('tarot://card/major/0');
      expect(foolCard).toEqual({
        type: 'major',
        arcana: MajorArcana.Fool
      });

      const worldCard = parseCardURI('tarot://card/major/21');
      expect(worldCard).toEqual({
        type: 'major',
        arcana: MajorArcana.World
      });
    });

    test('parses minor arcana URIs correctly', () => {
      const aceOfCups = parseCardURI('tarot://card/minor/cups/1');
      expect(aceOfCups).toEqual({
        type: 'minor',
        arcana: { suit: Suit.Cups, value: CardValue.Ace }
      });

      const kingOfSwords = parseCardURI('tarot://card/minor/swords/14');
      expect(kingOfSwords).toEqual({
        type: 'minor',
        arcana: { suit: Suit.Swords, value: CardValue.King }
      });
    });

    test('returns null for invalid URIs', () => {
      expect(parseCardURI('invalid://uri')).toBeNull();
      expect(parseCardURI('tarot://card/invalid/0')).toBeNull();
      expect(parseCardURI('tarot://card/major/22')).toBeNull(); // Out of range
      expect(parseCardURI('tarot://card/minor/invalid/1')).toBeNull();
      expect(parseCardURI('tarot://card/minor/cups/15')).toBeNull(); // Out of range
    });

    test('round-trip conversion works correctly', () => {
      const originalCard = {
        type: 'minor' as const,
        arcana: { suit: Suit.Pentacles, value: CardValue.Queen }
      };
      
      const uri = generateCardURI(originalCard);
      const parsedCard = parseCardURI(uri);
      
      expect(parsedCard).toEqual(originalCard);
    });
  });
}); 