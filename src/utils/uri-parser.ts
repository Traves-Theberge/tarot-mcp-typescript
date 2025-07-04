/**
 * URI parsing utilities for tarot card resource URIs
 */

import { TarotCard, MajorArcana, Suit, CardValue, getCardName } from '../core/index.js';

/**
 * Parse a tarot card URI and return the corresponding card
 * 
 * Expected URI format:
 * - Major Arcana: tarot://card/major/{number}
 * - Minor Arcana: tarot://card/minor/{suit}/{value}
 * 
 * @param uri - The URI to parse
 * @returns The corresponding tarot card, or null if invalid
 */
export function parseCardURI(uri: string): TarotCard | null {
  try {
    // Simple string parsing instead of URL constructor
    if (!uri.startsWith('tarot://card/')) {
      return null;
    }

    const pathParts = uri.split('/');
    if (pathParts.length < 4) {
      return null;
    }

    const cardType = pathParts[3]; // 'major' or 'minor'

    if (cardType === 'major') {
      return parseMajorArcanaURI(pathParts);
    } else if (cardType === 'minor') {
      return parseMinorArcanaURI(pathParts);
    }

    return null;
  } catch {
    return null;
  }
}

/**
 * Parse a major arcana URI
 */
function parseMajorArcanaURI(pathParts: string[]): TarotCard | null {
  if (pathParts.length !== 5) {
    return null;
  }

  const arcanaStr = pathParts[4];
  if (!arcanaStr) {
    return null;
  }

  const arcanaValue = parseInt(arcanaStr, 10);
  if (isNaN(arcanaValue) || arcanaValue < 0 || arcanaValue > 21) {
    return null;
  }

  const arcana = arcanaValue as MajorArcana;
  const tempCard: TarotCard = {
    type: 'major',
    arcana,
    name: '',
    uri: '',
    imagePath: ''
  };
  
  return {
    type: 'major',
    arcana,
    name: getCardName(tempCard),
    uri: `tarot://card/major/${arcanaValue}`,
    imagePath: `assets/images/major_arcana_${getCardName(tempCard).toLowerCase().replace(/\s+/g, '_')}.png`
  };
}

/**
 * Parse a minor arcana URI
 */
function parseMinorArcanaURI(pathParts: string[]): TarotCard | null {
  if (pathParts.length !== 6) {
    return null;
  }

  const suitName = pathParts[4];
  const valueStr = pathParts[5];

  if (!suitName || !valueStr) {
    return null;
  }

  // Convert suit name to enum (case-insensitive)
  const suit = Object.values(Suit).find(s => s.toLowerCase() === suitName.toLowerCase());
  if (!suit) {
    return null;
  }

  // Map string values to CardValue enum
  let cardValue: CardValue;
  
  if (valueStr === 'ace') {
    cardValue = CardValue.Ace;
  } else if (valueStr === 'page') {
    cardValue = CardValue.Page;
  } else if (valueStr === 'knight') {
    cardValue = CardValue.Knight;
  } else if (valueStr === 'queen') {
    cardValue = CardValue.Queen;
  } else if (valueStr === 'king') {
    cardValue = CardValue.King;
  } else {
    // Try to parse as number
    const numValue = parseInt(valueStr, 10);
    if (isNaN(numValue) || numValue < 1 || numValue > 14) {
      return null;
    }
    cardValue = numValue as CardValue;
  }

  const arcana = { suit, value: cardValue };
  const tempCard: TarotCard = {
    type: 'minor',
    arcana,
    name: '',
    uri: '',
    imagePath: ''
  };

  return {
    type: 'minor',
    arcana,
    name: getCardName(tempCard),
    uri: `tarot://card/minor/${suit}/${getCardValueString(cardValue)}`,
    imagePath: `assets/images/minor_arcana_${suit}_${getCardValueString(cardValue)}.png`
  };
}

/**
 * Convert CardValue enum to string representation for URIs
 */
function getCardValueString(value: CardValue): string {
  switch (value) {
    case CardValue.Ace:
      return 'ace';
    case CardValue.Page:
      return 'page';
    case CardValue.Knight:
      return 'knight';
    case CardValue.Queen:
      return 'queen';
    case CardValue.King:
      return 'king';
    default:
      return value.toString();
  }
}

/**
 * Generate a URI for a tarot card
 * 
 * @param card - The tarot card to generate a URI for
 * @returns The URI string
 */
export function generateCardURI(card: TarotCard): string {
  switch (card.type) {
    case 'major':
      return `tarot://card/major/${card.arcana}`;
    case 'minor':
      const minorArcana = card.arcana as { suit: Suit; value: CardValue };
      return `tarot://card/minor/${minorArcana.suit.toLowerCase()}/${getCardValueString(minorArcana.value)}`;
    default:
      throw new Error(`Unknown card type: ${(card as any).type}`);
  }
} 