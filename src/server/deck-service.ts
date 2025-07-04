/**
 * Deck service for drawing and managing tarot cards
 */

import { TarotCard, TarotCardError, createFullDeck, DECK_CONSTANTS } from '../core/index.js';
import {
  RandomNumberGenerator,
  SystemRandomNumberGenerator,
  shuffleArray,
} from '../utils/index.js';

/**
 * Service class for managing tarot deck operations
 */
export class TarotDeckService {
  private static readonly FULL_DECK = createFullDeck();
  private static readonly SHUFFLE_ITERATIONS = 10;

  constructor(private readonly rng: RandomNumberGenerator = new SystemRandomNumberGenerator()) {}

  /**
   * Draw cards from the deck
   * 
   * @param count - Number of cards to draw (1-78)
   * @returns Array of drawn cards
   * @throws TarotCardError if count is invalid
   */
  drawCards(count: number): readonly TarotCard[] {
    this.validateCardCount(count);

    // Create a copy of the full deck
    let deck = [...TarotDeckService.FULL_DECK];

    // Shuffle the deck multiple times for better randomness
    for (let i = 0; i < TarotDeckService.SHUFFLE_ITERATIONS; i++) {
      deck = shuffleArray(deck, this.rng);
    }

    // Return the requested number of cards
    return deck.slice(0, count);
  }

  /**
   * Get the complete tarot deck (78 cards)
   * 
   * @returns Array of all tarot cards
   */
  getFullDeck(): readonly TarotCard[] {
    return [...TarotDeckService.FULL_DECK];
  }

  /**
   * Get the total number of cards in a complete deck
   */
  get deckSize(): number {
    return DECK_CONSTANTS.TOTAL_CARDS;
  }

  /**
   * Validate card count is within valid range
   */
  private validateCardCount(count: number): void {
    if (count < 1 || count > DECK_CONSTANTS.TOTAL_CARDS) {
      throw new TarotCardError(`Invalid card count: ${count}. Must be between 1 and ${DECK_CONSTANTS.TOTAL_CARDS}.`);
    }
  }
} 