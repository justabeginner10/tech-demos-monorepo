# Media Picker

Dark SwiftUI playground for **[MediaPicker](https://github.com/exyte/MediaPicker)** (`import ExyteMediaPicker`, from **3.4.7**, annotated tag **3.4.7**, commit **3d1db8d**).

Product **`ExyteMediaPicker` only**. The SwiftPM package name at that tag is `ExyteMediaPicker` (the old product name was `MediaPicker`). `Package.swift` (`swift-tools-version: 5.9`) declares iOS 17 and no other platform. The license is MIT. This app targets iOS 18 to match sibling demos. The package floor is iOS 17.

Tag `3.4.7` is an annotated tag. The tag object is `e5d6b1367eb6aa92f8f572b32322d529a2bc87de`. It points at commit `3d1db8d5b1f553d066d67a57590f211ab534a531` (2026-10-02, "Adapt to iPhone Duo"). That tag is the highest tag on the repo. `gh release list` for this repo is empty, so there is no GitHub Release object; 3.4.7 is the latest published tag. `main` (`b36e7af`) is one commit ahead of the tag and only updates the README. Swift Package Manager requirement `from: 3.4.7` resolves the tag, not `main`.

The package depends on `AnchoredPopup` (resolved **1.3.1**) and `ActivityIndicatorView` (resolved **2.0.2**). The manifest enables the experimental `StrictConcurrency` feature. This demo does not change that.

The public surface this demo calls was read from tag `3.4.7`. The README on that tag still shows theme labels (`background`, `emptyTint`, `selectedTint`) that are not in the source. This app uses the initializers that are in the source: `MediaPickerTheme.Main` (`pickerBackground`, `pickerText`, …), `Selection.init(accent:tint:background:)`, and `CellStyle`. `LiveCameraCellStyle.prominant` is spelled that way in the package.

Two tabs:

- **Live** — picker among Photos, Albums, Camera, and Theme. Only the selected surface mounts one `MediaPicker`. Switching family or leaving the tab removes it. Chosen photos and videos stay in a grid under the controls, with a detail screen.
- **Gallery** — frozen painted cards. No `MediaPicker`.

Live chrome uses hardcoded light ink on a near-black page.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. The Simulator build, screenshots, and video are still to be done on Aditya's Mac. A Linux VM cannot run the Simulator. This app was not compiled for iOS and was not run.

What was checked here:

- `swiftc -parse` (Swift 6.0.3) accepted the seven app sources.
- `swift package resolve` of requirement `from: 3.4.7` selected tag `3.4.7` (`3d1db8d5b1f553d066d67a57590f211ab534a531`), plus `AnchoredPopup` 1.3.1 and `ActivityIndicatorView` 2.0.2. That graph is the checked-in `Package.resolved`.
- `swiftc -typecheck -swift-version 6` of those sources against stand-in SwiftUI, UIKit, AVKit, and ExyteMediaPicker modules. The ExyteMediaPicker stubs use the tag's public signatures, including the `EmptyView` initializer in `GenenricsTrick.swift`. MediaPickerApp, DemoScreen, Models, LiveSurfaces, GalleryScreen, and GallerySamples typechecked. DemoChrome's static helpers hit actor errors that come from the stand-in `View` being stricter than SwiftUI. That is not an iOS build of this app.

1. Open `apps/media-picker/MediaPicker.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **MediaPicker** scheme. Xcode resolves the remote Swift package `https://github.com/exyte/MediaPicker.git` (from 3.4.7 / tag `3.4.7`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/media-picker
xcodegen generate
```

`PRODUCT_MODULE_NAME = MediaPickerDemo` so the app module is not named `MediaPicker` (the view type) or `ExyteMediaPicker` (the package product). Bundle id is `com.techdemos.mediapicker`. The home-screen name is **Media Picker**.

Keep the picker on the Live tab. Keep Gallery free of `MediaPicker`. Leave the upstream example target (`MediaPickerExample`) out of this app.

## Privacy strings

Generated Info.plist keys:

| Key | Why it is here |
| --- | --- |
| `NSPhotoLibraryUsageDescription` | The grid fetches `PHAsset`s |
| `NSPhotoLibraryAddUsageDescription` | `PermissionsService` calls `PHPhotoLibrary.requestAuthorization(for: .addOnly)`. Missing this string terminates the app |
| `NSCameraUsageDescription` | Device camera mode calls `AVCaptureDevice.requestAccess(for: .video)` |
| `NSMicrophoneUsageDescription` | Video capture adds a microphone input when it is missing |

On the Simulator the package skips the camera permission request and forces the live camera cell to `.none`. Camera mode still presents, and the package shows its internal stub (`Camera` / unavailable / Close) instead of a session. Close is the package default: it sets the mode back to `.photos`. This demo does not replace that with `didPressCancelCamera`.

## What MediaPicker does

`MediaPicker` is a SwiftUI view, not a button. Pass `isPresented` and `onChange`. Modifiers copy the view and set selection, mode, or theme. `SelectionParameters` is a class, so `mediaSelectionType`, `mediaSelectionStyle`, `mediaSelectionLimit`, and `showFullscreenPreview` write through that shared object. `mediaSelectionLimit` takes an `Int`. Unlimited selection is the stored default `nil`, which this demo does not use.

`onChange` and `orientationHandler` are nonisolated function types. The callbacks in this app are built in `PickerSink`, then hop back with `MainActor.assumeIsolated`, same shape as the Lottie and Wave demos. The package invokes them from SwiftUI `onChange`, `onAppear`, and `onDisappear`.

| API | Role in this demo |
| --- | --- |
| `MediaPicker(isPresented:onChange:)` | Sheet content. Cancel and Done set `isPresented` to false |
| `mediaSelectionType(_:)` | `.photoAndVideo`, `.photo`, `.video` |
| `mediaSelectionStyle(_:)` | `.checkmark` or `.count` |
| `mediaSelectionLimit(_:)` | Copied into the selection service in `onAppear`. Photos remounts when the limit or the media type changes |
| `showFullscreenPreview(_:)` | `false` selects on tap. With a limit of 1 the picker also closes |
| `liveCameraCell(_:)` | `.none`, `.small`, `.prominant`. The Simulator build of the package ignores this and uses `.none` |
| `selectedMedia(_:)` | Restores library assets the next time the picker opens. Camera files are `URL`s and are not restored |
| `fullscreenMedia(_:)` | Photos surface. The package writes the item open in its fullscreen preview |
| `pickerMode(_:)` / `albums(_:)` | Albums surface. `.albums`, then `.album(Album)` for one row |
| `orientationHandler(_:)` | Camera surface records `.lock` / `.unlock`. No `AppDelegate` lock is installed |
| `mediaPickerTheme(main:selection:cellStyle:error:defaultHeader:)` | Theme surface. `DefaultHeader.init` also sets `UISegmentedControl.appearance()` |

After Done, each `Media` loads `getURL()` and `duration`. Photo cells then load `getThumbnailURL()`. Video cells load `getThumbnailData()` (an `AVAsset` frame). Photo detail reads the file at `getURL()`. Video detail plays that URL with `VideoPlayer`. `duration` is `nil` or `0` for a photo.

Image `getThumbnailData()` is not used. In this tag it calls `getData()`, and that Photos callback traps unless `PHImageResultIsDegradedKey` is set. A synchronous image request usually does not set the key.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Photos** | Both / Photos / Videos, Check / Count, live cell, limit 1...12, fullscreen preview. **Open photos**. Done fills the grid. A cell opens detail. |
| **Albums** | Opens on `.albums`. Titles from `albums(_:)` stay after dismiss. A row opens `.album`. The default header still switches Photos and Albums. |
| **Camera** | Opens on `.camera`. Simulator: the package stub, then Close lands on the photos grid and the readout moves from `.camera` to `.photos`. The orientation line flips `lock` then `unlock`. Device: the live camera. |
| **Theme** | Gold / Teal / Violet, selection style, spacing, corner radius. The header segment colors come from `defaultHeader`. |
| **Selected** | Thumbnails, a duration badge on video, detail, **Clear**. |
| **Leave the tab / family** | The active `MediaPicker` unmounts. The grid stays while Live stays mounted. Gallery never creates a picker. |

### Gallery

Lazy grid of painted cards: modes, the count-style selection ring, theme accents, the simulator camera card, and a photo/video result row. Chips name the APIs. Nothing on the card is a `MediaPicker`.

**Skipped:** `albumSelectionBuilder`, `cameraSelectionBuilder`, `cameraViewBuilder`, `applyFilter`, `setMediaPickerParameters`, `setSelectionParameters`, the deprecated `showLiveCameraCell`, and an `AppDelegate` orientation lock. The example project is not copied in.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the FloatingButton / Vortex demos; package floor is iOS 17)
- Network on first resolve for Swift Package `ExyteMediaPicker` **3.4.7** (tag `3.4.7`, pin `3d1db8d5b1f553d066d67a57590f211ab534a531`)
