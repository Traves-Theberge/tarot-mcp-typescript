/**
 * Utility functions for generating tarot card names
 */

import { MajorArcana, CardValue, Suit, TarotCard } from './tarot-card.js';

/**
 * Get the display name for a Major Arcana card
 */
export function getMajorArcanaName(arcana: MajorArcana): string {
  switch (arcana) {
    case MajorArcana.Fool:
      return 'The Fool';
    case MajorArcana.Magician:
      return 'The Magician';
    case MajorArcana.HighPriestess:
      return 'The High Priestess';
    case MajorArcana.Empress:
      return 'The Empress';
    case MajorArcana.Emperor:
      return 'The Emperor';
    case MajorArcana.Hierophant:
      return 'The Hierophant';
    case MajorArcana.Lovers:
      return 'The Lovers';
    case MajorArcana.Chariot:
      return 'The Chariot';
    case MajorArcana.Strength:
      return 'Strength';
    case MajorArcana.Hermit:
      return 'The Hermit';
    case MajorArcana.WheelOfFortune:
      return 'Wheel of Fortune';
    case MajorArcana.Justice:
      return 'Justice';
    case MajorArcana.HangedMan:
      return 'The Hanged Man';
    case MajorArcana.Death:
      return 'Death';
    case MajorArcana.Temperance:
      return 'Temperance';
    case MajorArcana.Devil:
      return 'The Devil';
    case MajorArcana.Tower:
      return 'The Tower';
    case MajorArcana.Star:
      return 'The Star';
    case MajorArcana.Moon:
      return 'The Moon';
    case MajorArcana.Sun:
      return 'The Sun';
    case MajorArcana.Judgement:
      return 'Judgement';
    case MajorArcana.World:
      return 'The World';
    default:
      throw new Error(`Unknown Major Arcana: ${arcana}`);
  }
}

/**
 * Get the display name for a card value
 */
export function getCardValueName(value: CardValue): string {
  switch (value) {
    case CardValue.Ace:
      return 'Ace';
    case CardValue.Two:
      return 'Two';
    case CardValue.Three:
      return 'Three';
    case CardValue.Four:
      return 'Four';
    case CardValue.Five:
      return 'Five';
    case CardValue.Six:
      return 'Six';
    case CardValue.Seven:
      return 'Seven';
    case CardValue.Eight:
      return 'Eight';
    case CardValue.Nine:
      return 'Nine';
    case CardValue.Ten:
      return 'Ten';
    case CardValue.Page:
      return 'Page';
    case CardValue.Knight:
      return 'Knight';
    case CardValue.Queen:
      return 'Queen';
    case CardValue.King:
      return 'King';
    default:
      throw new Error(`Unknown Card Value: ${value}`);
  }
}

/**
 * Get the display name for a Minor Arcana card
 */
export function getMinorArcanaName(suit: Suit, value: CardValue): string {
  const suitName = suit.charAt(0).toUpperCase() + suit.slice(1);
  return `${getCardValueName(value)} of ${suitName}`;
}

/**
 * Get the display name for any tarot card
 */
export function getCardName(card: TarotCard): string {
  switch (card.type) {
    case 'major':
      return getMajorArcanaName(card.arcana as MajorArcana);
    case 'minor':
      const minorArcana = card.arcana as { suit: Suit; value: CardValue };
      return getMinorArcanaName(minorArcana.suit, minorArcana.value);
    default:
      throw new Error(`Unknown card type: ${(card as any).type}`);
  }
} 