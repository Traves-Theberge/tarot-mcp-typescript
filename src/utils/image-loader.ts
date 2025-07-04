/**
 * Image loading and encoding utilities for tarot cards
 */

import { readFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';
import { TarotCard, MajorArcana, Suit, CardValue } from '../core/index.js';

/**
 * Error thrown when an image cannot be found or loaded
 */
export class ImageLoadError extends Error {
  constructor(message: string, public readonly cardName?: string) {
    super(message);
    this.name = 'ImageLoadError';
  }
}

/**
 * Get the filename for a major arcana card image
 */
function getMajorArcanaImageFileName(arcana: MajorArcana): string {
  const fileNameMap: Record<MajorArcana, string> = {
    [MajorArcana.Fool]: 'major_arcana_fool',
    [MajorArcana.Magician]: 'major_arcana_magician',
    [MajorArcana.HighPriestess]: 'major_arcana_priestess',
    [MajorArcana.Empress]: 'major_arcana_empress',
    [MajorArcana.Emperor]: 'major_arcana_emperor',
    [MajorArcana.Hierophant]: 'major_arcana_hierophant',
    [MajorArcana.Lovers]: 'major_arcana_lovers',
    [MajorArcana.Chariot]: 'major_arcana_chariot',
    [MajorArcana.Strength]: 'major_arcana_strength',
    [MajorArcana.Hermit]: 'major_arcana_hermit',
    [MajorArcana.WheelOfFortune]: 'major_arcana_fortune',
    [MajorArcana.Justice]: 'major_arcana_justice',
    [MajorArcana.HangedMan]: 'major_arcana_hanged',
    [MajorArcana.Death]: 'major_arcana_death',
    [MajorArcana.Temperance]: 'major_arcana_temperance',
    [MajorArcana.Devil]: 'major_arcana_devil',
    [MajorArcana.Tower]: 'major_arcana_tower',
    [MajorArcana.Star]: 'major_arcana_star',
    [MajorArcana.Moon]: 'major_arcana_moon',
    [MajorArcana.Sun]: 'major_arcana_sun',
    [MajorArcana.Judgement]: 'major_arcana_judgement',
    [MajorArcana.World]: 'major_arcana_world',
  };

  return fileNameMap[arcana];
}

/**
 * Get the filename for a minor arcana card image
 */
function getMinorArcanaImageFileName(suit: Suit, value: CardValue): string {
  const suitName = suit.toLowerCase();

  const valueNameMap: Record<CardValue, string> = {
    [CardValue.Ace]: 'ace',
    [CardValue.Two]: '2',
    [CardValue.Three]: '3',
    [CardValue.Four]: '4',
    [CardValue.Five]: '5',
    [CardValue.Six]: '6',
    [CardValue.Seven]: '7',
    [CardValue.Eight]: '8',
    [CardValue.Nine]: '9',
    [CardValue.Ten]: '10',
    [CardValue.Page]: 'page',
    [CardValue.Knight]: 'knight',
    [CardValue.Queen]: 'queen',
    [CardValue.King]: 'king',
  };

  const valueName = valueNameMap[value];
  return `minor_arcana_${suitName}_${valueName}`;
}

/**
 * Get the image filename for any tarot card
 */
function getCardImageFileName(card: TarotCard): string {
  switch (card.type) {
    case 'major':
      return `${getMajorArcanaImageFileName(card.arcana as MajorArcana)}.png`;
    case 'minor':
      const minorArcana = card.arcana as { suit: Suit; value: CardValue };
      return `${getMinorArcanaImageFileName(minorArcana.suit, minorArcana.value)}.png`;
    default:
      throw new Error(`Unknown card type: ${(card as any).type}`);
  }
}

/**
 * Load a tarot card image as base64-encoded string
 */
export function loadCardImageAsBase64(card: TarotCard): string {
  try {
    const fileName = getCardImageFileName(card);
    const imagePath = join(process.cwd(), 'assets', 'images', fileName);

    if (!existsSync(imagePath)) {
      throw new ImageLoadError(`Image file not found: ${fileName}`, getCardDisplayName(card));
    }

    const imageData = readFileSync(imagePath);
    return imageData.toString('base64');
  } catch (error) {
    if (error instanceof ImageLoadError) {
      throw error;
    }
    
    const cardName = getCardDisplayName(card);
    throw new ImageLoadError(`Failed to load image for card: ${cardName}`, cardName);
  }
}

/**
 * Helper function to get card display name for error messages
 */
function getCardDisplayName(card: TarotCard): string {
  // Import here to avoid circular dependencies
  const { getCardName } = require('../core/card-names.js') as typeof import('../core/card-names.js');
  return getCardName(card);
} 