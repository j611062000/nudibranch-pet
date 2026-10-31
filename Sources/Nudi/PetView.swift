import AppKit
import PetCore
import SwiftUI

struct PetView: View {
  @ObservedObject var store: PetStore
  @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

  var body: some View {
    VStack(alignment: .leading, spacing: 18) {
      HStack {
        VStack(alignment: .leading, spacing: 5) {
          Text("NUDI").font(.system(size: 11, weight: .bold, design: .monospaced)).tracking(4)
          Text(store.text(.subtitle)).font(.system(size: 13)).foregroundStyle(.secondary)
        }
        Spacer()
        Image(systemName: "water.waves").font(.system(size: 20, weight: .ultraLight)).foregroundStyle(.secondary)
      }

      ZStack {
        RoundedRectangle(cornerRadius: 22).fill(.white.opacity(0.045))
        TimelineView(.animation(minimumInterval: 1.0 / 12, paused: !store.isVisible || store.quietAnimation || systemReduceMotion || store.state.isSleeping)) { timeline in
          let phase = store.quietAnimation || systemReduceMotion ? 1 : timeline.date.timeIntervalSinceReferenceDate
          Image(nsImage: SlugDrawing.image(size: NSSize(width: 190, height: 124), phase: phase, sleeping: store.state.isSleeping))
            .renderingMode(.template).foregroundStyle(.white)
            .accessibilityLabel(store.text(store.state.isSleeping ? .sleepingPet : .awakePet))
        }
        VStack {
          HStack {
            Text(store.text(store.state.isSleeping ? .resting : .wandering))
              .font(.system(size: 10, weight: .medium, design: .monospaced)).foregroundStyle(.secondary)
            Spacer()
            Image(systemName: store.state.isSleeping ? "moon" : "circle.fill")
              .font(.system(size: store.state.isSleeping ? 11 : 5)).foregroundStyle(.secondary)
          }
          Spacer()
        }.padding(15)
        if let symbol = store.reaction {
          Image(systemName: symbol).font(.system(size: 18)).offset(x: -70, y: -45).accessibilityHidden(true)
        }
        if store.state.isSleeping {
          Text("z z Z").font(.system(size: 14, weight: .light, design: .rounded))
            .foregroundStyle(.secondary).offset(x: -65, y: -43).accessibilityHidden(true)
        }
      }.frame(height: 172)

      VStack(alignment: .leading, spacing: 7) {
        HStack(alignment: .firstTextBaseline) {
          Text("Nudi").font(.system(size: 23, weight: .semibold, design: .rounded))
          Text(store.text(.companion)).font(.system(size: 11)).foregroundStyle(.secondary)
        }
        Text(store.text(store.message ?? store.state.mood))
          .font(.system(size: 12)).foregroundStyle(.secondary)
          .frame(height: 30, alignment: .topLeading).fixedSize(horizontal: false, vertical: true)
      }

      HStack(spacing: 18) {
        meter(.fullness, value: store.state.fullness)
        meter(.happiness, value: store.state.happiness)
        meter(.energy, value: store.state.energy)
      }
      HStack(spacing: 9) {
        action(.feed, symbol: "sparkles", disabled: store.state.isSleeping, perform: store.feed)
        action(.pet, symbol: "heart", disabled: store.state.isSleeping, perform: store.pet)
        action(store.state.isSleeping ? .wake : .sleep, symbol: store.state.isSleeping ? "sun.max" : "moon", perform: store.toggleSleep)
      }
      Divider().overlay(.white.opacity(0.05))
      HStack {
        Text(store.text(.language)).font(.system(size: 11)).foregroundStyle(.secondary)
        Spacer()
        Picker(store.text(.language), selection: $store.language) {
          Text("English").tag(AppLanguage.english)
          Text("繁體中文").tag(AppLanguage.traditionalChinese)
        }.labelsHidden().pickerStyle(.segmented).frame(width: 180)
      }
      Toggle(store.text(.reduceMotion), isOn: $store.quietAnimation)
        .font(.system(size: 11)).toggleStyle(.switch).controlSize(.mini)
        .help(store.text(.motionHelp))
      HStack {
        Text(store.text(.localOnly)).font(.system(size: 9)).foregroundStyle(.tertiary)
        Spacer(minLength: 4)
        Button(store.text(.quit)) { NSApp.terminate(nil) }
          .font(.system(size: 10)).buttonStyle(.plain).foregroundStyle(.secondary)
          .keyboardShortcut("q")
      }
    }
    .padding(22).frame(width: 356)
    .background(Color(white: 0.095)).foregroundStyle(.white)
    .preferredColorScheme(.dark)
  }

  private func meter(_ key: Copy, value: Double) -> some View {
    VStack(spacing: 7) {
      HStack {
        Text(store.text(key)).font(.system(size: 10))
        Spacer()
        Text("\(Int(value.rounded()))").font(.system(size: 10, design: .monospaced))
      }.foregroundStyle(.secondary)
      GeometryReader { geometry in
        Capsule().fill(.white.opacity(0.08))
        Capsule().fill(.white.opacity(0.75)).frame(width: geometry.size.width * min(1, max(0, value / 100)))
      }.frame(height: 3)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(store.text(key)).accessibilityValue("\(Int(value.rounded())) / 100")
  }

  private func action(_ key: Copy, symbol: String, disabled: Bool = false, perform: @escaping () -> Void) -> some View {
    Button(action: perform) {
      HStack(spacing: 6) {
        Image(systemName: symbol).font(.system(size: 12))
        Text(store.text(key)).font(.system(size: 12, weight: .medium))
      }
      .frame(maxWidth: .infinity).frame(height: 40)
      .foregroundStyle(.white.opacity(disabled ? 0.25 : 0.9))
      .background(.white.opacity(disabled ? 0.025 : 0.07), in: RoundedRectangle(cornerRadius: 11))
      .overlay(RoundedRectangle(cornerRadius: 11).strokeBorder(.white.opacity(0.06)))
      .contentShape(RoundedRectangle(cornerRadius: 11))
    }
    .buttonStyle(.plain).disabled(disabled)
    .help(store.text(disabled ? .wakeFirst : key))
  }
}
