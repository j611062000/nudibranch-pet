import Combine
import Foundation
import PetCore

@MainActor
final class PetStore: ObservableObject {
  @Published private(set) var state: PetState
  @Published var message: Copy?
  @Published private(set) var reaction: PetReaction?
  @Published var isVisible = false
  @Published var language: AppLanguage {
    didSet { defaults.set(language.rawValue, forKey: "language") }
  }
  @Published var quietAnimation: Bool {
    didSet { defaults.set(quietAnimation, forKey: "quietAnimation") }
  }

  private let defaults: UserDefaults
  private var timer: Timer?
  private var reactionTask: Task<Void, Never>?
  private var messageTask: Task<Void, Never>?
  private let stateKey = "petState.v1"

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
    language = defaults.string(forKey: "language").flatMap(AppLanguage.init(rawValue:))
      ?? AppLanguage.preferred(Locale.preferredLanguages)
    quietAnimation = defaults.bool(forKey: "quietAnimation")
    if let data = defaults.data(forKey: stateKey),
       let saved = try? JSONDecoder().decode(PetState.self, from: data) {
      state = saved
    } else {
      state = PetState()
    }
    tick()
    timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
      Task { @MainActor in self?.tick() }
    }
    timer?.tolerance = 5
  }

  func tick() {
    state.advance(to: Date())
    save()
  }

  func feed() {
    if state.feed() {
      respond(.fed)
      play(.feeding)
    } else {
      respond(state.isSleeping ? .letSleep : .chewing)
    }
    save()
  }

  func pet() {
    if state.pet() {
      respond(.loved)
      play(.petted)
    } else {
      respond(state.isSleeping ? .letSleep : .alreadyLoved)
    }
    save()
  }

  func toggleSleep() {
    reactionTask?.cancel()
    reaction = nil
    state.toggleSleep()
    respond(state.isSleeping ? .goodNight : .goodMorning)
    save()
  }

  func text(_ key: Copy) -> String { key.text(language) }

  var activity: PetActivity {
    if state.isSleeping { return .sleeping }
    guard let reaction, reaction.isActive(at: ProcessInfo.processInfo.systemUptime) else { return .wandering }
    return reaction.activity
  }

  func animationPhase(at uptime: TimeInterval) -> Double {
    reaction?.elapsed(at: uptime) ?? uptime
  }

  var activityLabel: Copy {
    switch activity {
    case .wandering: return .wandering
    case .feeding: return .munching
    case .petted: return .feelingLoved
    case .sleeping: return .resting
    }
  }

  private func play(_ activity: PetActivity) {
    reactionTask?.cancel()
    reaction = PetReaction(activity: activity, startedAt: ProcessInfo.processInfo.systemUptime)
    reactionTask = Task { [weak self] in
      do { try await Task.sleep(for: .seconds(activity.reactionDuration)) } catch { return }
      self?.reaction = nil
    }
  }

  private func respond(_ text: Copy) {
    messageTask?.cancel()
    message = text
    messageTask = Task { [weak self] in
      do { try await Task.sleep(for: .seconds(3)) } catch { return }
      self?.message = nil
    }
  }

  func save() {
    if let data = try? JSONEncoder().encode(state) {
      defaults.set(data, forKey: stateKey)
    }
  }
}
