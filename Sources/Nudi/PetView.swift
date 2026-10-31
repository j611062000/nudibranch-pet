import AppKit
import SwiftUI

struct PetView: View {
  @ObservedObject var store: PetStore

  var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .center) {
        VStack(alignment: .leading, spacing: 5) {
          Text("NUDI / 海蛞蝓日常")
            .font(.system(size: 9, weight: .semibold, design: .monospaced))
            .tracking(2).foregroundStyle(OceanStyle.mint)
          Text("一小片海，陪你工作。")
            .font(.system(size: 19, weight: .medium, design: .rounded))
            .foregroundStyle(OceanStyle.cream)
        }
        Spacer()
        Menu {
          Toggle("減少動畫", isOn: $store.quietAnimation)
          Divider()
          Text("狀態自動儲存在這台 Mac")
          Text("Nudi · 本機原型 0.1.0")
          Divider()
          Button("結束 Nudi") { NSApplication.shared.terminate(nil) }
            .keyboardShortcut("q")
        } label: {
          Image(systemName: "ellipsis").font(.system(size: 18))
            .foregroundStyle(OceanStyle.cream.opacity(0.7))
            .frame(width: 28, height: 28)
        }
        .menuStyle(.borderlessButton).menuIndicator(.hidden).fixedSize()
        .accessibilityLabel("設定與結束")
      }
      .padding(.bottom, 20)

      Aquarium(store: store)

      HStack(alignment: .firstTextBaseline, spacing: 8) {
        Text(store.state.name).font(.system(size: 22, weight: .semibold, design: .rounded))
          .foregroundStyle(OceanStyle.cream)
        Text("你的海蛞蝓朋友").font(.system(size: 10)).foregroundStyle(OceanStyle.cream.opacity(0.45))
        Spacer()
        Text(store.state.isSleeping ? "晚安 ☾" : "陪伴中")
          .font(.system(size: 10, weight: .medium)).foregroundStyle(OceanStyle.mint)
          .padding(.horizontal, 10).padding(.vertical, 5)
          .background(OceanStyle.mint.opacity(0.08), in: Capsule())
      }.padding(.top, 19)

      Text(store.message ?? store.state.mood)
        .font(.system(size: 12)).foregroundStyle(OceanStyle.cream.opacity(0.68))
        .frame(maxWidth: .infinity, alignment: .leading).frame(height: 29, alignment: .topLeading)
        .padding(.top, 5)
        .accessibilityAddTraits(.updatesFrequently)

      HStack(spacing: 18) {
        meter("飽足", value: store.state.fullness, color: OceanStyle.mint)
        meter("心情", value: store.state.happiness, color: OceanStyle.lavender)
        meter("精神", value: store.state.energy, color: Color(red: 0.91, green: 0.79, blue: 0.56))
      }.padding(.bottom, 19)

      HStack(spacing: 10) {
        action("餵食", symbol: "sparkles", disabled: store.state.isSleeping, perform: store.feed)
        action("摸摸", symbol: "heart", disabled: store.state.isSleeping, perform: store.pet)
        action(store.state.isSleeping ? "起床" : "睡覺", symbol: store.state.isSleeping ? "sun.max" : "moon", perform: store.toggleSleep)
      }

      HStack(spacing: 5) {
        Image(systemName: "leaf").font(.system(size: 9))
        Text("不用趕，跟牠一起慢慢來。")
          .font(.system(size: 10))
      }.foregroundStyle(OceanStyle.cream.opacity(0.35)).padding(.top, 18)
    }
    .padding(22)
    .frame(width: 364)
    .background(OceanStyle.ink)
    .preferredColorScheme(.dark)
  }

  private func meter(_ title: String, value: Double, color: Color) -> some View {
    VStack(spacing: 7) {
      HStack {
        Text(title).font(.system(size: 10))
        Spacer()
        Text("\(Int(value.rounded()))").font(.system(size: 10, design: .monospaced))
      }.foregroundStyle(OceanStyle.cream.opacity(0.55))
      GeometryReader { geometry in
        Capsule().fill(.white.opacity(0.08))
        Capsule().fill(color.opacity(0.85)).frame(width: geometry.size.width * min(1, max(0, value / 100)))
      }.frame(height: 4)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(title).accessibilityValue("\(Int(value.rounded())) / 100")
  }

  private func action(_ title: String, symbol: String, disabled: Bool = false, perform: @escaping () -> Void) -> some View {
    Button(action: perform) {
      HStack(spacing: 7) {
        Image(systemName: symbol).font(.system(size: 13))
        Text(title).font(.system(size: 12, weight: .medium))
      }
      .frame(maxWidth: .infinity).frame(height: 42)
      .foregroundStyle(disabled ? OceanStyle.cream.opacity(0.25) : OceanStyle.cream)
      .background(.white.opacity(disabled ? 0.025 : 0.065), in: RoundedRectangle(cornerRadius: 12))
      .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.white.opacity(0.06)))
      .contentShape(RoundedRectangle(cornerRadius: 12))
    }
    .buttonStyle(.plain).disabled(disabled)
    .help(disabled ? "先讓小紫起床吧" : title)
  }
}
