import AppKit

/// One vector character for the status item, panel and app icon.
enum SlugDrawing {
  static func image(size: NSSize, phase: Double = 1, sleeping: Bool = false,
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
      draw(context, phase: phase, sleeping: sleeping)
      context.restoreGState()
      return true
    }
    image.isTemplate = true
    return image
  }

  private static func draw(_ c: CGContext, phase: Double, sleeping: Bool) {
    let breathe = sleeping ? -4.0 : sin(phase * 2.1) * 0.8
    let sway = sleeping ? -4.0 : sin(phase * 1.4) * 1.5
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
    if sleeping {
      c.setLineWidth(1.8)
      c.move(to: CGPoint(x: 21, y: 25))
      c.addQuadCurve(to: CGPoint(x: 27, y: 25), control: CGPoint(x: 24, y: 21))
      c.strokePath()
    } else {
      c.fillEllipse(in: CGRect(x: 22, y: 25 + breathe, width: 3.5, height: 4))
    }
    c.setLineWidth(1.5)
    c.move(to: CGPoint(x: 12, y: 21))
    c.addQuadCurve(to: CGPoint(x: 17, y: 21), control: CGPoint(x: 14, y: 18))
    c.strokePath()
  }
}
