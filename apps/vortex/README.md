# Vortex

Dark SwiftUI playground for **[Vortex](https://github.com/twostraws/Vortex)** (`import Vortex`, from **1.0.4**, tagged **1.0.4**, revision **9d9d901**).

Product **`Vortex` only**. The package floor is iOS 15 (and macOS 12, Mac Catalyst 15, tvOS 15, watchOS 8, visionOS 1). `VortexSystem.confetti(colors:in:)` is marked iOS 17+. This app targets iOS 18 to match sibling demos.

`main` (`c9efc55`) is four commits ahead of tag 1.0.4: README wording, and a tvOS availability annotation on the confetti color factory. Swift Package Manager requirement `from: 1.0.4` resolves the tag, not `main`.

Two tabs:

- **Live** — picker among Presets, Burst, and Custom. Only the selected surface mounts a `VortexView`. Splash is the one exception inside Presets: it stacks `.rain` and `.splash` together, matching the package sample, and only while Splash is selected.
- **Gallery** — frozen painted cards for the ten built-in presets plus the custom ember ring. No `VortexView`, no `VortexSystem`, no `VortexProxy`.

Live chrome uses hardcoded light ink on a near-black page so additive particles cannot wash out labels.

Presets are reference types. Every built-in system is passed through `makeUniqueCopy()` so attraction, `move(to:)`, and birth rate never write onto the shared static preset.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/vortex/Vortex.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **Vortex** scheme. Xcode resolves the remote Swift package `https://github.com/twostraws/Vortex.git` (from 1.0.4 / tag `1.0.4`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/vortex
xcodegen generate
```

`PRODUCT_MODULE_NAME = VortexDemo` so the app module is not named `Vortex` (the package product). Bundle id is `com.techdemos.vortex`.

Do not stack live presets. Do not put `VortexView` in the Gallery grid. Do not copy the package `Sandbox` target.

## What Vortex does

A `VortexSystem` describes emission. A `VortexView` draws it by resolving tagged SwiftUI symbols inside a `Canvas`. `VortexViewReader` hands back a `VortexProxy` for the first system it finds.

| API | Role |
| --- | --- |
| `VortexSystem` | Emitter: tags, shape, birth rate, motion, colors, optional secondary systems |
| `VortexSystem.makeUniqueCopy()` | Deep copy. Presets are classes; copies keep one view from mutating the shared value |
| `VortexView` | Renders one primary system and its active secondary systems |
| `VortexViewReader` / `VortexProxy` | `burst()`, `attractTo(_:)`, `move(to:)` |
| `VortexSystem.Shape` | `.point`, `.box`, `.ellipse`, `.ring` |
| `VortexSystem.ColorMode` | `.single`, `.random`, `.ramp`, `.randomRamp` |
| `VortexSystem.SpawnOccasion` | `.onBirth`, `.onDeath`, `.onUpdate` for secondary systems |
| `Image.circle` / `Image.confetti` / `Image.sparkle` | Particle images shipped in the package bundle |

Built-in presets and the tags their symbols must use:

| Preset | Tags | Notes |
| --- | --- | --- |
| `.confetti` | `square`, `circle` | `birthRate` is 0. Waits for `burst()` |
| `.confetti(colors:in:)` | `confetti` | iOS 17+. Resolves SwiftUI colors |
| `.fire` | `circle` | Soft edge, `.plusLighter`. Sandbox drags via `attractTo` |
| `.fireflies` | `circle` | Ellipse emitter. Sandbox repels with negative `attractionStrength` |
| `.fireworks` | `circle` | Secondary sparkles (`.onUpdate`) and explosion (`.onDeath`) |
| `.magic` | `sparkle` | Ring. This demo uses `Image.sparkle` from the package |
| `.rain` | `circle` | Fast, stretched |
| `.smoke` | `circle` | Large soft circles, gray ramp |
| `.snow` | `circle` | Slow fall from the top |
| `.spark` | `circle` | `emissionDuration` / `idleDuration` |
| `.splash` | `circle` | Secondary drops. Sample stacks it under `.rain` |

Symbol views are filled white so `ColorMode` can recolor them. Tags are applied on the views passed into `VortexView`, matching the package sandbox.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Presets** | Menu of the nine continuous presets. Switching unmounts the previous `VortexView`. **Fire** drag calls `attractTo` and sets `attractionStrength` to 2; release sets it back to 0. **Fireflies** drag sets strength to −2. **Splash** mounts rain and splash together. |
| **Burst** | `VortexViewReader` around `.confetti`. **Classic** uses the static preset (`square` + `circle`). **Sunset** and **Ice** call `confetti(colors:in:)`, which emits the `confetti` tag. Tap runs `move(to:)` then `burst()`. **Burst** fires without moving. |
| **Custom** | Hand-built ring emitter plus an `.onDeath` secondary system, both tagged `circle`. The slider writes `birthRate` on the instance `VortexView` is drawing. **Burst** uses `burstCount` (80). |
| **Leave the tab / family** | The active `VortexView` unmounts. Gallery never keeps a live system. |

Live content sits outside a page `ScrollView` (drag and tap own the stage) and uses a bottom `safeAreaInset` so the tab pill does not cover the particles.

### Gallery

Lazy grid of paused stand-ins for confetti, fire, fireflies, fireworks, magic, rain, smoke, snow, spark, splash, and the ember ring. Chips name the APIs. Illustrations are SwiftUI `Canvas` paint — not `VortexView`.

**Skipped:** copying the three example PNGs into the app asset catalog (`Image.sparkle` already comes from the package), `targetFrameRate` overrides, watchOS 2D rotation fallback, and the official Sandbox app clone.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Foldy / Minted / Rehearsal demos; package floor is iOS 15, confetti color factory is iOS 17)
- Network on first resolve for Swift Package `Vortex` **1.0.4+** (tagged `1.0.4`, pin `9d9d9016ceace579455f01f8e0bd59facae7d252`)
