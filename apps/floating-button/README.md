# Floating Button

Dark SwiftUI playground for **[FloatingButton](https://github.com/exyte/FloatingButton)** (`import FloatingButton`, from **1.4.1**, annotated tag **1.4.1**, commit **10d2671**).

Product **`FloatingButton` only**. `Package.swift` at that tag (`swift-tools-version: 5.9`) declares iOS 14, macOS 11, tvOS 14, and watchOS 7. The license is MIT. This app targets iOS 18 to match sibling demos. The package floor is iOS 14. Live uses iOS 17 animation (`Animation.snappy`, the two-parameter `onChange`), so the screens are an iOS 17+ demo at the sibling deployment target of 18.

Tag `1.4.1` is an annotated tag. The tag object is `a6bfaa4d40203e8fb7538328e5f96464a0b1060b`. It points at commit `10d2671e4678cf9400fcaee29dac2b20d40f2b38` (2026-07-03, "Claude code clean up"). That tag is the highest tag on the repo. `gh release list` for this repo is empty, so there is no GitHub Release object; 1.4.1 is the latest published tag. `main` (`0a2672f`) is one commit ahead of the tag and only adds a CalendarView link to the README. Swift Package Manager requirement `from: 1.4.1` resolves the tag, not `main`.

The public surface this demo calls was read from `Sources/FloatingButton/FloatingButton.swift` at that commit. Modifiers such as `direction` and `radius` exist only on `FloatingButtonGeneric`, which is what `.straight()` and `.circle()` return. The base `FloatingButton` already stores `menuType = .straight`, but without `.straight()` or `.circle()` those modifiers are not available.

Two tabs:

- **Live** — picker among Straight, Circle, and Labels. Only the selected surface mounts one `FloatingButton`. Switching family or leaving the tab removes it.
- **Gallery** — frozen painted cards. No `FloatingButton`.

Live chrome uses hardcoded light ink on a near-black page. The main button is gold. Submenu discs use amber, coral, teal, and violet.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. The Simulator build, screenshots, and video are still to be done on Aditya's Mac. A Linux VM cannot run the Simulator. This app was not compiled for iOS and was not run.

What was checked here:

- `swiftc -parse` (Swift 6.0.3) accepted the seven app sources.
- `swift package resolve` of requirement `from: 1.4.1` selected tag `1.4.1` (`10d2671e4678cf9400fcaee29dac2b20d40f2b38`). That pin is the checked-in `Package.resolved`.
- A separate Swift 6 file that calls the same initializers and modifiers was typechecked against the tag's sources. SwiftUI was a stand-in module so the check could run on Linux. That is not an iOS build of this app.

1. Open `apps/floating-button/FloatingButton.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **FloatingButton** scheme. Xcode resolves the remote Swift package `https://github.com/exyte/FloatingButton.git` (from 1.4.1 / tag `1.4.1`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/floating-button
xcodegen generate
```

`PRODUCT_MODULE_NAME = FloatingButtonDemo` so the app module is not named `FloatingButton` (the package product, and the view type). Bundle id is `com.techdemos.floatingbutton`. The home-screen name is **Floating Button**.

Keep the package menu on the Live tab. Keep Gallery free of `FloatingButton`. Leave the upstream example target (`FloatingButtonExample`) out of this app. `MainButton`, `IconButton`, and `IconAndTextButton` live in that example, not in the package product.

## What FloatingButton does

`FloatingButton` stacks a main button and a row of submenu buttons in one `ZStack`, then offsets the submenu buttons. `offset` does not grow the layout frame, so the view stays about as large as the main button. Open items draw outside that frame. This demo gives them a stage and pins the main button to the opposite edge.

The main button is a `Button` that toggles `isOpen`. Each submenu view is also wrapped in a `Button` whose action is empty. Closing from a submenu is the caller's job. The package example puts `onTapGesture` on the submenu view. This demo does the same, and the Open toggle writes the same binding.

| API | Role |
| --- | --- |
| `FloatingButton(mainButtonView:buttons:)` | Private `@State` for `isOpen`. The screen cannot read it |
| `FloatingButton(mainButtonView:buttons:isOpen:)` | External binding. The main button toggles it |
| `.straight()` / `.circle()` | Set the layout and return `FloatingButtonGeneric`, which owns the modifiers |
| `.spacing(_:)` | Straight: gap between items. Circle: used only when `radius` is nil |
| `.initialScaling(_:)` / `.initialOpacity(_:)` | Closed submenu scale and opacity. Defaults: `1` and `1` |
| `.initialOffset(x:y:)` | Straight only. Closed position is the open position plus this offset |
| `.animation(_:)` | Per-item animation. Default is `.easeInOut(duration: 0.4)` |
| `.delays(delayDelta:)` | `[0, delta, 2*delta, …]`, one entry per button |
| `.delays(_:)` | Explicit delays. The array length must match the button count |
| `.mainZStackAlignment(_:)` | `SwiftUI.Alignment` of the `ZStack`. Default `.center`. Read in `body` |
| `.inverseZIndex(_:)` | Reorders submenu `zIndex`. The main button stays above them |
| `.wholeMenuSize(_:)` / `.menuButtonsSize(_:)` | Bindings written from `calculateCoords` |
| `.direction(_:)` | Straight. `.left` (default), `.right`, `.top`, `.bottom` |
| `.alignment(_:)` | Straight. `.center` (default), `.left`, `.right`, `.top`, `.bottom` |
| `.startAngle(_:)` / `.endAngle(_:)` | Circle, radians. Defaults `.pi` and `2 * .pi` |
| `.radius(_:)` | Circle. Distance between centers. `nil` uses `(main + first button) / 2 + spacing` |
| `.layoutDirection(_:)` | Circle. `.clockwise` (default) or `.counterClockwise` |

`buttonAnimation` delays with `delays[i]` while closing and `delays[count - i - 1]` while opening. An array shorter than the button count traps. Empty delays mean no delay. `delays(delayDelta:)` builds one value per button, so it stays in range.

Circle angles are `start ± (end - start) / (count - 1) * i`, then `x = radius * cos`, `y = radius * sin`. One button divides by zero. This demo's circle stepper starts at 2. Screen y grows downward: 0° is right, 90° is down, 270° is up.

`calculateCoords` runs when the measured button size changes, not when a slider changes. Direction, alignment, spacing, initial offset, angles, radius, and button count are read there. This demo remounts the menu when those change so the coordinates are computed again. Scale, opacity, animation, delays, `inverseZIndex`, and `mainZStackAlignment` are read in `body` and update on the next render.

Straight size uses `alignment` to pick a horizontal or vertical total, while positions use `direction`. If those axes differ, the reported size does not match the visual stack. `menuButtonsSize` is the items. `wholeMenuSize` adds the main button. Circle writes the same `finalFrame.size` into both bindings, and that frame includes the main button. Circle does not read `initialOffset`.

`zIndex` of the main button is `1`, or `buttons.count` when inverse is on. Submenu values stay below that, so the main button remains on top. Inverse only changes which overlapping submenu is in front. Negative spacing is what makes them overlap.

The README asks for `AnyView`. The initializers are generic: every entry in `buttons` has to be the same view type. `AnyView` is the way to mix types. Straight and Circle pass one disc type. Labels passes `[AnyView]` and an `AnyView` main button, matching that README recipe. The example's `dropLast()` result is an `ArraySlice` and is not passed here.

The package enables the experimental `StrictConcurrency` feature in its manifest. This demo does not change that.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Straight** | Package defaults: direction `.left`, alignment `.center`, spacing 10, scale 1, opacity 1, ease-in-out 0.4, no delays. The main disc sits on the trailing edge. **Open** and the disc share the binding. A submenu tap sets it to false and names the item. **isOpen binding** off uses the two-argument init. The plus stays on the closed glyph because the private flag is not visible. Spacing, alignment, and offset remount the menu. **ZStack alignment** does not. |
| **Circle** | Defaults match the stored angles: 180° to 360°, clockwise, package radius. **Quarter** sets 270°…360° and radius 70, which is the README's `3/2 * .pi` … `2 * .pi` sample. **Counter** with those angles is the other README sample. **Lower** is 0°…180°. **Package radius** skips `.radius`. The caption uses `(56 + 44) / 2 + spacing`. |
| **Labels** | Three text rows and a capsule main button, both `AnyView`. Opens on the README text menu: `.top`, `.left`, spacing 10, spring, `delayDelta` 0.1, `initialOpacity` 0. A row tap closes the menu. |
| **Delays** | **None** leaves the array empty. **Delta** calls `delays(delayDelta:)`. **Array** calls `delays(_:)` with one number per button: `0, 0.08, 0.22, 0.40` trimmed to the count. Opening plays that list backwards. |
| **Leave the tab / family** | The active `FloatingButton` unmounts. Gallery never creates one. |

The stage is 340 pt and clips. Four discs at spacing 20 still fit. Radius stops at 110. Offset stops at ±240 so a slide starts just off the stage. The README sample uses `initialOffset(x: -1000)`.

### Gallery

Lazy grid of painted cards: directions, alignment, the quarter arc in both turns, closed-state scale / opacity / delay, the two size bindings, and the two initializers. Chips name the APIs. Nothing on the card is a `FloatingButton`.

**Skipped:** the example app's `Color(hex:)` helper and its icon list, `buttons.dropLast()` as an `ArraySlice`, a one-button circle, and copying `FloatingButtonExample` into this project.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the ActivityIndicatorView / AnimatedTabBar demos; package floor is iOS 14)
- Network on first resolve for Swift Package `FloatingButton` **1.4.1** (tag `1.4.1`, pin `10d2671e4678cf9400fcaee29dac2b20d40f2b38`)
