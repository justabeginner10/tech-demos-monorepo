# Rehearsal

Dark SwiftUI playground for **[Rehearsal](https://github.com/daneden/Rehearsal)** (`import Rehearsal`, from **0.5.1**, tagged **0.5.1**, revision **9a0c3b8**).

Product **`Rehearsal` only**. Do **not** add `RehearsalExamples` or the `InstallRehearsalSkill` plugin. The package’s `Examples/RehearsalExamples/MyCard` is the API reference for this playground — the demo views (`Showbill`, `TypeSample`, `StageGrid`) are original stand-ins that exercise the same `param(...)` types.

Two tabs:

- **Live** — picker among Card, Type, and Layout. Only the selected surface mounts a `Rehearse` (one floating panel at a time).
- **Gallery** — frozen Showbill / TypeSample / StageGrid snapshots at fixed values, with labeled param chips. No `Rehearse`, no `RehearsalHarness`, no sheet.

Live uses the library’s own iOS sheet (Copy values as code + Reset) and the bottom-bar slider toggle. A bottom `safeAreaInset` keeps the floating tab pill off that toggle.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/rehearsal/Rehearsal.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **Rehearsal** scheme. Xcode resolves the remote Swift package `https://github.com/daneden/Rehearsal.git` (from 0.5.1 / tag `0.5.1`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/rehearsal
xcodegen generate
```

`PRODUCT_MODULE_NAME = RehearsalDemo` so the app module is not named `Rehearsal` (the package product). Bundle id is `com.techdemos.rehearsal`.

Do not add `RehearsalExamples`. Do not install the agent-skill plugin.

## What Rehearsal does

`Rehearse(SomeView.self) { param in ... }` declares adjustable parameters inline — the call returns the current value and registers a control. The harness builds a floating panel from those `param(...)` rows:

| Type | Control |
| --- | --- |
| `String` | Text field |
| `Int` | Stepper + slider (`range:` defaults to `0...100`) |
| `Double` | Slider (`range:` defaults to `0...1`) |
| `Bool` | Toggle |
| `Color` | Color picker |
| `CaseIterable & Hashable` enum | Picker (segmented for ≤ 3 cases) |

Overrides: `param.slider`, `param.stepper`, `param.picker(options:)`, `param.custom`. The panel’s **Copy values as code** button copies a `Showbill(title: "…", nights: 3, …)` snippet; **Reset** clears storage back to the defaults.

The library is aimed at `#Preview`, but `Rehearse` is a normal `View`, so this playground mounts it on device / Simulator.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Card** | `Showbill`: title text, nights stepper, energy slider, starred toggle (animated), accent color, density enum (spring), ribbon picker (`hidden` / `premiere` / `soldOut` — not `CaseIterable`). Drag the sheet; preview stays interactive behind it (iOS 16.4+). |
| **Type** | `TypeSample`: headline, size, tracking / leading sliders, weight menu, ink color, italic toggle. |
| **Layout** | `StageGrid`: `param.stepper` for columns, spacing / corner / inset sliders, stacked toggle, fill color, align enum. |
| **Copy values as code** | Copies the current initializer (argument labels are the `param` names). |
| **Reset** | Restores the defaults declared in each `param(...)`. |
| **Leave the tab / family** | The active `Rehearse` unmounts, so the sheet and harness do not stack. |

Live content sits outside a page `ScrollView` (the package sheet and its fields must not live under a competing scroller) and uses a bottom `safeAreaInset` so the tab pill does not cover the library toggle.

### Gallery

Lazy grid of paused stand-ins: premiere Showbill, sold-out compact Showbill, display type, caption type, stacked 3-column stage, wide leading stage. Chips show the frozen param values.

**Skipped:** the package `MyCard` type itself, hand-wired `RehearsalHarness`, custom `Adjustable` conformances, the install-skill plugin.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the DialKit / ThemeKit / ShadKit demos; package floor is iOS 16)
- Network on first resolve for Swift Package `Rehearsal` **0.5.1+** (tagged `0.5.1`, pin `9a0c3b821a62fec92a18dd7bbcb690be5e14468a`)
