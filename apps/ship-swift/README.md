# ShipSwift

Dark SwiftUI playground for a slim, **copy-paste** slice of **[ShipSwift](https://github.com/signerlabs/ShipSwift)** (MIT, iOS 18+).

ShipSwift is **not** a typical Swift package. Components live under `ShipSwift/SWPackage/` and are meant to be copied (README Option 3). Types use the `SW` prefix; view modifiers use `.sw`.

Two tabs:

- **Live** — picker among Shimmer, Typewriter, Line, and Thinking. Only the selected recipe is mounted.
- **Gallery** — static snapshots of the looping recipes, plus one-shot charts and display components. No Metal, no CADisplayLink rows, no continuous timers on every card.

Heavy `SWModule` frameworks (SWAuth/Amplify, SWCamera, SWPaywall/StoreKit, SWChat ASR, TikTok) are out of scope.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up.

1. Open `apps/ship-swift/ShipSwift.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **ShipSwift** scheme.

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/ship-swift
xcodegen generate
```

`PRODUCT_MODULE_NAME = ShipSwiftDemo` so the app module is not named `ShipSwift` (the upstream type prefix / product name). Bundle id is `com.techdemos.shipswift`.

Vendored sources sit in `Vendor/SWPackage/` with the upstream MIT license in `Vendor/LICENSE` and a file list in `Vendor/NOTICE.md`. Two tiny local patches (Swift 6 `Task` hop in `SWTypewriterText`, stable `id` on `SWRingChart.DataPoint`) are listed there.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Shimmer** | Skeleton card + capsule CTA with a sweeping light band (`SWShimmer`). |
| **Writer** | Cycling `SWTypewriterText` headlines (spring per character). |
| **Line** | One `SWLineChart` (Catmull-Rom, target rule, point markers). One-shot Y reveal. |
| **Think** | Chat-style `SWThinkingIndicator` (`TimelineView` bounce). |
| **Leave the tab** | The active recipe unmounts so Gallery is the only surface on screen. |

### Gallery

Lazy grid of paused stand-ins (no `SWShimmer` / typewriter loop / glow sweep / `TimelineView`) plus one-shot `SWLineChart`, `SWDonutChart` (`Binding.constant`), `SWBarChart`, `SWRingChart`, `SWStatusBadge`, `SWKPICard`, `SWBulletPointText`, and `SWGradientDivider`.

**Skipped:** Metal shader backgrounds, `SWScrollingFAQ` (CADisplayLink), and every `SWModule` framework.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Liveline / DrafterCharts / Button Styles demos)
- No network resolve — recipes are vendored, not a remote package
