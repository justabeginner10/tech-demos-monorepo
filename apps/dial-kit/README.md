# DialKit

Dark SwiftUI playground for **[DialKit](https://github.com/mikelikesdesign/dialkit-ios)** (`import DialKit`, from **0.3.0**, tagged **v0.3**, revision **ed60519**).

Two tabs:

- **Live** — picker among Card, Type, and Shadow. Only the selected surface mounts a `DialPanelState` + `DialRoot`.
- **Gallery** — frozen card / type / shadow snapshots at fixed model values, with labeled control chips. No `DialRoot`, no `DialPanelState`, no drawer, no timers.

Live uses the host-controlled drawer (`showsFAB: false` + **Tune**) so DialKit’s FAB does not fight the floating tab pill.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up.

1. Open `apps/dial-kit/DialKit.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **DialKit** scheme. Xcode resolves the remote Swift package `https://github.com/mikelikesdesign/dialkit-ios` (from 0.3.0 / tag `v0.3`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/dial-kit
xcodegen generate
```

`PRODUCT_MODULE_NAME = DialKitDemo` so the app module is not named `DialKit` (the package product). Bundle id is `com.techdemos.dialkit`.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Card** | README `CardModel`: title text, corner radius, enabled toggle, fill hex, glass/solid, motion group (spring + transition + shuffle). Preview binds to `dial.values`. **Tune** (toolbar or button) opens the drawer. **Shuffle** cycles the title. |
| **Type** | Font size, weight select, tracking, line spacing, text color hex. Drives a sample paragraph. |
| **Shadow** | Radius, X/Y offset, opacity, color hex, layout inset. Still card — no timers. |
| **Leave the tab / family** | The active surface unmounts. `DialPanelState` deinits and unregisters from `DialStore`, so drawers do not stack. |

Unique `storageID`s: `dial-kit-card`, `dial-kit-type`, `dial-kit-shadow`.

Live content sits outside a page `ScrollView` (drawer text fields must not live under a competing scroller) and uses a bottom `safeAreaInset` so the tab pill does not cover **Tune**.

### Gallery

Lazy grid of paused stand-ins: glass card, disabled solid card, body type, caption type, deep shadow, soft shadow. Chips show the frozen control values.

**Skipped:** inline `DialRoot` mode, multi-panel picker in one drawer, SpriteKit, camera, continuous timers.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the ShadKit / ShipSwift / Liveline demos; package floor is iOS 17)
- Network on first resolve for Swift Package `dialkit-ios` **0.3.0+** (tagged `v0.3`, pin `ed60519`)
