import AppKit
import Combine
import PetCore
import SwiftUI

@main
enum NudiApp {
  @MainActor static func main() {
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    if CommandLine.arguments.count == 3, CommandLine.arguments[1] == "--render-icon" {
      exportIcon(to: CommandLine.arguments[2])
      return
    }
    let delegate = AppDelegate()
    app.delegate = delegate
    withExtendedLifetime(delegate) { app.run() }
  }

  @MainActor private static func exportIcon(to path: String) {
    let size = NSSize(width: 1024, height: 1024)
    let image = NSImage(size: size, flipped: false) { _ in
      NSColor(white: 0.09, alpha: 1).setFill()
      NSBezierPath(roundedRect: NSRect(x: 40, y: 40, width: 944, height: 944), xRadius: 210, yRadius: 210).fill()
      let pet = SlugDrawing.image(size: NSSize(width: 780, height: 500))
      pet.isTemplate = false
      // Draw the black silhouette into a layer, then tint it white.
      let whitePet = NSImage(size: pet.size, flipped: false) { rect in
        pet.draw(in: rect)
        NSColor.white.setFill()
        rect.fill(using: .sourceAtop)
        return true
      }
      whitePet.draw(in: NSRect(x: 122, y: 260, width: 780, height: 500))
      return true
    }
    guard let data = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: data),
          let png = bitmap.representation(using: .png, properties: [:]) else {
      fputs("Could not render app icon.\n", stderr)
      exit(1)
    }
    do { try png.write(to: URL(fileURLWithPath: path)) }
    catch { fputs("Could not write app icon.\n", stderr); exit(1) }
  }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
  private let store = PetStore()
  private let popover = NSPopover()
  private var statusItem: NSStatusItem!
  private var crawl = CrawlState()
  private var animationTimer: Timer?
  private var animationInterval: TimeInterval?
  private var lastFrame = ProcessInfo.processInfo.systemUptime
  private var subscriptions = Set<AnyCancellable>()
  private var screenAwake = true

  func applicationDidFinishLaunching(_ notification: Notification) {
    statusItem = NSStatusBar.system.statusItem(withLength: CrawlState.areaWidth + 8)
    statusItem.autosaveName = "Nudi.StatusItem"
    guard let button = statusItem.button else { return }
    button.target = self
    button.action = #selector(togglePopover)
    button.imagePosition = .imageOnly
    button.imageScaling = .scaleNone
    button.setAccessibilityIdentifier("nudi.status")

    popover.behavior = .transient
    popover.animates = false
    popover.delegate = self
    popover.contentViewController = NSHostingController(rootView: PetView(store: store))

    store.$state.combineLatest(store.$quietAnimation, store.$language, store.$reaction)
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in self?.refresh() }
      .store(in: &subscriptions)

    let center = NSWorkspace.shared.notificationCenter
    center.addObserver(self, selector: #selector(pauseForWorkspace), name: NSWorkspace.screensDidSleepNotification, object: nil)
    center.addObserver(self, selector: #selector(pauseForWorkspace), name: NSWorkspace.sessionDidResignActiveNotification, object: nil)
    center.addObserver(self, selector: #selector(pauseForWorkspace), name: NSWorkspace.willSleepNotification, object: nil)
    center.addObserver(self, selector: #selector(resumeForWorkspace), name: NSWorkspace.screensDidWakeNotification, object: nil)
    center.addObserver(self, selector: #selector(resumeForWorkspace), name: NSWorkspace.sessionDidBecomeActiveNotification, object: nil)
    center.addObserver(self, selector: #selector(resumeForWorkspace), name: NSWorkspace.didWakeNotification, object: nil)
    center.addObserver(self, selector: #selector(accessibilityChanged), name: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification, object: nil)
    refresh()

    if !UserDefaults.standard.bool(forKey: "hasLaunched") {
      UserDefaults.standard.set(true, forKey: "hasLaunched")
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in self?.showPopover() }
    }
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    showPopover()
    return false
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }

  func applicationWillTerminate(_ notification: Notification) {
    animationTimer?.invalidate()
    store.tick()
    NSWorkspace.shared.notificationCenter.removeObserver(self)
  }

  @objc private func togglePopover() {
    if popover.isShown { popover.performClose(nil) } else { showPopover() }
  }

  private func showPopover() {
    guard let button = statusItem?.button else { return }
    store.tick()
    store.isVisible = true
    NSApp.activate(ignoringOtherApps: true)
    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    popover.contentViewController?.view.window?.makeKey()
  }

  func popoverDidClose(_ notification: Notification) { store.isVisible = false }

  @objc private func pauseForWorkspace() {
    screenAwake = false
    popover.performClose(nil)
    refresh()
  }

  @objc private func resumeForWorkspace() {
    screenAwake = true
    store.tick()
    refresh()
  }

  @objc private func accessibilityChanged() { refresh() }

  private var shouldAnimate: Bool {
    screenAwake && !store.quietAnimation
      && !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
  }

  private func refresh() {
    guard let button = statusItem?.button else { return }
    button.toolTip = store.text(.openPet) + " · " + store.text(store.activityLabel)
    button.setAccessibilityLabel(button.toolTip)
    drawFrame()
    let interval: TimeInterval = store.state.isSleeping ? 0.5 : 0.1
    if shouldAnimate && (animationTimer == nil || animationInterval != interval) {
      animationTimer?.invalidate()
      animationInterval = interval
      lastFrame = ProcessInfo.processInfo.systemUptime
      let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
        MainActor.assumeIsolated { self?.animate() }
      }
      timer.tolerance = 0.025
      RunLoop.main.add(timer, forMode: .common)
      animationTimer = timer
    } else if !shouldAnimate {
      animationTimer?.invalidate()
      animationTimer = nil
      animationInterval = nil
    }
  }

  private func animate() {
    let now = ProcessInfo.processInfo.systemUptime
    let elapsed = now - lastFrame
    lastFrame = now
    guard statusItem.button?.window?.isVisible == true else { return }
    crawl.step(seconds: elapsed, paused: store.activity.pausesWalking)
    drawFrame()
  }

  private func drawFrame() {
    statusItem.button?.image = SlugDrawing.image(
      size: NSSize(width: CrawlState.areaWidth, height: 18),
      phase: shouldAnimate ? store.animationPhase(at: ProcessInfo.processInfo.systemUptime) : 1,
      activity: store.activity, facingRight: crawl.facingRight, x: crawl.x)
  }
}
