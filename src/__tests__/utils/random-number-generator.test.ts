/**
 * Tests for random number generator utilities
 */

import { SystemRandomNumberGenerator } from '../../utils/random-number-generator.js';
import { SeedablePseudoRNG } from '../test-support/index.js';

describe('Random Number Generator Tests', () => {
  describe('SystemRandomNumberGenerator', () => {
    test('generates random numbers', () => {
      const rng = new SystemRandomNumberGenerator();
      
      const num1 = rng.random();
      const num2 = rng.random();
      
      expect(num1).toBeGreaterThanOrEqual(0);
      expect(num1).toBeLessThan(1);
      expect(num2).toBeGreaterThanOrEqual(0);
      expect(num2).toBeLessThan(1);
      
      // Very unlikely to be equal (but theoretically possible)
      expect(num1).not.toBe(num2);
    });

    test('generates numbers in correct range', () => {
      const rng = new SystemRandomNumberGenerator();
      
      for (let i = 0; i < 100; i++) {
        const num = rng.random();
        expect(num).toBeGreaterThanOrEqual(0);
        expect(num).toBeLessThan(1);
      }
    });
  });

  describe('SeedablePseudoRNG', () => {
    test('generates deterministic sequences', () => {
      const rng1 = new SeedablePseudoRNG(42);
      const rng2 = new SeedablePseudoRNG(42);
      
      const sequence1 = Array.from({ length: 10 }, () => rng1.random());
      const sequence2 = Array.from({ length: 10 }, () => rng2.random());
      
      expect(sequence1).toEqual(sequence2);
    });

    test('different seeds produce different sequences', () => {
      const rng1 = new SeedablePseudoRNG(42);
      const rng2 = new SeedablePseudoRNG(43);
      
      const sequence1 = Array.from({ length: 10 }, () => rng1.random());
      const sequence2 = Array.from({ length: 10 }, () => rng2.random());
      
      expect(sequence1).not.toEqual(sequence2);
    });

    test('generates numbers in correct range', () => {
      const rng = new SeedablePseudoRNG(42);
      
      for (let i = 0; i < 100; i++) {
        const num = rng.random();
        expect(num).toBeGreaterThanOrEqual(0);
        expect(num).toBeLessThan(1);
      }
    });

    test('generates consistent values for same seed', () => {
      const rng = new SeedablePseudoRNG(42);
      
      // Test that the same seed always produces the same first few values
      const expectedValues = [rng.random(), rng.random(), rng.random()];
      
      rng.seed(42);
      const actualValues = [rng.random(), rng.random(), rng.random()];
      
      expect(actualValues).toEqual(expectedValues);
    });

    test('can be reseeded', () => {
      const rng = new SeedablePseudoRNG(42);
      const firstSequence = Array.from({ length: 5 }, () => rng.random());
      
      rng.seed(42); // Reset to same seed
      const secondSequence = Array.from({ length: 5 }, () => rng.random());
      
      expect(firstSequence).toEqual(secondSequence);
    });

    test('next() method works correctly', () => {
      const rng = new SeedablePseudoRNG(42);
      
      const values = Array.from({ length: 10 }, () => rng.next());
      
      // All values should be different (very high probability)
      const uniqueValues = new Set(values);
      expect(uniqueValues.size).toBe(values.length);
      
      // All values should be valid 32-bit unsigned integers
      for (const value of values) {
        expect(value).toBeGreaterThanOrEqual(0);
        expect(value).toBeLessThan(0x100000000); // 2^32
        expect(Number.isInteger(value)).toBe(true);
      }
    });
  });
}); 