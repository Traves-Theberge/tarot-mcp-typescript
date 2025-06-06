import Foundation

/// A simple seeded Linear Congruential Generator for deterministic testing
struct SeedablePseudoRNG: RandomNumberGenerator {
  private var state: UInt64

  init(seed: UInt64 = 1) {
    self.state = seed
  }

  mutating func next() -> UInt64 {
    // LCG parameters from Numerical Recipes
    // a = 1664525, c = 1013904223, m = 2^32
    state = state &* 1_664_525 &+ 1_013_904_223
    return state
  }

}
