# ShaderKit

Dark SwiftUI playground for **[ShaderKit](https://github.com/jamesrochabrun/ShaderKit)** (`import ShaderKit`, `import ShaderCards`, `import ShaderKitUI`, from **1.0.0**, tagged **1.3.0**, revision **0f4f5b4**).

Products **`ShaderKit`**, **`ShaderCards`**, and **`ShaderKitUI`**. Do not vendor the package source. Package floor is iOS 17; this app targets iOS 18 to match sibling demos.

Two tabs:

- **Live** — picker among Holo, Cards, and Jelly. Only the selected surface mounts Metal (one `HolographicCardContainer`, one `TradingCardView`, or one `JellySwitch` / `JellyButton`). Switching family or leaving the tab unmounts it.
- **Gallery** — painted stand-ins plus `CardFaceView` thumbnails with every shader pass stripped. No `HolographicCardContainer`, no `TradingCardView`, no jelly, no `.shader` / `.foil()`.

Live chrome uses hardcoded light ink on a near-black page so foil and glass cannot wash out labels. Card type sits on a scrim above the shaded fill.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/shader-kit/ShaderKit.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **ShaderKit** scheme. Xcode resolves the remote Swift package `https://github.com/jamesrochabrun/ShaderKit.git` (from 1.0.0 / tag `1.3.0`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/shader-kit
xcodegen generate
```

`PRODUCT_MODULE_NAME = ShaderKitDemo` so the app module is not named `ShaderKit` (the package product). Bundle id is `com.techdemos.shaderkit`.

Do not stack multiple live Metal surfaces. Do not put `HolographicCardContainer`, `TradingCardView`, `JellySwitch`, or `JellyButton` in the Gallery grid. Do not clone the package `Demo/` or `ShaderCardsDemo` target.

### Metal toolchain

ShaderKit foils are Metal shaders compiled by Xcode's build system. Build through Xcode (or `xcodebuild`). Plain `swift build` produces cards without foil.

On Xcode 26+ the Metal Toolchain is a separate download. If a build reports `missing Metal Toolchain`, run once:

```bash
xcodebuild -downloadComponent MetalToolchain
```

## What ShaderKit does

Composable Metal shaders for holographic cards, plus a Pokémon-style library (ShaderCards) and ray-marched jelly controls (ShaderKitUI).

| API | Role |
| --- | --- |
| `HolographicCardContainer` | Tilt host: drag, 3D rotation, shadow, shader context |
| `.foil()` / `.glitter()` / `.lightSweep()` | Convenience shader stack |
| `.shader(_:)` | Generic builder for any `ShaderEffect` |
| `.tradingCardHolo(_:)` | One-shot Sword & Shield foil construction |
| `.brushedTitanium()` … `.oilSlick()` | Opaque premium materials |
| `TradingCardView` | Interactive ShaderCards face in a holo container |
| `CardFaceView` | Static face; strip `cardEffects` for thumbnails |
| `JellySwitch` / `JellyButton` | ShaderKitUI spring-physics jelly |

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Holo** | One `HolographicCardContainer` (260×380, `.surfacePointer`). Menu picks Codex / Starburst / Glass / Frozen / Titanium / VMAX / Snowfall / Psychic. Drag the card. |
| **Cards** | One `TradingCardView` from `CardLibrary` (Emberfox, Tidecaller, Mindmoth, Nightfang, Glimmerkit). Drag to tilt the rarity foil. |
| **Jelly** | Segmented Switch vs Button. `darkMode: true`, sounds off. Only the selected jelly mounts. |
| **Leave the tab / family** | The active Metal surface unmounts. Gallery never keeps a live foil. |

Live content sits outside a page `ScrollView` (the card drag must own its gestures) and uses a bottom `safeAreaInset` so the tab pill does not cover the card.

### Gallery

Lazy grid of paused stand-ins: Codex rainbow, starburst rays, laminate glass, frozen ice, four material chips, a `CardFaceView` strip (shader-stripped), and a painted jelly switch/button. Chips name the APIs.

**Skipped:** `CardGalleryView` (its sheet mounts `TradingCardView`), `ExplodableCardView` / `CardLayerExplodeContainer`, `CardStudioView`, `SimpleCardContent` (needs a catalog image), gyroscope `MotionManager`, stacking more than one live foil.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Foldy / Minted / Rehearsal demos; package floor is iOS 17)
- Network on first resolve for Swift Package `ShaderKit` **1.0.0+** (tagged `1.3.0`, pin `0f4f5b41b58f2eaddfe2ba46d8dd721d0732d5c7`)
- Metal Toolchain installed when Xcode reports it missing (see above)
