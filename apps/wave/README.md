# Wave

Dark SwiftUI playground for **[Wave](https://github.com/jtrivedi/Wave)** (`import Wave`, from **0.3.4**, tag **0.3.4**, revision **72f4688**).

Product **`Wave` only**. The package floor is iOS 13 and macOS 10.12. This app targets iOS 18 to match sibling demos.

Tag `0.3.4` points at `72f4688be3cfd3b56fcc76f51bf2a59dfece017e` (2026-03-24, "Update generate_docs.sh"). That tag is fourteen commits ahead of `0.3.3` (`27b7e1d`), which is still `HEAD` of `main` and the latest GitHub Release. `0.3.4` is a lightweight tag, not a GitHub Release object. Swift Package Manager requirement `from: 0.3.4` resolves the tag. Those fourteen commits change `SpringAnimator` restart and finish behavior, immediate non-animated updates, and the `gestureVelocity` documentation. The demo is written against that tag, not against `main`.

`Spring` in the package is a class. On iOS 17+ SwiftUI also has a `Spring` struct, so a file that imports both cannot use the bare name. Inside the Wave module the `Wave` class shadows the module, which is why `Spring.swift` has an **internal** `typealias WaveSpring`. This app declares the same typealias in `Models.swift`, which imports Wave and not SwiftUI.

The generated Info.plist sets `CADisableMinimumFrameDuration` to true, as the package README asks, so ProMotion devices are not capped at 60 fps.

Two tabs:

- **Live** — picker among Drag, Springs, and Retarget. Only the selected surface keeps a `SpringAnimator`. Switching family or leaving the tab stops it.
- **Gallery** — frozen painted cards. No `SpringAnimator`, no `Wave.animate`.

Live chrome uses hardcoded light ink on a near-black page.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/wave/Wave.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **Wave** scheme. Xcode resolves the remote Swift package `https://github.com/jtrivedi/Wave.git` (from 0.3.4 / tag `0.3.4`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/wave
xcodegen generate
```

`PRODUCT_MODULE_NAME = WaveDemo` so the app module is not named `Wave` (the package product, and also the name of the `Wave` class). Bundle id is `com.techdemos.wave`.

Keep `SpringAnimator` on the Live tab. Keep Gallery free of animators. Leave the upstream sample (`Sample App/Wave-Sample`) out of this target.

## What Wave does

Wave integrates a spring on a display link. Every animation can change its `target` while it is running and keep its velocity, which is what the package means by retargeting.

SwiftUI in this demo is driven by the property API, the same one `SwiftUIViewController.swift` in the package sample uses. The block API (`Wave.animate`) writes `UIView.animator` and `CALayer.animator`. It is not mounted here.

| API | Role |
| --- | --- |
| `Spring(dampingRatio:response:mass:)` | `mass` defaults to 1. `response` is one undamped period, in seconds. `dampingRatio` 1 is critically damped |
| `Spring(dampingRatio:stiffness:mass:)` | Same spring, parameterized by stiffness `k`. Requires both arguments `> 0` |
| `Spring.defaultInteractive` | `dampingRatio` 0.8, `response` 0.20 |
| `Spring.defaultAnimated` | `dampingRatio` 1.0, `response` 0.82 |
| `Spring.defaultNonAnimated` | `dampingRatio` 1.0, `response` 0. Settling duration is reported as 1s so a display link can stay up; the value still snaps |
| `SpringAnimator<T>` | `T: SpringInterpolatable`. Public conformers used here are `CGPoint` and `CGFloat` (`CGSize` and `CGRect` exist too) |
| `SpringAnimator.value` / `target` / `velocity` | Must both be non-nil before `start()`. Velocity defaults to zero |
| `SpringAnimator.mode` | `AnimationMode.animated` or `.nonAnimated` |
| `SpringAnimator.valueChanged` | Called with the presentation value, including the synchronous `dt == 0` update inside `start()` |
| `SpringAnimator.completion` | `Event.finished(at:)` or `Event.retargeted(from:to:)`. Retarget fires when `target` changes while `state == .running` |
| `SpringAnimator.start()` / `stop(immediately:)` | `stop(immediately: true)` freezes `value`, zeros velocity, and emits `.finished` |
| `project(point:velocity:)` | Public helper. Default `decelerationRate` is 0.998. Displacement is `(velocity / 1000) * rate / (1 - rate)` |
| `Wave.animate(withSpring:mode:gestureVelocity:animations:completion:)` | UIKit block API. `gestureVelocity` applies to `center` (and the positional part of `frame`) only |

`valueChanged` and `completion` are nonisolated. The display link is a `CADisplayLink` added to the current run loop from `start()`, which this app calls on the main actor. The app hops back with `MainActor.assumeIsolated` so SwiftUI state updates on the same turn. A `Task` hop would undo the package's immediate-update behavior.

`DragGesture.Value.velocity` is points per second, the same unit as `UIPanGestureRecognizer.velocity(in:)`, which the package sample assigns straight to `SpringAnimator.velocity`. Wave's step is `value + velocity * dt` with `dt` in seconds.

`integralizeValues` stays false. The package notes that the flag quantizes continuous values.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Drag** | One `SpringAnimator<CGPoint>` (`dampingRatio` 0.72, `response` 0.70, the package SwiftUI sample) and one `SpringAnimator<CGFloat>` for scale. The gesture is on the stage, `minimumDistance` 0. While the finger is down, position `mode` is `.nonAnimated` and `target` is the grab point plus translation, so a second grab does not jump back to zero. Each of those updates finishes inside `start()`, so the label says **tracking** instead of `.ended`. Scale animates to 1.16 with `Spring.defaultInteractive`. |
| **Release** | Velocity is copied onto the position animator. The landing is `project(point:velocity:)` clamped 88 pt inside the stage. Mode returns to `.animated` and the release spring is the 0.72 / 0.70 spring. Scale returns to 1 with `Spring.defaultAnimated` and velocity 0. The ring is `target`. |
| **Spring home** | Sets position `target` to zero without clearing velocity, so an in-flight fling arcs home. `Event.retargeted` only fires when `state` is already `.running`. The Drag tab does not print that event; Retarget does. |
| **Springs** | Menu of six `Spring` values. **Run** flips `target` between 0 and 1. Switching preset while running restarts from the current value toward the same target, because a new `settlingDuration` must not inherit the old clock. **Snap** uses `defaultNonAnimated` and `AnimationMode.nonAnimated`. The knob is allowed outside 0...1 so underdamped motion can pass the end of the track. Readout values are taken from the live `Spring` instance (`response` and `stiffness` are derived from each other). |
| **Retarget** | `Spring(dampingRatio: 0.62, response: 0.90)`, a demo spring, not a package preset. Leading / Center / Trailing set `target`. Changing it while running keeps velocity and appends `retargeted`. **Toss** writes velocity `(1100, 260)` and leaves `target` put. If a run is already going, Toss stops it first so the settling clock starts over; that stop's `.finished` is not logged. |
| **Leave the tab / family** | `stop(immediately: true)` runs and the surface is removed. Gallery never keeps an animator. |

Live content sits outside a page `ScrollView` (the drag owns the stage) and uses a bottom `safeAreaInset` so the tab pill does not cover the stage.

### Gallery

Lazy grid of paused stand-ins: drag, fling arc, scale, three painted response curves, a retarget arc, an event list, the two modes, and a card for the UIKit block API. Chips name the APIs. Illustrations are SwiftUI paint.

**Skipped:** `Wave.animate` and every `UIView.animator` / `CALayer.animator` property (`frame`, `bounds`, `center`, `origin`, `alpha`, `backgroundColor`, `cornerRadius`, `scale`, `translation`, shadow, border). Also skipped: `SpringAnimator<CGSize>`, `SpringAnimator<CGRect>`, `integralizeValues`, `rubberband`, `mapRange`, the macOS sample, and copying `Sample App/`.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Vortex / Inferno demos; package floor is iOS 13)
- Network on first resolve for Swift Package `Wave` **0.3.4** (tag `0.3.4`, pin `72f4688be3cfd3b56fcc76f51bf2a59dfece017e`)
