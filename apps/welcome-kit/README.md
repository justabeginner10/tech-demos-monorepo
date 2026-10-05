# WelcomeKit

SwiftUI playground for **[WelcomeKit](https://github.com/atoll-studio/WelcomeKit)** (`import WelcomeKit`, from **1.5.0**, tagged **1.5.0**, revision **17cea83**).

Product **`WelcomeKit` only**. Package floor is iOS 17; this app targets iOS 18 to match sibling demos.

Two tabs:

- **Live** — the real first-launch sheet on first run (`.welcomeSheetOnFirstLaunch`), a **Show welcome again** control (`.welcomeSheet` + `.dismissible`), Harbor / Atelier / Signal presets, and **Reset first-launch state** (`WelcomeStore.reset`, then remount). System / Light / Dark restyles the chrome.
- **Gallery** — painted snapshots of those sheets plus a centered Ova card and a pink Lark card. No `WelcomeView`, no sheet modifiers.

Chrome uses semantic grouped backgrounds and primary / secondary ink so labels stay readable in light and dark. Sheet tints are saturated; continue labels are white.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/welcome-kit/WelcomeKit.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **WelcomeKit** scheme. Xcode resolves the remote Swift package `https://github.com/atoll-studio/WelcomeKit.git` (from 1.5.0 / tag `1.5.0`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/welcome-kit
xcodegen generate
```

`PRODUCT_MODULE_NAME = WelcomeKitDemo` so the app module is not named `WelcomeKit` (the package product). Bundle id is `com.techdemos.welcomekit`.

Do not vendor the package source. Do not clone `Demo/WelcomeKitDemo` from the package.

## What WelcomeKit does

Apple's "Welcome to…" first-launch screen: a big headline, SF Symbol feature rows, a button pinned to the bottom, then a staggered reveal.

| API | Role |
| --- | --- |
| `.welcomeSheetOnFirstLaunch` | Show once; flag lives in `UserDefaults` |
| `.welcomeSheet(isPresented:)` | Show again from Settings; does not touch the flag |
| `WelcomeView` | Present the screen yourself |
| `WelcomeFeature` | One row: title, subtitle, SF Symbol, optional per-row tint |
| `WelcomeHeadline` | Plain copy, `.welcome(to:)`, or `.whatsNew(in:)` |
| `WelcomeConfiguration` | Tint, symbols, motion, fonts, footnote, button |
| `WelcomeStore` | `hasSeenWelcome` / `markAsSeen` / `reset` / `key(for:)` |
| `WelcomePresentation.dismissible` | Swipe-to-dismiss when showing again |

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **First launch** | On a fresh install (or after Reset) the Harbor / Atelier / Signal sheet presents itself. Continue writes `WelcomeKit.hasSeen.playground`. |
| **Harbor / Atelier / Signal** | Different app names, SF Symbols, tints, and headlines. Harbor is a plain title; Atelier uses `.welcome(to:)`; Signal uses `.whatsNew(in:)`. |
| **Show welcome again** | Same screen, `.dismissible` — swipe it away or tap the button. The first-launch flag is unchanged. |
| **Reset first-launch state** | `WelcomeStore.reset(id: "playground")`. The first-launch host remounts so the sheet returns without killing the app. |
| **System / Light / Dark** | Chrome and the painted preview stay high-contrast in both schemes. |

Live first-launch uses id `"playground"` so it does not collide with the package default `"welcome"`.

### Gallery

Lazy grid of paused stand-ins: Harbor, Atelier, Signal, a centered Ova card (README sample copy), and pink Lark. Chips name the APIs. Illustrations are SwiftUI paint — not `WelcomeView`.

**Skipped:** `configuration.appIcon` (needs baked rounded artwork; macOS ignores it), `WelcomeView` presented by the app, `WelcomePresentation.fullScreenCover`, custom `WelcomeMetrics`, `WelcomeStore.markAsSeen`, the official knob-for-every-setting demo.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Enriched Markdown / Minted / Foldy demos; package floor is iOS 17)
- Network on first resolve for Swift Package `WelcomeKit` **1.5.0+** (tagged `1.5.0`, pin `17cea83890d7f814e4c8f1aca6080c7b38638a62`)
