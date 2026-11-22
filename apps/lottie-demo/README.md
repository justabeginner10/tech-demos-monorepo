# Lottie

Dark SwiftUI playground for **[Lottie](https://github.com/airbnb/lottie-spm)** (`import Lottie`, from **4.6.1**, tag **4.6.1**, revision **0aff162**).

Product **`Lottie` only**. `lottie-spm` is the Swift Package Manager distribution of [lottie-ios](https://github.com/airbnb/lottie-ios). Its `Package.swift` (`swift-tools-version: 6.0`) declares iOS 13, macOS 10.15, tvOS 13, and visionOS 1. This app targets iOS 18 to match sibling demos.

Tag `4.6.1` on `lottie-spm` is a lightweight tag. It points at `0aff16288f8dc1e3dab35cbf5cf45979673fd3df` (2026-06-13, "Update to 4.6.1 (#33)"). That tag is also the latest GitHub Release. Swift Package Manager requirement `from: 4.6.1` resolves the tag.

The package does not compile lottie-ios from source. `Package.swift` at that revision is a binary target:

- URL `https://github.com/airbnb/lottie-ios/releases/download/4.6.1/Lottie.xcframework.zip`
- checksum `03d3f3b085da9479bcab7b0ad4b6d75a88425d27bf3c7582698fddce14c9181f`

The zip was downloaded in this environment and its SHA-256 matched that checksum. There is also a stub target `_LottieStub` so the product can be embedded. The app does not import the stub.

The SwiftUI API this demo calls was read from lottie-ios tag `4.6.1`, commit `f4db77d7feacba0c2360b84a40c38a6ce8ff399d` (2026-06-13, "Bump version to 4.6.1"). That tag is lightweight too. `LottieView` and `LottiePlaybackMode` live in `Sources/Public/Animation/` at that commit.

Two tabs:

- **Live** — picker among Playback, Range, and Markers. Only the selected surface keeps a `LottieView`. Switching family or leaving the tab removes it.
- **Gallery** — one looping `LottieView` per bundled JSON file. Leaving the tab removes those players too.

Gallery mounts real players because the files are the thing being shown. Live is where transport, speed, scrubbing, and ranges live.

Live chrome uses hardcoded light ink on a near-black page so the strokes stay readable.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator. This app was not compiled here.

`swiftc -parse` accepted the Swift sources. `swift package resolve` of requirement `from: 4.6.1` selected tag `4.6.1` (`0aff16288f8dc1e3dab35cbf5cf45979673fd3df`) and downloaded the XCFramework zip. Those checks are not an iOS build.

1. Open `apps/lottie-demo/Lottie.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **Lottie** scheme. Xcode resolves the remote Swift package `https://github.com/airbnb/lottie-spm.git` (from 4.6.1 / tag `4.6.1`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/lottie-demo
xcodegen generate
```

`PRODUCT_MODULE_NAME = LottieDemo` so the app module is not named `Lottie` (the package product). Bundle id is `com.techdemos.lottie`. The home-screen name is **Lottie**.

`LottieAnimation.named` loads `name.json` from the bundle root, or from an `Animations` subdirectory if the root copy is missing. The checked-in project copies the five JSON files to the bundle root. After `xcodegen generate`, confirm they are still in Copy Bundle Resources.

Keep the players on the selected tab. There is no network load and no `DotLottieFile`.

## What Lottie does

`LottieView(animation:)` wraps a `LottieAnimationView`. The synchronous initializer takes a `LottieAnimation?` already loaded with `LottieAnimation.named`. Modifiers copy the view and set playback, speed, or a progress override. On each SwiftUI update, `applyCurrentAnimationConfiguration` calls `setPlaybackMode` only when the new `LottiePlaybackMode` differs from `currentPlaybackMode`, so a parent re-render does not restart a run that is already in that mode.

`animationSpeed` is applied the same way: only when the `Double` differs from the view's current speed.

`getRealtimeAnimationProgress` wraps the view in a `TimelineView` and writes `realtimeAnimationProgress` into a binding on the main queue. The binding is written, not read. Passing `nil` pauses that timeline. This demo passes a binding only while a run's status is `playing`.

`animationDidFinish` stores a `LottieCompletionBlock`, which is `(Bool) -> Void`. `true` means the run reached the end. `false` means it was interrupted. `.loop` and `.autoReverse` use a repeat count of `.greatestFiniteMagnitude`, so they do not finish until something else stops them. `.playOnce` and `.repeat(2)` do finish.

The block is nonisolated. The completion comes from `CAAnimationDelegate.animationDidStop`, on the main thread. The app hops back with `MainActor.assumeIsolated` in `PlaybackSink`, same shape as the Wave demo's display-link sink.

| API | Role |
| --- | --- |
| `LottieAnimation.named(_:bundle:subdirectory:animationCache:)` | Loads `name.json` or `name.lot`. This app uses `.json`. Cache default is `LottieAnimationCache.shared` |
| `LottieView(animation:)` | Synchronous SwiftUI wrapper. Placeholder is `EmptyView` |
| `LottieView.resizable()` | Scales the animation to the size the parent proposes |
| `LottieView.looping()` | `.playing(.fromProgress(0, toProgress: 1, loopMode: .loop))` |
| `LottieView.playing(_:)` | Plays a `LottiePlaybackMode.PlaybackMode` |
| `LottieView.paused(at:)` | Pauses. Default state is `.currentFrame` |
| `LottieView.playbackMode(_:)` | The modifier `playing` and `paused(at:)` both call |
| `LottieView.animationSpeed(_:)` | Playback rate. `1` is the file's frame rate |
| `LottieView.currentProgress(_:)` | Pauses at a 0...1 progress. `nil` leaves the current run alone |
| `LottieView.currentFrame(_:)` | Pauses at a frame. `nil` leaves the current run alone |
| `LottieView.animationDidFinish(_:)` | Called when the active run finishes or is interrupted |
| `LottieView.getRealtimeAnimationProgress(_:)` | One-way progress binding. iOS 15+ |
| `LottiePlaybackMode.playing(.fromProgress(_:toProgress:loopMode:))` | `from` nil starts at the current progress |
| `LottiePlaybackMode.playing(.fromFrame(_:toFrame:loopMode:))` | `from` nil starts at the current frame |
| `LottiePlaybackMode.playing(.marker(_:loopMode:))` | Plays one marker for its duration. A missing name exits |
| `LottiePlaybackMode.playing(.fromMarker(_:toMarker:playEndMarkerFrame:loopMode:))` | Plays from one marker to another |
| `LottiePlaybackMode.playing(.markers(_:))` | Plays names in order. No loop mode. A missing name is skipped |
| `LottieLoopMode` | `.playOnce`, `.loop`, `.autoReverse`, `.repeat(Float)`, `.repeatBackwards(Float)` |
| `LottieAnimation.markerNames` / `frameTime(forMarker:)` / `durationFrameTime(forMarker:)` | Marker list and where each one sits |
| `LottieAnimation.frameTime(forProgress:)` / `progressTime(forFrame:clamped:)` | Converts the two clocks |
| `LottieAnimation.startFrame` / `endFrame` / `framerate` / `duration` | `duration` is `(endFrame - startFrame) / framerate` |

`LottieAnimationView.stop()` removes the animation and sets `currentFrame` to `0`. There is no `stop()` modifier on `LottieView`. Stop in this app is `.paused(at: .progress(0))`, which assigns `currentProgress` and lands on `startFrame`. These files start at frame 0, so the two agree.

`LottieAnimationView.pause()` freezes the current frame. Pause in this app is `.paused(at: .currentFrame)`.

Play while a run is already in the same mode does not call `setPlaybackMode` again, because the modes compare equal. Tapping Play during a run bumps the view identity so the new view applies `.fromProgress(0, ...)`. Tapping Play after pause uses `from: nil`, which resumes. Tapping Play after stop, or after `animationDidFinish(true)`, uses `from: 0`.

A marker named `reduced motion` (also `reduced_motion`, `reduced-motion`, `reducedmotion`, case insensitive) is the package's reduced-motion stand-in. The default `LottieConfiguration.reducedMotionOption` follows the system switch. While Reduce Motion is on, play commands on a file that has that marker play the marker instead. Only `pulse.json` has it.

## Bundled files

The five JSON files in `Sources/Animations/` were written for this demo. They are original vector animations, not downloads. No LottieFiles asset, no sample from the lottie-ios test suite, and no third-party artwork is copied in. They are dedicated to the public domain under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).

Each file is 200×200, 30 fps, frames 0 to 60 (`ip` 0, `op` 60, Bodymovin `v` 5.7.4). Colors are the page accent `(1, 0.55, 0.22)`, a blue `(0.45, 0.78, 1)`, and near-white ink. Alpha in a color array is ignored by lottie-ios; opacity is a separate channel.

| File | What moves | Markers (`cm`, frame, duration) |
| --- | --- | --- |
| `pulse.json` | Filled ellipse. Scale and opacity ease out and back | `in` 0+30, `out` 30+30, `reduced motion` 30+12 |
| `orbit.json` | Stroked ellipse. Trim end stays at 28. Offset runs 0 to 360 | `spin` 0+60 |
| `check.json` | Open polyline, round cap. Trim end draws the mark, then holds at 100 | `draw` 0+40, `hold` 40+20 |
| `bars.json` | Three rounded rectangles. Scale Y is staggered | `rise` 0+30, `fall` 30+30 |
| `bounce.json` | Ellipse position and squash, plus a static ground bar | `up` 0+32, `down` 32+28 |

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Playback** | Clip menu, loop (`Once`, `Loop`, `Reverse`, `Twice`), speed 0.25...3. **Play** / **Pause** / **Stop**. The readout is `getRealtimeAnimationProgress` while status is `playing`. Once and Twice end on `finished` and pause at the current frame. Loop and Reverse keep going. |
| **Range** | **Progress** calls `currentProgress`. **Frame** calls `currentFrame`. **Play progress** is `fromProgress`. **Play frames** is `fromFrame`. A lower end than the start plays backward. Changing an end or the loop while a span is active restarts that span. |
| **Markers** | **Play marker**, **Play span** (`playEndMarkerFrame` toggle), **Play sequence**. The sequence omits the reduced-motion name. `markers(_:)` does not take a loop mode. A missing marker name exits (`marker`) or is skipped (`markers`). |
| **Leave the tab / family** | The active `LottieView` unmounts. Gallery's players unmount when Live is open. |

### Gallery

Lazy grid of the five files. Each card calls `LottieView.looping()` and `.resizable()`. Chips name the shape channels in that file. The caption is `LottieAnimation.named`.

**Skipped:** `DotLottieFile` and the async `LottieView` initializers, `LottieAnimation.loadedFrom(url:)` (no network), `currentTime(_:)`, `getRealtimeAnimationFrame`, `LottieBackgroundBehavior`, image / text / font providers, `AnimationKeypath` value providers, and the rendering-engine switch. `LottieConfiguration` stays at `.automatic`. `LottieLoopMode.repeatBackwards` is not in the picker. Deprecated entry points (`play()`, `play(loopMode:)`, and the old `LottiePlaybackMode` cases such as `.fromProgress` at the top level) are not called. The supported forms are `.playing(_:)` and `.paused(at:)`.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Wave / Confetti demos; package floor is iOS 13)
- Network on first resolve for Swift Package `Lottie` **4.6.1** (tag `4.6.1`, pin `0aff16288f8dc1e3dab35cbf5cf45979673fd3df`)
