# Header

Dark SwiftUI playground for **[ScalingHeaderScrollView](https://github.com/exyte/ScalingHeaderScrollView)** (`import ScalingHeaderScrollView`, from **3.1.0**, annotated tag **3.1.0**, commit **f328af2**).

Product **`ScalingHeaderScrollView` only**. `Package.swift` at that tag (`swift-tools-version: 5.9`) declares iOS 15. This app targets iOS 18 to match sibling demos.

Tag `3.1.0` is an annotated tag. The tag object is `d4dab347bd5173d69f93d69c31012dbb07004c4b` (2026-10-20T07:07:12Z, empty message). It points at commit `f328af2bcfda8308aa9564dac47babdf01ef7947` (2026-10-20, "Adapt to iPhone Duo"). That commit is also `HEAD` of `main`. There is no GitHub Release for this repo. Swift Package Manager requirement `from: 3.1.0` resolves the tag. The license is MIT.

The public surface this demo calls was read from that commit: `ScalingHeaderScrollView`, `ScalingHeaderTabView`, and the modifiers on `ScalingHeaderViewAPI`. The header closure is `(height, progress)`. `0` progress is fully expanded. `1` is fully collapsed. The same direction is what `initialSnapPosition` and `headerSnappingPositions` use in source (`0` expands, `1` collapses). The package README's snap paragraph says the opposite.

Two tabs:

- **Live** — picker among Profile, Refresh, and Tabs. Only the selected surface keeps a package view. Switching family or leaving the tab removes it.
- **Gallery** — frozen painted cards. No `ScalingHeaderScrollView` and no `ScalingHeaderTabView`.

Live chrome uses hardcoded light ink on a near-black page. The header art is a bundled gradient plus SF Symbols.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator. This app was not compiled here.

`swiftc -parse` accepted the Swift sources. `swift package resolve` of requirement `from: 3.1.0` selected tag `3.1.0` (`f328af2bcfda8308aa9564dac47babdf01ef7947`). Those checks are not an iOS build.

1. Open `apps/scaling-header-scroll-view/ScalingHeaderScrollView.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **ScalingHeaderScrollView** scheme. Xcode resolves the remote Swift package `https://github.com/exyte/ScalingHeaderScrollView.git` (from 3.1.0 / tag `3.1.0`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/scaling-header-scroll-view
xcodegen generate
```

`PRODUCT_MODULE_NAME = ScalingHeaderScrollViewDemo` so the app module is not named `ScalingHeaderScrollView` (the package product). Bundle id is `com.techdemos.scalingheaderscrollview`. The home-screen name is **Header**.

Keep the package view on the Live tab. Keep Gallery free of it. Leave the upstream example target out of this app. Its photos, fonts, and brand images are not copied.

## What the package does

`ScalingHeaderScrollView` pins a header over a UIKit scroll view. The header height tracks the scroll offset between `minHeight` and `maxHeight` (initializer arguments; the old `.height(min:max:)` modifier is deprecated). The header builder is called with that height and a collapse progress.

`ScalingHeaderTabView` is the same header shared by one page per `CaseIterable` tab. Each page keeps its own scroll offset. The header height stays in sync.

| API | Role |
| --- | --- |
| `ScalingHeaderScrollView(minHeight:maxHeight:header:content:)` | Header closure `(CGFloat, CGFloat) -> View` is height, then progress. Defaults 150 and 350 |
| `ScalingHeaderTabView(selection:minHeight:maxHeight:header:pageContent:)` | `Tab: Hashable & CaseIterable`. Header alignment starts at `.bottom` |
| `collapseProgress(_:)` | Binding. `0` expanded, `1` collapsed. Written when the header height changes |
| `scrollOffset(_:)` | Binding of the scroll view's raw `contentOffset.y` (negative while the header is open) |
| `scrollToTop(resetScroll:)` | Set the binding to `true`. The package clears it and scrolls to the expanded offset |
| `allowsHeaderGrowth(_:)` | Pulling down can grow the header past `maxHeight`. Default off. Ignored when a pull-to-refresh action is set |
| `allowsHeaderCollapse(_:)` | Default on. Off keeps the header at `maxHeight` |
| `hideScrollIndicators(_:)` | Hides the package's thin custom indicator. Default is to show it |
| `headerIsClipped(_:)` | Default on. Off lets header content draw outside the shrinking frame |
| `headerAlignment(_:)` | Alignment inside the header frame. Scroll-view default is `.center` |
| `scrollViewDidReachBottom(perform:)` | Called from `scrollViewDidScroll` while the offset is at the bottom |
| `snapHeaderToState(_:animated:)` | Binding of `SnapHeaderState?` (`.expanded`, `.collapsed`, `.custom(CGFloat)`). The package clears it after applying |
| `setHeaderSnapMode(_:)` | `.disabled`, `.immediately`, `.afterFinishAccelerating`. The last two fill stops `[0, 1]` only when none are set yet |
| `headerSnappingPositions(snapPositions:)` | Stops in `0...1` with `0` expanded and `1` collapsed. Values need to ascend or the snap walk finds no range |
| `initialSnapPosition(initialSnapPosition:)` | Read once, when the scroll view is created. `0` expanded, `1` collapsed |
| `pullToRefresh(isActive:perform:)` | Async action. The petal spinner shows after a 60 pt pull past the expanded inset. `isActive` defaults to `true` |
| `pullToLoadMore(isActive:contentOffset:perform:)` | Same idea at the bottom, after 60 pt of overscroll. `contentOffset` is stored on `ScalingHeaderParameters` and is not read in 3.1.0 |
| `scalingHeaderSafeAreaInsets` | Environment value. The header ignores the safe area, so this is the window inset |

`SnapHeaderState.custom` is added to `-minHeight` to form the content offset. A midpoint offset uses `(minHeight - maxHeight) / 2`.

Deprecated and not called: `allowsHeaderSnap()` and `height(min:max:)`. `PetalSpinner` is internal. The spinner appears on its own once pull-to-refresh or pull-to-load-more is configured.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Profile** | Gradient header, SF Symbol mountains, and an avatar. The large name fades out as `progress` goes to 1. The compact name fades in. Min and max height rebuild the scroll view. **Lift** snaps on finger-up. **Coast** waits until deceleration ends. **Thirds** snaps to `0`, `0.5`, or `1`. **Expand** / **Mid** / **Collapse** write `snapHeaderToState`. **Top** sets `scrollToTop`. |
| **Refresh** | Pull down to insert a note. Pull up past the last row to append four. Toggles pass `isActive`. The readout counts refreshes, loads, and throttled bottom callbacks. Snap is immediate. |
| **Tabs** | `ScalingHeaderTabView` over Notes, Places, and Saved. The segmented control sits in the header. Each page is a different length. Leave a page scrolled, switch, and come back. **Expand**, **Collapse**, and **Top** sit on a bar over the pages. |
| **Leave the tab / family** | The package view unmounts. Gallery never keeps one. |

### Gallery

Lazy grid of painted cards: two header heights, a progress fade, snap stops, a pull glyph, three tab pages, and modifier names. Chips name the APIs. Nothing on this tab constructs the package.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the other demos; package floor is iOS 15)
- Network on first resolve for Swift Package `ScalingHeaderScrollView` **3.1.0** (tag `3.1.0`, pin `f328af2bcfda8308aa9564dac47babdf01ef7947`)
