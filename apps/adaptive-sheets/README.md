# AdaptiveSheets

SwiftUI playground for **[AdaptiveSheets](https://github.com/huyparody/AdaptiveSheets)** **1.0.0**.

The package gives one SwiftUI API for bottom sheets. On **iOS 16.4 and later** it uses native `presentationDetents`, `presentationBackgroundInteraction`, `presentationCornerRadius`, `presentationDragIndicator`, and `interactiveDismissDisabled`. On **earlier systems** the same call goes through the library’s UIKit sheet (`UISheetPresentationController`). This demo targets iOS 18, so the native path is the one you will see.

## Open and run

1. Open `apps/adaptive-sheets/AdaptiveSheets.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **AdaptiveSheets** scheme.

```bash
cd apps/adaptive-sheets
xcodegen generate
```

`PRODUCT_MODULE_NAME = AdaptiveSheetsDemo` so the app module is not named `AdaptiveSheets` (the package). Bundle id is `com.techdemos.adaptivesheets`.

## Package

- URL: `https://github.com/huyparody/AdaptiveSheets`
- Product: `AdaptiveSheets`
- Version: `1.0.0` (only published tag; `from: 1.0.0` in `project.yml`)
- Library platforms: iOS 15+, `swift-tools-version: 6.0`

## Screens

1. **Basic sheet** — `isPresented`, detents `.medium` and `.large`, `startDetent: .medium`, `grabberIndicator: .visible`, swipe dismiss allowed.
2. **Custom heights** — `.height(180)`, `.fraction(0.55)`, `.medium`, starting at `.height(180)`.
3. **Background taps** — a block map and a counter. Switch `backgroundInteraction` between `.automatic`, `.enabled`, `.enabledUpThrough(.height(160))`, and `.disabled`. With “Up through 160”, taps register while the sheet rests on that short detent.
4. **Locked sheet** — `cornerRardius: 32`, `disableDismissOnSwipe: true`, grabber `.visible` or `.hidden`, and `onDismiss` (status text plus an alert). Close it with the button inside the sheet.
5. **From a list** — `adaptiveSheets(item:)` for an `Identifiable` selection. The content closure receives `Item?`.

## Parameters actually used

Both overloads live on `View`:

```swift
func adaptiveSheets<Content: View>(
    isPresented: Binding<Bool>,
    detents: [AdaptiveDetents],
    startDetent: AdaptiveDetents? = nil,
    backgroundInteraction: AdaptivePresetationBackgroundInteraction = .automatic,
    grabberIndicator: AdaptiveVisibility = .visible,
    disableDismissOnSwipe: Bool = false,
    cornerRardius: CGFloat = 20,
    onDismiss: (() -> Void)? = nil,
    bottomSheetcontent: () -> Content
) -> some View

func adaptiveSheets<Content: View, Item: Identifiable>(
    item: Binding<Item?>,
    detents: [AdaptiveDetents],
    startDetent: AdaptiveDetents? = nil,
    backgroundInteraction: AdaptivePresetationBackgroundInteraction = .automatic,
    grabberIndicator: AdaptiveVisibility = .visible,
    disableDismissOnSwipe: Bool = false,
    cornerRardius: CGFloat = 20,
    onDismiss: (() -> Void)? = nil,
    bottomSheetcontent: (Item?) -> Content
) -> some View
```

`AdaptiveDetents`: `.medium`, `.large`, `.fraction(_:)`, `.height(_:)`.

`AdaptivePresetationBackgroundInteraction`: `.automatic`, `.enabled`, `.enabledUpThrough(_:)`, `.disabled`.

`AdaptiveVisibility`: `.visible`, `.hidden`.

### README typos vs the source

Checked against tag `1.0.0` (`Sources/AdaptiveSheets/AdaptiveSheets.swift` and the Bridging types).

| README | Source |
| --- | --- |
| `cornerRardius` | Same spelling. There is no `cornerRadius` parameter. The README matches the source; both misspell radius. |
| Background values used as `.enabledUpThrough` | The type name is `AdaptivePresetationBackgroundInteraction` (`Presetation`, not `Presentation`). The README never prints that type name. |
| Item closure `{ item in if let item = item }` | The builder is `(Item?) -> Content`, so the value is optional even though `sheet(item:)` only calls it with a value. |
| Trailing closure | The parameter label in source is `bottomSheetcontent`. Call sites use a trailing closure and do not need the label. |
