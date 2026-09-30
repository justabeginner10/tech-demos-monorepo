# DesignFoundation

Dark SwiftUI playground for **[DesignFoundation](https://github.com/NerdSnipe-Inc/design-foundation)** (`import DesignFoundation`, from **1.7.1**, tagged **1.7.1**, revision **88cea25**).

Product **`DesignFoundation` only** (MIT). Do **not** add DesignFoundationPro or other commercial packages.

Two tabs (iOS 18 floating Live / Gallery pill):

- **Live** — picker among Themes, Components, and Toast. Only the selected surface is mounted.
- **Gallery** — frozen Slate / Aurora / Copper / Sage / Garnet cards plus chips, atoms, and a static `DFPopupCard`. Isolated via `.dfTheme(_:)` or `.dfThemePreset(_:)` per card. No `DFToastQueue` writes, no presented `.dfPopup`.

Root install: `.dfToast(style: .filled)` then `.dfTheme(.slateDark)` then `.demoChromeScheme()` (`.preferredColorScheme(.dark)`) on the `WindowGroup` content. Chrome is dark-hardcoded (`DemoPalette`) so a light island cannot paint `Color.primary` as dark-on-black. Themed islands set `environment(\.colorScheme)` from that card's light/dark side so `.dfThemePreset` and token fallbacks stay contrasted without overriding the dark window. Prefer `theme.colors.background` on themed content.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/design-foundation/DesignFoundation.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **DesignFoundation** scheme. Xcode resolves the remote Swift package `https://github.com/NerdSnipe-Inc/design-foundation` (from 1.7.1 / tag `1.7.1`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/design-foundation
xcodegen generate
```

`PRODUCT_MODULE_NAME = DesignFoundationDemo` so the app module is not named `DesignFoundation` (the package product). Bundle id is `com.techdemos.designfoundation`.

Do not add DesignFoundationPro.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Themes** | Tiles for `.slate`, `.aurora`, `.copper`, `.sage`, `.garnet`. **Dark variant** flips island `colorScheme` so `.dfThemePreset` picks light/dark. The preview strip (DFAvatar, DFBadge, DFChip, DFButton, DFText, DFTextField, DFProgressBar, DFCard) re-skins from tokens. |
| **Components** | Curated primitives + inputs: DFButton styles, DFTextField, DFChip, DFToggle, DFProgressBar, DFCard, DFEmptyState. Own preset picker; not the 44-component dump. |
| **Toast** | **Success** / **Error** enqueue `DFToastQueue.shared` (root `.dfToast()`). **Sheet** presents `.dfPopup` `.sheet`; **Floater** presents `.floater(position: .bottom)`. Error toast has a Retry action. |
| **Leave the tab / family** | The active surface unmounts. Gallery does not keep a live picker or popup. |

Live uses a bottom `safeAreaInset` so the floating tab pill does not cover the preview. Components read `@Environment(\.dfTheme)`.

### Gallery

Lazy grid of paused stand-ins: Slate light (`.dfTheme`), Aurora dark (`.dfThemePreset`), Copper light, Sage dark, Garnet light, a chip row, a nord-style atom strip, and a frozen `DFPopupCard` (no host). Each snapshot injects its own theme.

**Skipped:** full 44-component catalog, Liquid Glass (iOS 26+), command palette, data tables, DesignFoundationPro blocks/screens.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the ThemeKit / DialKit / ShadKit demos; package floor is iOS 18)
- Network on first resolve for Swift Package `design-foundation` **1.7.1+** (tagged `1.7.1`, pin `88cea25ee45bf957f706d7a1a7e39f3c83f5af54`)
