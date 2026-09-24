# SwiftViz

Dark SwiftUI playground for **[SwiftViz](https://github.com/omarsinan/SwiftViz)** (`import SwiftViz`, from **1.0.0**, resolved **1.1.1**).

Two tabs:

- **Live** — one interactive `SVBarChart` at a time (stacked or simple). Tap a bar for the package spring detail. Optional currency / percent formatter and average line.
- **Gallery** — static README samples. `isInteractive: false`. No timer.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up.

1. Open `apps/swift-viz/SwiftViz.xcodeproj` in Xcode 16+ (Swift 6). The package’s `Package.swift` declares `swift-tools-version: 6.2`, so a current Xcode that can resolve Swift 6.2 packages is safest.
2. Pick an iPhone simulator (iOS 17+).
3. Run the **SwiftViz** scheme. Xcode resolves the remote Swift package `https://github.com/omarsinan/SwiftViz.git` (from 1.0.0).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/swift-viz
xcodegen generate
```

`PRODUCT_MODULE_NAME = SwiftVizDemo` so the app module is not named `SwiftViz` (the package product).

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Stacked / Simple** | Only the selected family is mounted. Stacked uses `data:` + `SVCategory`; Simple uses `values:`. |
| **Plain / Currency / Percent** | `valueFormatter` on the detail overlay (`$120`, `12.5%`). |
| **Average line** | Dashed overlay + y-axis average label. Hidden while a bar is selected. |
| **Tap a bar** | Spring expand to the package detail panel. `expandedLabels` show weekday / quarter names. |
| **Leave the tab** | The interactive chart unmounts so Gallery is the only surface on screen. |

### Gallery

Lazy grid of static charts (`isInteractive: false`, no live timer): simple bars, expanded labels, stacked revenue/expenses, weekly hex colors, average line on/off, custom `SVBarChartStyle`, titled chart with axes hidden.

**Skipped:** none of the listed public 1.1.1 bar-chart surfaces. Pie / donut / line are still on the package roadmap.

## Requirements

- Xcode that can resolve a `swift-tools-version: 6.2` package / Swift 6
- iOS 17 simulator (package floor; siblings in this repo often target 18)
- Network on first resolve for Swift Package `SwiftViz` **1.0.0+** (pinned **1.1.1** in `Package.resolved`)
