extension Task where Success == Never, Failure == Never {
  static func megaYield() async {
    for _ in 1...30 {
      let task = Task<Void, Never>.detached(priority: .low) {
        for _ in 1...30 {
          await Task.yield()
        }
      }
      await Task.yield()
      await task.value
    }
  }
}
