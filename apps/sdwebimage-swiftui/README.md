# WebImage

Dark SwiftUI playground for **[SDWebImageSwiftUI](https://github.com/SDWebImage/SDWebImageSwiftUI)** (`import SDWebImageSwiftUI`, from **3.1.4**, annotated tag **3.1.4**, commit **0e331457**).

Product **`SDWebImageSwiftUI` only**. The tag object is `26e32ea49cdca5c173393086837e1b5728ad7e3c`. It points at `0e331457ca9af2f0b08bcaa138a91ffb907b004f` (2025-11-03, "Released v3.1.4 version"). The license is MIT. `Package.swift` at that tag (`swift-tools-version: 5.3`) declares iOS 14, macOS 11, tvOS 14, and watchOS 7, and depends on SDWebImage `from: 5.21.1`. This app's deployment target is iOS 17.0. The home-screen name is **WebImage**. The app module is `SDWebImageSwiftUIDemo`, because the package product is `SDWebImageSwiftUI`.

Tag `3.1.4` is the newest tag on the repository. Swift Package Manager requirement `from: 3.1.4` resolves that tag. The newest SDWebImage tag that satisfies `from: 5.21.1` at the time of this change is **5.21.7** (`2de3a496eaf6df9a1312862adcfd54acd73c39c0`, annotated tag object `d057b643aa4abdce29e0d11c39fb26378516d6cd`, 2026-02-26, "Bumped version to 5.21.7"). `Package.resolved` records those two commits. This machine has no Swift toolchain, so that file was written from the git tags, not from `swift package resolve`.

`WebImage` is the SwiftUI loader. `AnimatedImage` is the `UIViewRepresentable` player (`#if !os(watchOS)` in the package). GIF is registered by default. Animated WebP is not: `SDImageCodersManager` starts as IO, GIF, and APNG. This app calls `SDImageCodersManager.shared.addCoder(SDImageAWebPCoder.shared)` once. `addCoder` appends, and decode walks the list in reverse, so AWebP is tried before the IO coder. `SDImageAWebPCoder` is the ImageIO WebP coder, iOS 14+.

Two tabs:

- **Live** — picker among Load, Motion, Player, and Cache. Only the selected surface mounts a loader. Opens on Load.
- **Gallery** — a grid of remote stills, plus one GIF `AnimatedImage` and one animated-WebP `AnimatedImage`. Leaving the tab removes them.

Chrome is a near-black page with light ink.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator. This app was not compiled here.

1. Open `apps/sdwebimage-swiftui/SDWebImageSwiftUI.xcodeproj` in Xcode 16+ (iOS 17 SDK).
2. Pick an iPhone simulator.
3. Run the **SDWebImageSwiftUI** scheme. Xcode resolves `https://github.com/SDWebImage/SDWebImageSwiftUI.git` (from 3.1.4 / tag `3.1.4`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/sdwebimage-swiftui
xcodegen generate
```

`PRODUCT_MODULE_NAME = SDWebImageSwiftUIDemo`. Bundle id is `com.techdemos.sdwebimageswiftui`.

Do not copy the package `Example` target.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Load** | `WebImage` phase content. Activity or progress indicator. `AnyTransition.fade(duration:)`, `.flipFromLeft(duration:)`, or `.flipFromBottom(duration:)`. Options: `.progressiveLoad`, `.refreshCached`, `.scaleDownLargeImages`, `.fromCacheOnly`. **Reload** remounts the view so the SwiftUI transition runs again. |
| **Motion** | `WebImage(url:isAnimating:)` on a GIF or an animated WebP. The binding starts at `true`. **Play** / **Pause** writes that binding. `.pausable`, `.playbackRate`, `.playbackMode`, `.customLoopCount`. |
| **Player** | `AnimatedImage` for the same clips, with a SwiftUI placeholder. **Play** / **Pause** uses `isAnimating`. Indicator is `SDWebImageActivityIndicator` or `SDWebImageProgressIndicator` (`.activity` / `.progress`). Transition is `SDWebImageTransition.fade(duration:)`, `.flipFromLeft(duration:)`, or `.curlUp(duration:)`. `.incrementalLoad`, `.maxBufferSize`, `.forceTransition`. |
| **Cache** | `SDImageCache.shared.calculateSize`, `.clearMemory()`, and `.clearDisk(onCompletion:)`. The path is `diskCachePath`. Clearing memory leaves disk files. Clearing disk loads the image from the network again. |

### Gallery

Lazy grid of eight HTTPS stills (Picsum JPEGs, two static WebP files, no API keys). Each tile calls `WebImage` with `.indicator(.activity)` and `.transition(.fade(duration: 0.35))`. The GIF card and the WebP card call `AnimatedImage(url:placeholderImage:)`.

**Skipped:** `ImageManager` as a standalone observable, bundle and `Data` initializers, `onViewCreate` / `onViewUpdate`, HEIC / AVIF / SVG coders, and a custom `SDWebImageManager`.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 17 simulator (same floor as the Grid demo; package floor is iOS 14)
- Network for the remote images and for the first resolve of Swift Package `SDWebImageSwiftUI` **3.1.4** (tag `3.1.4`, commit `0e331457ca9af2f0b08bcaa138a91ffb907b004f`)
