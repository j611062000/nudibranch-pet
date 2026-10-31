import AppKit
#if canImport(PetCore)
import PetCore
#endif

/// One vector character for the status item, panel and app icon.
enum SlugDrawing {
  static func image(size: NSSize, phase: Double = 1, activity: PetActivity = .wandering,
                    facingRight: Bool = false, x: Double? = nil) -> NSImage {
    let image = NSImage(size: size, flipped: false) { rect in
      guard let context = NSGraphicsContext.current?.cgContext else { return false }
      context.saveGState()
      context.clip(to: rect)
      let width = x == nil ? size.width : 30
      let scale = min(width / 100, size.height / 64)
      let originX = x ?? (size.width - 100 * scale) / 2
      context.translateBy(x: originX, y: (size.height - 64 * scale) / 2)
      context.scaleBy(x: scale, y: scale)
      if facingRight {
        context.translateBy(x: 100, y: 0)
        context.scaleBy(x: -1, y: 1)
      }
      draw(context, phase: phase, activity: activity, showEffects: x == nil)
      context.restoreGState()
      if let x, activity != .wandering {
        context.saveGState()
        context.clip(to: rect)
        context.translateBy(x: PetActivity.badgeX(petX: x), y: 5 + (sin(phase * 2) + 1))
        context.setFillColor(NSColor.black.cgColor)
        context.setStrokeColor(NSColor.black.cgColor)
        if activity == .petted {
          let heart = CGMutablePath()
          heart.move(to: CGPoint(x: 4, y: 0))
          heart.addCurve(to: CGPoint(x: 0, y: 5), control1: CGPoint(x: 2, y: 2), control2: CGPoint(x: -1, y: 3))
          heart.addCurve(to: CGPoint(x: 4, y: 5), control1: CGPoint(x: 0, y: 8), control2: CGPoint(x: 3, y: 8))
          heart.addCurve(to: CGPoint(x: 8, y: 5), control1: CGPoint(x: 5, y: 8), control2: CGPoint(x: 8, y: 8))
          heart.addCurve(to: CGPoint(x: 4, y: 0), control1: CGPoint(x: 9, y: 3), control2: CGPoint(x: 6, y: 2))
          context.addPath(heart)
          context.fillPath()
        } else if activity == .feeding {
          let bite = Int(phase * 2).isMultiple(of: 2)
          context.fillEllipse(in: CGRect(x: 1, y: 1, width: 6, height: 6))
          if bite {
            context.setBlendMode(.clear)
            context.fillEllipse(in: CGRect(x: 4, y: 4, width: 4, height: 4))
          }
        } else {
          context.setLineWidth(1.2)
          context.setLineCap(.round)
          context.move(to: CGPoint(x: 1, y: 6))
          context.addLine(to: CGPoint(x: 6, y: 6))
          context.addLine(to: CGPoint(x: 1, y: 1))
          context.addLine(to: CGPoint(x: 6, y: 1))
          context.strokePath()
        }
        context.restoreGState()
      }
      return true
    }
    image.isTemplate = true
    return image
  }

  private static func draw(_ c: CGContext, phase: Double, activity: PetActivity, showEffects: Bool) {
    let sleeping = activity == .sleeping
    let chewing = activity == .feeding
    let happy = activity == .petted
    let breathe = sleeping ? -8 + sin(phase * 1.2) * 0.5 : sin(phase * 2.1) * 0.8
    let sway = sleeping ? -7.0 : sin(phase * (happy ? 5 : 1.4)) * (happy ? 2.5 : 1.5)
    c.saveGState()
    c.translateBy(x: 50, y: 8)
    if chewing { c.scaleBy(x: 1 + sin(phase * 10) * 0.025, y: 1 - sin(phase * 10) * 0.04) }
    if happy { c.rotate(by: sin(phase * 5) * 0.035) }
    c.translateBy(x: -50, y: -8)
    c.setFillColor(NSColor.black.cgColor)
    let body = CGMutablePath()
    body.move(to: CGPoint(x: 7, y: 19))
    body.addCurve(to: CGPoint(x: 31, y: 44 + breathe), control1: CGPoint(x: 6, y: 31), control2: CGPoint(x: 16, y: 42 + breathe))
    body.addCurve(to: CGPoint(x: 76, y: 31 + breathe), control1: CGPoint(x: 47, y: 53 + breathe), control2: CGPoint(x: 68, y: 45 + breathe))
    body.addCurve(to: CGPoint(x: 93, y: 16), control1: CGPoint(x: 81, y: 23), control2: CGPoint(x: 91, y: 23))
    body.addCurve(to: CGPoint(x: 39, y: 8), control1: CGPoint(x: 96, y: 8), control2: CGPoint(x: 65, y: 7))
    body.addCurve(to: CGPoint(x: 7, y: 19), control1: CGPoint(x: 21, y: 7), control2: CGPoint(x: 9, y: 9))
    body.closeSubpath()
    c.addPath(body)
    c.fillPath()

    c.setStrokeColor(NSColor.black.cgColor)
    c.setLineCap(.round)
    c.setLineWidth(6.5)
    for (baseX, tipX, tipY) in [(20.0, 14.0, 52.0), (31.0, 29.0, 57.0)] {
      c.move(to: CGPoint(x: baseX, y: 38 + breathe))
      c.addQuadCurve(to: CGPoint(x: tipX + sway, y: tipY + breathe), control: CGPoint(x: baseX - 2, y: 48 + breathe))
      c.strokePath()
    }
    // Rounded gill rosette with negative gaps that survive small sizes.
    c.setLineWidth(5)
    for (dx, dy) in [(-8.0, 12.0), (-1.0, 18.0), (7.0, 16.0), (13.0, 9.0)] {
      c.move(to: CGPoint(x: 70, y: 34 + breathe))
      c.addLine(to: CGPoint(x: 70 + dx + sway * 0.5, y: 34 + dy + breathe))
      c.strokePath()
    }

    // Clear pixels rather than a fixed eye color: template tint remains native.
    c.setBlendMode(.clear)
    if sleeping || happy {
      c.setLineWidth(1.8)
      c.move(to: CGPoint(x: 21, y: 25))
      c.addQuadCurve(to: CGPoint(x: 27, y: 25), control: CGPoint(x: 24, y: 21))
      c.strokePath()
    } else {
      c.fillEllipse(in: CGRect(x: 22, y: 25 + breathe, width: 3.5, height: 4))
    }
    if chewing {
      c.fillEllipse(in: CGRect(x: 11, y: 18, width: 6, height: 3 + (sin(phase * 10) + 1) * 1.5))
    } else {
      c.setLineWidth(1.5)
      c.move(to: CGPoint(x: 12, y: 21))
      c.addQuadCurve(to: CGPoint(x: 17, y: 21), control: CGPoint(x: 14, y: 18))
      c.strokePath()
    }
    c.restoreGState()

    c.setFillColor(NSColor.black.cgColor)
    c.setStrokeColor(NSColor.black.cgColor)
    if chewing && showEffects {
      let bite = (phase * 2).truncatingRemainder(dividingBy: 1)
      c.fillEllipse(in: CGRect(x: 1 + bite * 7, y: 21 + sin(bite * .pi) * 5, width: 3.5, height: 3.5))
      c.fillEllipse(in: CGRect(x: 2, y: 32, width: 2, height: 2))
    }
    if happy && showEffects {
      let y = 48 + (sin(phase * 2) + 1) * 2
      let heart = CGMutablePath()
      heart.move(to: CGPoint(x: 48, y: y))
      heart.addCurve(to: CGPoint(x: 42, y: y + 7), control1: CGPoint(x: 44, y: y + 3), control2: CGPoint(x: 40, y: y + 4))
      heart.addCurve(to: CGPoint(x: 48, y: y + 7), control1: CGPoint(x: 43, y: y + 11), control2: CGPoint(x: 47, y: y + 10))
      heart.addCurve(to: CGPoint(x: 54, y: y + 7), control1: CGPoint(x: 50, y: y + 10), control2: CGPoint(x: 54, y: y + 11))
      heart.addCurve(to: CGPoint(x: 48, y: y), control1: CGPoint(x: 56, y: y + 4), control2: CGPoint(x: 52, y: y + 3))
      c.addPath(heart)
      c.fillPath()
    }
    if sleeping && showEffects {
      let float = (sin(phase * 1.2) + 1) * 1.5
      c.setLineWidth(1.6)
      c.setLineCap(.round)
      c.setLineJoin(.round)
      for (x, y, size) in [(44.0, 43.0 + float, 5.0), (54.0, 51.0 + float, 7.0)] {
        c.move(to: CGPoint(x: x, y: y + size))
        c.addLine(to: CGPoint(x: x + size, y: y + size))
        c.addLine(to: CGPoint(x: x, y: y))
        c.addLine(to: CGPoint(x: x + size, y: y))
        c.strokePath()
      }
    }
  }
}
