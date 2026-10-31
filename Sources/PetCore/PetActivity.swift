import Foundation

public enum PetActivity: String, CaseIterable {
  case wandering, feeding, petted, sleeping

  public var pausesWalking: Bool { self != .wandering }
  public var reactionDuration: Double {
    switch self {
    case .feeding: return 4
    case .petted: return 3
    default: return 0
    }
  }

  /// Leave a readable 8-point reaction badge beside the 30-point pet.
  public static func badgeX(petX: Double) -> Double {
    let right = petX + CrawlState.petWidth + 2
    return right + 8 <= CrawlState.areaWidth - 1 ? right : max(1, petX - 10)
  }
}

/// Uses a monotonic clock so changing the wall clock cannot stretch a reaction.
public struct PetReaction: Equatable {
  public let activity: PetActivity
  public let startedAt: TimeInterval

  public init(activity: PetActivity, startedAt: TimeInterval) {
    self.activity = activity
    self.startedAt = startedAt
  }

  public func elapsed(at uptime: TimeInterval) -> Double { max(0, uptime - startedAt) }
  public func isActive(at uptime: TimeInterval) -> Bool {
    elapsed(at: uptime) < activity.reactionDuration
  }
}
