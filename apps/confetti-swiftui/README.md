# Confetti

Dark SwiftUI playground for **[ConfettiSwiftUI](https://github.com/simibac/ConfettiSwiftUI)** (`import ConfettiSwiftUI`, from **3.0.0**, tag **3.0.0**, revision **9ae5bc2**).

Product **`ConfettiSwiftUI` only**. The package manifest lists iOS 14, macOS 11, tvOS 14, and watchOS 7. This app targets iOS 18 to match sibling demos.

Tag `3.0.0` points at `9ae5bc2ce2149980884d4612321c3a266d6bf82c` (2026-01-05, "fixes issue #69"). That commit is also `HEAD` of the default branch. Swift Package Manager requirement `from: 3.0.0` resolves the tag.

Two tabs:

- **Live** — picker among Burst, Pieces, and Recipes. Only the selected surface mounts `.confettiCannon`. Switching family or leaving the tab removes it.
- **Gallery** — frozen painted cards. No `confettiCannon`, no `ConfettiCannon`, no trigger binding.

Live chrome uses hardcoded light ink on a near-black page so pieces stay readable.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/confetti-swiftui/ConfettiSwiftUI.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **ConfettiSwiftUI** scheme. Xcode resolves the remote Swift package `https://github.com/simibac/ConfettiSwiftUI.git` (from 3.0.0 / tag `3.0.0`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/confetti-swiftui
xcodegen generate
```

`PRODUCT_MODULE_NAME = ConfettiSwiftUIDemo` so the app module is not named `ConfettiSwiftUI` (the package product). Bundle id is `com.techdemos.confettiswiftui`. The home-screen name is **Confetti**.

Keep the cannon on the Live tab. Keep Gallery free of `confettiCannon`. Leave the upstream configurator app (`ConfettiSwiftUIDemo`) out of this target.

## What ConfettiSwiftUI does

`.confettiCannon(trigger:)` mounts a `ConfettiCannon` in a `ZStack` over the view you attach it to. Any change to the `Equatable` binding after the cannon has appeared fires one burst (or several, when `repetitions` is greater than 1). The initial value does not fire. This demo uses `Int`, which is what the package README uses. The modifier is generic over `T: Equatable`. Its doc comment still says `counter`; the argument label is `trigger`.

The burst origin is the center of that view. `0°` points right and `90°` points up (`y` uses `-sin`). The default wedge is `60°` to `120°`.

| API | Role |
| --- | --- |
| `View.confettiCannon(trigger:num:confettis:colors:confettiSize:rainHeight:fadesOut:opacity:openingAngle:closingAngle:radius:repetitions:repetitionInterval:hapticFeedback:)` | Public entry point. Defaults: 20 pieces, all five shapes, spectrum colors, size 10, rain 600, fade on, opacity 1, angles 60° and 120°, radius 300, 1 repetition, interval 1, haptics on |
| `ConfettiCannon` | The view the modifier constructs. Same arguments |
| `ConfettiType.shape` | `.circle`, `.triangle`, `.square`, `.slimRectangle`, `.roundedCross` |
| `ConfettiType.text` | Emoji or other strings. Drawn with a system font of `confettiSize` |
| `ConfettiType.sfSymbol(symbolName:)` | SF Symbol, same font size, tinted with the palette |
| `ConfettiType.image` | Asset-catalog name. This demo does not ship images |
| `ConfettiType.allCases` | The five shapes only. Text, symbols, and images are not in that list |

The initializer pairs every confetti value with every color, then each piece picks one pair at random. Shapes are framed to `confettiSize`. Text and symbols also get `foregroundColor`. An empty `confettis` or `colors` array crashes (`randomElement()!`). `num` below 1 crashes (`0 ... num - 1`). Sliders stay at 1 or more, and the stage substitutes the defaults if a request arrives empty.

`fadesOut` animates opacity to 0 during the fall. Otherwise opacity stays at the given maximum. Repetitions are scheduled `repetitionInterval` seconds apart. On iOS, `hapticFeedback` plays a heavy impact once per repetition. The package skips that path on tvOS and visionOS, and uses a watch click on watchOS.

Explosion time is `radius / 1300` seconds. The fall lasts `(rainHeight + radius) / 200` seconds and starts after a tenth of the explosion. Distance is `pow(random(0.01...1), 2/7) * radius`. If the opening angle is greater than the closing angle, the range wraps by 360°.

The cannon copies these arguments in `init`. Live sets `.id` from the current knobs so the next burst uses the new arguments. Editing a slider replaces the cannon; it does not retarget pieces already on screen, and it does not increment `trigger`.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Burst** | Package defaults: five shapes, spectrum, count 20, radius 300, wedge 60°–120°, rain 600, one shot, haptics on. **Burst** increments `trigger`. **Reset** restores the defaults without firing. Poster is red and white. The README color sample is red and black; black would disappear on this page. |
| **Pieces** | Menu of shapes, emoji (`.text`), letters (`.text`, tinted), and SF Symbols (`symbolName`). Count and size change. Angles stay on the default wedge. |
| **Recipes** | Firework (`num: 50`, `0°`…`360°`, `radius: 200`), hearts (four `.text` hearts), rain (one bill, size 30, 50 steps, interval 0.1), repeat (3 times, 0.7 s). Rain passes `hapticFeedback: false`. The README omits that flag, so the package default would fire fifty heavy impacts. |
| **Leave the tab / family** | The active cannon unmounts. Gallery never keeps one. |

The stage is the view the modifier is attached to. The dot in the middle is the origin. Pieces are not clipped to the card, so a large radius or rain height travels over the knobs.

### Gallery

Lazy grid of paused stand-ins: the five shapes, emoji, letters, symbols, firework, hearts, rain, the triple repeat, the default wedge, and an image-name card. Chips name the APIs. Illustrations are SwiftUI paint.

**Skipped:** `ConfettiType.image` assets (the README names `arb`, `eth`, `btc`, `op`, `link`, `doge`), the endless 100-repeat sample, the upstream configurator app, and the watchOS haptic.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Vortex / Inferno demos; package floor is iOS 14)
- Network on first resolve for Swift Package `ConfettiSwiftUI` **3.0.0** (tag `3.0.0`, pin `9ae5bc2ce2149980884d4612321c3a266d6bf82c`)
