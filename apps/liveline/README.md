# Liveline

Dark SwiftUI playground for **[Liveline](https://github.com/ParthJadhav/liveline-swift)** realtime charts (`import Liveline`, tagged **0.7.0**).

A `LivelineDataStream` holds a bounded fake tape. The same ticks drive a live line, 20-second OHLC candles, and a three-series compare chart. Drag any chart to scrub; the value badge and tooltip come from the package.

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

| Control | What to look for |
| --- | --- |
| **Live ticks** | Off pauses the 220ms tick loop and sets `paused` on each chart. On resumes the stream. |
| **Dither style** | Applies `.livelineChartStyle(.dither)` to the whole gallery. Variants: gradient / dotted / hatched / solid, bloom `.aura`. Off restores each chart’s own style. |
| **Drag a chart** | Built-in scrub tooltip + live value badge. The **Scrub** row mirrors `onHover`. |
| **Window chips** | 30s / 1m / 3m on the line; 2m / 4m / 8m on candles; 1m / 3m / 5m on compare. |
| **Line / candle toggle** | On the Session tape chart, Liveline’s mode control morphs OHLC into a line (`onModeChange`). |
| **Series chips** | Tape / Drift / Echo can be hidden independently. |

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the MotionEyes / Button Styles demos)
- Network on first resolve for Swift Package `Liveline` **0.7.0+**
