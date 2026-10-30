# PopupView

Dark SwiftUI playground for **[PopupView](https://github.com/exyte/PopupView)** (`import PopupView`, from **5.0.8**, tag **5.0.8**, revision **99695337**).

Product **`PopupView` only**. `Package.swift` at that tag requires iOS 17, macOS 14, tvOS 17, and watchOS 10 (`swift-tools-version: 6.0`). The package README still says iOS 15 and Xcode 12; the manifest is the floor. This app targets iOS 18 to match sibling demos.

Tag `5.0.8` is annotated and peels to `99695337ce9e965b70e4aa14b49b1a9920017333` (2026-10-06, "Merge pull request #300 from JustSAT/fix/watchos-safe-area-insets"). That commit is the newest tag on the repo. Swift Package Manager requirement `from: 5.0.8` resolves the tag. The demo is written against that tag, not against `master`.

Version 5 moved the types off the generic popup class (`Popup.DisplayMode`, `Popup.DismissSource`) and took scroll popups off `PopupType`. A scroll sheet is `.scrollPopup`, not `.type(.scroll)`.

Two tabs:

- **Live** — picker among Toasts, Floaters, and Sheets. Only the selected surface mounts `.popup` or `.scrollPopup`. Switching family or leaving the tab removes it.
- **Gallery** — frozen painted cards. No `.popup`, no `.scrollPopup`, no presentation binding.

Live chrome uses hardcoded light ink on a near-black page. Popup cards use a light paper fill so they read the way the package samples do.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/popup-view/PopupView.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **PopupView** scheme. Xcode resolves the remote Swift package `https://github.com/exyte/PopupView.git` (from 5.0.8 / tag `5.0.8`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/popup-view
xcodegen generate
```

`PRODUCT_MODULE_NAME = PopupViewDemo` so the app module is not named `PopupView` (the package product). Bundle id is `com.techdemos.popupview`. The home-screen name is **PopupView**.

Keep the modifier on the Live tab. Keep Gallery free of `.popup` and `.scrollPopup`. Leave the upstream sample (`PopupExample/`) out of this target.

## What PopupView does

`.popup(isPresented:)` mounts the content when the binding is true. `.popup(item:)` does the same for an `Equatable` optional: `nil` hides it, any value shows it. The package copies that value for the dismiss animation. `.scrollPopup` is the scrolling sheet. It takes the same `isPresented` or `item` binding, plus a `header` that stays out of the scroll.

`customize` receives a fresh `Popup.PopupTypeParameters` or `Popup.ScrollPopupParameters` and returns it. The methods mutate the class and return `self`, so the call order does not matter.

| API | Role |
| --- | --- |
| `View.popup(isPresented:view:customize:)` | Bool presentation. `customize` defaults to `{ $0 }` |
| `View.popup(item:itemView:customize:)` | Optional `Equatable` presentation |
| `View.scrollPopup(isPresented:view:header:customize:)` | Scrolling sheet. `header` replaces any `headerView` set inside `customize` |
| `View.scrollPopup(item:itemView:header:customize:)` | Same, driven by an item |
| `Popup.PopupType.default` | Centered dialog. Ignores the safe area. Default position `.center` |
| `Popup.PopupType.toast` | Pinned to an edge (`.bottom` unless `position` says otherwise). No padding. Ignores the safe area so the background can bleed. Inset your own text with `popupSafeAreaInsets` |
| `Popup.PopupType.floater(verticalPadding:horizontalPadding:useSafeAreaInset:)` | Padded card. Defaults are `10`, `10`, and `true`. With the flag on, a centered floater centers in the safe rect |
| `Popup.Position` | `topLeading`, `top`, `topTrailing`, `leading`, `center`, `trailing`, `bottomLeading`, `bottom`, `bottomTrailing` |
| `Popup.AppearAnimation` | `topSlide`, `bottomSlide`, `leftSlide`, `rightSlide`, `centerScale`, `none` |
| `appearFrom` / `disappearTo` | `nil` copies the position: leading → `leftSlide`, trailing → `rightSlide`, top → `topSlide`, anything else (including center and bottom) → `bottomSlide`. `disappearTo` copies `appearFrom` when it is also `nil` |
| `Popup.DisplayMode` | `.overlay` in the view, `.sheet` via `fullScreenCover`, `.window` via `UIWindow`. Default is `.window` |
| `animation` | Default `.easeOut(duration: 0.3)` |
| `autohideIn` | `nil` (the default) never hides on its own. A drag in progress waits until the finger lifts |
| `dismissibleIn(_:_:)` | After this delay the package sets the binding to `true`. Until then tap, outside tap, and drag do nothing. The caller has to start the binding at `false`. On dismiss, a non-nil delay sets it back to `false` |
| `dragToDismiss` | Default `true`. Direction follows `appearFrom`, not a separate axis: up, down, leading, or trailing. `.centerScale` and `.none` do not move |
| `dragToDismissDistance` | Overrides the default threshold, which is one third of the popup's width or height |
| `closeOnTap` | Default `true`. A control or gesture inside the body replaces it; dismiss yourself in that case |
| `closeOnTapOutside` | Default `false` |
| `allowTapThroughBG` | Default `false`. On an overlay the background stops hit-testing, so an outside tap cannot both pass through and dismiss. A window can dismiss and then return the hit. A sheet is a full-screen cover, so the page underneath does not receive the tap |
| `backgroundColor` / `backgroundView` | Outside area. Default is clear. If `backgroundView` is set, the color is ignored |
| `useKeyboardSafeArea` | Default `false`. Not mounted here |
| `becomesKeyWindow` | Default `true`. Window mode only. Toasts in this demo pass `false` so they do not take the key window |
| `popupDismiss` | Environment closure. Sets the bool to `false` or the item to `nil`. Injected for overlay, sheet, and window |
| `popupSafeAreaInsets` | Device safe area, for toast content. The package does not inset a toast for you |
| `Popup.DismissSource` | `binding`, `tapInside`, `tapOutside`, `drag`, `autohide`, `exitCommand` |
| `Popup.ScrollPopupPosition` | `.bottom(topPadding)` default `.bottom(70)`, or `.center(verticalPadding)` |

`exitCommand` is the path for a TV remote and the Mac escape key. This app does not send it.

Overlay positions against the view the modifier is attached to (the stage card). Window and sheet use the screen. Changing `displayMode` while a window is up removes that modifier (`.id` includes the mode) and clears the binding in the same update, so `WindowManager` gets `onDisappear`.

The package README's Swift 6 note still holds: a `.window` popup does not refresh `@State` stored inside the popup body. This demo passes bindings and reads `popupDismiss` instead.

On a window, the outside-tap hit test calls the same dismiss closure the modifier uses for an external close, and that closure records `Popup.DismissSource.binding`. Overlay outside taps record `.tapOutside`.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Toasts** | `.type(.toast)` on the top or bottom edge. **Show** sets `isPresented`. Autohide Off / 2s / 4s maps to `nil`, `2`, and `4`. The bar is text only, so **Close on tap** still works. Drag up on a top toast and down on a bottom one. **Scrim** is `backgroundColor`. **Spring** swaps `.easeOut(duration: 0.3)` for `.spring`. The text padding includes `popupSafeAreaInsets`, including when the host is the overlay, so the bar is taller than the glyphs inside the card. |
| **Stage** | Counts taps that reach the card. A blocking background does not increment it. Passthrough does, in overlay mode. |
| **Floaters** | `.popup(item:)`. Invite, Gift, and Sent set the item; **Clear item** sets `nil`. The card is at most 260 points wide so leading and trailing are visible. The padding slider is passed as both `verticalPadding` and `horizontalPadding` (they are separate arguments; the package default is 10). **useSafeAreaInset** is the third floater argument. **Autohide 3s** matches the package's small floater sample. Spring starts on, because that sample passes `.animation(.spring)`. |
| **Sheets · Center** | `.type(.default)`, `.position(.center)`, `closeOnTap(false)`, `dragToDismiss(false)`. **Zoom** is `.centerScale` in and out. **Slide** leaves `appearFrom` nil, so a centered dialog still enters from the bottom. **Leave up** zooms in and uses `disappearTo(.topSlide)`. **None** is `.none`. **Thanks** calls `popupDismiss`. Background is clear, `backgroundColor(.black.opacity(0.4))`, or `backgroundView` with a material. |
| **Sheets · Drag card** | The README sheet: `.type(.toast)`, `.position(.bottom)`, `dragToDismiss`. **Distance 120** passes `dragToDismissDistance(120)`; off uses one third of the card height. **Lock dismiss 1.5s** passes `dismissibleIn(1.5, $dismissEnabled)` and starts the binding at `false`. **Close** is disabled until that binding becomes `true`. The grabber is ordinary content. |
| **Sheets · Scroll** | `.scrollPopup`, header grabber, `closeOnTap(false)`. **Center position** switches `.bottom(64)` to `.center(24)`. Drag the header, or scroll to the top and keep pulling. **Dismiss** calls `popupDismiss`. |
| **Display** | Overlay (starts here), Window (the package default), or Sheet. Window and sheet cover the screen, including the Hide button. |
| **Leave the tab / family** | The modifier is unmounted. Gallery never mounts one. |

Live content scrolls, with a bottom `safeAreaInset` so the tab pill does not cover the last control. The stage is the view the modifier is attached to.

### Gallery

Lazy grid of paused stand-ins: both toast edges, a floater, the centered dialog, the drag card, the scroll sheet, the three display modes, dismiss sources, the item binding, and the three backgrounds. Chips name the APIs. Illustrations are SwiftUI paint.

**Skipped:** `useKeyboardSafeArea` (the package sample calls out a keyboard-height bug on scroll popups), stacking more than one popup at once (overlay and window can; sheet cannot), `isOpaque` and `dismissSourceCallback` (both deprecated), `exitCommand`, and the watchOS sample.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Vortex / Inferno demos; package floor is iOS 17)
- Network on first resolve for Swift Package `PopupView` **5.0.8** (tag `5.0.8`, pin `99695337ce9e965b70e4aa14b49b1a9920017333`)
