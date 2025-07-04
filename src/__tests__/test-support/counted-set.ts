/**
 * TypeScript equivalent of Swift's CountedSet for tracking element frequencies
 */
export class CountedSet<T> {
  private storage = new Map<T, number>();

  insert(element: T): void {
    const currentCount = this.storage.get(element) ?? 0;
    this.storage.set(element, currentCount + 1);
  }

  remove(element: T): void {
    const currentCount = this.storage.get(element);
    if (currentCount === undefined || currentCount <= 0) {
      return;
    }
    if (currentCount === 1) {
      this.storage.delete(element);
    } else {
      this.storage.set(element, currentCount - 1);
    }
  }

  count(element: T): number {
    return this.storage.get(element) ?? 0;
  }

  get size(): number {
    return this.storage.size;
  }

  clear(): void {
    this.storage.clear();
  }
} 