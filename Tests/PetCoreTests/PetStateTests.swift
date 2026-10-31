import Foundation
import XCTest
@testable import PetCore

final class PetStateTests: XCTestCase {
  private let start = Date(timeIntervalSince1970: 1_700_000_000)

  func testElapsedTimeIsIndependentOfTickFrequency() {
    var once = PetState(now: start)
    var frequently = once
    once.advance(to: start.addingTimeInterval(3600))
    for minute in 1...60 {
      frequently.advance(to: start.addingTimeInterval(Double(minute) * 60))
    }
    XCTAssertEqual(once.fullness, frequently.fullness, accuracy: 0.0001)
    XCTAssertEqual(once.energy, frequently.energy, accuracy: 0.0001)
    XCTAssertEqual(once.happiness, frequently.happiness, accuracy: 0.0001)
  }

  func testSleepingRecoversEnergyAndCannotBeFedOrPetted() {
    var pet = PetState(now: start)
    pet.energy = 30
    pet.toggleSleep(at: start)
    pet.advance(to: start.addingTimeInterval(3600))
    XCTAssertEqual(pet.energy, 48)
    XCTAssertFalse(pet.feed(at: start.addingTimeInterval(3600)))
    XCTAssertFalse(pet.pet(at: start.addingTimeInterval(3600)))
  }

  func testFeedingCooldownAndUpperBound() {
    var pet = PetState(now: start)
    XCTAssertTrue(pet.feed(at: start))
    XCTAssertFalse(pet.feed(at: start.addingTimeInterval(9)))
    XCTAssertTrue(pet.feed(at: start.addingTimeInterval(10)))
    XCTAssertEqual(pet.fullness, 100)
  }

  func testLongAbsenceDoesNotHarmPet() {
    var pet = PetState(now: start)
    pet.advance(to: start.addingTimeInterval(90 * 86400))
    XCTAssertEqual(pet.fullness, 20)
    XCTAssertEqual(pet.energy, 20)
    XCTAssertGreaterThanOrEqual(pet.happiness, 20)
  }

  func testClockRollbackDoesNotChangeNeeds() {
    var pet = PetState(now: start)
    pet.advance(to: start.addingTimeInterval(-3600))
    XCTAssertEqual(pet.fullness, 80)
    XCTAssertEqual(pet.energy, 90)
  }

  func testPersistenceRoundTripPreservesSleepAndCooldown() throws {
    var pet = PetState(now: start)
    pet.feed(at: start)
    pet.toggleSleep(at: start)
    let data = try JSONEncoder().encode(pet)
    XCTAssertEqual(try JSONDecoder().decode(PetState.self, from: data), pet)
  }
}
