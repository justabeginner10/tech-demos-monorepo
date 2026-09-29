# ThemeKit

Dark SwiftUI playground for **[ThemeKit](https://github.com/isamercan/ThemeKit)** (`import ThemeKit`, from **1.14.0**, tagged **v1.14.0**, revision **1192130**).

Product **`ThemeKit` only** (core + components). Lottie and Calendar package traits are **not** enabled, so resolution stays zero third-party deps.

Two tabs (iOS 18 floating Live / Gallery pill):

- **Live** — picker among Themes, Components, and Generator. Only the selected surface is mounted.
- **Gallery** — frozen Default / ocean / dracula cards plus a chip grid. Isolated `Theme` instances via `.theme(_:)`. No `ThemePicker`, no `Theme.shared` writes, no timers.

Root install: `Theme.shared.applyPersistedConfig()` in `App.init`, `.themeKit(reactToRuntimeChanges: false)` then `.demoChromeScheme()` (`.preferredColorScheme(.dark)`) on the `WindowGroup` content. ThemeKit's own Demo binds the window scheme to `theme.isDark`; this playground does **not** — a light `Theme.shared` would paint `Color.primary` as dark-on-black chrome. Themed islands (`ThemedPreviewStrip`, Gallery `.theme(_:)`) set `environment(\.colorScheme)` from that palette's `isDark` so token fallbacks stay contrasted without overriding the dark window. The preview strip is keyed on `Theme.revision` so it still re-skins.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/theme-kit/ThemeKit.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **ThemeKit** scheme. Xcode resolves the remote Swift package `https://github.com/isamercan/ThemeKit.git` (from 1.14.0 / tag `v1.14.0`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/theme-kit
xcodegen generate
```

`PRODUCT_MODULE_NAME = ThemeKitDemo` so the app module is not named `ThemeKit` (the package product). Bundle id is `com.techdemos.themekit`.

Do not add `ThemeKitLottie`, `ThemeKitCalendar`, or `ThemeKitTravel`. Do not set package traits `Lottie` or `Calendar`.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Themes** | Curated `ThemePicker` (default, cupcake, aqua, nord, dracula, sunset — not all 33). Tap a tile to `ThemePreset.apply()` on `Theme.shared`. The preview strip (Avatar, Badge, Chip, PrimaryButton, ThemeButton, TextInput, ProgressBar, Card) re-skins. **Dark variant** calls `Theme.shared.setColorScheme(dark:)`. |
| **Components** | The same token-bound strip against whatever `Theme.shared` is now. Type in the name field; toggle the Pool chip. Not the 175-count catalog. |
| **Generator** | `ColorPicker` / hex / swatch chips call `Theme.shared.applyGenerated(primaryHex:)` (and `persistConfig()`). Same preview re-skins on device. No Figma, MCP, or CSS import. |
| **Leave the tab / family** | The active surface unmounts. Gallery does not keep a live picker. |

Live uses a bottom `safeAreaInset` so the floating tab pill does not cover the preview. Components read `@ThemeContext` / `\.theme`.

### Gallery

Lazy grid of paused stand-ins: Default (`ThemePreset`), ocean (`loadTheme(named: "oceanTheme")`), dracula (`ThemePreset`), a status-chip row, and a nord atom strip. Each snapshot injects its own `Theme` with `.theme(_:)`.

**Skipped:** full 175-component catalog, Confetti / Aura / BorderBeam, Dialog / Drawer / Tour, Lottie, Calendar, CSS/Figma import, the in-repo Demo app clone.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the DialKit / ShadKit / LazyLayoutKit demos; package floor is iOS 15.6)
- Network on first resolve for Swift Package `ThemeKit` **1.14.0+** (tagged `v1.14.0`, pin `119213052bdaf306fb324cb0ba66ee524520f523`)
