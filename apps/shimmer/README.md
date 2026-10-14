# Shimmer

A small SwiftUI playground for [SwiftUI-Shimmer](https://github.com/markiv/SwiftUI-Shimmer) by Vikram Kriplaney (MIT). Package product and import: **Shimmer**. Exact version **1.5.1**, revision `0226e21f9bf355d40e07e5f5e1c33679d50e167f`. The library has no external package dependencies.

## Open and run

1. Open `apps/shimmer/Shimmer.xcodeproj` in Xcode 16+ with the iOS 18 SDK.
2. Choose the **Shimmer** scheme and an iPhone simulator.
3. Run. Xcode resolves the committed package pin.

The app module is `ShimmerDemo` to avoid colliding with the library module. Bundle ID: `com.techdemos.shimmer`. The generated project and shared scheme are committed; XcodeGen is only needed after changing `project.yml`.

```bash
cd apps/shimmer
xcodegen generate
```

## Try it

| Control | Expected behavior |
| --- | --- |
| Live | A moving highlight crosses a redacted recipe card. |
| Mode | Mask changes opacity; Overlay adds a mint highlight; Background paints the highlight behind content. |
| Animate loading | Off removes the shimmer and leaves a static skeleton. |
| Right-to-left preview | Reverses the highlight's direction and the preview's layout. |
| Cycle / Band size | Change animation duration and the gradient's extent. |
| Show loaded recipe | Reveals the recipe and stops the shimmer. Load again restores the placeholder. |
| Gallery | Static loading and loaded examples, without background animation. |
| System Reduce Motion | Suppresses shimmer while keeping the loading placeholder. |

The loading card has a VoiceOver label rather than announcing placeholder text. This is a local, deterministic loading-state demonstration; it does not fetch data or require credentials.

## Validation

The public API and exact revision were checked against the upstream tag, and the project configuration and scheme received structural checks. This demo was authored in a Linux cloud environment without Xcode or an iOS simulator: **it has not been compiled or run**. Simulator interaction checks, a screenshot, and a video remain required on a Mac before considering it validated.
