import Foundation

public enum AppLanguage: String, CaseIterable {
  case english = "en"
  case traditionalChinese = "zh-Hant"

  public static func preferred(_ languages: [String]) -> AppLanguage {
    languages.first?.hasPrefix("zh") == true ? .traditionalChinese : .english
  }
}

public enum Copy: CaseIterable {
  case subtitle, companion, resting, wandering, feed, pet, sleep, wake
  case fullness, happiness, energy, language, reduceMotion, quit, localOnly, munching, feelingLoved
  case slowDown, dreaming, hungry, sleepy, lonely, content
  case fed, chewing, loved, alreadyLoved, letSleep, goodNight, goodMorning
  case settings, openPet, sleepingPet, awakePet, wakeFirst, motionHelp

  public func text(_ language: AppLanguage) -> String {
    let pair: (String, String)
    switch self {
    case .subtitle: pair = ("A little company. A slower day.", "一小片海，陪你慢慢來。")
    case .companion: pair = ("Your little sea slug", "你的海蛞蝓朋友")
    case .resting: pair = ("Resting", "休息中")
    case .wandering: pair = ("Wandering", "散步中")
    case .munching: pair = ("Munching", "吃點心中")
    case .feelingLoved: pair = ("Feeling loved", "開心撒嬌中")
    case .feed: pair = ("Feed", "餵食")
    case .pet: pair = ("Pet", "摸摸")
    case .sleep: pair = ("Sleep", "睡覺")
    case .wake: pair = ("Wake up", "起床")
    case .fullness: pair = ("Fullness", "飽足")
    case .happiness: pair = ("Mood", "心情")
    case .energy: pair = ("Energy", "精神")
    case .language: pair = ("Language", "語言")
    case .reduceMotion: pair = ("Reduce motion", "減少動畫")
    case .quit: pair = ("Quit Nudi", "結束 Nudi")
    case .localOnly: pair = ("Saved on this Mac · No account needed", "自動儲存在這台 Mac · 不需帳號")
    case .slowDown: pair = ("No rush. Just a little company.", "不用趕，跟牠一起慢慢來。")
    case .dreaming: pair = ("Dreaming of a quiet little ocean.", "正在做海底的夢。")
    case .hungry: pair = ("A little snack would be lovely.", "想吃一點小點心。")
    case .sleepy: pair = ("Getting a little sleepy.", "有一點睏了。")
    case .lonely: pair = ("Happy to spend a moment with you.", "想跟你待在一起。")
    case .content: pair = ("It's okay to take your time today.", "今天也慢慢來就好。")
    case .fed: pair = ("Munch. Thanks for the little treat!", "啊嗚，謝謝你的小點心！")
    case .chewing: pair = ("Still chewing. Another bite in a moment.", "慢慢嚼，等一下再吃。")
    case .loved: pair = ("A little nudge of affection for you.", "喜歡你，啵。")
    case .alreadyLoved: pair = ("Feeling very loved already.", "感受到你的喜歡了 ♡")
    case .letSleep: pair = ("Shh. Let your little friend rest.", "噓，讓牠再睡一下。")
    case .goodNight: pair = ("Good night, little ocean dreamer.", "晚安，海浪會輕輕陪著你。")
    case .goodMorning: pair = ("Hello again. Let's take it slow.", "早安！一起慢慢開始吧。")
    case .settings: pair = ("Settings", "設定")
    case .openPet: pair = ("Nudi — click to visit your sea slug", "Nudi — 點擊看看你的海蛞蝓")
    case .sleepingPet: pair = ("A chubby sea slug sleeping", "正在睡覺的胖胖海蛞蝓")
    case .awakePet: pair = ("A chubby sea slug with short feelers", "長著短觸角的胖胖海蛞蝓")
    case .wakeFirst: pair = ("Wake Nudi first", "先讓 Nudi 起床吧")
    case .motionHelp: pair = ("System Reduce Motion is also respected.", "也會遵循系統的減少動態效果設定。")
    }
    return language == .english ? pair.0 : pair.1
  }
}
