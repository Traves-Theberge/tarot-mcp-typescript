/**
 * Factory functions for creating tarot decks and collections
 */

import { MajorArcana, Suit, CardValue, TarotCard } from './tarot-card.js';
import { getCardName } from './card-names.js';

/**
 * Create all Major Arcana cards
 */
export function createMajorArcanaCards(): readonly TarotCard[] {
  return Object.values(MajorArcana)
    .filter((value): value is MajorArcana => typeof value === 'number')
    .map(
      (arcana): TarotCard => {
        const tempCard: TarotCard = {
          type: 'major',
          arcana,
          name: '',
          uri: '',
          imagePath: ''
        };
        const name = getCardName(tempCard);
        const uri = `tarot://card/major/${arcana}`;
        const imagePath = `assets/images/major_arcana_${name.toLowerCase().replace(/\s+/g, '_')}.png`;
        
        return {
          type: 'major',
          arcana,
          name,
          uri,
          imagePath
        };
      }
    );
}

/**
 * Create all Minor Arcana cards
 */
export function createMinorArcanaCards(): readonly TarotCard[] {
  const cards: TarotCard[] = [];

  for (const suit of Object.values(Suit)) {
    for (const value of Object.values(CardValue)) {
      if (typeof value === 'string') {
        const arcana = { suit, value };
        const tempCard: TarotCard = {
          type: 'minor',
          arcana,
          name: '',
          uri: '',
          imagePath: ''
        };
        const name = getCardName(tempCard);
        const uri = `tarot://card/minor/${suit}/${value}`;
        const imagePath = `assets/images/minor_arcana_${suit}_${value}.png`;
        
        cards.push({
          type: 'minor',
          arcana,
          name,
          uri,
          imagePath
        });
      }
    }
  }

  return cards;
}

/**
 * Create the complete tarot deck (78 cards)
 */
export function createFullDeck(): readonly TarotCard[] {
  return [...createMajorArcanaCards(), ...createMinorArcanaCards()];
}

/**
 * Deck constants
 */
export const DECK_CONSTANTS = {
  MAJOR_ARCANA_COUNT: 22,
  MINOR_ARCANA_COUNT: 56,
  TOTAL_CARDS: 78,
  SUITS_COUNT: 4,
  VALUES_PER_SUIT: 14,
} as const; 