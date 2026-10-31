import Foundation
import PetCore

// No XCTest dependency: also runs with standalone Xcode Command Line Tools.
var checks = 0
func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
  checks += 1
  guard condition() else { fatalError("FAIL: \(message)") }
}
let start = Date(timeIntervalSince1970: 1_700_000_000)
var once = PetState(now: start)
var frequent = once
once.advance(to: start.addingTimeInterval(3600))
for minute in 1...60 { frequent.advance(to: start.addingTimeInterval(Double(minute) * 60)) }
expect(abs(once.fullness - frequent.fullness) < 0.0001, "Tick frequency must not change fullness")
expect(abs(once.happiness - frequent.happiness) < 0.0001, "Tick frequency must not change mood")
expect(abs(once.energy - frequent.energy) < 0.0001, "Tick frequency must not change energy")
var pet = PetState(now: start)
expect(pet.feed(at: start), "First feeding succeeds")
expect(!pet.feed(at: start.addingTimeInterval(9)), "Feeding cooldown")
expect(pet.feed(at: start.addingTimeInterval(10)), "Cooldown expires")
expect(pet.fullness == 100, "Fullness is capped")
expect(pet.pet(at: start.addingTimeInterval(10)), "First petting succeeds")
expect(!pet.pet(at: start.addingTimeInterval(11)), "Petting cooldown")
pet.energy = 30
pet.toggleSleep(at: start.addingTimeInterval(10))
pet.advance(to: start.addingTimeInterval(3610))
expect(pet.energy == 48, "Sleep recovers energy")
expect(!pet.feed(at: start.addingTimeInterval(3610)), "Cannot feed asleep")
expect(!pet.pet(at: start.addingTimeInterval(3610)), "Cannot pet asleep")
let restored = try JSONDecoder().decode(PetState.self, from: JSONEncoder().encode(pet))
expect(restored == pet, "Persistence retains sleep and cooldowns")
pet.toggleSleep(at: start.addingTimeInterval(3610))
pet.advance(to: start.addingTimeInterval(90 * 86400))
expect([pet.fullness, pet.energy, pet.happiness].allSatisfy { (20...100).contains($0) }, "Long absence stays gentle")
pet = PetState(now: start)
pet.feed(at: start)
pet.advance(to: start.addingTimeInterval(-3600))
expect(pet.fullness == 96 && pet.energy == 90, "Clock rollback preserves needs")
expect(pet.feed(at: start.addingTimeInterval(-3590)), "Rollback does not lock feeding for an hour")

var crawl = CrawlState()
var turns = 0
for _ in 0..<10000 {
  let direction = crawl.facingRight
  crawl.step(seconds: 0.1)
  expect(crawl.x >= CrawlState.inset && crawl.x + CrawlState.petWidth <= CrawlState.areaWidth - CrawlState.inset, "Character stays inside its reserved area")
  if direction != crawl.facingRight { turns += 1 }
}
expect(turns > 20, "Repeated edge turns")
let position = crawl.x
let phase = crawl.phase
crawl.step(seconds: 10, paused: true)
expect(crawl.x == position && crawl.phase == phase, "Reduced motion freezes movement and breathing")
crawl.step(seconds: .infinity)
crawl.step(seconds: -.infinity)
crawl.step(seconds: .nan)
expect(crawl.x == position, "Ignore invalid time steps")
crawl.step(seconds: 3600)
expect(abs(crawl.x - position) <= 1.001, "Wake cannot cause a large jump")
expect(AppLanguage.preferred(["zh-TW"]) == .traditionalChinese, "Chinese system language")
expect(AppLanguage.preferred(["en-US"]) == .english, "English system language")
expect(AppLanguage.preferred(["fr-FR"]) == .english, "English fallback")
for copy in Copy.allCases {
  expect(!copy.text(.english).isEmpty && !copy.text(.traditionalChinese).isEmpty, "Both translations exist")
  expect(copy.text(.english) != copy.text(.traditionalChinese), "Translations are distinct")
}
print("PASS: \(checks) checks (pet state, persistence, bounded motion, clock changes, bilingual copy)")
