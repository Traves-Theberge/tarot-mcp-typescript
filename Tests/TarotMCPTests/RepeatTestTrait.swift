import Testing

struct RepeatTestTrait: TestTrait, TestScoping {
  struct Failures: Error {
    let underlyingErrors: [any Error]

    init(underlyingErrors: [any Error]) {
      assert(!underlyingErrors.isEmpty)
      self.underlyingErrors = underlyingErrors
    }
  }

  let count: Int

  init(count: Int) {
    assert(count > 1, "RepeatTestTrait requires count > 1")
    self.count = count
  }

  func provideScope(
    for test: Test,
    testCase: Test.Case?,
    performing function: @Sendable () async throws -> Void
  ) async throws {
    var errors = [any Error]()
    for i in 0..<count {
      do {
        try await function()
      } catch {
        errors.append(error)
      }
    }
    if !errors.isEmpty {
      throw Failures(underlyingErrors: errors)
    }
  }
}

extension TestTrait where Self == RepeatTestTrait {
  static func `repeat`(count: Int) -> Self {
    RepeatTestTrait(count: count)
  }
}
