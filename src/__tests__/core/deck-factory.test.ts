/**
 * Tests for TarotDeck functionality
 * TypeScript equivalent of Swift TarotDeckTests
 */

import { MajorArcana, Suit, CardValue, TarotCard } from '../../core/index.js';
import { createFullDeck } from '../../core/deck-factory.js';
import { getCardName } from '../../core/card-names.js';
import { TarotDeckService } from '../../server/deck-service.js';
import { CountedSet, SeedablePseudoRNG } from '../test-support/index.js';

describe('Tarot Deck Tests', () => {
  const fullDeck = createFullDeck();

  describe('Full Deck', () => {
    test('has exactly 78 cards', () => {
      expect(fullDeck).toHaveLength(78);
    });

    test('contains all 22 Major Arcana cards', () => {
      const majorCards = fullDeck.filter(card => card.type === 'major');
      expect(majorCards).toHaveLength(22);

      // Check that all Major Arcana are present
      const majorArcanaValues = Object.values(MajorArcana).filter(v => typeof v === 'number') as number[];
      for (const expectedArcana of majorArcanaValues) {
        const found = majorCards.some(card => 
          card.type === 'major' && card.arcana === expectedArcana
        );
        expect(found).toBe(true);
      }
    });

    test('contains all 56 Minor Arcana cards', () => {
      const minorCards = fullDeck.filter(card => card.type === 'minor');
      expect(minorCards).toHaveLength(56);

      const suits = Object.values(Suit);
      const values = Object.values(CardValue).filter(v => typeof v === 'number') as number[];
      
      expect(suits).toHaveLength(4);
      expect(values).toHaveLength(14);

      // Check that all combinations of suits and values are present
      for (const suit of suits) {
        for (const value of values) {
          const found = minorCards.some(card =>
            card.type === 'minor' && 
            card.arcana.suit === suit && 
            card.arcana.value === value
          );
          expect(found).toBe(true);
        }
      }
    });
  });

  describe('Draw Cards', () => {
    // Repeat test multiple times like Swift's .repeat(count: 10)
    test.each(Array.from({ length: 10 }, (_, i) => i))('drawCards with count=1 returns a valid card from the deck (iteration %i)', () => {
      const rng = new SeedablePseudoRNG(Math.random() * 1000000);
      const deckService = new TarotDeckService(rng);
      const cards = deckService.drawCards(1);
      expect(cards).toHaveLength(1);
      
      const cardNames = fullDeck.map(getCardName);
      expect(cards.length).toBeGreaterThan(0);
      if (cards.length > 0) {
        expect(cardNames).toContain(getCardName(cards[0]!));
      }
    });

    test.each(Array.from({ length: 10 }, (_, i) => i))('drawCards returns correct number of cards (iteration %i)', () => {
      const rng = new SeedablePseudoRNG(Math.random() * 1000000);
      const deckService = new TarotDeckService(rng);
      
      const oneCard = deckService.drawCards(1);
      expect(oneCard).toHaveLength(1);

      const threeCards = deckService.drawCards(3);
      expect(threeCards).toHaveLength(3);

      const tenCards = deckService.drawCards(10);
      expect(tenCards).toHaveLength(10);
    });

    test.each(Array.from({ length: 10 }, (_, i) => i))('drawCards returns valid cards from the deck (iteration %i)', () => {
      const rng = new SeedablePseudoRNG(Math.random() * 1000000);
      const deckService = new TarotDeckService(rng);
      const cards = deckService.drawCards(5);

      const fullDeckNames = new Set(fullDeck.map(getCardName));
      for (const card of cards) {
        expect(fullDeckNames.has(getCardName(card))).toBe(true);
      }
    });

    test('drawCards with count larger than deck throws error', () => {
      const rng = new SeedablePseudoRNG(42);
      const deckService = new TarotDeckService(rng);
      expect(() => deckService.drawCards(100)).toThrow('Invalid card count: 100. Count must be between 1 and 78.');
    });

    test('drawCards with zero count throws error', () => {
      const rng = new SeedablePseudoRNG(42);
      const deckService = new TarotDeckService(rng);
      expect(() => deckService.drawCards(0)).toThrow();
    });

    test('drawRandomCard with seeded RNG is deterministic', () => {
      const rng1 = new SeedablePseudoRNG(42);
      const rng2 = new SeedablePseudoRNG(42);
      const deckService1 = new TarotDeckService(rng1);
      const deckService2 = new TarotDeckService(rng2);

      const cards1 = deckService1.drawCards(1);
      const cards2 = deckService2.drawCards(1);

      expect(cards1.length).toBe(1);
      expect(cards2.length).toBe(1);
      if (cards1.length > 0 && cards2.length > 0) {
        expect(getCardName(cards1[0]!)).toBe(getCardName(cards2[0]!));
      }
    });

    test.each(Array.from({ length: 10 }, (_, i) => i))('drawCards with seeded RNG is deterministic (iteration %i)', () => {
      const seed = Math.floor(Math.random() * 1000000);
      const rng1 = new SeedablePseudoRNG(seed);
      const rng2 = new SeedablePseudoRNG(seed);
      const deckService1 = new TarotDeckService(rng1);
      const deckService2 = new TarotDeckService(rng2);

      const cards1 = deckService1.drawCards(5);
      const cards2 = deckService2.drawCards(5);

      expect(cards1).toHaveLength(cards2.length);

      for (let i = 0; i < cards1.length; i++) {
        expect(getCardName(cards1[i]!)).toBe(getCardName(cards2[i]!));
      }
    });

    test.each(Array.from({ length: 10 }, (_, i) => i))('Seeded RNG produces consistent sequences (iteration %i)', () => {
      const seed = Math.floor(Math.random() * 1000000);
      const rng1 = new SeedablePseudoRNG(seed);
      const rng2 = new SeedablePseudoRNG(seed);
      const deckService1 = new TarotDeckService(rng1);
      const deckService2 = new TarotDeckService(rng2);

      const sequence1 = Array.from({ length: 10 }, () => deckService1.drawCards(1)[0]);
      const sequence2 = Array.from({ length: 10 }, () => deckService2.drawCards(1)[0]);

      for (let i = 0; i < sequence1.length; i++) {
        expect(getCardName(sequence1[i]!)).toBe(getCardName(sequence2[i]!));
      }
    });

    test('drawCards with seeded RNG snapshot', () => {
      const rng = new SeedablePseudoRNG(38474);
      const deckService = new TarotDeckService(rng);
      const cards = deckService.drawCards(5);
      
      // Convert to a format similar to Swift's snapshot
      const cardNames = cards.map(getCardName);
      expect(cardNames).toMatchSnapshot();
    });

    test('Consecutive single card draws are evenly distributed', () => {
      const rng = new SeedablePseudoRNG(12345);
      const deckService = new TarotDeckService(rng);
      const picks = new CountedSet<string>();
      
      // Draw 78,000 cards like in Swift test
      for (let i = 0; i < 78000; i++) {
        const cards = deckService.drawCards(1);
        expect(cards.length).toBe(1);
        if (cards.length > 0) {
          picks.insert(getCardName(cards[0]!));
        }
      }

      // Each card should appear roughly 1000 times (78000 / 78 = 1000)
      // Allow range of 500-1500 like Swift test
      for (const card of fullDeck) {
        const count = picks.count(getCardName(card));
        expect(count).toBeGreaterThanOrEqual(500);
        expect(count).toBeLessThanOrEqual(1500);
      }
    });
  });
}); 