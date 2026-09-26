# ShadKit

Dark SwiftUI playground for **[ShadKit](https://github.com/jasonkneen/ShadKit)** (`import ShadcnUI` / `AIElementsUI` / `CanvasUI`, from **0.3.0**, resolved **0.3.0**).

Two tabs:

- **Live** — picker among Theme, Chat, and Elements. Only the selected surface is mounted.
- **Gallery** — static snapshots of the same surfaces. No mock stream, no `CanvasView`, no forever timers.

Live **Canvas** (`CanvasView` pan/zoom/grid) is skipped on purpose so the simulator stays light. Gallery shows two frozen `CanvasNodeCard`s instead.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up.

1. Open `apps/shad-kit/ShadKit.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **ShadKit** scheme. Xcode resolves the remote Swift package `https://github.com/jasonkneen/ShadKit` (from 0.3.0).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/shad-kit
xcodegen generate
```

`PRODUCT_MODULE_NAME = ShadKitDemo` so the app module is not named `ShadKit` (the package name) or any of its library products (`ShadcnUI`, `AIElementsUI`, `CanvasUI`). Bundle id is `com.techdemos.shadkit`.

The package also ships an executable target named `ShadKitDemo`; this app does **not** depend on that target or on `AIElementsGallery`.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Theme** | Neutral / Zinc / Stone / Gray / Slate base colors, token swatches, `ShadcnButton` / `ShadcnTextField` / `ShadcnBadge` / `ShadcnCard`. `.shadcnSurface()` on the card. |
| **Chat** | Pinned outside the page scroller. Tap the composer, type, Send (or a suggestion chip). Streams a canned `AIMockChatTransport` reply — no network. Composer sits above the floating tab pill. |
| **Elements** | Settled `AIReasoning`, completed `AITool`, `AICodeBlock`, `AIResponse`. No live stream. |
| **Leave the tab** | The active surface unmounts and any mock stream is stopped. |

### Gallery

Lazy grid of paused stand-ins: token swatches, buttons, badges, card, static `AIMessage` bubbles, settled reasoning, completed tool, code fence, markdown response, and two frozen canvas node cards.

**Skipped:** live `CanvasView`, `AIElementsGallery`, provider composer templates (ChatGPT / Claude / Grok), overlays that need a Mac pointer.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Liveline / DrafterCharts / ShipSwift demos)
- Network on first resolve for Swift Package `ShadKit` **0.3.0+** (tagged `v0.3.0`, pin `f628b20`)
