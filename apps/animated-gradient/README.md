# Gradient

Dark SwiftUI playground for **[AnimatedGradient](https://github.com/exyte/AnimatedGradient)** (`import AnimatedGradient`, from **1.0.1**, annotated tag **1.0.1**, commit **c0e19120**).

Product **`AnimatedGradient` only**. `Package.swift` at that tag (`swift-tools-version: 5.9`) declares iOS 14 and no other platform. The library target enables the experimental `StrictConcurrency` feature. This app's deployment target is iOS 17.0. The home-screen name is **Gradient**. The app module is `AnimatedGradientDemo`, because the package product is already `AnimatedGradient`. The license is MIT.

Tag `1.0.1` is an annotated tag with an empty message. The tag object is `99dc685c906d1d06bf0580aff63a9409aefb0e68`. It points at commit `c0e19120abda483a61058721c6c7d65c82c4ebe9` (2025-03-26, "Merge commit '0ee1c58136392355a30f47c1de15fcaa39b8a8b0'"). That tag is the newest tag on the repository. There is no GitHub Release object for 1.0.1, or for 1.0.0. Swift Package Manager requirement `from: 1.0.1` resolves the tag. Default-branch `HEAD` is `6d69e75466ffd16f03343defe6302103a9d9a043` (2026-11-06, "Update readme"). `Sources/` and `Package.swift` at that commit match the tag. The README difference is two links in the other-libraries list.

The type this demo animates with is `AnimatedLinearGradient`. Presets are `GradientPreset.pastel` and `GradientPreset.bright`. The manual blend uses `View.animatableLinearGradient(fromGradient:toGradient:progress:startPoint:endPoint:)`.

Two tabs:

- **Live** — one `AnimatedLinearGradient`. Palette, cycle length, simultaneous colors, animation, duration, and both unit points are editable. A second well drives `animatableLinearGradient` from a progress slider. Opens on this tab.
- **Gallery** — one card per preset or modifier overload. Leaving the tab removes every gradient.

Chrome is a near-black page with light ink. The gradient fills a fixed-height well. Controls sit under it, so the blend stays visible.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator. This app was not compiled here. `swiftc -parse` accepted the sources. That is a syntax parse, not a typecheck. `swift package resolve` for `from: 1.0.1` selected tag 1.0.1 at `c0e19120abda483a61058721c6c7d65c82c4ebe9`.

1. Open `apps/animated-gradient/AnimatedGradient.xcodeproj` in Xcode 16+ (iOS 17 SDK).
2. Pick an iPhone simulator.
3. Run the **AnimatedGradient** scheme. Xcode resolves the remote Swift package `https://github.com/exyte/AnimatedGradient.git` (from 1.0.1 / tag `1.0.1`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/animated-gradient
xcodegen generate
```

`PRODUCT_MODULE_NAME = AnimatedGradientDemo`. Bundle id is `com.techdemos.animatedgradient`.

Do not copy the package's `AnimatedGradientExample` target. That target also imports `Flow`, which this demo does not use.

## What AnimatedGradient does

`AnimatedLinearGradient` is a `Rectangle` blended between two `Gradient` values. `onAppear` copies `colors`, builds the first pair of gradients, and animates `progress` from 0 to 1. When that animation finishes, the view advances the window and animates 0 to 1 again.

Defaults below are the stored properties in `AnimatedLinearGradient.swift` at tag 1.0.1.

| API | Default | What it does |
| --- | --- | --- |
| `init(colors:)` | none | The only public initializer. The cycle walks this array |
| `numberOfSimultaneousColors(_:)` | 2 | How many stops are on screen. Each stop blends one palette color into the next |
| `setAnimation(_:)` | `.linear(duration: 3)` | The animation passed to `withAnimation` for `progress` 0 → 1 |
| `gradientPoints(start:end:)` | `.topTrailing` to `.bottomLeading` | `UnitPoint`s of the linear gradient |
| `gradientPoints(start:)` | end becomes `.bottomLeading` | One-argument overload. It replaces the end. It does not keep a previous end |
| `gradientPoints(end:)` | start becomes `.topTrailing` | One-argument overload. It replaces the start. It does not keep a previous start |
| `GradientPreset.pastel` | six colors | `D2C7F6`, `EFC6B7`, `F4F2C1`, `A2EFE9`, `DCF4C4`, `F5B8CE` |
| `GradientPreset.bright` | six colors | `FFE53B`, `00FFA9`, `6094EA`, `0D4DFF`, `F02FC2`, `FF2525` |
| `animatableLinearGradient(fromGradient:toGradient:progress:startPoint:endPoint:)` | none | Public `View` method. Mixes equal-length stop lists by `progress` |

`nextGradients` starts from a private index of 0 and adds 1 before building stops, so the first window begins at palette index 1. Stop `k` blends `colors[index + k]` into `colors[index + k + 1]`, wrapping with the internal cycle subscript. The next finished transition slides that window forward by one. A simultaneous count larger than the palette repeats colors. A count of 1 is a solid crossfade. An empty `colors` array returns without changing the gradients. This demo keeps at least two colors.

The completion handler sets `progress` back to 0 without an animation, then animates it to 1. The reset is how the next pair of gradients appears.

`onChange(of: colors)` writes the new array onto the view model and leaves the current gradients in place. The new array is used the next time `nextGradients` runs. `numberOfSimultaneousColors` and `setAnimation` are read in `onAppear` and again inside the completion handler that `body` installs. `gradientPoints` are arguments of the modifier in `body`, so a new start or end is used on the next refresh. **Remount** changes the view's identity so `onAppear` runs immediately.

`Color.mix` lerps red, green, and blue and drops opacity. The mixed color is opaque. The modifier indexes `toGradient.stops[i]` for every stop in `fromGradient`. The animated view builds both gradients from the same pair list, so the counts match. The driver passes two gradients of two stops each. A shorter `toGradient` would trap. This demo does not build that case.

Reduce Motion is not a package API. The demo then shows a SwiftUI `LinearGradient` of the selected colors and points. That gradient is the whole palette, not the current animated window.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Palette** | Spectrum starts as `[.red, .green, .blue]` plus orange, yellow, and purple. Pastel and Bright are `GradientPreset` |
| **Colors in the cycle** | `prefix` of that palette, from 2 through 6. The init receives that array |
| **Simultaneous colors** | 1...8. The stored default is 2. 5 on a 3-color prefix repeats stops |
| **Animation** | `.linear`, `.easeIn`, `.easeOut`, or `.easeInOut`, each with the duration. The package default and the example use `.linear` |
| **Duration** | 0.5...10, step 0.1. The stored default is 3. The example slider is 1...10. Duration 0 is omitted because the completion handler would schedule the next pass immediately |
| **Start / End** | `gradientPoints(start:end:)`. Defaults are `.topTrailing` and `.bottomLeading` |
| **Remount** | New view identity. `onAppear` reads the current colors, count, and animation |
| **Package defaults** | Spectrum prefix 3, simultaneous 2, `.linear(duration: 3)`, `.topTrailing` to `.bottomLeading`, driver progress 0, then remount |
| **Driver** | `animatableLinearGradient` from `[.red, .yellow]` to `[.blue, .green]`, `.leading` to `.trailing`. The slider is `progress` |
| **Leave the tab** | The stage says "Unmounted" |

The lines under the stage are the modifiers on the view. A new palette, count, or animation shows up when the current transition finishes, or when you tap **Remount**. Points update without remounting. With Reduce Motion on, those lines name the `LinearGradient` substitute instead.

### Gallery

| Card | Call | What to look for |
| --- | --- | --- |
| **Minimal** | `AnimatedLinearGradient(colors: [.red, .green, .blue])` | No modifiers. Stored defaults |
| **Modifiers** | `.numberOfSimultaneousColors(2)`, `.setAnimation(.linear(duration: 5))`, `.gradientPoints(start: .bottomLeading, end: .topTrailing)` | The README sample |
| **Pastel** | `GradientPreset.pastel` | All six pastel colors, stored defaults |
| **Bright** | `GradientPreset.bright` | All six bright colors, stored defaults |
| **Example** | `Array(GradientPreset.pastel.prefix(upTo: 2))` plus simultaneous 2, linear 3 seconds, `.bottomLeading` to `.topTrailing` | The example screen's initial state |
| **One stop** | `.numberOfSimultaneousColors(1)` | Solid crossfade of red, green, and blue |
| **Cycled stops** | `.numberOfSimultaneousColors(5)` | Five stops on three colors |
| **Start only** | `.gradientPoints(start: .topLeading)` | End is `.bottomLeading` because that is what the overload writes |
| **End only** | `.gradientPoints(end: .bottom)` | Start is `.topTrailing` because that is what the overload writes |

**Skipped:** `Pair` (public type, internal `left` and `right`), `Color.hex` and `Color.init(hex:)` (internal; the example app copies them locally), the internal cycle subscript, and the internal `onAnimationCompleted` observer. The demo calls `animatableLinearGradient` rather than constructing `AnimatableLinearGradientModifier` itself. The package `Example` screens are not copied. CocoaPods is marked deprecated after 1.0.0 in the package README. This app uses Swift Package Manager.

## Dependencies

- Network on first resolve for Swift Package `AnimatedGradient` **1.0.1** (tag `1.0.1`, pin `c0e19120abda483a61058721c6c7d65c82c4ebe9`)
