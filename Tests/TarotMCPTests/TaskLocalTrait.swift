import Testing

struct TaskLocalTrait<Value: Sendable>: Trait, SuiteTrait, TestTrait {
  let value: Value
  let taskLocal: TaskLocal<Value>
}

extension TaskLocalTrait: TestScoping {
  func provideScope(
    for test: Test,
    testCase: Test.Case?,
    performing function: () async throws -> Void
  ) async throws {
    try await taskLocal.withValue(value) {
      try await function()
    }
  }
}

extension Trait {
  static func taskLocal<Value: Sendable>(_ taskLocal: TaskLocal<Value>, value: Value) -> Self
  where Self == TaskLocalTrait<Value> {
    TaskLocalTrait(value: value, taskLocal: taskLocal)
  }
}
