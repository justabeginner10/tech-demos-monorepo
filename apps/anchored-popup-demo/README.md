# Anchored Popup

Dark SwiftUI playground for **[AnchoredPopup](https://github.com/exyte/AnchoredPopup)** (`import AnchoredPopup`, from **1.3.1**, annotated tag **1.3.1**, commit **f93c51e**).

Product **`AnchoredPopup` only**. `Package.swift` at that tag (`swift-tools-version: 5.9`) declares iOS 17 and no other platform. The license is MIT. This app targets iOS 17, the same floor as the package.

Tag `1.3.1` is an annotated tag. The tag object is `325d0daaf1afc8e80ca8da3824c5ba9a029aa6db`. It points at commit `f93c51e75ff4e5242328ac24c8fb12f1f1e84eda` (2026-10-12, "Fix popup during portrait/landscape rotation"). That tag is the highest tag on the repo. `gh release list` for this repo is empty, so there is no GitHub Release object; 1.3.1 is the latest published tag. `main` (`77018a0`, "Update readme") is one commit ahead of the tag and does not change the library sources. Swift Package Manager requirement `from: 1.3.1` resolves the tag, not `main`.

The public surface this demo calls was read from `Sources/AnchoredPopup/PublicAPI.swift` at that commit. A few README lines disagree with that file. This app follows the source:

- `anchorRelative` defaults `boundsMode` to `.free`. The README says `.safeArea`.
- `PopupParameters.animation` is stored as `.easeIn(duration: 0.3)`. The method comment says easeOut.
- Opening and closing from code are `AnchoredPopup.launchGrowingAnimation(id:)` and `AnchoredPopup.launchShrinkingAnimation(id:)`. The README's `launchAnchoredAnimation` is not in the source.

Two pages, switched with the app's own bottom bar so neither page is removed from the tree:

- **Live** — Corners, Placement, and Behavior. All three stay mounted. An open popup is a `UIWindow` or a sheet whose presenter has to remain in the tree to close it.
- **Gallery** — frozen painted cards. No `useAsPopupAnchor`.

Live chrome uses hardcoded light ink on a near-black page. Source discs are gold. Popup cards are warm paper so they read on the default blur.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. The Simulator build, screenshots, and video are still to be done on Aditya's Mac. A Linux VM cannot run the Simulator. This app was not compiled for iOS and was not run.

What was checked here:

- `git ls-remote --tags` on `https://github.com/exyte/AnchoredPopup.git`. `1.3.1` is the highest tag. The tag object peels to `f93c51e75ff4e5242328ac24c8fb12f1f1e84eda`.
- `Package.swift` at that commit is iOS 17 only, which matches this app's deployment target.
- `project.yml`, the Xcode project, and `Package.resolved` use the same URL, product name `AnchoredPopup`, and requirement `from: 1.3.1` (up to next major, minimum 1.3.1). The pin is the tag's commit.
- `swiftc -parse` (Swift 6.0.3) accepted the seven app sources.
- Those sources were typechecked with Swift 6 against a stand-in `SwiftUI` module and a stand-in `AnchoredPopup` module whose public signatures were copied from `PublicAPI.swift` at the tag. `@main` and `#Preview` were left out of that check because they are provided by the real SDK. That is not an iOS build of this app.
- Call sites use only symbols from `PublicAPI.swift`: both `useAsPopupAnchor` overloads, `PopupParameters` methods, `AnchoredPopupPosition`, `AnchoredPopupBoundsMode`, `AnchoredPopupBackground` (including `init(viewBuilder:)`), `DisplayMode`, `launchGrowingAnimation`, `launchShrinkingAnimation`, and `anchoredPopupDismiss`.

1. Open `apps/anchored-popup-demo/AnchoredPopup.xcodeproj` in Xcode 16+ (iOS 17 SDK).
2. Pick an iPhone simulator.
3. Run the **AnchoredPopup** scheme. Xcode resolves the remote Swift package `https://github.com/exyte/AnchoredPopup.git` (from 1.3.1 / tag `1.3.1`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/anchored-popup-demo
xcodegen generate
```

`PRODUCT_MODULE_NAME = AnchoredPopupDemo` so the app module is not named `AnchoredPopup` (the package product, and the class that launches animations). Bundle id is `com.techdemos.anchoredpopup`. The home-screen name is **Anchored Popup**.

Leave the upstream example target (`AnchoredPopupExample`) out of this app.

## What AnchoredPopup does

`useAsPopupAnchor` records the source view's global frame and, on tap when `openOnTap` is true, moves that id to `.growing`. The popup is drawn in a new `UIWindow` (`.window`, the stored default) or in the package's own full-screen presenter (`.sheet`). It scales up from the source frame with `PopupParameters.animation`.

| API | Role |
| --- | --- |
| `useAsPopupAnchor(id:contentBuilder:)` | Defaults: `.window`, `.screenRelative()` (center of the screen), `.easeIn(duration: 0.3)`, `openOnTap` true, `closeOnTap` true, `closeOnTapOutside` false, passthrough false, `.blur()` (radius 6) |
| `useAsPopupAnchor(id:contentBuilder:customize:)` | Starts from `PopupParameters()` and applies the returned value |
| `.position(.anchorRelative(_:boundsMode:))` | Sticks that unit point of the popup to the same unit point of the source. Default bounds `.free` (no clamp) |
| `.position(.auto)` | Picks one of the four corners so the popup stays in the safe area, preferring the source's side of the screen |
| `.position(.screenRelative(_:boundsMode:))` | Aligns a unit point of the popup to that unit point of the bounds. Defaults `.center` and `.screen` |
| `.position(.absolute(_:position:))` | Puts that unit point of the popup on a window `CGPoint`. No clamp |
| `.displayMode(.window)` / `.displayMode(.sheet)` | Window can show many popups and can pass taps through. Sheet shows one |
| `.animation(_:)` | Grow and shrink. Stored default `.easeIn(duration: 0.3)` |
| `.background(.none / .color / .blur(radius:) / .view)` | Full-screen backdrop. `.blur()` is radius 6. `AnchoredPopupBackground(viewBuilder:)` wraps the view in `AnyView` immediately |
| `.openOnTap(_:)` | `false` leaves the tap gesture off. Call `launchGrowingAnimation(id:)` |
| `.closeOnTap(_:)` | Tap on the popup content shrinks it. The gesture is simultaneous with buttons inside the card |
| `.closeOnTapOutside(_:)` | Tap on the backdrop shrinks it. Stored default `false` |
| `.isBackgroundPassthrough(_:)` | Window hit testing only. A backdrop tap can fall through to the app |
| `AnchoredPopup.launchGrowingAnimation(id:)` / `launchShrinkingAnimation(id:)` | Set that id's state. The id has to exist already (the source has reported a frame) |
| `@Environment(\.anchoredPopupDismiss)` | Closure installed on the presented tree. Calls `launchShrinkingAnimation` for that id |

`launchShrinkingAnimation` on an id that is already `.hidden` leaves it in `.shrinking`. The source tap only grows from `.hidden` or a missing id, so this demo does not call shrink from the outside. Shrink and the environment dismiss live on the card, which is only on screen while the popup is up.

The package README's state note matches the window path: a parent `@State` captured in the builder does not refresh the window. A `Binding`, or `@State` stored inside the popup view, does. Behavior's card takes a `Binding`. The line under the stage is the parent value.

Changing animation, background, or flags updates the modifier's parameters for the next grow. The window or sheet already on screen keeps the values from the moment it opened. Switch display mode only after closing. Each mode has its own id, and both discs stay mounted, so the presenter that opened the popup can still close it.

A displayed popup reads later source-frame changes and snaps. Placement's source control is that path. `.auto` also uses the new frame when it picks a corner.

The package enables the experimental `StrictConcurrency` feature in its manifest. This demo does not change that.

## What to tap

### Corners

| Control | What to look for |
| --- | --- |
| **TL / TR / BL / BR** | `.anchorRelative` with that corner, so the card grows into the stage. `boundsMode` follows the Bounds control. Backdrop is `.blur(radius: 6)`. `closeOnTap` is true. Display mode is `.window`, so more than one card can be open. |
| **Bounds** | Free (source default, no clamp), Safe, or Screen. Does not change the Defaults disc. An open card keeps the mode it grew with. |
| **closeOnTapOutside** | Off by default, matching the stored default. On closes a corner card when the backdrop is tapped. |
| **Defaults** | The two-argument `useAsPopupAnchor`. The card grows toward the center of the screen. |

### Placement

| Control | What to look for |
| --- | --- |
| **Auto** | `.position(.auto)`. Move **Source** between the corners and the center, then open. The card picks a corner on the source's side of the safe area. |
| **Screen** | `.screenRelative` with the unit point and bounds you pick. `.screenRelative()` with no arguments is center / screen; this picker starts at top / safe area so it is not the same as Defaults. |
| **Absolute** | `.absolute` plus a window `CGPoint`. The popup point is which part of the card sits on that coordinate. The sliders are window points, not stage points. |
| **Source, while open** | A displayed card follows the disc's new global frame. |

### Behavior

| Control | What to look for |
| --- | --- |
| **Window / Sheet** | Two discs, one id each. The hidden one stays mounted. Window is the stored default. Sheet is the single-popup presenter. |
| **Animation** | Ease in 0.3 is the stored default. Snappy, ease out, and linear are the other calls. |
| **Background** | Blur radius 6, blur radius 16, a color, `.none`, and `AnchoredPopupBackground(viewBuilder:)`. |
| **openOnTap** | Off hides the disc's tap and shows **Grow**, which calls `launchGrowingAnimation`. |
| **closeOnTap** | Off by default here so Next name, Shrink, and Environment dismiss do not also fight a content tap. On means a tap anywhere on the card shrinks it, including on those buttons. |
| **closeOnTapOutside** | On by default on this surface so the backdrop is a way out. |
| **isBackgroundPassthrough** | Window only. With outside-tap also on, the backdrop tap shrinks and the tap continues to the page underneath. |
| **Next name** | Writes the `Binding`. **Parent note** under the stage changes. That is the update path the package README shows for window mode. |
| **Shrink** | `launchShrinkingAnimation(id:)`. |
| **Environment dismiss** | `@Environment(\.anchoredPopupDismiss)`. |

### Gallery

Lazy grid of painted cards: corners, the three positions, bounds, backgrounds, dismissal, and window versus sheet. Chips name the APIs. Nothing on the card calls the package.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 17 simulator (package floor; this target is 17.0)
- Network on first resolve for Swift Package `AnchoredPopup` **1.3.1** (annotated tag `1.3.1`, pin `f93c51e75ff4e5242328ac24c8fb12f1f1e84eda`)
