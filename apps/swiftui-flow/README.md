# Flow

Dark SwiftUI playground for **[SwiftUI-Flow](https://github.com/tevelee/SwiftUI-Flow)** (`import Flow`, from **3.5.5**, annotated tag **3.5.5**, commit **196e725**).

Product **`Flow` only**. `Package.swift` at that tag (`swift-tools-version: 5.9`) declares iOS 16, macOS 13, tvOS 16, and watchOS 9. `Package@swift-6.swift` adds visionOS 1. `LazyHFlow` and `LazyVFlow` are marked iOS 17. This app's deployment target is iOS 17.0 so those types are in range. The home-screen name is **Flow**. The app module is `SwiftUIFlowDemo`, because the package module is `Flow`.

Tag `3.5.5` is an annotated tag. The tag object is `304e632ab12440f686d3c60c5bc7e4f1aca27b7c`. It points at commit `196e7256758333914eb2313e349032fcd057ba6e` (2026-10-16, "bench: support hosts without instruction counters"). That tag is the newest version tag on the repository. The license is MIT.

The types this demo lays out with are `HFlow` and `VFlow`. `HFlowLayout` and `VFlowLayout` are the `Layout` values those views own. Wrapping uses the proposal on the flow axis: width for rows, height for columns.

Two tabs:

- **Live** — one tag cloud. The axis, both alignments, item spacing, line spacing, justification, and even distribution are editable. Add, remove, and tap-to-remove chips animate with `.snappy` unless Reduce Motion is on. Opens on this tab.
- **Gallery** — one card per feature, each with the arguments written on the card. Leaving the tab removes every flow.

Chrome is a near-black page with light ink. Chips are colored capsules. Fixed-width blocks are used where the wrap has to be obvious.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator. This app was not compiled here. `swiftc -parse` (Swift 6.0.3) accepted the seven app sources. `swift package resolve` for `from: 3.5.5` selected tag 3.5.5 at `196e7256758333914eb2313e349032fcd057ba6e`.

1. Open `apps/swiftui-flow/SwiftUIFlow.xcodeproj` in Xcode 16+ (iOS 17 SDK).
2. Pick an iPhone simulator.
3. Run the **SwiftUIFlow** scheme. Xcode resolves the remote Swift package `https://github.com/tevelee/SwiftUI-Flow.git` (from 3.5.5 / tag `3.5.5`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/swiftui-flow
xcodegen generate
```

`PRODUCT_MODULE_NAME = SwiftUIFlowDemo`. Bundle id is `com.techdemos.swiftuiflow`.

Do not copy the package's `Example` target.

## What Flow does

`HFlow` wraps onto new rows when the next child does not fit the proposed width. `VFlow` wraps onto new columns when the next child does not fit the proposed height. `nil` spacing uses `ViewSpacing` between neighbors. A number forces that gap.

`justified` stretches gaps, not items, and only when the proposal on the flow axis is finite. A line with one visible item is left alone. Every other line is stretched, including the last line. `distributeItemsEvenly` selects the Knuth–Plass line breaker. Off selects the greedy breaker, which fills earlier lines first. The two flags are independent.

`HFlowLayout.init(alignment:)` stores that value as the vertical alignment and hard-codes horizontal alignment to `.leading`. `VFlowLayout.init(alignment:)` stores that value as the horizontal alignment and hard-codes vertical alignment to `.top`. The two-axis initializers take both alignments and both spacings. On `VFlow`, `horizontalSpacing` is the column gap and `verticalSpacing` is the item gap.

| API | Default | What it does |
| --- | --- | --- |
| `HFlow(alignment:itemSpacing:rowSpacing:justified:distributeItemsEvenly:)` | vertical `.center`, spacing `nil`, both flags false | Rows. `alignment` is vertical |
| `HFlow(alignment:spacing:justified:distributeItemsEvenly:)` | same, one spacing for both axes | `spacing` sets item and row gaps |
| `HFlow(horizontalAlignment:verticalAlignment:horizontalSpacing:verticalSpacing:justified:distributeItemsEvenly:)` | no default for either alignment | Live uses this initializer |
| `VFlow(alignment:itemSpacing:columnSpacing:justified:distributeItemsEvenly:)` | horizontal `.center`, spacing `nil`, both flags false | Columns. `alignment` is horizontal |
| `VFlow` two-axis initializer | no default for either alignment | Same parameter names as `HFlow` |
| `HFlowLayout` / `VFlowLayout` | same defaults as the views | `Layout` values. `FlowLayoutCache` is the cache the protocol requires |
| `.flexibility(_:)` | `.natural` | `.minimum` stays at the minimum size. `.natural` may grow. `.maximum` may take a whole line |
| `.maxLines(_:)` / `.maxLines(_:overflow:)` | no cap | Drops lines past the limit. The overflow view is hidden when nothing is hidden |
| `.itemSeparator` / `.lineSeparator` | none | Drawn between items or lines, not on the outer edge |
| `ItemSeparator` | | Replaces the automatic item separator at that boundary. `ItemSeparator { EmptyView() }` clears it |
| `LineBreak()` | | Empty child that ends the line |
| `.startInNewLine()` | `true` when called with no argument | Forces that child onto a new line |
| `LazyHFlow` / `LazyVFlow` | iOS 17 | Same layout. Inside a scroll view, items reveal as that axis moves |

The stage has a fixed height. `HFlow` breaks on the stage width. `VFlow` breaks on that height. An unbounded width does not wrap rows. An unbounded height does not wrap columns.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Axis** | `HFlow` wraps rows in the stage width. `VFlow` wraps columns in the 260 pt height |
| **Horizontal / vertical alignment** | Both go to the two-axis initializer. Inside a line, one axis lines the chips up. The other shifts a short line against the longest line |
| **Custom item spacing** | On passes the slider as the gap between chips. Off passes `nil`, which is `ViewSpacing`. The screen opens at 8 |
| **Custom line spacing** | On passes the slider as the row gap (`HFlow`) or the column gap (`VFlow`). Off passes `nil`. The screen opens at 18 |
| **Justified** | Gaps grow so multi-item lines fill the finite proposal. A one-item line does not move |
| **Distribute evenly** | On uses Knuth–Plass. Off fills earlier lines first |
| **Add chip / Remove last / tap a chip** | Identity comes from `FlowChip.id`. The count stays between 3 and 18. `.snappy(duration: 0.32)` runs unless Reduce Motion is on |
| **Package defaults** | `HFlow`, horizontal `.leading`, vertical `.center`, both spacings `nil`, justification off, distribution off, the 12 seed chips. That pair of alignments is what `HFlowLayout(alignment: .center)` stores |
| **Leave the tab** | The stage says "Unmounted" |

### Gallery

| Card | Call | What to look for |
| --- | --- | --- |
| **Tag cloud** | `HFlow(horizontalAlignment: .center, verticalAlignment: .top)` | Varied chip heights share the top of each row. Short rows sit in the center. Spacing is the `nil` default |
| **Columns** | `VFlow(alignment: .leading, itemSpacing: 8, columnSpacing: 16)` | Eight labels wrap across columns inside a 200 pt height |
| **Row alignment** | `HFlow(alignment:spacing:)` | `.top`, `.center`, `.bottom`, and `.firstTextBaseline` on the same three chips |
| **Spacing** | `HFlow(itemSpacing: 4, rowSpacing: 20)` | Tight gaps inside a row, wide gaps between rows |
| **Justified** | `HFlow(spacing: 8, justified:)` | The same six blocks. On stretches the gaps. Off keeps 8 pt |
| **Distribute** | `HFlow(spacing: 8, distributeItemsEvenly:)` | The same eight widths. Greedy packs the top. Even balances the rows |
| **Flexibility** | `.flexibility(.minimum)`, `.natural`, `.maximum` | Each block is `minWidth: 44` and `maxWidth: .infinity` |
| **Line limit** | `.maxLines(2) { hidden in Text("+\(hidden)") }` | The flow is capped at 280 pt wide. The badge is the hidden count, and it is omitted when every chip fits |
| **Separators** | `.itemSeparator`, `.lineSeparator`, `ItemSeparator` | Dots between chips, a divider between rows, and one explicit `·` on a single boundary |
| **Breaks** | `LineBreak()`, `.startInNewLine()` | Yellow starts after an empty break. Green is forced onto its own line |
| **Layout** | `HFlowLayout(alignment: .top, itemSpacing: 8, rowSpacing: 12)` and `VFlowLayout(alignment: .leading, itemSpacing: 8, columnSpacing: 12)` | The `Layout` types, called as views |
| **Direction** | `.environment(\.layoutDirection, .rightToLeft)` | Chip 1 starts on the right |
| **Lazy** | `LazyHFlow(data:spacing:)` in a vertical `ScrollView`, `LazyVFlow(data:alignment:spacing:)` in a horizontal `ScrollView` | 28 chips. The vertical flow has a 160 pt height so columns wrap |

**Skipped:** `.flexibility(.grow)`. The package README at tag 3.5.5 shows `.grow(2)` and `.grow(1)`. `FlexibilityBehavior` in `Sources/Flow/LayoutModifiers.swift` at that tag has `.minimum`, `.natural`, and `.maximum` only. Also skipped: the package `Example` app, `ItemSeparator { EmptyView() }`, and calling `FlowLayoutCache` yourself.

## Dependencies

- Network on first resolve for Swift Package `Flow` **3.5.5** (tag `3.5.5`, pin `196e7256758333914eb2313e349032fcd057ba6e`)
