/**
 * Array shuffling utilities using Fisher-Yates algorithm
 */

import { RandomNumberGenerator } from './random-number-generator.js';

/**
 * Shuffle an array in-place using Fisher-Yates algorithm
 * 
 * @param array - The array to shuffle (modified in-place)
 * @param rng - Random number generator to use
 */
export function shuffleArrayInPlace<T>(array: T[], rng: RandomNumberGenerator): void {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(rng.random() * (i + 1));
    const temp = array[i]!;
    array[i] = array[j]!;
    array[j] = temp;
  }
}

/**
 * Create a shuffled copy of an array using Fisher-Yates algorithm
 * 
 * @param array - The array to shuffle (original is not modified)
 * @param rng - Random number generator to use
 * @returns A new shuffled array
 */
export function shuffleArray<T>(array: readonly T[], rng: RandomNumberGenerator): T[] {
  const copy = [...array];
  shuffleArrayInPlace(copy, rng);
  return copy;
} 