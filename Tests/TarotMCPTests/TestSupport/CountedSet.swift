struct CountedSet<Element: Hashable> {
  private var storage: [Element: Int] = [:]

  mutating func insert(_ element: Element) {
    storage[element, default: 0] += 1
  }

  mutating func remove(_ element: Element) {
    guard let currentCount = storage[element], currentCount > 0 else { return }
    if currentCount == 1 {
      storage.removeValue(forKey: element)
    } else {
      storage[element] = currentCount - 1
    }
  }

  func count(of element: Element) -> Int {
    return storage[element] ?? 0
  }
}
