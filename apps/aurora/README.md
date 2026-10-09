# Aurora

SwiftUI playground for **[Aurora](https://github.com/tornikegomareli/Aurora)** (`import Aurora`, from **0.5.2**, tagged **0.5.2**, revision **a3f9296**).

Product **`Aurora` only**. Package floor is iOS 17; this app targets iOS 18 to match sibling demos.

Two tabs:

- **Live** — exactly one `AuroraGlow` at a time. A thin Metal ring is masked to the host `Capsule` / `RoundedRectangle` stroke. A palette `AngularGradient` stroke is blurred behind it (normal blend) in a fixed gutter so Glow size and Style only change the outward bloom, never the field size or interior. Knobs cover `AuroraGlow.Palette`, `.speed`, `AuroraGlow.Style` (intensity), `.cornerRadius` / shape presets, `.glowSize`, a glow on/off toggle that unmounts Metal, and `AuroraGlow.Burster.fire()`. System / Light / Dark restyles the chrome.
- **Gallery** — painted snapshots of a button, prompt, card, full-screen edge, and the six palettes. No `AuroraGlow`, no `.glow`, no `AuroraText` in the grid. Tap a tile to open a sheet that mounts **one** live glow; dismiss to unmount it.

Chrome uses semantic grouped backgrounds and primary / secondary ink so labels stay readable in light and dark. The glow itself is the package shader.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/aurora/Aurora.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **Aurora** scheme. Xcode resolves the remote Swift package `https://github.com/tornikegomareli/Aurora.git` (from 0.5.2 / tag `0.5.2`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/aurora
xcodegen generate
```

`PRODUCT_MODULE_NAME = AuroraDemo` so the app module is not named `Aurora` (the package product). Bundle id is `com.techdemos.aurora`.

Do not vendor the package source. Do not clone `Examples/AuroraExamples` from the package. Do not stack multiple live `AuroraGlow` or `AuroraText` views.

### Metal shaders

Aurora ships precompiled metallibs (`Sources/Aurora/Metallibs`) for macOS, iOS, and the iOS simulator. This app has no `.metal` of its own. Build through Xcode (or `xcodebuild`).

## What Aurora does

An Apple Intelligence–style animated glow ring, drawn by a Metal fragment shader — no images, no GIFs. Optional `AuroraText` fills glyphs with the same metaball field.

| API | Role |
| --- | --- |
| `AuroraGlow` | SwiftUI ring backed by `colorEffect` |
| `.glow(_:cornerRadius:)` / `.glow(_:)` | Overlay a glow on any view |
| `AuroraGlow.Style` | `.subtle` / `.standard` / `.dramatic` intensity profiles |
| `AuroraGlow.Palette` | `.appleIntelligence`, `.sunset`, `.ocean`, `.forest`, `.monochrome`, `.cyberpunk` |
| `.speed` / `.cornerRadius` / `.glowSize` / `.borderWidth` | Ring geometry and pace |
| `AuroraGlow.Burster` | `@MainActor` controller to re-fire the burst |
| `.isVisible` / `OutroStyle` | Animated hide |
| `.glowWhileLoading(_:)` | Intro while loading, outro when done |
| `AuroraText` | Shimmering glyph fill (same palettes) |

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Prompt / Card** | One host. Metal glow masked to a `Capsule` / `RoundedRectangle` stroke; blurred non-Metal bloom behind. Switching unmounts the other. |
| **Show glow** | Off removes `AuroraGlow` from the tree so TimelineView is not ticking. |
| **Palette chips** | Six built-in palettes. Fires `Burster` so the intro burst replays. |
| **Intensity** | `AuroraGlow.Style`: Subtle / Standard / Dramatic — bloom radius/opacity, thin ring 3–5pt. |
| **Speed / Glow / Corner** | `.speed`, outward bloom size, `.cornerRadius`. |
| **Rect / Round / Capsule** | Writes `.cornerRadius` (8 / 24 / 80). The shader is always a rounded rect. |
| **Trigger burst** | `burster.fire()`. |
| **Leave the tab** | The live glow unmounts. Gallery never keeps a live ring in the grid. |
| **System / Light / Dark** | Chrome stays high-contrast in both schemes. |

### Gallery

Lazy grid of paused stand-ins: capsule Continue button, Siri-style prompt, inset card, full-screen edge, and a six-swatch palette strip. Chips name the APIs. Illustrations are SwiftUI paint — not `AuroraGlow`.

Tap a tile for one live preview sheet (masked `AuroraGlow` stroke + bloom, or `AuroraGlow.ignoresSafeArea()` for the full-screen / palette cases). Dismissing the sheet unmounts that glow.

**Skipped:** `AuroraText` (a second Metal fill), `.glowWhileLoading`, custom `AuroraGlow.Profile`, intro/outro/wash knobs, `Palette(base:anchors:)` hand-rolls, stacking more than one live glow.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the ShaderKit / WelcomeKit / Minted demos; package floor is iOS 17)
- Network on first resolve for Swift Package `Aurora` **0.5.2+** (tagged `0.5.2`, pin `a3f9296a1e7744529b69d8a9f9e360bf3c8c81bf`)
