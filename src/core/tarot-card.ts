/**
 * Represents a suit in the Minor Arcana
 */
export enum Suit {
  Wands = 'wands',
  Pentacles = 'pentacles', 
  Swords = 'swords',
  Cups = 'cups'
}

/**
 * Represents a value in the Minor Arcana (ace, 2-10, page, knight, queen, king)
 */
export enum CardValue {
  Ace = 'ace',
  Two = '2',
  Three = '3', 
  Four = '4',
  Five = '5',
  Six = '6',
  Seven = '7',
  Eight = '8',
  Nine = '9',
  Ten = '10',
  Page = 'page',
  Knight = 'knight',
  Queen = 'queen',
  King = 'king'
}

/**
 * Represents a Major Arcana card number (0-21)
 */
export enum MajorArcana {
  Fool = 0,
  Magician = 1,
  HighPriestess = 2,
  Empress = 3,
  Emperor = 4,
  Hierophant = 5,
  Lovers = 6,
  Chariot = 7,
  Strength = 8,
  Hermit = 9,
  WheelOfFortune = 10,
  Justice = 11,
  HangedMan = 12,
  Death = 13,
  Temperance = 14,
  Devil = 15,
  Tower = 16,
  Star = 17,
  Moon = 18,
  Sun = 19,
  Judgement = 20,
  World = 21
}

/**
 * Represents a tarot card with its properties
 */
export interface TarotCard {
  readonly type: 'major' | 'minor';
  readonly name: string;
  readonly uri: string;
  readonly imagePath: string;
  readonly arcana: MajorArcana | { suit: Suit; value: CardValue };
}

/**
 * Card response interface for API responses
 */
export interface CardResponse {
  name: string;
  uri: string;
}

/**
 * Error class for tarot card operations
 */
export class TarotCardError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'TarotCardError';
  }
}

/**
 * Type guard to check if a card is a Major Arcana card
 */
export function isMajorArcanaCard(card: TarotCard): boolean {
  return card.type === 'major';
}

/**
 * Type guard to check if a card is a Minor Arcana card
 */
export function isMinorArcanaCard(card: TarotCard): boolean {
  return card.type === 'minor';
} 