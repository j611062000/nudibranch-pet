import AppKit
import ImageIO
import UniformTypeIdentifiers

/// Render a documentation animation with the same art and movement as the app.
/// The surrounding menu bar is illustrative, not a desktop screen recording.
@main
enum DemoRenderer {
  static func main() throws {
    guard CommandLine.arguments.count == 2 else {
      fputs("Usage: render-demo output.gif\n", stderr)
      exit(1)
    }
    let output = URL(fileURLWithPath: CommandLine.arguments[1])
    let size = NSSize(width: 960, height: 270)
    var crawl = CrawlState()
    let initialX = crawl.x
    var states: [(crawl: CrawlState, activity: PetActivity, phase: Double)] = []
    var turns = 0
    repeat {
      states.append((crawl, .wandering, crawl.phase))
      let direction = crawl.facingRight
      crawl.step(seconds: 0.125)
      if direction != crawl.facingRight { turns += 1 }
    } while !(turns >= 2 && crawl.facingRight && crawl.x >= initialX) && states.count < 400

    for activity in [PetActivity.feeding, .petted, .sleeping] {
      let duration = activity == .sleeping ? 4 : activity.reactionDuration
      for frame in 0..<Int(duration * 8) {
        states.append((crawl, activity, Double(frame) / 8))
      }
    }

    guard let destination = CGImageDestinationCreateWithURL(output as CFURL, UTType.gif.identifier as CFString, states.count, nil) else {
      throw NSError(domain: "NudiDemo", code: 1)
    }
    CGImageDestinationSetProperties(destination, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] as CFDictionary)
    for state in states {
      try autoreleasepool {
        let frame = NSImage(size: size, flipped: false) { rect in
          NSColor(white: 0.075, alpha: 1).setFill()
          rect.fill()
          text("NUDI", at: CGPoint(x: 42, y: 211), size: 20, weight: .bold, color: .white)
          text("A little sea slug for your menu bar.", at: CGPoint(x: 42, y: 181), size: 15, color: NSColor(white: 0.58, alpha: 1))

          NSColor.black.setFill()
          NSRect(x: 24, y: 90, width: 912, height: 56).fill()
          text("Finder", at: CGPoint(x: 48, y: 109), size: 14, weight: .semibold)
          text("File     Edit     View", at: CGPoint(x: 110, y: 109), size: 14)

          let pet = SlugDrawing.image(size: NSSize(width: 100, height: 18), phase: state.phase, activity: state.activity,
                                     facingRight: state.crawl.facingRight, x: state.crawl.x)
          tint(pet).draw(in: NSRect(x: 487, y: 100, width: 200, height: 36))
          symbol("wifi", in: NSRect(x: 746, y: 105, width: 25, height: 25))
          symbol("battery.100", in: NSRect(x: 794, y: 104, width: 35, height: 26))
          text("9:41", at: CGPoint(x: 860, y: 109), size: 14, weight: .medium)

          let caption: String
          switch state.activity {
          case .wandering: caption = "Slow steps. Tiny naps. A softer workday."
          case .feeding: caption = "Feed / 餵食 — a little snack, a little munch."
          case .petted: caption = "Pet / 摸摸 — a happy wiggle and a little love."
          case .sleeping: caption = "Sleep / 睡覺 — soft breaths and tiny Zs."
          }
          text(caption, at: CGPoint(x: 42, y: 39), size: 13, color: NSColor(white: 0.48, alpha: 1))
          text("English / 繁體中文", at: CGPoint(x: 778, y: 39), size: 12, color: NSColor(white: 0.48, alpha: 1))
          return true
        }
        guard let cg = frame.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
          throw NSError(domain: "NudiDemo", code: 2)
        }
        CGImageDestinationAddImage(destination, cg, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 0.125, kCGImagePropertyGIFUnclampedDelayTime: 0.125]] as CFDictionary)
      }
    }
    guard CGImageDestinationFinalize(destination) else { throw NSError(domain: "NudiDemo", code: 3) }
    print("Rendered \(states.count) frames at 8 fps: \(output.lastPathComponent)")
  }

  static func tint(_ image: NSImage) -> NSImage {
    image.isTemplate = false
    return NSImage(size: image.size, flipped: false) { rect in
      image.draw(in: rect)
      NSColor.white.setFill()
      rect.fill(using: .sourceAtop)
      return true
    }
  }

  static func symbol(_ name: String, in rect: NSRect) {
    if let image = NSImage(systemSymbolName: name, accessibilityDescription: nil) { tint(image).draw(in: rect) }
  }

  static func text(_ value: String, at point: CGPoint, size: CGFloat,
                   weight: NSFont.Weight = .regular, color: NSColor = .white) {
    (value as NSString).draw(at: point, withAttributes: [.font: NSFont.systemFont(ofSize: size, weight: weight), .foregroundColor: color])
  }
}
