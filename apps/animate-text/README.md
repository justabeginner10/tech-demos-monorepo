# Animate Text

Dark SwiftUI playground for **[AnimateText](https://github.com/jasudev/AnimateText)** (`import AnimateText`, exact **0.5.0**, lightweight tag **0.5.0**, commit **c55847e**).

Product **`AnimateText` only**. `Package.swift` at that tag (`swift-tools-version: 5.5`) declares iOS 14 and macOS 11. The license is MIT. This app targets iOS 17. The package floor is iOS 14.

Tag `0.5.0` is a lightweight tag. It points at commit `c55847e03bb3f36cf83cc217fe60ec5feda9ddd6` (2022-02-09, "Bug fix."). It is the only tag on the repo. Swift Package Manager requirement `exact: 0.5.0` resolves that tag.

The public surface this demo calls was read from `Sources/AnimateText` at that commit. There is no separate typewriter type. The glyph scramble is `ATRandomTypoEffect` / `ATTypoEffect`, which drive `ATRandomTypoAnimation`.

Two tabs:

- **Live** — picker among Effects, Glyphs, and Custom. Only the selected surface keeps one `AnimateText`. Switching family or leaving the tab removes it.
- **Gallery** — one `AnimateText` per built-in effect, all on the word "Animate". Leaving the tab removes them.

Live chrome uses hardcoded light ink on a near-black page. The stage clips, so large scale and offset travel is cut at the card edge.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. The Simulator build, screenshots, and video are still to be done on Aditya's Mac. A Linux VM cannot run the Simulator. This app was not compiled for iOS and was not run.

What was checked here:

- `swiftc -parse` (Swift 6.4.2) accepted the seven app sources.
- The package pin is unchanged: `Package.resolved` is still exact **0.5.0** (`c55847e03bb3f36cf83cc217fe60ec5feda9ddd6`). `SWIFT_VERSION` is still 6.0.
- The same sources were typechecked with Swift 6.4.2 against stand-in SwiftUI and AnimateText modules. The AnimateText protocol and `AnimateText` view were copied from that tag and compiled as Swift 5, matching the package. The stand-in `View` and `ViewModifier` are `@MainActor`. `#Preview` was left out of that check, and `@main` was left out because the stand-in `App` protocol is not the compiler's entry-point hook. That is not an iOS build of this app. The same check rejects the previous unisolated `StaggerRiseEffect` conformance with `#ConformanceIsolation`.

1. Open `apps/animate-text/AnimateText.xcodeproj` in Xcode 16+ (iOS 17 SDK).
2. Pick an iPhone simulator.
3. Run the **AnimateText** scheme. Xcode resolves the remote Swift package `https://github.com/jasudev/AnimateText.git` at exact **0.5.0**.

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/animate-text
xcodegen generate
```

`PRODUCT_MODULE_NAME = AnimateTextDemo` so the app module is not named `AnimateText` (the package product, and the view type). Bundle id is `com.techdemos.animatetext`. The home-screen name is **Animate Text**.

Keep the package view on the selected tab. Leave the upstream example target (`AnimateTextExample`) and `ATAnimateTextPreview` out of this app.

## What AnimateText does

`AnimateText<Effect>` splits a bound `String` and applies one `ATTextAnimateEffect` to each piece. The effect type is the generic argument. `ATUnitType.letters` maps the string to characters. `ATUnitType.words` splits on spaces and puts the spaces back as their own elements.

The animation does not run for the initial value. `body` shows one `Text` until `onChange(of: text)` fires. That handler sets an internal value to `0`, splits the string, then sets the value to `1` on the next main-queue turn. Each built-in effect animates from `data.value`. This demo starts the binding at `""` and assigns the phrase in `onAppear`, and it remounts the view when the effect, unit, phrase, replay count, glyph set, or delay changes.

`userInfo` is stored when the view is created. It is passed into `Effect.init(_:_:)` for every element. It is not a binding.

`ATElementData` has no public initializer, so this app does not construct `ATRandomTypoAnimation` itself. The package creates the data and the effect.

| API | Role |
| --- | --- |
| `AnimateText<Effect>($text, type:userInfo:)` | Splits `$text` and runs `Effect`. `type` defaults to `.letters`. `userInfo` defaults to `nil` |
| `ATUnitType.letters` / `.words` | Character split, or space-separated words with the spaces kept as elements |
| `ATTextAnimateEffect` | `ViewModifier` plus `data`, `userInfo`, and `init(_:_:)` |
| `ATElementData` | `element`, `index`, `count`, `value`, `size`, `invValue`, `scale`, `invScale`, `locValue` |
| Basic effects | `ATOpacityEffect`, `ATScaleEffect`, `ATBlurEffect`, `ATSlideEffect`, `ATOffsetEffect`, `ATRotateEffect`, `ATTopBottomEffect`, `ATBottomTopEffect` |
| Advanced effects | `ATChainEffect`, `ATChimeBellEffect`, `ATCurtainEffect`, `ATDropEffect`, `ATHangEffect`, `ATPaperEffect`, `ATSpringEffect`, `ATTwistEffect`, `ATRandomTypoEffect`, `ATTypoEffect` |
| `ATRandomTypoEffect` | Scrambles with `ATRandomTypoAnimation` and the modifier's default glyph set. Ignores `userInfo` |
| `ATTypoEffect` | Same scramble. If `userInfo` is `[String: Any]`, it force-casts `userInfo["base"]` to `String`. `nil` keeps `"-"` |
| `StaggerRiseEffect` | App type. Opacity and a 18pt rise. A `Double` userInfo is the per-index delay. Anything else uses `0.06`, the README sample. The conformance is `@MainActor`: the protocol refines `ViewModifier`, so a plain Swift 6 conformance is inferred onto the main actor and its `data`, `userInfo`, and `init` cannot satisfy the nonisolated requirements |

`ATTypoEffect` crashes if `userInfo` is a dictionary and `"base"` is missing or not a `String`. An empty base would also call `arc4random_uniform(0)` inside `ATRandomTypoAnimation`. The glyph field falls back to `"-"` when it is empty.

`locValue` divides by `count - 1`. None of the built-in effects read it. This app does not read it either.

The package calls the iOS 14 `onChange(of:perform:)`. That method is deprecated in iOS 17 and is still what the package uses. This app does not reimplement it.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Effects** | Menu of all 18 built-in effects. **Letters** / **Words** sets `ATUnitType`. The phrase menu swaps the binding, which is what starts a run. **Replay** remounts the same phrase. `userInfo` is `nil`, so **Typo** uses the `"-"` glyph. |
| **Glyphs** | **Random** is `ATRandomTypoEffect` (default ASCII set inside `ATRandomTypoAnimation`, plus a pad of `-`). **Fixed** is `ATTypoEffect` with `userInfo: ["base": …]`. The field is that string. |
| **Custom** | `AnimateText<StaggerRiseEffect>`. **Delay** is the `Double` passed as `userInfo`. It is read when the effect is created, so moving the slider remounts the line. |
| **Leave the tab / family** | That surface's `AnimateText` unmounts. Gallery's effects unmount while Live is open. |

### Gallery

Lazy grid of the 18 package effects. Every card binds `"Animate"`, uses `.letters`, and passes `userInfo: nil`. **Replay all** remounts the grid. Chips name the effect type.

**Skipped:** `ATAnimateTextPreview`, constructing `ATElementData` or `ATRandomTypoAnimation` by hand, and `ATElementData.locValue`.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 17 simulator (this demo's floor; package floor is iOS 14)
- Network on first resolve for Swift Package `AnimateText` **0.5.0** (tag `0.5.0`, pin `c55847e03bb3f36cf83cc217fe60ec5feda9ddd6`)
