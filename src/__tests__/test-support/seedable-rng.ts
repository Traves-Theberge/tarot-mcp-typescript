/**
 * TypeScript equivalent of Swift's SeedablePseudoRNG
 * A simple seeded Linear Congruential Generator for deterministic testing
 */
export class SeedablePseudoRNG {
  private state: number;

  constructor(seed: number = 1) {
    this.state = seed >>> 0; // Ensure unsigned 32-bit integer
  }

  /**
   * Generate next random number using LCG algorithm
   * Uses parameters from Numerical Recipes: a = 1664525, c = 1013904223, m = 2^32
   */
  next(): number {
    // LCG formula: (a * state + c) % m
    this.state = Math.imul(this.state, 1664525) + 1013904223;
    this.state = this.state >>> 0; // Keep as unsigned 32-bit
    return this.state;
  }

  /**
   * Generate random number between 0 and 1 (exclusive)
   */
  random(): number {
    return this.next() / 0x100000000; // 2^32
  }

  /**
   * Generate random integer between min (inclusive) and max (exclusive)
   */
  randomInt(min: number, max: number): number {
    return Math.floor(this.random() * (max - min)) + min;
  }

  /**
   * Reset the generator to a specific seed
   */
  seed(newSeed: number): void {
    this.state = newSeed >>> 0;
  }
} 