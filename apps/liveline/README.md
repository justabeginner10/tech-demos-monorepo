# Liveline

Dark SwiftUI playground for **[Liveline](https://github.com/ParthJadhav/liveline-swift)** realtime charts (`import Liveline`, tagged **0.7.0**).

Two tabs:

- **Live** — one ticking Canvas at a time (line, candlestick, or multi-series) fed by a `LivelineDataStream`.
- **Gallery** — static samples of the other public families. No timer.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up.

1. Open `apps/liveline/Liveline.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **Liveline** scheme. Xcode resolves the remote Swift package `https://github.com/ParthJadhav/liveline-swift` (from 0.7.0).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/liveline
xcodegen generate
```

`PRODUCT_MODULE_NAME = LivelineDemo` so the app module is not named `Liveline` (the package product).

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Line / Candles / Compare** | Only the selected family is on screen and ticking (~220ms). The other two are not laid out. |
| **Live ticks** | Off pauses the tick loop and sets `paused` on the chart. |
| **Dither style** | Per-chart `.dither` with bloom `.low` at 24 FPS (not `.aura`). Variants: gradient / dotted / hatched / solid. |
| **Drag the chart** | Built-in scrub tooltip + live value badge. The **Scrub** row updates only when the hovered value actually moves. |
| **Window chips** | 30s / 1m / 3m on the line; 2m / 4m / 8m on candles; 1m / 3m / 5m on compare. |
| **Line / candle toggle** | On Candles, Liveline’s mode control morphs OHLC into a line. `lineData` is empty unless that morph is on. |

### Gallery

Lazy grid of static charts (no live timer): bar, range-band, scatter, step, lollipop, bubble, box-plot, waterfall, error-bar, dumbbell, stacked-bar, stacked-area, streamgraph, timeline, heatmap, radar, donut, gauge, funnel, histogram, bullet, treemap, sunburst, Sankey.

Streamgraph is stacked-area with `LivelineStackedAreaStyle(baseline: .centered)` — 0.7.0 has no separate streamgraph initializer.

**Skipped:** none of the listed 0.7.0 public families.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the MotionEyes / Button Styles demos)
- Network on first resolve for Swift Package `Liveline` **0.7.0+**
