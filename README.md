# Nudi · A tiny sea slug for your Mac

**English** | [繁體中文](README.zh-TW.md)

A chubby, monochrome nudibranch companion designed to crawl slowly within its own little space in the macOS menu bar.

**This repository contains a design and Swift prototype, not an installable or runnable app yet.** The image below is an AI-assisted concept illustration, not a screenshot of a working app.

![Chubby monochrome nudibranch concept](docs/monochrome-chubby-concept.png)

*The concept shows the pet inside the menu bar, with enlarged crawling, turning, and resting poses below. The labels in the illustration are in Traditional Chinese.*

## Design direction

- A rounded, plump silhouette with short feelers and a small gill rosette.
- The entire pet stays within the menu bar height and the app's own fixed-width area.
- Gentle crawling, turning, pauses, and naps without crossing other apps' icons.
- Click to open a companion panel for feeding, petting, and sleep.
- Offline use and local persistence, with no death or punishment for being away.

## What's included

- `Sources/PetCore/`: fullness, happiness, energy, sleep, and interaction cooldowns.
- `Sources/Nudi/`: a SwiftUI companion panel, vector artwork, and a UserDefaults persistence prototype.
- `Tests/PetCoreTests/`: tests for elapsed time, sleep, feeding cooldowns, value bounds, and persistence.
- `docs/`: the selected concept and design notes in English and Traditional Chinese.

**Still to build:** the native menu bar entry point, bounded crawling animation, the chubby monochrome character artwork in code, app packaging, and hands-on runtime validation. The current SwiftUI panel is an earlier colorful aquarium exploration; it does not yet implement the selected design. The prototype UI is currently in Traditional Chinese; English UI support remains planned.

## Build and test

Requires macOS 13 or later and Swift 5.9 or later. Use Xcode Command Line Tools or Xcode to compile. The XCTest tests need a toolchain that includes XCTest; full Xcode is recommended. There are no third-party package dependencies.

```sh
swift build
swift test
```

The package currently produces the `NudiPrototype` library for compilation and testing. There is no `swift run` entry point or downloadable `.app` yet.

The prototype library compiled successfully on the development Mac. Tests could not run because its Command Line Tools installation lacks the `XCTest` module; a passing test run has not been established.

See the [design notes](docs/DESIGN.en.md) for the intended behavior and checks needed before release.
