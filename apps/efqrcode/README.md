# EFQRCode

Dark SwiftUI playground for **[EFQRCode](https://github.com/EFPrefix/EFQRCode)** (`import EFQRCode`, from **7.0.3**, tag **7.0.3**, revision **07ff9e2**). MIT.

Product **`EFQRCode` only**. Tag `7.0.3` is an annotated tag. The commit is `07ff9e2e83a4bbd384e5a8e33b47f389c9aac762` (2025-08-03, "7.0.3"). `Package.swift` at that commit declares iOS 13, macOS 10.15, tvOS 13, and watchOS 6. `Package@swift-5.9.swift` adds visionOS 1. This app targets iOS 18 to match the Vortex, Lottie, and Confetti demos.

`swift package resolve` of requirement `from: 7.0.3` selected tag `7.0.3` and these pins:

| Package | Version | Revision |
| --- | --- | --- |
| EFQRCode | 7.0.3 | `07ff9e2e83a4bbd384e5a8e33b47f389c9aac762` |
| swift_qrcodejs | 2.3.1 | `d1605333f7edac39b4518538ef4f2638fdd2e4d6` |
| SwiftDraw | 0.22.0 | `a19594794cdcdee5135caad3bc119096c50c92c2` |

`swiftc -parse` accepted the app sources. Those checks are not an iOS build.

7.0 replaced the 6.x `EFQRCodeGenerator` chain with `EFQRCode.Generator` plus an `EFQRCodeStyle` enum. The text initializer requires `style`. A file comment that shows `EFQRCode.Generator("Hello World")` with no style does not match the signature in this tag.

Two tabs:

- **Live** — picker among Content, Styles, and Marks. Only the selected surface builds a generator. Switching family or leaving the tab drops it.
- **Gallery** — frozen painted cards. No `EFQRCode.Generator`, no `EFQRCode.Recognizer`.

Live chrome uses hardcoded light ink on a near-black page. The code itself sits on white so the modules stay readable.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator. This app was not compiled here.

1. Open `apps/efqrcode/EFQRCode.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **EFQRCode** scheme. Xcode resolves the remote Swift package `https://github.com/EFPrefix/EFQRCode.git` (from 7.0.3 / tag `7.0.3`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/efqrcode
xcodegen generate
```

`PRODUCT_MODULE_NAME = EFQRCodeDemo` so the app module is not named `EFQRCode` (the package product). Bundle id is `com.techdemos.efqrcode`. The home-screen name is **EFQRCode**.

Keep the generator on the selected Live family. Keep Gallery free of `EFQRCode.Generator`. Leave the upstream example app out of this target.

## What EFQRCode does

`EFQRCode.Generator` encodes text or data and asks the style for SVG. `toImage(width:)` rasterizes that SVG with SwiftDraw. `toSVG()` returns the markup. `EFQRCode.Recognizer` reads a `CGImage` with Core Image and returns `[String]`. An empty array means nothing was found.

| API | Role |
| --- | --- |
| `EFQRCode.Generator(_:encoding:errorCorrectLevel:style:)` | Text in, style required. Encoding default is UTF-8. Correction default is `.h` |
| `EFCorrectionLevel` | `.l` 7%, `.m` 15%, `.q` 25%, `.h` 30% |
| `EFQRCodeStyle` | `.basic`, `.image`, `.bubble`, `.d25`, `.dsj`, `.function`, `.imageFill`, `.line`, `.randomRectangle`, `.resampleImage` |
| `generator.toImage(width:)` | `UIImage` at a point width. This demo uses 280 |
| `generator.toSVG()` | SVG string. The caption reports its character count |
| `EFQRCode.Recognizer(image:)` / `recognize()` | Core Image decode. High accuracy, then a grayscale low-accuracy pass |
| `EFStyleParamIcon` | Center image. `percentage` is clamped at 0.33 inside the package |
| `EFStyleParamBackdrop` / `EFStyleParamBackdropImage` | Backdrop color and optional picture |
| `EFStyleParamImage.static(image:)` | Still `CGImage`. Animated frames are not used here |
| `EFImageMode` | `.scaleAspectFill`, `.scaleAspectFit`, `.scaleToFill` |

On `.image`, `.imageFill`, and `.resampleImage`, the fill picture is what `getParamImages()` reports as the watermark. Those `image` parameters are `Optional` and have no default, so the call always passes the argument. On `.basic`, `getParamImages()` returns `nil` for the watermark. The backdrop picture is a separate `EFStyleParamBackdropImage`.

The icon and the wash are drawn in the app with Core Graphics. Nothing is copied from the package examples.

`UIImage.cgImage()` on the package is not public. Recognize uses `UIImage.cgImage`, then `CIContext.createCGImage` if that property is nil.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Content** | The field starts as the package sample URL. Correction is `.h`, which is the `Generator` default. **Generate** calls `EFQRCode.Generator` with `EFStyleBasicParams()` and `toImage` / `toSVG`. **Recognize** runs `EFQRCode.Recognizer` on that image. |
| **Styles** | Menu of the ten `EFQRCodeStyle` cases. Knobs match the params type: basic data shape and scale, bubble colors, line direction and thickness, 2.5D heights, DSJ position style with package data colors, fade or circle, image fill, random-rectangle color, resample contrast and exposure. Picture styles can turn the fill image off (`image: nil`). Correction stays `.h`. |
| **Marks** | Basic style plus `EFStyleParamIcon` (percentage 0.12...0.33) and an optional backdrop image at alpha 0.45. **Recognize** is here too. A large icon at `.l` can fail to decode. `.h` is the starting level. |
| **Leave the tab / family** | The active generator is released. Gallery never creates one. |

### Gallery

Lazy grid of painted stand-ins for the ten styles, the icon, and the recognizer. Chips name the APIs. Illustrations are SwiftUI shapes.

**Skipped:** GIF, APNG, PDF, JPEG, and video export, animated `EFStyleParamImage`, camera capture, and the upstream UIKit example app.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Vortex / Lottie / Confetti demos; package floor is iOS 13)
- Network on first resolve for Swift Package `EFQRCode` **7.0.3** (tag `7.0.3`, pin `07ff9e2e83a4bbd384e5a8e33b47f389c9aac762`)
