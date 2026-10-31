import Combine
import Foundation
import PetCore

@MainActor
final class PetStore: ObservableObject {
  @Published private(set) var state: PetState
  @Published var message: Copy?
  @Published var reaction: String?
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
      respond(.fed, symbol: "sparkles")
    } else {
      respond(state.isSleeping ? .letSleep : .chewing, symbol: nil)
    }
    save()
  }

  func pet() {
    if state.pet() {
      respond(.loved, symbol: "heart.fill")
    } else {
      respond(state.isSleeping ? .letSleep : .alreadyLoved, symbol: nil)
    }
    save()
  }

  func toggleSleep() {
    state.toggleSleep()
    respond(state.isSleeping ? .goodNight : .goodMorning, symbol: nil)
    save()
  }

  func text(_ key: Copy) -> String { key.text(language) }

  private func respond(_ text: Copy, symbol: String?) {
    reactionTask?.cancel()
    message = text
    reaction = symbol
    reactionTask = Task { [weak self] in
      do { try await Task.sleep(for: .seconds(3)) } catch { return }
      self?.message = nil
      self?.reaction = nil
    }
  }

  func save() {
    if let data = try? JSONEncoder().encode(state) {
      defaults.set(data, forKey: stateKey)
    }
  }
}
