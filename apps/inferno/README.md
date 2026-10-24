# Inferno

Dark SwiftUI playground for **[Inferno](https://github.com/twostraws/Inferno)** (`import Inferno`, revision **a40c7a0**).

Product **`Inferno` only**. The package manifest lists iOS 15 (and macOS 12, Mac Catalyst 15, tvOS 15, visionOS 1). Every shader entry point, `InfernoShaderLibrary`, the `View` modifiers, and the `AnyTransition` helpers are marked **iOS 17+**. This app targets iOS 18 to match sibling demos.

Inferno has **no version tags**. `main` at the time of this demo is `a40c7a0bdec03aae1bd0b96c41d6a75451bafd2c` (2026-05-17, variable-blur README). The Xcode project pins that revision. A `from:` requirement cannot resolve, because Swift Package Manager has no versions to compare.

Two tabs:

- **Live** — picker among Glow, Distort, and Transition. Only the selected surface mounts one shader (one `colorEffect`, one `distortionEffect` / `layerEffect`, or one `AnyTransition`). Switching effect or leaving the tab unmounts it.
- **Gallery** — frozen painted cards for those same effects, plus a chip card for the other view modifiers. No `InfernoShaderLibrary`, no `.infrared()` / `.checkerboard` / `.variableBlur`, no `TimelineView`, no Inferno transition.

Live chrome uses hardcoded light ink on a near-black page so a bright shader cannot wash out labels. The poster under the shader is a solid gradient with white type.

## How Inferno is integrated

Inferno's README still documents the original workflow: copy the `.metal` file you want into the app target (and `Transitions.swift` when you want a transition), then call `ShaderLibrary.water(...)`. `ShaderLibrary` looks up stitchable functions in the **app** target's default Metal library. That path is for projects that do not link the package.

The repo also ships a real Swift package. `Package.swift` declares one library product, `Inferno`, and `resources: [.process("Shaders")]`. Xcode compiles those `.metal` files into the package resource bundle. `InfernoShaderLibrary` loads them with `ShaderLibrary.bundle(.inferno)`. The public `View` modifiers (`.infrared()`, `.checkerboard(size:color:)`, `.emboss(strength:)`, and the rest) and the `AnyTransition` helpers (`circles`, `swirl`, `pixellate`, `wind`, and the others) call that library. Shimmer, sinebow, the light grid, water, wave, and the loupes have no view modifier; call `InfernoShaderLibrary` directly. The package's own sandbox does the same.

This demo **links the package and does not copy `.metal` sources into the app**. Copying them as well would compile the same stitchable functions into the app library and into the package bundle. Calls go through `InfernoShaderLibrary` or the public Swift wrappers. Where the upstream README shows `ShaderLibrary.sinebow`, the package equivalent is `InfernoShaderLibrary.sinebow` with the same arguments. Shimmer's README sample already uses `InfernoShaderLibrary`.

`Transitions.swift` stays inside the package. The app uses the public `AnyTransition` methods and does not vendor that file. `CircleTransition` and the other modifier types in that file are internal.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/inferno/Inferno.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **Inferno** scheme. Xcode resolves the remote Swift package `https://github.com/twostraws/Inferno.git` at revision `a40c7a0bdec03aae1bd0b96c41d6a75451bafd2c`.

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/inferno
xcodegen generate
```

`PRODUCT_MODULE_NAME = InfernoDemo` so the app module is not named `Inferno` (the package product). Bundle id is `com.techdemos.inferno`.

Do not stack live shaders. Do not put `InfernoShaderLibrary`, Inferno view modifiers, or Inferno transitions in the Gallery grid. Do not copy the package `Sandbox` target.

### Metal toolchain

The app target has no `.metal` of its own. Inferno's shaders are compiled as part of the Swift package when Xcode builds the app. Build through Xcode (or `xcodebuild`).

On Xcode 26+ the Metal Toolchain is a separate download. If a build reports `missing Metal Toolchain`, run once:

```bash
xcodebuild -downloadComponent MetalToolchain
```

## What Inferno does

Stitchable Metal fragment shaders for SwiftUI: color replacements, generative fills, distortions, a variable blur, and transitions. Parameters below are the ones the caller passes. SwiftUI still supplies `position`, `color`, and (for layer effects) the layer.

| API | Role |
| --- | --- |
| `InfernoShaderLibrary` | `@dynamicMemberLookup` into `ShaderLibrary.bundle(.inferno)` |
| `InfernoShaderLibrary.shimmer` | `colorEffect`. Size, time, duration, gradient width, max lightness |
| `InfernoShaderLibrary.sinebow` | `colorEffect`. Size and time. Draws its own lines; multiplies by alpha |
| `InfernoShaderLibrary.lightGrid` | `colorEffect`. Size, time, density, speed, group size, brightness |
| `View.infrared()` | `colorEffect` with no parameters. Luma maps to blue → yellow → red |
| `InfernoShaderLibrary.water` | `distortionEffect`. Size, time, speed, strength, frequency |
| `InfernoShaderLibrary.wave` | `distortionEffect`. Time, speed, smoothing, strength. No size argument |
| `InfernoShaderLibrary.simpleLoupe` / `warpingLoupe` | `layerEffect`. Size, touch, max distance, zoom |
| `AnyTransition.circles(size:)` | Circle reveal. Package animates insertion |
| `AnyTransition.swirl(radius:)` | Twist. Insertion and removal both run the shader |
| `AnyTransition.pixellate(squares:steps:)` | Pixelate both ways. `steps` ≥ 60 is the smooth default |
| `AnyTransition.wind(size:)` | Horizontal streaks. Package animates insertion |

Suggested starts, from the shader headers: shimmer duration 3 / width 0.3 / lightness 0.9; light grid density 8 / speed 3 / group 1 / brightness 3; water 3 / 3 / 10; wave 5 / 10 / 5; loupe max distance 0.05 and zoom 2; circles 20; swirl 0.5; pixellate 20 squares and 60 steps; wind 0.2.

Shimmer's Metal function uses `fmod(time, animationDuration)`. The duration slider starts at 0.4 so that modulus stays defined. Light-grid group size starts at 1 because the shader divides by it.

`maxSampleOffset` for water, wave, and both loupes is `.zero`, matching the upstream samples.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Glow** | Menu: Shimmer, Sinebow, Lights, Infrared. Only the selected effect is in the tree. Sinebow and the light grid have no source-color tint; infrared is `View.infrared()` on the poster. |
| **Distort** | Water, Wave, or Loupe. Water and wave take a `TimelineView` clock. Loupe is Simple or Warp; drag recenters `touch`. The loupe opens in the middle of the stage. |
| **Transition** | Circles, Swirl, Pixels, or Wind. **Hide** / **Reveal** runs a 1.2s animation. Circles and Wind show the shader on the way in. Swirl and Pixellate show it both ways. |
| **Leave the tab / family** | The active shader unmounts. Gallery never keeps a live effect. |

Live content sits outside a page `ScrollView` (the loupe drag must own the stage) and uses a bottom `safeAreaInset` so the tab pill does not cover the poster.

### Gallery

Lazy grid of paused stand-ins: shimmer band, sinebow strokes, a light grid, an infrared ramp, water and wave marks, a loupe ring, circle / swirl / pixel / wind marks, and a painted checkerboard. Chips name the APIs. Illustrations are SwiftUI paint.

**Skipped:** `.checkerboard`, `.emboss`, `.gradientFill`, `.interlace`, `.invertAlpha`, `.passthrough`, `.rainbowNoise`, `.recolor`, animated gradient fill, circle-wave and relative-wave distortions, bubble, color planes, white noise, and the other transitions (`circleWave`, `diamonds`, `diamondWave`, `crosswarpLTR`, `crosswarpRTL`, `radial`, `genie`). `.variableBlur(radius:maxSampleCount:verticalPassFirst:normalizeEdges:mask:)` and the `maskRenderer` overload `(GeometryProxy, inout GraphicsContext) -> Void` are skipped so Live does not mount the two-pass layer effect. The upstream README's blur sample closure does not match that signature.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the ShaderKit / Aurora / Foldy demos; shader API floor is iOS 17)
- Network on first resolve for Swift Package `Inferno` at revision `a40c7a0bdec03aae1bd0b96c41d6a75451bafd2c`
- Metal Toolchain installed when Xcode reports it missing (see above)
