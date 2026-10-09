# Pow

SwiftUI playground for **[Pow](https://github.com/EmergeTools/Pow)** (`import Pow`, from **1.0.6**, tagged **1.0.6**, revision **1b4b1dd**).

Product **`Pow` only**. Package floor is iOS 15; this app targets iOS 18 to match sibling demos.

Two tabs:

- **Live** — one effect target at a time, in a `ScrollView` below the navigation bar. Controls, then the badge, then **Fire effect** or **Insert / Remove view** in normal document order, then 120pt of bottom padding so the floating tab bar cannot cover the button. Jump keeps empty space above the badge so a leap does not cover the caption. The Effects family fires Spray, Jump, Pulse (the current ping API), Shine, Spin, Shake, Wiggle, Glow, Rise, and Haptic from `.changeEffect`. The Transitions family inserts or removes a badge with Pop, Flip, Anvil, Blinds, Boing, Swoosh, and Vanish (`.movingParts`). Switching family, switching the menu, or leaving the tab unmounts the previous target.
- **Gallery** — painted snapshots (name, API, short description). Tiles do not run Pow. Tapping a tile opens a sheet with a single live demo of that effect or transition.

Chrome uses semantic grouped backgrounds and primary ink, with an opaque muted label (not `Color.secondary`) so captions stay readable in light and dark. The live badge is white on a saturated rose fill; spray and rise particles are white so they read on the badge. The Gallery Spray tile is a rose badge with white hearts, matching Live.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/pow/Pow.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **Pow** scheme. Xcode resolves the remote Swift package `https://github.com/EmergeTools/Pow.git` (from 1.0.6 / tag `1.0.6`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/pow
xcodegen generate
```

`PRODUCT_MODULE_NAME = PowDemo` so the app module is not named `Pow` (the package product). Bundle id is `com.techdemos.pow`.

Do not vendor the package source. Do not clone `Example/Pow Example` from the package.

## What Pow does

Change effects fire whenever an `Equatable` value updates. Transitions live under `AnyTransition.movingParts`.

| API | Role |
| --- | --- |
| `.changeEffect(_:value:isEnabled:)` | Run an `AnyChangeEffect` when `value` changes |
| `.spray(origin:layer:)` | Particle burst from an origin |
| `.jump(height:)` | Leap and bounce |
| `.pulse(shape:style:drawingMode:count:)` | Growing rings; replaces deprecated `.ping` |
| `.shine(angle:duration:)` | Sweeping highlight |
| `.spin(axis:rate:)` | 3D spin with `SpinRate` |
| `.shake(rate:)` / `.wiggle(rate:)` | Horizontal shake / z-wiggle |
| `.glow(color:radius:)` | Blooming halo |
| `.rise(origin:layer:)` | Particles that float upward |
| `.feedback(hapticNotification:)` | Haptic change feedback |
| `.movingParts.pop` / `.flip` / `.anvil` | Insertion (pop, anvil) or 3D flip |
| `.movingParts.blinds` / `.boing` / `.swoosh` / `.vanish` | Reveal, squash, 3D swoop, particle dissolve |
| `.particleLayer(name:)` | Draw spray / rise / pulse particles above clipping ancestors |
| `.delay(_:)` | Hold a change effect (not wired in this playground) |

## What to tap

### Live

Default tab on launch. System / Light / Dark restyles the chrome. Effects / Transitions picks the family.

| Control | What to look for |
| --- | --- |
| **Effects → Spray** | Tap the rose badge or **Fire effect**. Hearts and sparkles burst from the chosen origin. |
| **Jump** | Height slider. The badge leaps and settles. |
| **Pulse** | Shape, fill vs stroke, count. Rings expand behind the badge. (Ping was renamed to Pulse in Pow.) |
| **Shine** | Duration and angle. A highlight sweeps the badge. |
| **Spin** | Axis X/Y/Z, Default/Fast, boost. The badge spins then coasts. |
| **Shake / Wiggle** | Default vs Fast rate. |
| **Glow** | Color and radius. A halo blooms. |
| **Rise** | Origin. Plus and star particles float up. |
| **Haptic** | Success / Warning / Error / Impact / Selection. Visual tap still fires; haptics need a device. |
| **Transitions → Pop** | **Remove view** / **Insert view**. Pop is insertion-only. |
| **Flip** | Rotates toward / away from the viewer. |
| **Anvil** | Drops in from the top (insertion-only, ~1.4s). |
| **Blinds** | Slat width, Venetian / Vertical, staggered. |
| **Boing** | Edge. Overshoot squashes the badge. |
| **Swoosh** | Back-to-front 3D move. |
| **Vanish** | Particle dissolve on removal. Increased brightness toggle. |
| **Leave the tab** | The live target unmounts. Gallery never keeps it. |

Live spray / rise / pulse use `ParticleLayer.named("playground")` so particles are not clipped by the card.

### Gallery

Lazy grid, two sections. Each tile is a static drawing plus the API name.

Tap any tile → sheet with one live badge. **Fire** for change effects, **Insert / Remove** for transitions. **Close** dismisses and unmounts.

**Skipped:** `.feedback(SoundEffect)` (needs bundled audio), deprecated `.ping` / `.hapticFeedback`, conditional `.pushDown` / `.smoke` / repeating `.glow`, `.risingParticle`, vanish masks, `rotate3D`.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the ShaderKit / WelcomeKit / Foldy demos; package floor is iOS 15)
- Network on first resolve for Swift Package `Pow` **1.0.6+** (tagged `1.0.6`, pin `1b4b1dda28c50b95f0872927ee2226fe8b58950e`)
