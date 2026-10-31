import Foundation

/// Coordinates are local to our status item, never global screen coordinates.
public struct CrawlState {
  public static let areaWidth: Double = 100
  public static let petWidth: Double = 30
  public static let inset: Double = 3
  public private(set) var x: Double = 35
  public private(set) var facingRight = true
  public private(set) var phase: Double = 0
  public private(set) var pauseRemaining: Double = 0

  public init() {}

  public mutating func step(seconds: Double, paused: Bool = false) {
    guard !paused, seconds.isFinite, seconds > 0 else { return }
    // Never jump after a suspended process or wake from sleep.
    let dt = min(seconds, 0.25)
    phase += dt
    if pauseRemaining > 0 {
      pauseRemaining = max(0, pauseRemaining - dt)
      return
    }
    let end = Self.areaWidth - Self.petWidth - Self.inset
    x += (facingRight ? 1 : -1) * dt * 4
    if x >= end {
      x = end
      facingRight = false
      pauseRemaining = 1.5
    } else if x <= Self.inset {
      x = Self.inset
      facingRight = true
      pauseRemaining = 1.5
    }
  }
}
