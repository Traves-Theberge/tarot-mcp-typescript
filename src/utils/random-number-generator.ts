/**
 * Random number generation utilities for deterministic and system randomness
 */

/**
 * Interface for random number generators
 */
export interface RandomNumberGenerator {
  /**
   * Generate a random number between 0 (inclusive) and 1 (exclusive)
   */
  random(): number;
}

/**
 * System random number generator using Math.random()
 */
export class SystemRandomNumberGenerator implements RandomNumberGenerator {
  random(): number {
    return Math.random();
  }
}

/**
 * Seedable pseudo-random number generator for deterministic testing
 * Uses Linear Congruential Generator (LCG) algorithm
 */
export class SeedablePseudoRNG implements RandomNumberGenerator {
  private seed: number;

  constructor(seed: number) {
    this.seed = seed;
  }

  random(): number {
    // Linear Congruential Generator (LCG) algorithm
    // Using the same constants as many standard implementations
    this.seed = (this.seed * 1664525 + 1013904223) % 2 ** 32;
    return this.seed / 2 ** 32;
  }

  /**
   * Reset the generator with a new seed
   */
  reset(seed: number): void {
    this.seed = seed;
  }

  /**
   * Get the current seed value
   */
  getCurrentSeed(): number {
    return this.seed;
  }
} 