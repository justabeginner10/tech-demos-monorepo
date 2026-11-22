# Tab Bar

Dark SwiftUI playground for **[AnimatedTabBar](https://github.com/exyte/AnimatedTabBar)** (`import AnimatedTabBar`, from **1.0.1**, tag **1.0.1**, revision **f38b370**).

Product **`AnimatedTabBar` only**. The package manifest lists iOS 16. This app targets iOS 18 to match sibling demos.

Tag `1.0.1` is an annotated tag (object `9b5d297`) pointing at `f38b37064fafe098118e24c8c7d582d8622cca95` (2026-07-03, "Claude code clean up"). There is no GitHub Release for this repo; the Releases list is empty. `main` (`dcc0032`, 2026-07-08) is one commit ahead of the tag and only adds a CalendarView link to the README. Swift Package Manager requirement `from: 1.0.1` resolves the tag, not `main`.

`1.0.1` is the cleanup after `1.0.0` (`e958616`). It stores `internalPrevSelectedIndex` with `State(initialValue:)`, fixes `CGPath` length lookup, caches `ButtonsBar` sizes, and makes the droplet mask a `ViewBuilder`. The demo is written against that tag.

Two tabs:

- **Live** — picker among Ball, Droplet, and Wiggle. Only the selected surface mounts one `AnimatedTabBar`. Switching family or leaving the tab removes it.
- **Gallery** — frozen painted cards. No `AnimatedTabBar`, no `DropletButton`, no `WiggleButton`.

Live chrome uses hardcoded light ink on a near-black page. The bar itself stays white, which is `barColor`'s default, so the ball and the icons stay readable.

The system tab bar on this screen is only Live versus Gallery. `AnimatedTabBar` is the package control inside the Live stage. It is not a container for pages. The stage title follows `selectedIndex`.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/animated-tab-bar/AnimatedTabBar.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **AnimatedTabBar** scheme. Xcode resolves the remote Swift package `https://github.com/exyte/AnimatedTabBar.git` (from 1.0.1 / tag `1.0.1`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/animated-tab-bar
xcodegen generate
```

`PRODUCT_MODULE_NAME = AnimatedTabBarDemo` so the app module is not named `AnimatedTabBar` (the package product). Bundle id is `com.techdemos.animatedtabbar`. The home-screen name is **Tab Bar**.

Keep the package bar on the Live tab. Keep Gallery free of `AnimatedTabBar`. Leave the upstream example target (`AnimatedTabBarExample`) out of this app. `ColorButton` and `KeyframeWiggleButton` live in that example, not in the package product.

## What AnimatedTabBar does

`AnimatedTabBar` lays buttons in a row, tints them, and moves a 10 pt ball. Parabolic and teleport trajectories also notch the bar under the selection. Straight slides one notch.

The builder walks a `TupleView` with a mirror (`getViews`). Pass the buttons as direct children. A `ForEach` or `Group` inside the builder is one child. The array initializer is the one that takes a list, and every element has to be the same view type.

| API | Role |
| --- | --- |
| `AnimatedTabBar(selectedIndex:prevSelectedIndex:content:)` | Builder. `prevSelectedIndex` defaults to `nil`, stored as `.constant(0)` |
| `AnimatedTabBar(selectedIndex:prevSelectedIndex:views:)` | Same bar from an array. The package maps each element to `AnyView` |
| `barColor` / `selectedColor` / `unselectedColor` / `ballColor` | Defaults: white, red, black, red. Selected tint needs a template image or an SF Symbol |
| `verticalPadding` / `cornerRadius` | Defaults: 30 and 0. Radius is `.cornerRadius` on the bar background |
| `ballAnimation` / `indentAnimation` / `buttonsAnimation` | Each defaults to `.easeOut(duration: 0.6)` |
| `ballTrajectory` | `.parabolic` (default), `.teleport`, `.straight` |
| `didSelectIndex` | Called from the bar's tap, after it writes `prevSelectedIndex` and `selectedIndex` |
| `DropletButton(imageName:dropletColor:isSelected:)` | Asset-catalog image name. Draws `Image(imageName)`, then a droplet masked to that image |
| `WiggleButton(image:maskImage:imageSize:isSelected:)` | `imageSize` defaults to 20. The background shape is masked by `maskImage` |
| `View.alongPath(t:trajectory:)` / `View.teleportEffect(t:from:to:)` | Public geometry effects the ball uses |
| `View.frameGetter(_:)` | Public preference helper the droplet uses to size its mask |
| `Path.length` / `Path.point(at:)` | Public helpers `alongPath` uses to walk the quad curve |

On iOS 17 and later the package applies `foregroundStyle` with `.animation(.linear)` and does not read `buttonsAnimation`. The pre-iOS 17 branch is the one that uses `buttonsAnimation`. This app is iOS 18, so that modifier is wired on the Ball surface and does not change the tint curve.

The ball's previous index for the animation is `internalPrevSelectedIndex`, updated in `onChange(of: selectedIndex)`. The external `prevSelectedIndex` binding is written only by the tap gesture. Omitting it does not stop the ball. The example's color buttons are what read the binding, and those types are not in the package.

`ballTrajectory`:

- **Parabolic** — quad curve from the previous button to the next. Control point is 100 pt above the start. The visible peak is about half of that. Each cell is an `IndentableRect` with `delay` 0.7, animated by `indentAnimation`.
- **Teleport** — `teleportEffect`. The first and last 20% of the ball animation scale the dot. The middle uses a large negative scale so it drops out, then it reappears over the new tab. Indent matches parabolic.
- **Straight** — the dot's `offset` slides at y = 15 with `ballAnimation`. One `SlidingIndentRect` moves from the previous x to the next, driven by `indentAnimation`.

Right-to-left layout flips the ball row. There is no control for that.

`DropletButton` runs a 0.9 s linear ramp of `t` when `isSelected` becomes true, and snaps `t` back to 0 when it becomes false. The icon dips in scale through the first part of that ramp. The droplet starts growing after `t` passes 0.3. After `t` passes 0.5 the droplet is masked by the image; before that the mask is the icon's rectangle. Appearing already selected sets `t = 1` in `onAppear`, so the open state is there without playing the ramp.

`WiggleButton` scales the image with `t` (up to 1.2×) and springs a bump (`tForBg`) with stiffness 300 and damping 5 while selected. The bump is masked by `maskImage`. Appearing already selected sets `t = 1` and leaves `tForBg` at 0, so the bump waits for the next selection change. The example also wraps the button in `.scaleEffect(1.2)`. That wrapper is not a package parameter. This demo does the same on the Wiggle surface.

The example's straight bar uses `.interpolatingSpring(stiffness: 130, damping: 15)` for the ball and `.easeOut(duration: 0.3)` for the indent. Ball's motion menus include those curves. The spring initializer is the one the example calls.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Ball** | Five SF Symbols in the builder, with `prevSelectedIndex`. Starts on the package defaults: parabolic, white bar, red selected, black idle, red ball, radius 0, padding 30, both motions easeOut 0.6. **Parabolic** arcs. **Teleport** vanishes and returns. **Straight** slides, and the notch slides with it. Changing trajectory rebuilds the bar (`.id`) so the old curve does not carry over. |
| **Set index** | Writes the binding only. The ball still moves, because `onChange` updates the internal previous index. The readout says `binding`, not `tap`. |
| **Tap a symbol** | The bar sets `prevSelectedIndex`, then `selectedIndex`, then `didSelectIndex`. The readout says `tap`. |
| **Droplet** | Array initializer. Five template PDFs (`dropletHouse`, `dropletSearch`, `dropletBell`, `dropletPerson`, `dropletGear`), not SF Symbols. Droplet color starts at the example purple (`7D26FE`). Selected and idle start at grey 30%, ball white, radius 16, padding 15, trajectory parabolic. `prevSelectedIndex` is omitted, matching that example bar. |
| **Wiggle** | Array of `WiggleButton`. Outline symbol plus the `.fill` mask, `imageSize` starting at 20, teleport, purple / purple 30% / white ball, radius 16, padding 28, outer scale 1.2. |
| **Leave the tab / family** | The active bar unmounts. Gallery never keeps one. |

The stage leaves empty space above the bar so the parabolic arc has room. The ball is a geometry effect and draws outside its layout frame.

### Gallery

Lazy grid of paused stand-ins: parabolic arc, teleport, straight slide, droplet silhouettes, wiggle symbols, the four color defaults, an indent, and the two initializers. Chips name the APIs. Illustrations are SwiftUI paint. The droplet card draws this app's template images. It does not construct `DropletButton`.

**Skipped:** `ColorButton` and `KeyframeWiggleButton` (example target only; the keyframe button is iOS 17 and not part of the product). The example's `colorTab*` and `tab*` PDFs are not copied. CocoaPods (the README marks it deprecated after 0.1.4). Stacking several bars on one `selectedIndex` the way the example screen does. A control for `buttonsAnimation`, because iOS 17+ ignores it. `alongPath`, `teleportEffect`, `frameGetter`, and `Path.length` are named above and not given their own live surface.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Wave / Confetti demos; package floor is iOS 16)
- Network on first resolve for Swift Package `AnimatedTabBar` **1.0.1** (tag `1.0.1`, pin `f38b37064fafe098118e24c8c7d582d8622cca95`)
