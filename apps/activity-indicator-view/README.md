# ActivityIndicatorView

Dark SwiftUI playground for **[ActivityIndicatorView](https://github.com/exyte/ActivityIndicatorView)** (`import ActivityIndicatorView`, from **2.0.2**, annotated tag **2.0.2**, commit **41f89372**).

Product **`ActivityIndicatorView` only**. `Package.swift` at that tag (`swift-tools-version: 5.9`) declares iOS 15, macOS 12, watchOS 8, and tvOS 15. This app targets iOS 18 to match sibling demos.

Tag `2.0.2` is an annotated tag. The tag object is `2c02e0a3e0d151bcc434f1d0cda9d60f7edec485`. It points at commit `41f89372c018decaf965e8dddeb6e5347741beb4` (2026-09-10, "Merge pull request #28 from georgmay/patch-1"). That commit is also `HEAD` of the default branch. There is no GitHub Release object for 2.0.2. Swift Package Manager requirement `from: 2.0.2` resolves the tag.

The only public type this demo uses is `ActivityIndicatorView`. Its initializer is `init(type: IndicatorType)`. The indicator views under `Sources/ActivityIndicatorView/Indicators/` are internal. There is no visibility, color, or size parameter on the view. Visibility is "is the view in the hierarchy". Color for most presets is `foregroundStyle` (the package README writes `.foregroundColor`). Size is `.frame(width:height:)`.

Two tabs:

- **Gallery** — one `ActivityIndicatorView` per `IndicatorType` case, each built with that case's default associated values. Opens on this tab.
- **Live** — one case at a time. Count, inset, line width, line cap, arc color, and gradient colors are editable. Switching case, or **Package defaults**, writes that case's defaults back.

Visible, size, and foreground are shared by both tabs. Turning Visible off, or leaving the tab, removes the package view so its `.task` animation stops.

Chrome is a near-black page with light ink. The indicator sits on a light well so the default black growing arc and a red foreground both read. Gradient stays on a dark well so the README's `.white` stop is visible. A white foreground, or a white arc color, also flips that well to dark.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator. This app was not compiled here.

1. Open `apps/activity-indicator-view/ActivityIndicatorView.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **ActivityIndicatorView** scheme. Xcode resolves the remote Swift package `https://github.com/exyte/ActivityIndicatorView.git` (from 2.0.2 / tag `2.0.2`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/activity-indicator-view
xcodegen generate
```

`PRODUCT_MODULE_NAME = ActivityIndicatorViewDemo` so the app module is not named `ActivityIndicatorView` (the package product). Bundle id is `com.techdemos.activityindicatorview`. The home-screen name is **Indicators**.

Do not copy the package's `ActivityIndicatorViewExample` target.

## What ActivityIndicatorView does

`ActivityIndicatorView` switches on `IndicatorType` and returns one internal indicator. Defaults below are the associated-value defaults in `ActivityIndicatorView.swift` at tag 2.0.2.

| Case | Defaults | What the demo can change |
| --- | --- | --- |
| `.default(count:)` | `count` 8 | count 1...12 |
| `.arcs(count:lineWidth:)` | `count` 3, `lineWidth` 2 | count 1...4, line width 1...12 |
| `.rotatingDots(count:)` | `count` 5 | count 1...8 |
| `.flickeringDots(count:)` | `count` 8 | count 1...12 |
| `.scalingDots(count:inset:)` | `count` 3, `inset` 2 | count 1...5, inset 0...6 |
| `.opacityDots(count:inset:)` | `count` 3, `inset` 4 | count 1...5, inset 0...6 |
| `.equalizer(count:)` | `count` 5 | count 1...8 |
| `.growingArc(_:lineWidth:)` | color `.black`, `lineWidth` 4 | arc color, line width 1...12 |
| `.growingCircle` | no associated values | frame and foreground only |
| `.gradient(_:_:lineWidth:)` | `lineWidth` 4, line cap `.butt`. Colors are required | two colors, line cap, line width |

`.growingCircle` is a case with no associated values, so the call is `.growingCircle`, not `.growingCircle()`. The `default` case is a Swift keyword. Call sites in this app put backticks around `default`.

`GrowingArcIndicatorView` strokes with the color stored on the case. `foregroundStyle` does not recolor it. `GradientIndicatorView` strokes an `AngularGradient` of the array you pass, with `StrokeStyle(lineWidth:lineCap:)`, and ignores foreground too. The other eight indicators draw `Shape`s, so they inherit `foregroundStyle`.

Slider floors are taken from the indicator sources, not from a guessed API:

- `Default`, `FlickeringDots`, `ScalingDots`, `OpacityDots`, and `Equalizer` divide by `count`. Count starts at 1.
- Arcs sets `radius = width / 2 - index * count`. At the 36 pt minimum frame, count 5 makes the inner radius negative, so the slider stops at 4.
- Scaling and opacity dots use `(width - inset * (count - 1)) / count`. Count 5 and inset 6 still fit in 36 pt.
- Rotating dots hard-code `/ 5` in the scale formula. Counts above 5 make later dots scale through zero. The slider allows that, up to 8.

The package example declares `@State showLoadingIndicator` and never reads it. This demo's **Visible** toggle does remove the view.

## What to tap

### Gallery

| Control | What to look for |
| --- | --- |
| **Ten cards** | Default, Arcs, Rotating Dots, Flickering Dots, Scaling Dots, Opacity Dots, Equalizer, Growing Arc, Growing Circle, Gradient. Each call under the well is the package default. |
| **Visible** | Off replaces every indicator with "Hidden". On mounts them again. |
| **Size** | Shared `.frame`. The README sample is 50×50. The slider is 36...120 pt, step 2. |
| **Foreground** | `foregroundStyle` on the eight shape presets. Growing Arc stays `.black`. Gradient stays `[.white, .red]` with line cap `.butt`. |
| **Leave the tab** | Cards say "Unmounted". Live is the only place still able to mount a view, and only while that tab is selected. |

### Live

| Control | What to look for |
| --- | --- |
| **Type** | Menu of the ten cases. Changing it resets count, inset, line width, line cap, arc color, and gradient colors to that case's defaults. |
| **Count / Inset / Line width** | Shown only for cases that have that associated value. The monospaced line is the call `ActivityIndicatorView(type:)` will receive. |
| **Line cap** | Gradient only. Butt, Round, Square. Butt is the package default. |
| **Arc color** | Growing Arc only. Default Black. White flips the well dark so the stroke stays visible. |
| **Gradient start / end** | Default White and Red, on a dark well. |
| **Package defaults** | Same reset as changing type. Does not change Visible, size, or foreground. |
| **Visible / leave the tab** | The stage says "Hidden" or "Unmounted" and the package view is gone. |

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Wave / Vortex / ConfettiSwiftUI demos; package floor is iOS 15)
- Network on first resolve for Swift Package `ActivityIndicatorView` **2.0.2** (annotated tag `2.0.2`, pin `41f89372c018decaf965e8dddeb6e5347741beb4`)
