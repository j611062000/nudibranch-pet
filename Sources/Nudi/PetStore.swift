import Combine
import Foundation
import PetCore

@MainActor
final class PetStore: ObservableObject {
  @Published private(set) var state: PetState
  @Published var message: String?
  @Published var reaction: String?
  @Published var isVisible = false
  @Published var quietAnimation: Bool {
    didSet { defaults.set(quietAnimation, forKey: "quietAnimation") }
  }

  private let defaults: UserDefaults
  private var timer: Timer?
  private var reactionTask: Task<Void, Never>?
  private let stateKey = "petState.v1"

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
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
      respond("啊嗚，謝謝你的小點心！", symbol: "sparkles")
    } else {
      respond(state.isSleeping ? "噓，讓牠再睡一下。" : "慢慢嚼，等一下再吃。", symbol: nil)
    }
    save()
  }

  func pet() {
    if state.pet() {
      respond("喜歡你，啵。", symbol: "heart.fill")
    } else {
      respond(state.isSleeping ? "噓，讓牠再睡一下。" : "感受到你的喜歡了 ♡", symbol: nil)
    }
    save()
  }

  func toggleSleep() {
    state.toggleSleep()
    respond(state.isSleeping ? "晚安，海浪會輕輕陪著你。" : "早安！一起慢慢開始吧。", symbol: nil)
    save()
  }

  private func respond(_ text: String, symbol: String?) {
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
