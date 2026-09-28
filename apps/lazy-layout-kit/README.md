# LazyLayoutKit

Dark SwiftUI playground for **[LazyLayoutKit](https://github.com/Dave861/LazyLayoutKit)** (`import LazyLayoutKit`, from **0.3.0**, tagged **0.3.0**, revision **b48ad3d**).

Two tabs:

- **Live** — picker among Masonry, Justified, and Timeline. Only the selected surface mounts a `LazyLayoutView`.
- **Gallery** — frozen masonry / justified / timeline snapshots at a small N, with labeled algorithm chips. No `LazyLayoutView`, no million-item scroll, no timers.

Live uses cheap solid-color cells (no network images, blur, or forever timers). A bottom `safeAreaInset` keeps the floating tab pill off the scroll content.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up.

1. Open `apps/lazy-layout-kit/LazyLayoutKit.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **LazyLayoutKit** scheme. Xcode resolves the remote Swift package `https://github.com/Dave861/LazyLayoutKit.git` (from 0.3.0 / tag `0.3.0`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/lazy-layout-kit
xcodegen generate
```

`PRODUCT_MODULE_NAME = LazyLayoutKitDemo` so the app module is not named `LazyLayoutKit` (the package product). Bundle id is `com.techdemos.lazylayoutkit`.

FPS claims in the package README are **Release** on device. This demo itself ships as a normal Debug-runnable playground; do not treat Simulator Debug hitching as a package measurement.

## What to tap

### Live

Default dataset is **360** items. Stress (off by default) raises that to **8,000** — still not 1,000,000.

| Control | What to look for |
| --- | --- |
| **Masonry** | `MasonryLayout(columns: 2 or 3)` over aspect-ratio photo cards. Toggle 2 / 3 columns. Scroll; only on-screen tiles exist. |
| **Justified** | `JustifiedLayout(targetRowHeight: 140)` on the same photo models. Row count is a result of the content. |
| **Timeline** | `TimelineLayout` with start + duration blocks. Density is kept sparse so scrolling stays smooth (the package notes ~67 items per 1,000 pt hitches). |
| **Jump** | Toolbar button. `LazyLayoutPosition.scrollTo(id:anchor: .center)` to a mid/late item — proves id-based scroll without that cell having been built. |
| **Stress** | 8,000 items. Off by default. |
| **Leave the tab / family** | The active `LazyLayoutView` unmounts. Only one virtualized scroll exists at a time. |

Live content sits outside a page `ScrollView` (`LazyLayoutView` is already a vertical scroller) and uses a bottom `safeAreaInset` so the tab pill does not cover tiles.

### Gallery

Lazy grid of paused stand-ins: 8-item masonry, 8-item justified, 8-item overlapping timeline, plus a chip card noting that the CoreText `TextMeasurer` feed is skipped as a Live default. Frames come from the built-in algorithms; views are all built because N is tiny.

**Skipped:** 1,000,000-item Live default, eager `Layout` baseline, self-sizing CoreText feed as a Live surface, custom `LazyLayoutAlgorithm` types.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the DialKit / ShadKit / Liveline demos; package floor is iOS 18)
- Network on first resolve for Swift Package `LazyLayoutKit` **0.3.0+** (tagged `0.3.0`, pin `b48ad3d172a7dc2313e0ac17511b97ee14657d88`)
