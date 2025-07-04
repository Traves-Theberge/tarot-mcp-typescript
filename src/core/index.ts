/**
 * Core tarot domain models and utilities
 * 
 * This module exports all the core types, enums, and utility functions
 * for working with tarot cards and decks.
 */

// Core types and enums
export * from './tarot-card.js';

// Naming utilities
export * from './card-names.js';

// Deck creation utilities
export * from './deck-factory.js';

// Constants
export const DECK_CONSTANTS = {
  TOTAL_CARDS: 78,
  MAJOR_ARCANA_COUNT: 22,
  MINOR_ARCANA_COUNT: 56,
  SUITS_COUNT: 4,
  VALUES_PER_SUIT: 14
} as const; 