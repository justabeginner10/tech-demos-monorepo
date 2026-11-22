# Pow

Dark SwiftUI playground for **[Pow](https://github.com/EmergeTools/Pow)** (`import Pow`, exact **1.0.6**, tag **1.0.6**, revision **1b4b1dd**).

Product **`Pow` only**. License is MIT. The package floor is iOS 15, macOS 12, Mac Catalyst 15, and tvOS 15. This app targets iOS 18 to match sibling demos. The package manifest sets `swiftLanguageVersions: [.v5]`. The app target is Swift 6.

Tag `1.0.6` points at `1b4b1dda28c50b95f0872927ee2226fe8b58950e` (2026-02-20, "Fix ambiguous use of .pi (#83)"). That commit is also `HEAD` of the default branch. `project.yml` uses `exactVersion: 1.0.6`, so a later tag cannot satisfy the requirement. The Xcode project requirement is `exactVersion`, and `Package.resolved` pins that revision.

Pow's own manifest also declares `SnapshotPreviews-iOS` at exact `0.10.21` (tag `v0.10.21`). The Pow target does not link it unless `enablePreviews` is turned on in that `Package.swift`. This app's resolved file pins Pow only, the same way sibling demos pin their direct package.

Two tabs:

- **Live** — picker among Effects and Transitions. Only the selected surface is mounted. Effects attaches one `changeEffect`. Transitions inserts one view with one `AnyTransition.movingParts` value.
- **Gallery** — frozen painted cards. Those files do not import Pow. No `changeEffect`, no `conditionalEffect`, no `movingParts` transition.

Live chrome uses hardcoded light ink on a near-black page so glow and shine stay readable.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/pow/Pow.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **Pow** scheme. Xcode resolves the remote Swift package `https://github.com/EmergeTools/Pow.git` at exact 1.0.6 (tag `1.0.6`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/pow
xcodegen generate
```

`PRODUCT_MODULE_NAME = PowDemo` so the app module is not named `Pow` (the package product). Bundle id is `com.techdemos.pow`.

Keep `changeEffect` and `movingParts` on the Live tab. Keep Gallery free of both. Leave the upstream example app (`Example/`) out of this target.

## What Pow does

`View.changeEffect(_:value:isEnabled:)` watches an `Equatable` value. After the view has appeared, a change runs the `AnyChangeEffect` when `isEnabled` is true (the default). The initial value does not run the effect. This demo watches an `Int` and increments it from **Trigger**.

`View.conditionalEffect(_:condition:)` is the other entry point. It can repeat a change effect or hold a continuous effect while a `Bool` is true. It is not mounted here.

Transitions are namespaced under `AnyTransition.movingParts`.

| API | Role in this demo |
| --- | --- |
| `changeEffect(_:value:isEnabled:)` | Effects tab. `isEnabled` stays at its default, `true` |
| `.shake(rate: .fast)` | `AnyChangeEffect.ShakeRate.fast` (phase length 0.3). `.shake` uses `ShakeRate.default` (0.8) |
| `.glow(color:radius:)` | Accent color, radius 20. The package clamps radius to 100. Static `.glow` uses `.accentColor` and radius 16 |
| `.jump(height:)` | Height 40. The view rises, then the underdamped spring bounces it back |
| `.spin(axis:rate:)` | Axis `(x: 0, y: 1, z: 0)`, `SpinRate.fast`. Static `.spin` is that axis with `SpinRate.default` |
| `.shine` | Calls `shine(duration: 1)`. Cooldown is half the duration. A faster second tap can be ignored |
| `.movingParts.boing(edge: .top)` | Spring `duration` 0.55, `bounce` 0.35 is attached with `AnyTransition.animation`. Removal also fades over 0.2s |
| `.movingParts.pop(_:)` | Accent `ShapeStyle`. Insertion only, linear 1.2s baked into the transition. Removal is `.identity` |
| `.movingParts.flip` | Inserts by rotating toward the viewer. The show/hide transaction is a spring with bounce 0.35 so overshoot can carry the rotation past rest |
| `.movingParts.iris(origin:blurRadius:)` | Origin `.center`, `blurRadius` 10. The card uses `compositingGroup()` first, as the package iris example does |
| `.movingParts.wipe(angle:blurRadius:)` | Insertion 45°, removal 225°, `blurRadius` 10. Those angles are the ones in the package doc comment |

`AnyChangeEffect.delay(_:)` can postpone any change effect. It is not used.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Effects** | Segmented menu of Shake, Glow, Jump, Spin, and Shine. Switching replaces the stage, so the previous modifier is gone and the counter returns to 0. **Trigger** adds 1 to the `Int` `changeEffect` is watching. The stage is not clipped, so the jump and the glow can leave the card. |
| **Transitions** | Segmented menu of Boing, Pop, Flip, Iris, and Wipe. **Show** / **Hide** toggles insertion inside `withAnimation`. Switching the menu removes the stage, including a transition that has not finished. Pop disappears immediately on Hide because its removal is `.identity`. |
| **Leave the tab / family** | The active surface is removed. Gallery never keeps an effect or a transition. |

Live content sits outside a page `ScrollView` and uses a bottom `safeAreaInset` so the tab pill does not cover the stage.

### Gallery

Lazy grid of paused stand-ins for the five effects and five transitions. Chips name the APIs. Illustrations are SwiftUI paint.

**Skipped:** `wiggle`, `pulse` (and the deprecated `ping`), `spray`, `rise` (and the deprecated `risingParticle`), `feedback(hapticNotification:)`, `feedback(hapticImpact:)`, `feedbackHapticSelection`, `feedback(_:)` sound effects, `conditionalEffect`, `AnyConditionalEffect.repeat`, conditional `glow`, `pushDown`, `smoke`, `particleLayer(name:)`, and `ParticleLayer`. Also skipped: transitions `anvil`, `blinds`, `blur`, `clock(origin:blurRadius:)`, `filmExposure`, `flicker`, `glare`, `move`, `poof`, `skid`, `swoosh`, `vanish`, and `rotate3D`. `Animation.movingParts` timing curves (`anticipate`, `overshoot`, `anticipateOvershoot`, and the exponential eases) are not used.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Vortex / Wave demos; package floor is iOS 15)
- Network on first resolve for Swift Package `Pow` **1.0.6** (tag `1.0.6`, pin `1b4b1dda28c50b95f0872927ee2226fe8b58950e`)

## What was checked here

On this Linux VM, without Xcode or a Simulator:

- Tag `1.0.6` resolves to `1b4b1dda28c50b95f0872927ee2226fe8b58950e`, which matched `HEAD`.
- The calls above were read from that tag's `Sources/Pow` (not from a later commit).
- `swiftc -parse` (Swift 6.2.1) accepted every file under `apps/pow/Sources`.
- A throwaway Swift package with `.package(..., exact: "1.0.6")` resolved only `pow` at `1.0.6` / `1b4b1dda28c50b95f0872927ee2226fe8b58950e`. SnapshotPreviews was not part of that client graph.

Not checked: an Xcode build, an iOS Simulator launch, screenshots, or video. Do those on Aditya's Mac.
