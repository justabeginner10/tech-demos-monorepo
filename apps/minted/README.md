# Minted

Dark SwiftUI playground for **[Minted](https://github.com/haplollc/Minted)** (`import Minted`, from **1.1.1**, tagged **v1.1.1**, revision **0cdb91a**).

Product **`Minted` only**. iOS 17+ package floor; this app targets iOS 18 to match sibling demos.

Two tabs:

- **Live** — picker among Award, Pin, and Reverse. Only the selected surface mounts a SceneKit coin (`SpinningCoinView` or `SpinningArtworkCoinView`). Switching family or leaving the tab unmounts it.
- **Gallery** — `CoinThumbnailView` snapshots, `CoinLineArt`, and stills of bundled pin JPGs. No live SceneKit coins (avoids hitch spam from concurrent `SCNView`s).

Live chrome uses hardcoded light ink on a near-black page so the clear SceneKit canvas cannot wash out labels.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/minted/Minted.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **Minted** scheme. Xcode resolves the remote Swift package `https://github.com/haplollc/Minted` (from 1.1.1 / tag `v1.1.1`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/minted
xcodegen generate
```

`PRODUCT_MODULE_NAME = MintedDemo` so the app module is not named `Minted` (the package product). Bundle id is `com.techdemos.minted`.

Do not stack multiple live coins. Do not put `SpinningCoinView` or `SpinningArtworkCoinView` in the Gallery grid.

## What Minted does

Flat SVG / pin artwork is extruded at runtime into a physically-lit gold medallion: cloisonné enamel, engraved lettering, studio reflections, a die-struck orange-peel back. No 3D model files.

| API | Role |
| --- | --- |
| `CoinDesign` | Vector mint: silhouette, enamel palette, engraving, arc text, art path |
| `CoinDesign(svgPathData:)` | Parse an SVG `d` string |
| `CoinDesign(svgFileData:)` | Merge every `<path>` via the document viewBox |
| `CoinDesign(art:)` | Mint a SwiftUI `Path` or `CGPath` |
| `SpinningCoinView` | Live SceneKit hero; idle spin + drag-to-flick |
| `ArtworkCoin` / `ArtworkCoin(sample:)` | Trace bundled (or your) pin art into metal |
| `SpinningArtworkCoinView` | Live SceneKit hero for a finished pin |
| `CoinThumbnailView` | Off-main-thread snapshot + disk cache |
| `CoinSnapshotter` | Same pipeline; returns a `UIImage` |
| `CoinLineArt` | Quiet outline for locked / unearned states |

Silhouettes: `.seal`, `.octagon`, `.circle`, `.diamond`, `.custom(CGPath)`. Engravings: `.petals` (default), `.rays`, `.lattice`, `.plain`.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Award** | `SpinningCoinView` + `CoinDesign`. Heart / Star / Alpine / Trophy. Menus restyle silhouette and engraving on this one coin. Drag to flick; idle spin resumes. Alpine uses `artSplit` / `artLower` (two-tone enamel). |
| **Pin** | `ArtworkCoin(sample:)` + `SpinningArtworkCoinView`. The JPEG analyze/mint runs off the main thread (and the default pin is prefetched while Award is up). A placeholder shows until the single live coin mounts. Menu picks among the eight bundled pins. |
| **Reverse** | `SpinningCoinView(design:initialRotation: .pi)` shows the orange-peel back. **Face** / **Back** remounts this one coin. |
| **Leave the tab / family** | The active SceneKit coin unmounts. Gallery never keeps a live coin. |

Live content sits outside a page `ScrollView` (the SceneKit pan must own its gestures) and uses a bottom `safeAreaInset` so the tab pill does not cover the medallion.

### Gallery

Lazy grid of paused stand-ins: award seal, alpine split, first-class rays, champion lattice, compass SVG file, Path ellipse, locked `CoinLineArt`, and a strip of bundled pin JPEGs. Chips name the APIs. Thumbnails go through `CoinThumbnailView` → `CoinSnapshotter`.

**Skipped:** `ArtworkCoin(image:)` from app-bundled assets (samples cover the pipeline), `CoinSilhouette.custom`, calling `CoinSnapshotter.shared.snapshot` directly (the thumbnail view already does), widgets / share sheets.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Foldy / Rehearsal / ThemeKit demos; package floor is iOS 17)
- Network on first resolve for Swift Package `Minted` **1.1.1+** (tagged `v1.1.1`, pin `0cdb91a23edfad5dd9ec41252584303f078547fe`)
