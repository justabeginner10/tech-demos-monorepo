# Grid

Dark SwiftUI playground for **[Grid](https://github.com/exyte/Grid)** (`import ExyteGrid`, from **1.5.4**, annotated tag **1.5.4**, commit **c4d1cabb**).

Product **`ExyteGrid` only**. `Package.swift` at that tag (`swift-tools-version: 5.3`) declares iOS 14, macOS 10.15, and tvOS 14. This app's deployment target is iOS 17.0. The home-screen name is **Grid**. The app module is `GridDemo`, because SwiftUI already defines `Grid` and the package type is also `Grid`. Call sites in this app write `ExyteGrid.Grid`.

Tag `1.5.4` is an annotated tag. The tag object is `92abb65ac0a6f6fd757ae9b8fb363abf15e102a5`. It points at commit `c4d1cabb0c7fcbd35f664c31ad23e7aa32bc3dd4` (2026-09-15, "Fix overlapping in ScrollView"). That tag is the newest tag on the repository. There is no GitHub Release object for 1.5.4. The newest published GitHub Release is 1.5.0 (2023-03-20). Swift Package Manager requirement `from: 1.5.4` resolves the tag. The license is MIT.

The type this demo lays out with is `Grid`. Tracks are `GridTrack` (`.fr`, `.pt`, `.fit`). Placement uses `gridSpan`, `gridStart`, `GridContentMode`, `GridFlow`, `GridPacking`, `GridSpacing`, `GridAlignment`, `gridCellBackground`, `gridCellOverlay`, and `gridAnimation`. `GridGroup` is the container that gets past the 10-view builder limit.

Two tabs:

- **Live** — one `ExyteGrid.Grid` of identifiable tiles. Tracks, content mode, flow, packing, spacing, the focus span, and item alignment are editable. Layout changes use `.gridAnimation(Animation.default)`. Opens on this tab.
- **Gallery** — one card per feature, each with the arguments written on the card. Leaving the tab removes every grid.

Chrome is a near-black page with light ink. Cells are colored rounded rects. The text is the content `.fit` and scroll-mode tracks measure. `gridCellBackground` paints the positioned cell, which is how the package examples fill a track.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator. This app was not compiled here. `swiftc -parse` accepted the sources. `swift package resolve` for `from: 1.5.4` selected tag 1.5.4 at `c4d1cabb0c7fcbd35f664c31ad23e7aa32bc3dd4`.

1. Open `apps/grid-demo/Grid.xcodeproj` in Xcode 16+ (iOS 17 SDK).
2. Pick an iPhone simulator.
3. Run the **Grid** scheme. Xcode resolves the remote Swift package `https://github.com/exyte/Grid.git` (from 1.5.4 / tag `1.5.4`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/grid-demo
xcodegen generate
```

`PRODUCT_MODULE_NAME = GridDemo`. Bundle id is `com.techdemos.grid`.

Do not copy the package's `Example` target.

## What Grid does

`Grid` measures its cells, arranges them into tracks, then positions them. The initializer arguments below win over the matching environment modifiers (`.gridContentMode`, `.gridFlow`, `.gridPacking`, `.gridCommonItemsAlignment`, `.gridContentAlignment`, `.gridCache`). Animation is environment-only: `.gridAnimation(_:)`.

Defaults below are `Constants` at tag 1.5.4.

| API | Default | What it does |
| --- | --- | --- |
| `tracks: Int` | one track when the array form is omitted | Repeats `.fr(Constants.defaultFractionSize)`. `defaultFractionSize` is 1. `tracks: 3` is three `.fr(1)` tracks |
| `GridTrack.fr` | fraction 1 when built from an `Int` | Flexible share of the fixed axis |
| `GridTrack.pt` | none | Fixed points on the fixed axis |
| `GridTrack.fit` | none | Sizes to the cell's own content |
| `GridContentMode.fill` | default | Growing tracks share the parent's size as `.fr(1)` |
| `GridContentMode.scroll` | | Scrolls on the growing axis. Those tracks are sized as `.fit`. Rows-flow scrolls vertically. Columns-flow scrolls horizontally |
| `GridFlow.rows` | default | Columns are the fixed tracks. Cells walk across, then down |
| `GridFlow.columns` | | Rows are the fixed tracks. Cells walk down, then across |
| `GridPacking.sparse` | default | Auto-placement only moves forward |
| `GridPacking.dense` | | A later cell that fits may move back into a hole |
| `GridSpacing` | 5 on both axes | `GridSpacing(horizontal:vertical:)`, an `Int` literal (both axes), or `[horizontal, vertical]` |
| `gridSpan(column:row:)` | 1 by 1 | Spans. Each side is clamped to at least 1. `[column, row]` is the array form |
| `gridStart(column:row:)` | automatic | Pins a cell. A negative index becomes `nil`. `[column, row]` is the array form |
| `commonItemsAlignment` | `.center` | Alignment of every cell inside its area |
| `gridItemAlignment(_:)` | | One cell. Wins over the common alignment |
| `contentAlignment` | `.center` | Moves the whole grid when it is smaller than the proposal |
| `gridCellBackground` / `gridCellOverlay` | | Drawn in the positioned cell. The closure receives `CGSize?` |
| `gridAnimation(_:)` | `nil` | Animation on the inner stack. `nil` leaves changes unanimated |
| `Grid(_:)` where `Element: Identifiable` | | Stable ids for those cells, which is what animation follows |
| `Grid(0..<n, tracks:)` | | Range init. Ids follow view order |
| `GridGroup` | | One grid cell per child. `GridBuilder` itself stops at 10 direct views |

A fill-mode grid inside an unbounded height, such as this page's `ScrollView`, sees a proposal of about 10 pt on the growing axis and falls back to scroll-sized tracks. Every grid in this app sits in a well with a fixed height so `.fill` keeps a real size.

`GridFlow`, `GridContentMode`, `GridPacking`, and `GridCacheMode` are not `Hashable` at this tag. The pickers bind app enums and pass `.rows`, `.fill`, `.sparse`, and the other cases into the initializer.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Tracks** | Fractions (`tracks: 3`), points (`.pt(76)`, `.pt(40)`, `.pt(96)`), or fit (`.fit`, `.fr(1)`, `.fit`). All three recipes have three fixed tracks |
| **Content mode** | Fill shares the 240 pt stage. Scroll lets the cells keep their text size and moves along the flow |
| **Flow** | Rows walk across. Columns walk down. Wide spans the fixed axis |
| **Packing** | A is 1×1. Wide spans the fixed axis and leaves a hole beside A. Dense can place a later cell back into that hole. Sparse only moves forward |
| **Item alignment** | `commonItemsAlignment`. The package default is `.center` |
| **Cells** | 4...16. The grid is `Grid(tiles)` with `Identifiable` ids |
| **F column / row span** | `gridSpan(column:row:)` on the cell titled F. Column span stops at 3. Row span stops at 2 |
| **Horizontal / vertical spacing** | `GridSpacing(horizontal:vertical:)`. 5 and 5 match the package default |
| **Animate layout** | On passes `.gridAnimation(Animation.default)`. Off passes `nil`. Reduce Motion also passes `nil` |
| **Package defaults** | Fill, rows, sparse, spacing 5, center alignment, 12 cells, F at 1×1, animation on |
| **Leave the tab** | The stage says "Unmounted" |

### Gallery

| Card | Call | What to look for |
| --- | --- | --- |
| **Fractional** | `Grid(tracks: 3)` | Six equal `.fr(1)` cells. Spacing is the 5 pt default |
| **Fixed points** | `Grid(0..<6, tracks: [.pt(64), .pt(40), .pt(88)], spacing: 8, contentAlignment: .leading)` | The columns stay 64, 40, and 88 pt and sit on the leading edge |
| **Fit** | `tracks: [.fit, .fr(1), .fit]` | The outer columns hug "A" / "B" and "longer" / "fit". The middle track takes the rest |
| **Spans** | `gridSpan(column:row:)` and `gridSpan([3, 1])` | 2×1, 1×2, and 3×1. The 1×2 cell is `.gridItemAlignment(.bottom)` |
| **Starts** | `gridStart(column:row:)` and `gridStart([2, 1])` | Cells pinned to column and row, including a 2×2 and a full-width row |
| **Content mode** | `.scroll` and `.fill` | The same 18 cells. Scroll moves. Fill shares a 160 pt well |
| **Flow** | `flow: .rows` and `flow: .columns` | The same nine numbers. Rows read across. Columns read down. `tracks: 3` is the fixed axis |
| **Packing** | `packing: .sparse` and `.dense`, `gridSpan(column: 4)` on cell 2 | Four tracks. Sparse leaves the hole. Dense fills it with 3, 4, and 5 |
| **Spacing** | `spacing: [18, 6]` | Horizontal gap 18, vertical gap 6 |
| **GridGroup** | `GridGroup(0..<12)` inside `Grid(tracks: 4)` | Twelve cells from one builder child |

**Skipped:** `gridCache` (the source name; the package README calls this modifier `gridCaching`). The default is `.inMemoryCache`. Also skipped: the `ForEach` path inside the builder, `GridGroup` over `Identifiable` models and an explicit `id` key path, and the single-value `GridGroup` inits. Live sets content mode, flow, packing, spacing, and common alignment on the initializer, so the environment modifiers for those are not also applied. The package `Example` screens are not copied.

## Dependencies

- Network on first resolve for Swift Package `ExyteGrid` **1.5.4** (tag `1.5.4`, pin `c4d1cabb0c7fcbd35f664c31ad23e7aa32bc3dd4`)
