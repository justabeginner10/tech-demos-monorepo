# Foldy

Dark SwiftUI playground for **[Foldy](https://github.com/InsaneArts/foldy)** (`import Foldy`, from **0.3.0**, tagged **0.3.0**, revision **99e56ee**).

Landing: [foldy-landing](https://tornikegomareli.github.io/foldy-landing/). Product **`Foldy` only**.

Two tabs:

- **Live** — picker among Swipe, Tilt, and Pager. Only the selected surface mounts a Metal fold (one `FoldTransition`, `foldEffect`, or `FoldPager` at a time).
- **Gallery** — frozen marketing cards that describe those surfaces. No `FoldTransition`, no `foldEffect`, no `FoldPager`, no concurrent live Metal.

Live chrome uses hardcoded light ink on a near-black page so glass materials cannot wash out labels. Fold content itself is solid high-contrast panes (indigo cover, amber inner, coral tilt, atlas places).

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/foldy/Foldy.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **Foldy** scheme. Xcode resolves the remote Swift package `https://github.com/insanearts/foldy.git` (from 0.3.0 / tag `0.3.0`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/foldy
xcodegen generate
```

`PRODUCT_MODULE_NAME = FoldyDemo` so the app module is not named `Foldy` (the package product). Bundle id is `com.techdemos.foldy`.

Do not stack multiple live folds. Do not add the package `Examples/FoldyDemo` target.

## What Foldy does

A Metal shader keeps the interface on a fixed plane and refracts it through a tilting pane of frosted glass. Zero shows the source; one shows the destination.

| API | Role |
| --- | --- |
| `FoldTransition` | Fold between two SwiftUI views; both keep their state |
| `.foldSwipe(progress:)` | Drive the fold with a swipe; content stays tappable |
| `.foldEffect(angle:)` / `.foldEffect(tilt:)` | Tilt one view on one or two axes |
| `FoldPager` | Page a list with page-turn folds |
| `FoldStyle` / `FoldAppearance` | Hinge, choreography, and six glass materials |

Appearances: `.frosted` (default), `.clear`, `.grain`, `.gloss`, `.ink`, `.midnight`. Every one is invisible at rest — fold to a midpoint to see the material.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Swipe** | `FoldTransition` + `.foldSwipe`. Cover (indigo) folds onto Inner (amber). Menu picks appearance; segmented picker is Reveal vs Page. **Play** animates 0↔1; **Mid** parks at 0.5 so the glass is visible; **Reset** returns to the cover. Drag the pane in any direction. |
| **Tilt** | One `.foldEffect(angle:)`. Slider −70°…70°. **Rest** returns to 0° (live content, recapture). **30°** is the reference hinge. |
| **Pager** | `FoldPager` over five original place cards. Swipe left / right or use Previous / Next. Appearance restyles the same pager. |
| **Leave the tab / family** | The active Metal fold unmounts. Gallery never keeps a live fold. |

Live content sits outside a page `ScrollView` (the fold container must own its gestures) and uses a bottom `safeAreaInset` so the tab pill does not cover the pane.

### Gallery

Lazy grid of paused stand-ins: swipe reveal, page turn, midnight glass, six material chips, a 30° tilt card, a four-place atlas strip, and an island-pull sketch. Chips name the APIs. Illustrations are SwiftUI paint — not `FoldTransition`.

**Skipped:** live `FoldCutout` / `FoldCutoutPull` / `FoldCutoutGhost`, `FoldContainerView` UIKit, `FoldMotionSource` gyroscope, the official ten-scene demo clone, Showcase (six folds at once).

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Rehearsal / ThemeKit / DialKit demos; package floor is iOS 17)
- Network on first resolve for Swift Package `Foldy` **0.3.0+** (tagged `0.3.0`, pin `99e56ee7000398a3e5ddaa3922e078a2547a1615`)
