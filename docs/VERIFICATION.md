# v0.2.0 interaction animations / 選單列互動動畫

Date: 2026-10-31. Same Apple Silicon environment as v0.1.0 below.

- `./scripts/check.sh`: **PASS**, 10,621 assertions, including reaction duration, paused walking during every interaction, and reaction-badge bounds/non-overlap across the full travel area.
- Feed: four seconds of chewing and a snack badge; Pet: three seconds of happy motion with a heart. Sleep: closed eyes, a lower pose, gentle breathing, and a floating Z at a reduced 2 fps update rate.
- The system/app Reduce Motion preference freezes the pose and badge while reaction expiry still returns the pet to its normal static state. Screen sleep stops the animation timer.
- Failed/cooldown interactions update the message without cancelling an already-playing reaction. Sleeping cancels transient reactions.
- The panel and menu bar share the same activity and drawing code; activity labels and accessibility text are bilingual.
- README GIF: 368 frames at 960 × 270, infinite loop, 47.84 seconds after GIF delay rounding. Feeding, heart, and sleeping samples were visually inspected; read-back verified changing pixels.
- Universal build and ad-hoc signing passed. The same notarization, older macOS, Intel runtime, and wider desktop-scenario limitations from v0.1.0 apply.

# v0.1.0 verification / 驗證紀錄

Date: 2026-10-31. Environment: macOS 27.0.1, Apple Silicon, Swift 6.4 Command Line Tools.

## Automated checks

- `./scripts/check.sh`: **PASS**, 10,091 assertions covering time progression, need bounds, feed/pet cooldowns, sleep recovery, JSON persistence, clock rollback, bounded crawling over 10,000 frames, edge turns, paused motion, delayed wake ticks, and both languages.
- `./scripts/build-app.sh --universal`: **PASS**, Apple Silicon and Intel Mach-O slices, app icon generation, valid `Info.plist`, ad-hoc signing, signature verification, ZIP, and SHA-256 sidecar.
- Installed bundle: `codesign --verify --deep --strict` passed after extracting the ZIP into the personal Applications folder.
- Linked libraries: only system libraries/frameworks; no dependency on the build directory.
- Parent workspace lint: passed with four existing warnings, zero errors. No parent frontend source changes.

The local SDK reports missing developer-library search paths and an Intel compatibility archive warning. The universal link and signature checks succeed, but Intel runtime behavior has not been tested on an Intel Mac.

## Hands-on app checks

- The native app launches with a monochrome companion panel and without a Dock icon.
- Feed increases fullness; petting increases mood and shows localized feedback.
- Sleep switches the illustration and disables feeding/petting; Wake restores those controls.
- English ↔ Traditional Chinese switches labels, mood text, accessibility descriptions, and control help immediately. Both layouts were visually inspected.
- Quit, install from ZIP, and relaunch preserve needs, sleep state, language, and Reduce Motion preference. Sleep recovery was visible after relaunch.
- The installed app was returned to awake mode with Reduce Motion off.

The 10,000-frame check verifies movement bounds and turning logic. The UI automation surface captures the companion panel rather than the whole system menu bar; a captured end-to-end visual recording of menu bar travel is not included.

## Limits

- Not Apple-notarized or Developer ID signed. Downloaded builds may require the macOS per-app Open Anyway flow.
- Runtime testing was on one Apple Silicon Mac. Older supported macOS versions and Intel hardware remain untested.
- Multi-display, automatic menu bar hiding, full-screen, crowded/notched menu bars, system sleep/wake, system Reduce Motion changes, and long-duration energy measurements need broader testing.
- No login-item registration, automatic updates, network access, or telemetry.

## 繁體中文摘要

核心邏輯、雙語文字、通用版打包與簽署檢查已通過。已在本機實測餵食、摸摸、睡眠／起床、中英文切換與重新啟動後的狀態保留。邊界與轉身以連續 10,000 幀測試驗證；目前沒有選單列移動的完整錄影。Intel、舊版 macOS、多螢幕與長時間耗電仍未完整實測。此版本尚未經 Apple 公證。

## README animation

Both READMEs embed `docs/menu-bar-demo.gif`. It is rendered by `scripts/render-demo.sh` using the app's actual vector drawing and movement model, with an illustrated surrounding menu bar (not a screen recording). ImageIO read-back verified 280 frames, 960 × 270 dimensions, an infinite loop, and changing frame pixels. GIF centisecond rounding produces a 36.4-second loop. File size is approximately 108 KB. Sampled frames were visually inspected.
