# BottomSheets

SwiftUI playground for **[c-villain/BottomSheets](https://github.com/c-villain/BottomSheets)** **1.0.0**.

The package is a drop-in-style sheet API for iOS 14 and later. On **iOS 16.4+** it presents the system sheet. `nativeBottomSheetDisabled(_:)` forces the custom implementation.

This app targets **iOS 18.0**, so the native path is what you get until a screen turns it off.

## Open and run

1. Open `apps/bottom-sheets/BottomSheets.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **BottomSheets** scheme.

```bash
cd apps/bottom-sheets
xcodegen generate
```

`PRODUCT_MODULE_NAME = BottomSheetsBackportDemo` so the app module is not named `BottomSheets` (the package). Bundle id is `com.techdemos.bottomsheets`.

## What is backported vs native

| Modifier / type | Role | iOS 16.4+ native path | Custom path |
| --- | --- | --- | --- |
| `bottomSheet(isPresented:_:selection:interaction:content:)` | Present the sheet | System `.sheet` | Custom overlay / cover |
| `BPresentationDetent` `.medium` `.large` `.height` `.fraction` | Detents | Mapped to `PresentationDetent` | Used directly |
| `selection` | Current detent binding | Mapped to `presentationDetents(_:selection:)` | Drives custom height |
| `BPresentationBackgroundInteraction` | Hits behind the sheet | `presentationBackgroundInteraction` | Custom hit testing |
| `bPresentationDragIndicator` / `BVisibility` | Grabber | Library draws its own capsule and hides the system indicator | Same capsule |
| `bPresentationBackground(Color)` | Sheet fill | `presentationBackground` | Custom background |
| `bPresentationCornerRadius` | Top corners | `presentationCornerRadius` | Custom shape |
| `bInteractiveDismissDisabled` | Block swipe to dismiss | `interactiveDismissDisabled` | Custom gesture |
| `nativeBottomSheetDisabled` | Force custom sheet | Switches off the system sheet | No effect beyond staying custom |
| `presentationContentOverlay` | Dim color behind the sheet | Ignored | Custom only |
| `presentationShadow` | Sheet shadow | Ignored | Custom only |
| `presentationOverDragLimit` | Rubber-band past the top detent | Ignored | Custom only |

There is no backport of `presentationContentInteraction`. Scrollable content has to scroll itself.

`bPresentationBackground` accepts a `Color` only, not a `Material` or `ShapeStyle`.

`interaction: .enabled(upThrough:)` must use a detent that is also in the detent set.

In tag 1.0.0, passing a `selection` binding drops `interaction` on the **custom** path (`BottomSheetView` does not forward it). The maps screen omits `selection` so background interaction works if you force the custom sheet. The native path honors both.

Below iOS 16.4 the package always uses the custom sheet. `nativeBottomSheetDisabled` is unnecessary there.

## Screens

1. **Basic detents** — height, medium, fraction, and large, plus a selection binding and buttons that assign it.
2. **Maps-like** — map stays interactive through medium (`.enabled(upThrough: .medium)`), with the drag indicator visible. Large blocks and dims the map on the native path.
3. **Styled sheet** — custom path, so background, corner radius, shadow, dim overlay, and overdrag are all visible.
4. **Form** — `TextField`s and a `List` inside the sheet, with optional `bInteractiveDismissDisabled`.
5. **Native or custom** — `nativeBottomSheetDisabled` toggles the two paths. The sheet closes when you flip it so the next presentation uses the path you picked.
