import Foundation

/// A gentle companion: needs stop falling at 20, and there is no death state.
public struct PetState: Codable, Equatable {
  public var name = "小紫"
  public var fullness: Double = 80
  public var happiness: Double = 85
  public var energy: Double = 90
  public var isSleeping = false
  public var lastUpdated: Date
  public var lastFed: Date?
  public var lastPetted: Date?

  public init(now: Date = Date()) {
    lastUpdated = now
  }

  public mutating func advance(to now: Date) {
    let elapsed = now.timeIntervalSince(lastUpdated)
    // A backward clock change must not grant energy or subtract needs.
    guard elapsed >= 0 else {
      lastUpdated = now
      return
    }
    let hours = min(elapsed, 24 * 60 * 60) / 3600
    fullness = max(20, min(100, fullness - hours * 3))
    happiness = max(20, min(100, happiness - hours * 2))
    energy = max(20, min(100, energy + hours * (isSleeping ? 18 : -4)))
    lastUpdated = now
  }

  @discardableResult
  public mutating func feed(at now: Date = Date()) -> Bool {
    advance(to: now)
    guard !isSleeping, lastFed.map({ now.timeIntervalSince($0) >= 10 }) ?? true else { return false }
    fullness = min(100, fullness + 16)
    happiness = min(100, happiness + 4)
    lastFed = now
    return true
  }

  @discardableResult
  public mutating func pet(at now: Date = Date()) -> Bool {
    advance(to: now)
    guard !isSleeping, lastPetted.map({ now.timeIntervalSince($0) >= 3 }) ?? true else { return false }
    happiness = min(100, happiness + 10)
    lastPetted = now
    return true
  }

  public mutating func toggleSleep(at now: Date = Date()) {
    advance(to: now)
    isSleeping.toggle()
  }

  public var mood: String {
    if isSleeping { return "正在做海底的夢" }
    if fullness < 40 { return "想吃一點小點心" }
    if energy < 40 { return "有一點睏了" }
    if happiness < 40 { return "想跟你待在一起" }
    return "今天也慢慢來就好"
  }
}
