# ProgressIndicatorView

Dark SwiftUI playground for **[ProgressIndicatorView](https://github.com/exyte/ProgressIndicatorView)** (`import ProgressIndicatorView`, from **1.1.0**, annotated tag **1.1.0**, commit **4bc9c200**).

Product **`ProgressIndicatorView` only**. `Package.swift` at that tag (`swift-tools-version: 5.9`) declares iOS 14, macOS 11, tvOS 14, and watchOS 7. This app targets iOS 17. The README checked in at that same tag still says iOS 13 and `from: "0.0.1"`. The platforms in `Package.swift` are the ones SPM uses.

Tag `1.1.0` is an annotated tag. The tag object is `3b65b8b67116f23ffe64ebba272e3d62e594538c` (tagger AlisaMylnikova, 2025-03-27 15:21:48 +0700, no message body). It points at commit `4bc9c200713c7a01bd7ff810c80796c0c28bf066` (2025-03-27 15:20:21 +0700, "Merge commit '383453eab08cdf55ed79a1b5040271daf85f2781'"). That tag is the newest tag on the repository. Tags present: `0.0.1`, `0.0.2`, `0.0.3`, `0.0.4`, `1.0.0`, `1.0.1`, `1.1.0`. There is no GitHub Release object. Swift Package Manager requirement `from: 1.1.0` resolves the tag. `main` (`6c894e32`) is four README-only commits ahead of this tag. The Swift sources at `main` match `1.1.0`. This app pins the tag.

The type this demo draws with is `ProgressIndicatorView`. Its initializer is `init(isVisible: Binding<Bool>, type: IndicatorType)`. The indicator views under `Sources/Indicators/` are internal. `View.sizeGetter(_:)` in `Sources/Extensions/SizeGetter.swift` is also public. `ImpulseBarView` calls it. This demo does not.

Two tabs:

- **Gallery** — one `ProgressIndicatorView` per `IndicatorType` case, each built with that case's default associated values. Opens on this tab.
- **Live** — one case at a time. Track color, dash count, line width, and stroke color are editable. Switching case, or **Package defaults**, writes those defaults back.

Progress, Visible, foreground, bar height, and diameter are shared by both tabs. Turning Visible off passes `isVisible: false`, and the package body returns `EmptyView()`. Leaving the tab removes the package view.

Chrome is a near-black page with light ink. The indicator sits on a light well so a red foreground and the default clear track both read. A white foreground, a white track, or a white circle stroke flips that well to dark.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator. This app was not compiled here. `swiftc -parse` (Swift 6.0.3) accepted the sources. `swift package resolve` for `from: 1.1.0` selected tag 1.1.0 at `4bc9c200713c7a01bd7ff810c80796c0c28bf066`. `swift package dump-package` on that tag reports product `ProgressIndicatorView` and platforms iOS 14, macOS 11, tvOS 14, and watchOS 7.

1. Open `apps/progress-indicator-view/ProgressIndicatorView.xcodeproj` in Xcode 16+ (iOS 17 SDK).
2. Pick an iPhone simulator.
3. Run the **ProgressIndicatorView** scheme. Xcode resolves the remote Swift package `https://github.com/exyte/ProgressIndicatorView.git` (from 1.1.0 / tag `1.1.0`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/progress-indicator-view
xcodegen generate
```

`PRODUCT_MODULE_NAME = ProgressIndicatorViewDemo` so the app module is not named `ProgressIndicatorView` (the package product). Bundle id is `com.techdemos.progressindicatorview`. The home-screen name is **Progress**.

Do not copy the package's `ProgressIndicatorViewExample` target.

## What ProgressIndicatorView does

`ProgressIndicatorView` switches on `IndicatorType` and returns one internal indicator when `isVisible` is true. Defaults below are the associated-value defaults in `ProgressIndicatorView.swift` at tag 1.1.0. `.circle` has no default for `lineWidth` or `strokeColor`. The gallery uses the example's `8` and `.red` for those two.

| Case | Defaults | What the demo can change |
| --- | --- | --- |
| `.default(progress:)` | progress binding only. Sector count is a private 8 | the shared progress binding |
| `.bar(progress:backgroundColor:)` | `backgroundColor` `.clear` | track color |
| `.impulseBar(progress:backgroundColor:)` | `backgroundColor` `.clear` | track color |
| `.dashBar(progress:numberOfItems:backgroundColor:)` | `numberOfItems` 8, `backgroundColor` `.clear` | dash count 1...16, track color |
| `.circle(progress:lineWidth:strokeColor:backgroundColor:)` | `backgroundColor` `.clear`. Line width and stroke are required | line width 1...24, stroke color, track color |

The `default` case is a Swift keyword. Call sites in this app put backticks around `default`.

Every case takes `Binding<CGFloat>` for progress. The package example stores two bindings: `progress` (bars and circle, reset at 1) and `progressForDefaultSector` (0...1.5). This demo keeps one binding and lets the slider run 0...1.5, in steps of 0.01.

What that value does, from the indicator sources:

- **Bar** draws two capsules. The track is `backgroundColor`. The fill width is `min(max(width * progress, 0), width)`, animated with `.easeIn`. Color is `foregroundStyle`. Past 1, the bar stays full.
- **Impulse bar** clamps the same way, then masks a 100 pt white gradient that travels the full width on a 1.5s linear `repeatForever`. The gradient colors are fixed in the package. Foreground colors the fill capsule.
- **Dash bar** lays out `numberOfItems` capsules with a private 4 pt spacing. Item `index` fills when `progress > index / numberOfItems`. Width is `(fullWidth - (count - 1) * 4) / count`. Count 0 would divide by zero, so the slider starts at 1. Foreground colors the fill.
- **Default** draws eight rounded rectangles. Opacity is `progress * 2 - index / 8 - 0.1`, animated linearly. When `progress > 1`, `onChange` sets the rotation to `2π` over one second. At `progress <= 1` the rotation is `.zero`. The example's second binding is what crosses 1. Foreground colors the sectors. Count is not a parameter.
- **Circle** strokes two arcs. The track is a full turn (`-π/2` to `3π/2`) in `backgroundColor`. The progress end angle is `-π/2 + (3π/2) * progress`, so progress 1 is three quarters of a turn and progress `4/3` is a full turn. The radius is `rect.width / 2`, and the stroke is centered on that radius, so the frame clips `lineWidth / 2` on every side. `strokeColor` paints the progress arc. `foregroundStyle` does not.

`Auto progress` repeats the example timer (`every: 1/5` second). Up through 0.9 it uses the example's fast and slow steps (`1/30` and `1/120`). From 0.9 up to 1 it snaps to 1. From 1 up to 1.5 it adds `1/10`, which is the example's step for the default sector, then returns to 0. The slider is disabled while this runs.

## What to tap

### Gallery

| Control | What to look for |
| --- | --- |
| **Five cards** | Default, Bar, Impulse Bar, Dash Bar, Circle. Each call under the well is the package default. Circle passes `lineWidth: 8` and `strokeColor: .red` because that case has no defaults for them. |
| **Progress** | 0...1.5. Bars clamp at 1. Circle keeps sweeping past 1. Default rotates once progress is above 1. |
| **Auto progress** | The shared value walks on its own. The slider stops tracking touches until auto is off. |
| **Visible** | Off leaves the package view mounted and passes `isVisible: false`. The well says "Hidden". On passes `true`. |
| **Bar height / Diameter** | Shared frames. Bar height starts at 8. Diameter starts at 72. |
| **Foreground** | `foregroundStyle` on the four shape presets. Circle stays `strokeColor: .red`. |
| **Leave the tab** | Cards say "Unmounted". Live is the only place still able to mount a view, and only while that tab is selected. |

### Live

| Control | What to look for |
| --- | --- |
| **Type** | Menu of the five cases. Changing it resets track, dash count, line width, and stroke to the package defaults. |
| **Track color** | `backgroundColor` for every case except Default. Clear is the default. Gray 25% is the example track. White flips the well dark. |
| **Dash count** | Dash Bar only. Default 8. Range 1...16. |
| **Line width / Stroke color** | Circle only. The monospaced line is the call `ProgressIndicatorView(isVisible:type:)` will receive. |
| **Package defaults** | Same reset as changing type. Does not change progress, Visible, foreground, or frame size. |
| **Visible / leave the tab** | The stage says "Hidden" or "Unmounted". Hidden still owns a `ProgressIndicatorView`. Unmounted does not. |

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 17 simulator (same floor as the Grid / AlertKit / WhatsNewKit demos; package floor is iOS 14)
- Network on first resolve for Swift Package `ProgressIndicatorView` **1.1.0** (annotated tag `1.1.0`, pin `4bc9c200713c7a01bd7ff810c80796c0c28bf066`)
