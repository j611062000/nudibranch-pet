import SwiftUI

enum OceanStyle {
  static let ink = Color(red: 0.055, green: 0.12, blue: 0.16)
  static let mint = Color(red: 0.65, green: 0.88, blue: 0.80)
  static let lavender = Color(red: 0.77, green: 0.70, blue: 0.94)
  static let cream = Color(red: 0.98, green: 0.95, blue: 0.88)
}

/// Original vector artwork; no downloaded assets or image services.
struct SlugArt: View {
  var time: Double = 0
  var sleeping = false

  var body: some View {
    Canvas { context, size in
      let scale = min(size.width / 280, size.height / 180)
      context.translateBy(x: (size.width - 280 * scale) / 2, y: (size.height - 180 * scale) / 2)
      context.scaleBy(x: scale, y: scale)
      let breath = sin(time * 1.8) * (sleeping ? 1.2 : 2.2)
      let sway = sin(time * 1.3) * 3

      // Soft foot, broad ruffled mantle, and a tapered tail.
      var foot = Path()
      foot.move(to: CGPoint(x: 29, y: 137))
      foot.addCurve(to: CGPoint(x: 245, y: 142), control1: CGPoint(x: 80, y: 99), control2: CGPoint(x: 223, y: 100))
      foot.addQuadCurve(to: CGPoint(x: 263, y: 153), control: CGPoint(x: 253, y: 153))
      foot.addCurve(to: CGPoint(x: 29, y: 149), control1: CGPoint(x: 198, y: 174), control2: CGPoint(x: 51, y: 168))
      foot.closeSubpath()
      context.fill(foot, with: .color(Color(red: 0.72, green: 0.63, blue: 0.83)))

      var mantle = Path()
      mantle.move(to: CGPoint(x: 26, y: 137))
      mantle.addCurve(to: CGPoint(x: 90, y: 78 + breath), control1: CGPoint(x: 20, y: 101), control2: CGPoint(x: 51, y: 73 + breath))
      mantle.addCurve(to: CGPoint(x: 212, y: 111 + breath), control1: CGPoint(x: 131, y: 62 + breath), control2: CGPoint(x: 192, y: 80 + breath))
      mantle.addQuadCurve(to: CGPoint(x: 249, y: 140), control: CGPoint(x: 231, y: 136))
      mantle.addQuadCurve(to: CGPoint(x: 218, y: 149), control: CGPoint(x: 240, y: 154))
      mantle.addQuadCurve(to: CGPoint(x: 181, y: 151), control: CGPoint(x: 199, y: 163))
      mantle.addQuadCurve(to: CGPoint(x: 143, y: 153), control: CGPoint(x: 161, y: 163))
      mantle.addQuadCurve(to: CGPoint(x: 101, y: 150), control: CGPoint(x: 122, y: 164))
      mantle.addQuadCurve(to: CGPoint(x: 63, y: 149), control: CGPoint(x: 80, y: 160))
      mantle.addQuadCurve(to: CGPoint(x: 26, y: 137), control: CGPoint(x: 32, y: 157))
      mantle.closeSubpath()
      context.fill(mantle, with: .linearGradient(
        Gradient(colors: [.white, OceanStyle.cream, Color(red: 0.88, green: 0.80, blue: 0.91)]),
        startPoint: CGPoint(x: 100, y: 65), endPoint: CGPoint(x: 130, y: 164)))
      context.stroke(mantle, with: .color(OceanStyle.lavender), lineWidth: 3)

      // A rosette of gills at the rear makes this a nudibranch, not a snail.
      for index in 0..<7 {
        let angle = Double(index) * 0.47 - 1.42
        let base = CGPoint(x: 187, y: 103 + breath)
        let tip = CGPoint(x: 187 + sin(angle) * 34 + sway, y: 98 - cos(angle) * 43 + breath)
        var leaf = Path()
        leaf.move(to: base)
        leaf.addQuadCurve(to: tip, control: CGPoint(x: tip.x - 13, y: tip.y + 6))
        leaf.addQuadCurve(to: base, control: CGPoint(x: tip.x + 12, y: tip.y + 18))
        context.fill(leaf, with: .color(index.isMultiple(of: 2) ? OceanStyle.lavender : Color(red: 0.90, green: 0.72, blue: 0.84)))
        var vein = Path()
        vein.move(to: base)
        vein.addLine(to: tip)
        context.stroke(vein, with: .color(.white.opacity(0.45)), style: StrokeStyle(lineWidth: 1, lineCap: .round))
      }

      // Two ribbed rhinophores, gently swaying in the water.
      for (x, y, lean) in [(57.0, 91.0, -7.0), (97.0, 82.0, 4.0)] {
        var horn = Path()
        horn.move(to: CGPoint(x: x - 6, y: y + breath))
        horn.addCurve(to: CGPoint(x: x + lean + sway - 5, y: y - 39 + breath),
                      control1: CGPoint(x: x - 10, y: y - 14), control2: CGPoint(x: x + lean - 13 + sway, y: y - 36))
        horn.addQuadCurve(to: CGPoint(x: x + lean + sway + 6, y: y - 37 + breath), control: CGPoint(x: x + lean + sway + 3, y: y - 47))
        horn.addCurve(to: CGPoint(x: x + 7, y: y + breath), control1: CGPoint(x: x + lean + 13 + sway, y: y - 23), control2: CGPoint(x: x + 8, y: y - 10))
        horn.closeSubpath()
        context.fill(horn, with: .linearGradient(Gradient(colors: [Color(red: 0.68, green: 0.53, blue: 0.83), OceanStyle.lavender]), startPoint: CGPoint(x: x, y: y - 40), endPoint: CGPoint(x: x, y: y)))
        for rib in 0..<4 {
          let ry = y - 31 + Double(rib) * 6 + breath
          let rx = x + (lean + sway) * (1 - Double(rib) * 0.16)
          var line = Path()
          line.move(to: CGPoint(x: rx - 5, y: ry))
          line.addQuadCurve(to: CGPoint(x: rx + 5, y: ry + 1), control: CGPoint(x: rx, y: ry + 3))
          context.stroke(line, with: .color(.white.opacity(0.45)), lineWidth: 1.3)
        }
      }

      for (x, y, r) in [(118.0, 99.0, 4.0), (138, 112, 5), (111, 130, 3), (157, 95, 3), (169, 133, 4), (206, 132, 3), (145, 142, 2)] {
        context.fill(Path(ellipseIn: CGRect(x: x, y: y + breath, width: r * 2, height: r * 1.5)), with: .color(OceanStyle.lavender.opacity(0.48)))
      }

      let blink = sleeping || time.truncatingRemainder(dividingBy: 6.2) < 0.16
      for x in [48.0, 80.0] {
        if blink {
          var eye = Path()
          eye.move(to: CGPoint(x: x - 3, y: 116 + breath))
          eye.addQuadCurve(to: CGPoint(x: x + 4, y: 116 + breath), control: CGPoint(x: x, y: 120 + breath))
          context.stroke(eye, with: .color(OceanStyle.ink), style: StrokeStyle(lineWidth: 2.3, lineCap: .round))
        } else {
          context.fill(Path(ellipseIn: CGRect(x: x - 2, y: 111 + breath, width: 5, height: 7)), with: .color(OceanStyle.ink))
          context.fill(Path(ellipseIn: CGRect(x: x - 1, y: 112 + breath, width: 1.6, height: 1.6)), with: .color(.white))
        }
      }
      for x in [39.0, 82.0] {
        context.fill(Path(ellipseIn: CGRect(x: x, y: 121 + breath, width: 12, height: 6)), with: .color(Color.pink.opacity(0.24)))
      }
      var smile = Path()
      smile.move(to: CGPoint(x: 59, y: 121 + breath))
      smile.addQuadCurve(to: CGPoint(x: 69, y: 121 + breath), control: CGPoint(x: 64, y: 128 + breath))
      context.stroke(smile, with: .color(OceanStyle.ink.opacity(0.7)), style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
    }
    .accessibilityLabel(sleeping ? "睡著的粉紫色海蛞蝓" : "奶白色身體、粉紫色觸角的海蛞蝓")
  }
}

struct Aquarium: View {
  @ObservedObject var store: PetStore
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    TimelineView(.animation(minimumInterval: 1.0 / 24, paused: !store.isVisible || store.quietAnimation || reduceMotion)) { timeline in
      let t = store.quietAnimation || reduceMotion ? 1.0 : timeline.date.timeIntervalSinceReferenceDate
      ZStack {
        RoundedRectangle(cornerRadius: 24)
          .fill(LinearGradient(colors: [Color(red: 0.10, green: 0.26, blue: 0.30), Color(red: 0.12, green: 0.32, blue: 0.34)], startPoint: .topLeading, endPoint: .bottomTrailing))
        Canvas { context, size in
          for i in 0..<9 {
            let x = Double((i * 71 + 23) % 310) + sin(t * 0.4 + Double(i)) * 6
            let y = size.height - (t * (7 + Double(i % 3) * 3) + Double(i * 31)).truncatingRemainder(dividingBy: size.height + 20)
            let radius = Double(2 + i % 3)
            context.stroke(Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2)), with: .color(.white.opacity(0.13)), lineWidth: 1)
          }
          var floor = Path()
          floor.move(to: CGPoint(x: 0, y: 211))
          floor.addQuadCurve(to: CGPoint(x: size.width, y: 211), control: CGPoint(x: size.width * 0.5, y: 178))
          floor.addLine(to: CGPoint(x: size.width, y: size.height))
          floor.addLine(to: CGPoint(x: 0, y: size.height))
          floor.closeSubpath()
          context.fill(floor, with: .color(OceanStyle.mint.opacity(0.07)))
          for i in 0..<5 {
            let x = 17.0 + Double(i) * 8
            var stem = Path()
            stem.move(to: CGPoint(x: x, y: 228))
            stem.addCurve(to: CGPoint(x: x + sin(t + Double(i)) * 5, y: 167 - Double(i % 3) * 14), control1: CGPoint(x: x - 18, y: 208), control2: CGPoint(x: x + 15, y: 188))
            context.stroke(stem, with: .color(OceanStyle.mint.opacity(0.20)), style: StrokeStyle(lineWidth: 5, lineCap: .round))
          }
          for i in 0..<17 {
            let x = Double((i * 53 + 73) % 320)
            let y = 223.0 + Double((i * 17) % 28)
            context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2)), with: .color(OceanStyle.cream.opacity(0.18)))
          }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))

        Ellipse().fill(.black.opacity(0.12)).frame(width: 181, height: 14).blur(radius: 5).offset(y: 77)
        SlugArt(time: t, sleeping: store.state.isSleeping)
          .frame(width: 265, height: 174)
          .rotationEffect(.degrees(store.state.isSleeping ? -3 : sin(t * 0.7) * 1.2))
          .offset(x: store.state.isSleeping ? 0 : sin(t * 0.35) * 7, y: 22)

        VStack {
          HStack {
            Label(store.state.isSleeping ? "RESTING" : "LITTLE OCEAN", systemImage: store.state.isSleeping ? "moon" : "water.waves")
              .font(.system(size: 9, weight: .medium, design: .monospaced)).tracking(1.5)
            Spacer()
            Circle().fill(OceanStyle.mint.opacity(0.7)).frame(width: 5, height: 5)
          }
          .foregroundStyle(OceanStyle.mint.opacity(0.8))
          Spacer()
        }.padding(18)

        if store.state.isSleeping {
          Text("z z Z").font(.system(size: 18, weight: .light, design: .rounded))
            .foregroundStyle(OceanStyle.lavender).offset(x: -64, y: -43 + sin(t) * 3)
        }
        if let reaction = store.reaction {
          Image(systemName: reaction).font(.system(size: 27))
            .foregroundStyle(reaction == "heart.fill" ? Color(red: 0.98, green: 0.68, blue: 0.76) : OceanStyle.cream)
            .offset(x: -62, y: -57 + sin(t * 3) * 4)
        }
      }
    }
    .frame(height: 258)
  }
}
