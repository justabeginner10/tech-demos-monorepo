# Find My Tab Bar

SwiftUI chrome demo of a floating, morphing bottom tab bar in the spirit of iOS 26 Find My.

This is an original recreation of the *look and feel* — floating material, a sliding selection pill, and a peeking sheet — not a Find My clone and not a copy of Kavsoft’s project. Design reference: [Kavsoft on X](https://x.com/_Kavsoft/status/1937194655965462599).

Map labels (Harbor Green, Civic Bowl, North Quay, Ridgeway) and dummy people/devices/items are original stand-ins. SF Symbols only; no Apple artwork.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this PR. Capture both on a Mac as a follow-up.

1. Open `apps/find-my-tab-bar/FindMyTabBar.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **FindMyTabBar** scheme.

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/find-my-tab-bar
xcodegen generate
```

## What to tap

| Control | What to look for |
| --- | --- |
| **People / Devices / Items / Me** | The blue capsule **slides and resizes** onto the new tab. The selected tab **expands** to icon + title; the others collapse to icons. Map pins cross-fade to that tab. Peek list updates. |
| **Drag the sheet** | Chrome snaps between **bar** (capsule over the map), **peek** (a few rows), and **half**. Corner radius morphs with height. |
| **Tap the map** | Sheet collapses to the floating bar. |
| **Green location button** | Jumps to **Me**, reopens peek, and recenters the “You” pin. |

The bar is custom material chrome — not a system `TabView`. Selection uses `matchedGeometryEffect` and a spring (`duration: 0.46`, `bounce: 0.26`).

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the MotionEyes demo)

iOS 26 Liquid Glass APIs are **not** required. The floating look uses `regularMaterial`, a continuous rounded rect, a hairline stroke, and a drop shadow so the project stays buildable on the iOS 18 SDK.
