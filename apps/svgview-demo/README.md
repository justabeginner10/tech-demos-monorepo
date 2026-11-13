# SVGView

Dark SwiftUI playground for **[SVGView](https://github.com/exyte/SVGView)** (`import SVGView`, from **1.0.6**, annotated tag **1.0.6**, commit **6465962f**).

Product **`SVGView` only**. `Package.swift` at that tag (`swift-tools-version: 5.3`) declares iOS 14, macOS 11, and watchOS 7, and `swiftLanguageVersions: [.v5]`. This app's deployment target is iOS 17.0. The home-screen name is **SVGView**. The app module is `SVGViewDemo`, because the package product and the SwiftUI type are both `SVGView`.

Tag `1.0.6` is an annotated tag. The tag object is `b3963bfe7248626f754ddd05c20780ca83def9c1`. It points at commit `6465962facdd25cb96eaebc35603afa2f15d2c0d` (2023-08-30, "Bump version"). The tag message is empty. That tag is the newest tag on the repository. There is no `1.0.5` tag. There is no GitHub Release object. Swift Package Manager requirement `from: 1.0.6` resolves the tag. The license is MIT.

The type this demo draws with is `SVGView`. A picture is an `SVGNode` tree: `SVGParser` builds one from a file, string, data, stream, or `XMLElement`, or the app builds one from `SVGViewport`, `SVGCircle`, `SVGRect`, and the other model types. `SVGView(svg:)` renders a node the app already holds. `getNode(byId:)` walks groups. Live writes `r`, `opacity`, `fill`, and `transform` on the nodes it finds.

Two tabs:

- **Live** — one mark, parsed once and kept. Source, radius, opacity, fill, pupil translation, and a tap are editable. Opens on this tab.
- **Gallery** — one card per entry point. Leaving the tab removes every picture.

Chrome is a near-black page with light ink. Fills in the artwork are explicit, because a missing `fill` becomes black and would disappear on this page.

## Open and run

This worker did not have Xcode or an iOS Simulator, and `swiftc` is not installed here, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator. This app was not compiled here. `git ls-remote --tags` shows `1.0.6` as the newest tag, at the commit above.

1. Open `apps/svgview-demo/SVGView.xcodeproj` in Xcode 16+ (iOS 17 SDK).
2. Pick an iPhone simulator.
3. Run the **SVGView** scheme. Xcode resolves the remote Swift package `https://github.com/exyte/SVGView.git` (from 1.0.6 / tag `1.0.6`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/svgview-demo
xcodegen generate
```

`PRODUCT_MODULE_NAME = SVGViewDemo`. Bundle id is `com.techdemos.svgview`.

The checked-in project copies the artwork to the bundle root. `SVGView(contentsOf:)` then links `swatch.png` from beside `image.svg`. After `xcodegen generate`, confirm those files are still in Copy Bundle Resources at the bundle root.

Do not copy the package's test suite or W3C fixtures.

## What SVGView does

`SVGView` stores an `SVGNode?` and its body is `svg?.toSwiftUI()`. Each concrete node (`SVGCircle`, `SVGRect`, `SVGGroup`, `SVGViewport`, `SVGText`, `SVGPath`, and the image types) is an `ObservableObject` and draws itself. `SVGNode` and `SVGShape` are not `ObservableObject`. Their `@Published` fields (`opacity`, `transform`, `fill`, `stroke`) are still the fields the package README assigns. This demo assigns them, then changes session state so SwiftUI renders `SVGView` again and the node views read the new values. `SVGCircle.r`, `cx`, and `cy` are `@Published` on `SVGCircle` itself.

`onTapGesture` appends a `TapGesture` to the node. That list is internal and is not published, so the gesture is installed before the next render. `addGesture` maps the gesture value to `()`, so a drag location cannot be read from a node gesture. The pupil drag is a SwiftUI `DragGesture` on the stage, and it writes `transform`.

| API | Role |
| --- | --- |
| `SVGView(contentsOf:)` | Parses a file URL. The linker becomes relative to that file |
| `SVGView(string:)` / `SVGView(data:)` / `SVGView(stream:)` | Parses markup already in memory. The stream init reads synchronously |
| `SVGView(xml:)` | Renders an `XMLElement` from `DOMParser` |
| `SVGView(svg:)` | Renders a node the app already holds. Live uses this so later edits keep the same objects |
| `SVGParser.parse(contentsOf:data:string:stream:xml:settings:)` | The same parses, with optional `SVGSettings` |
| `SVGView.getNode(byId:)` | `svg?.getNode(byId:)`. Groups walk their children |
| `SVGNode.onTapGesture` / `removeAllGestures()` | Tap on a node, or clear that list |
| `SVGCircle.r` / `SVGNode.opacity` / `SVGShape.fill` | The live knobs. Fill is `SVGColor(hex:)` |
| `SVGNode.transform` | `CGAffineTransform(translationX:y:)` on the pupil |
| `SVGNode.frame()` | Reported for the disc. `SVGCircle.frame()` is the circle's box |
| `SVGViewport` / `SVGLength.pixels` / `SVGPreserveAspectRatio` | The root of a built tree. `SVGLength` cases are public. The pixel and percent initializers are not |
| `SVGSettings(fontSize:ppi:)` | Default font size is 16. Default ppi is 96. Used when the text has no `font-size`, or when the size is in inches |

`SVGScreen.main(ppi:)` at this tag fixes the screen size at 100 by 100. Percentage lengths are resolved against that, not against the view box. The artwork uses pixels and inches.

## Bundled files

The files in `Sources/Artwork/` were written for this demo. They are original drawings, not downloads. No asset from the package test suite and no third-party artwork is copied in. They are dedicated to the public domain under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/). `mark.svg` is the same markup as `MarkDocument.svg`.

| File | What it shows |
| --- | --- |
| `mark.svg` | Plate, spark, disc, and pupil, with those ids. Live parses this from a file, from the same string, from UTF-8 data, or builds it with model types |
| `shapes.svg` | Rect, circle, ellipse, line, polygon, polyline, and an even-odd path |
| `gradient.svg` | `linearGradient` and `radialGradient` referenced by `fill="url(#id)"` |
| `strokes.svg` | Dash array, round cap, round join, and `fill-opacity` |
| `reuse.svg` | A circle in `defs`, copied three times with `use` and `xlink:href` |
| `type.svg` | `text-anchor` start, middle, and end |
| `style.svg` | A `style` element. Class `.hot` and id `#cool` set fill |
| `image.svg` | `swatch.png` beside the file, plus the same PNG as a `data:image/png;base64` URI |
| `swatch.png` | A 16 by 16 checker, original, CC0 |

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Source** | File calls `SVGParser.parse(contentsOf:)`. String and Data parse `MarkDocument.svg`. Nodes builds the same ids with `SVGViewport` |
| **Disc radius** | `getNode(byId: "disc") as? SVGCircle`, then `r`. The readout shows `frame()` |
| **Disc opacity** | `SVGNode.opacity`. A tap on the disc toggles 0.35 and 1 |
| **Pupil x / y** | `transform` translation, clamped to ±40. Dragging the stage writes the same transform |
| **Disc fill** | `SVGColor(hex:)` on `fill`. With Animate on, the swatch and the tap use `withAnimation` |
| **Node tap** | On installs `onTapGesture`. Off calls `removeAllGestures()`. The stage drag still moves the pupil |
| **Package defaults** | File source, radius 52, opacity 1, orange, pupil at identity, tap on |
| **Leave the tab** | The stage says "Unmounted" |

Reduce Motion skips `withAnimation` on the tap and the fill swatches. Sliders and the drag always assign directly.

### Gallery

| Card | Call | What to look for |
| --- | --- | --- |
| **File** | `SVGView(contentsOf: shapes.svg)` | The seven shape elements |
| **String** | `SVGView(string:)` | Three circles from a string in the app |
| **Data** | `SVGView(data:)` | UTF-8 bytes of another string |
| **Stream** | `SVGView(stream:)` | An `InputStream` over UTF-8 bytes, opened, parsed, then closed |
| **XML** | `DOMParser.parse(string:)` then `SVGView(xml:)` | The element tree, then the same renderer |
| **Nodes** | `SVGView(svg:)` | `SVGLinearGradient(degree:from:to:)`, `SVGRadialGradient`, `SVGColor.by(name:)`, a dashed `SVGStroke`, `PathSegment`, and `SVGText` |
| **Gradients** | `gradient.svg` | Orange-to-purple linear rect, white-to-blue radial circle |
| **Strokes** | `strokes.svg` | Dashed line, rounded polyline, translucent dashed rect |
| **Use** | `reuse.svg` | Three copies of one circle |
| **Text** | `type.svg` | Start, middle, and end anchors |
| **Style** | `style.svg` | Orange from `.hot`, blue from `#cool` |
| **Group** | `SVGView(string:)` | `opacity` and `rotate(-14 120 70)` on a `g` |
| **Image** | `image.svg` | Left tile from `swatch.png`. Right tile from the data URI |
| **Aspect** | `preserveAspectRatio` | `xMidYMid meet` fits. `xMidYMid slice` fills and clips |
| **Settings** | `SVGParser.parse(string:settings:)` | Top row is `fontSize` 14 and 40 with no `font-size` attribute. Bottom row is `0.22in` at ppi 96 and 192 |

**Skipped:** `SVGView(fileURL:)` and `SVGParser.parse(fileURL:)` are deprecated. `clip-path` does not resolve here, because `clipPath` is not in the parser map, so the delegate returns nil. `mask` is stored on the node and `applyNodeAttributes` never reads it. `opaque` is stored and not read. `addGesture` cannot drive the pupil, because the value is discarded. Remote image URLs are not used. `Serializer` is internal. Radial `fx` and `fy` are parsed and not used by `toSwiftUI`. The package test SVGs are not copied.

## Dependencies

- Network on first resolve for Swift Package `SVGView` **1.0.6** (tag `1.0.6`, pin `6465962facdd25cb96eaebc35603afa2f15d2c0d`)
