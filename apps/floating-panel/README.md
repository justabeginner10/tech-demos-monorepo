# FloatingPanel

SwiftUI playground for **[FloatingPanel](https://github.com/scenee/FloatingPanel)** (from **3.2.4**). Maps-style persistent panels with the library's SwiftUI modifiers.

## Open and run

1. Open `apps/floating-panel/FloatingPanel.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **FloatingPanel** scheme.

```bash
cd apps/floating-panel
xcodegen generate
```

`PRODUCT_MODULE_NAME = FloatingPanelDemo` so the app module is not named `FloatingPanel` (the package). Bundle id is `com.techdemos.floatingpanel`.

## Package

- SPM: `https://github.com/scenee/FloatingPanel`
- Product: `FloatingPanel`
- Resolved: 3.2.4
- Deployment target: iOS 18.0 (library SwiftUI API requires iOS 15+)

## Screens

### Map

A persistent panel over a map-like canvas, similar to Apple Maps.

- Custom `FloatingPanelLayout` with tip, half, and full anchors
- Grabber handle and grabber padding
- Scroll tracking on the places `List` via `floatingPanelScrollTracking`
- Backdrop alpha that increases from tip to full
- Surface appearance: continuous corner radius and shadow
- Programmatic moves to tip, half, and full through `floatingPanelState`
- `FloatingPanelBehavior` spring settings and momentum projection
- Content mode `fitToBounds` and content inset adjustment `.never`

### Modal

Presents a panel modally with `FloatingPanelCoordinator`.

- `present` from the main hosting controller
- `isRemovalInteractionEnabled` so a downward drag dismisses the panel
- Backdrop tap-to-dismiss
- `floatingPanelDidRemove` sends a dismissed event back to SwiftUI
- Half and full anchors, grabber, opaque surface, and a close button

### Playground

Live controls for the SwiftUI modifiers and a coordinator that applies the rest:

- Corner radius
- Opaque surface versus translucent (`.transparent` plus a material content background)
- Grabber visibility and grabber padding
- Backdrop opacity and tap-to-dismiss
- Scroll tracking and whether scrolling is allowed at half
- Content mode (static or fit-to-bounds) and content inset adjustment
- Spring response time, spring deceleration rate, momentum projection, and rubber banding

Tap-to-dismiss removes the panel. Use **Show panel** on the canvas to present it again.
