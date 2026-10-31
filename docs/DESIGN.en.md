# Design direction

**English** | [繁體中文](DESIGN.md)

## Character

A monochrome silhouette that fits alongside native macOS menu bar icons. The body should be short and plump, like a little piece of mochi, with a rounded head, a short tail, two short feelers, and a small gill rosette on its back. Prioritize a readable silhouette at small sizes; simplify the eyes and smile when necessary.

`monochrome-chubby-concept.png` is an AI-generated concept illustrating the selected direction. It is neither a production icon asset nor an app screenshot. The implementation needs artwork redrawn for small sizes and a transparent background, rather than using the whole concept board as a menu bar asset.

## Movement area

Reserve a fixed-width region with a native `NSStatusItem`. Every part of the character must stay within that region and the menu bar height. Turn around at the left and right boundaries without crossing or covering other apps' icons.

The first version will not use a desktop overlay or travel across the entire top edge of the screen. The status item is 108 points wide, with a 100-point drawing area and a 30 × 18-point character slot. Drawing is clipped to that area.

Apple's [statusItem(withLength:) documentation](https://developer.apple.com/documentation/appkit/nsstatusbar/statusitem(withlength:)) describes allocating space for a status item.

## Motion and interaction

- Crawl: slow movement with subtle body stretching and feeler motion.
- Turn: reverse direction at the boundary.
- Rest: settle down, close the eyes, and stop moving.
- Click: open controls for feeding, petting, sleeping, and quitting the app.
- Respect the system's Reduce Motion setting and offer a static mode.
- Stop the companion panel's scene animation when it closes; measure and tune the menu bar update rate.
- Support Traditional Chinese and English controls with immediate switching and a saved preference.

## Coverage and remaining validation

1. Native app launch, companion interactions, quit, and relaunch were exercised on Apple Silicon.
2. Readability with light and dark menu bars and different display scaling settings.
3. Auto-hidden menu bars, full-screen apps, multiple displays, and notched displays.
4. Sleep/wake behavior, state persistence, and interaction cooldowns after relaunch.
5. Idle CPU and energy use, Reduce Motion, and keyboard access.
6. A universal `.app` and ZIP are packaged and ad-hoc signed. Developer ID signing and Apple notarization remain future distribution work.

See [the verification record](VERIFICATION.md) for the checks actually completed; the other scenarios above are not claimed as fully validated.
