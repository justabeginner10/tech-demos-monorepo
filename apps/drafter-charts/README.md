# DrafterCharts

Dark SwiftUI playground for **[DrafterCharts](https://github.com/AndroidPoet/DrafterCharts)** (`import DrafterCharts`, tagged **0.2.0**).

Two tabs:

- **Live** — one ticking Canvas at a time (line, area, candlestick, or stream graph).
- **Gallery** — static samples of all **27** public chart types. No timer.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up.

1. Open `apps/drafter-charts/DrafterCharts.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **DrafterCharts** scheme. Xcode resolves the remote Swift package `https://github.com/AndroidPoet/DrafterCharts` (from 0.2.0).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/drafter-charts
xcodegen generate
```

`PRODUCT_MODULE_NAME = DrafterChartsDemo` so the app module is not named `DrafterCharts` (the package product).

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Line / Area / Candles / Stream** | Only the selected family is on screen and ticking (~280ms). The other three are not laid out. |
| **Live ticks** | Off pauses the tick loop. Scene inactivity and leaving the tab also pause. |
| **Replay reveal** | Re-runs the package left-to-right entrance on the **active** chart only. |

### Gallery

Lazy grid of static charts (`animate: false`, no live timer): bar, grouped bar, stacked bar, histogram, waterfall, line, grouped line, stacked line, area, step line, pie, donut, scatter, bubble, candlestick, box plot, radar, gauge, bullet, funnel, treemap, polar area, sunburst, Sankey, stream graph, Gantt, contribution heatmap.

**Skipped:** none of the listed 0.2.0 public families.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Liveline / MotionEyes / Button Styles demos)
- Network on first resolve for Swift Package `DrafterCharts` **0.2.0+**
