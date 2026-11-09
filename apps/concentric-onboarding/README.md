# Onboarding

Dark SwiftUI playground for **[ConcentricOnboarding](https://github.com/exyte/ConcentricOnboarding)** (`import ConcentricOnboarding`, from **1.1.1**, annotated tag **1.1.1**, commit **a8e51cd**).

Product **`ConcentricOnboarding` only**. `Package.swift` at that tag (`swift-tools-version: 5.9`) declares iOS 14 and enables `StrictConcurrency`. This app targets iOS 17. On this tag the page change finishes through `withAnimation(_:completion:)`, which the package compiles in for iOS 17 and Swift 5.9 or newer. Below iOS 17 that completion is not installed, so the circle can grow without advancing the page.

Tag `1.1.1` is annotated. The tag object is `5bb40c70f54cb8270724c13206efaaa1aa889bd9` (2025-04-01T13:23:10Z, tagger Alisa Mylnikova, empty message). It points at commit `a8e51cd46e3a32839c3a7fac4142e8af38d61875` (2025-04-01, "Fix xcode 15 warnings"). That is the newest tag. `main` (`cc93b9ad`) is newer and untagged. There is no GitHub Release. Swift Package Manager requirement `from: 1.1.1` resolves the tag. The license is MIT.

The public surface this demo calls was read from that commit: `ConcentricOnboardingView`, `duration(_:)`, `nextIcon(_:)`, and the closure methods on the same type. `goToNextPage(animated:)` and `goToPreviousPage(animated:)` are public too. They mutate the view's private `@State`. The drawn button is what calls `goToNextPage` unless `didPressNextButton` replaces it.

Two tabs:

- **Live** — picker among Pages, Finish, and Button. Only the selected surface keeps a `ConcentricOnboardingView`. Switching family or leaving the tab removes it.
- **Gallery** — frozen painted cards. No `ConcentricOnboardingView`.

Live chrome uses hardcoded light ink on a near-black page. Page copy and SF Symbols are original. The upstream grape sample and its images are not copied.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. The Simulator build, screenshots, and video are still to be done on Aditya's Mac. A Linux VM cannot run the Simulator. This app was not compiled for iOS and was not run.

What was checked here:

- `swiftc -parse` (Swift 6.0.3) accepted the seven app sources.
- `swift package resolve` of requirement `from: 1.1.1` selected tag `1.1.1` (`a8e51cd46e3a32839c3a7fac4142e8af38d61875`). That pin is the checked-in `Package.resolved`.
- With `#Preview` removed, the sources were typechecked with `-swift-version 6` against stand-in SwiftUI and ConcentricOnboarding modules. The ConcentricOnboarding signatures in that stand-in were copied from tag `1.1.1`. That is not an iOS build of this app.

1. Open `apps/concentric-onboarding/ConcentricOnboarding.xcodeproj` in Xcode 16+ (iOS 17 SDK).
2. Pick an iPhone simulator.
3. Run the **ConcentricOnboarding** scheme. Xcode resolves the remote Swift package `https://github.com/exyte/ConcentricOnboarding.git` (from 1.1.1 / tag `1.1.1`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/concentric-onboarding
xcodegen generate
```

`PRODUCT_MODULE_NAME = ConcentricOnboardingDemo` so the app module is not named `ConcentricOnboarding` (the package product). Bundle id is `com.techdemos.concentriconboarding`. The home-screen name is **Onboarding**.

Keep the package view on the Live tab. Keep Gallery free of it. Leave the upstream example target out of this app.

## What the package does

`ConcentricOnboardingView` takes `[PageContent]`, a tuple `(view: Content, background: Color)`. Every page is the same `Content` type. It needs at least two pages; fewer prints `Warning: Add more pages.` The first background fills the screen. The button circle uses the next page's background, and the SF Symbol is tinted with the current background.

The button sits 300 points below the view's center. Its diameter is 60. Those numbers are private. The circle's width comes from `UIScreen.main.bounds.width`, not from the view's width. The view ignores the vertical safe area.

| API | Role |
| --- | --- |
| `ConcentricOnboardingView(pageContents:)` | The only initializer |
| `duration(_:)` | Full transition length in seconds. Default 1. Grow is `easeIn` for half, shrink is `easeOut` for half. The page slide is `easeInOut` for the full interval |
| `nextIcon(_:)` | SF Symbol name on the button. Default `chevron.forward`. One icon for every page |
| `animationWillBegin(perform:)` | Before an animated transition |
| `animationDidEnd(perform:)` | After the index updates at the end of an animated transition |
| `didChangeCurrentPage(perform:)` | `(Int) -> Void` when `currentIndex` changes. Not called for the initial page |
| `didGoToLastPage(perform:)` | Same step as the page callback, when the new index is the last page |
| `insteadOfCyclingToFirstPage(perform:)` | Replaces the wrap from the last page to page 0. No animation runs |
| `insteadOfCyclingToLastPage(perform:)` | Replaces the wrap from page 0 to the last page inside `goToPreviousPage` |
| `didPressNextButton(perform:)` | Replaces the button action. `goToNextPage` is not called |
| `goToNextPage(animated:)` | Default button action. `animated` defaults to `true`. On the last page, either cycles or runs `insteadOfCyclingToFirstPage` |
| `goToPreviousPage(animated:)` | Backward transition. The package draws no back button. On page 0, either cycles or runs `insteadOfCyclingToLastPage` |

Unanimated `goToNextPage(animated: false)` changes the index and skips `animationWillBegin` / `animationDidEnd`. The button always asks for the animated path. The button is disabled while a transition is running.

`Direction` and `AnimatableShape` are internal. There is no public binding for the page index, no button color or position argument, and no per-page icon.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Pages** | Four backgrounds (coral, gold, teal, indigo). The button shows the next color. **Duration** is `duration(_:)`, from 0.4s to 2.0s. **Chevron / Arrow / Check** is `nextIcon(_:)`. The log lists `animationWillBegin`, `didChangeCurrentPage`, `didGoToLastPage`, and `animationDidEnd`. On the last page the flow cycles to Mark. |
| **Finish** | Three pages, `duration(1.5)`, `chevron.forward`. Next on the last page runs `insteadOfCyclingToFirstPage` and stays. **Start over** remounts the flow. |
| **Button** | `didPressNextButton` counts presses and does not change the page. The circle still shows the other page's color. `duration(1.0)` and `nextIcon("arrow.right")` are set; the replacement skips the transition, so the duration is not played. |
| **Leave the tab / family** | The package view unmounts. Gallery never keeps one. |

`goToPreviousPage(animated:)` is not called. A second next/back control held by the parent would be a different view value, and its `@State` is not the on-screen flow.

### Gallery

Lazy grid of paused stand-ins: the four page colors, a two-circle sketch, the three symbols, and cards for duration, callbacks, cycling, and the manual methods. Chips name the APIs. Illustrations are SwiftUI paint.

**Skipped:** the upstream example images, `goToPreviousPage` as a live control, and `insteadOfCyclingToLastPage` (nothing in this app calls `goToPreviousPage`).

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 17 simulator (same floor as the WhatsNewKit / AlertKit / Grid demos; package floor is iOS 14, and this tag's animation completion needs iOS 17)
- Network on first resolve for Swift Package `ConcentricOnboarding` **1.1.1** (tag `1.1.1`, pin `a8e51cd46e3a32839c3a7fac4142e8af38d61875`)
