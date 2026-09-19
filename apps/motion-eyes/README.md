# MotionEyes

SwiftUI playground that wires [MotionEyes](https://github.com/edwardsanchez/MotionEyes) so it is obvious whether an animation actually interpolated.

MotionEyes samples traced values on a `CADisplayLink` (default engine `.displayLink`) and logs change bursts:

```text
[MotionEyes][Demo Card][offset] -- Start … --
[MotionEyes][Demo Card][offset] x=12.400 y=-8.100
…
[MotionEyes][Demo Card][offset] -- End … -- xDelta=92.000 yDelta=-54.000
```

An animated `withAnimation` change produces **Start → many FPS samples → End**. The same assignment without animation is a **one-frame snap**.

Context: [Edward Sanchez on MotionEyes](https://x.com/edwardsanchez/status/2027213479099425002).

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this PR. Capture both on a Mac as a follow-up.

```bash
git clone --recurse-submodules https://github.com/justabeginner10/tech-demos-monorepo.git
# already cloned?
git submodule update --init --recursive
```

1. Open `apps/motion-eyes/MotionEyes.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **MotionEyes** scheme (it passes `--motioneyes-info-logs` so traces show up at `info` as well as in the in-app panel).

The scheme already depends on the official package at `Vendor/MotionEyes/package`. That path is required because upstream keeps `Package.swift` in the `package/` subdirectory, so a remote SwiftPM URL of `https://github.com/edwardsanchez/MotionEyes` will not resolve.

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/motion-eyes
xcodegen generate
```

## What to tap

| Control | What happens | What the trace should show |
| --- | --- | --- |
| **Spring move** / **Fade** / **Scale** | Values change inside `withAnimation(.spring…)` | Green **Start**, a stream of samples at the selected FPS, blue **End** with deltas. Banner: *Animation ran*. |
| **Snap move** / **Snap fade** / **Snap scale** | Same values, animations disabled | Almost no interpolating samples. Banner: *Animation did not run*. |
| **Reset all** | Springs everything back to rest | Another interpolated burst. |
| **Tracing enabled** | Toggles `.motionTrace(..., enabled:)` | Off = no new MotionEyes lines. |

The orange **Target @State** chips jump on tap. That is expected: SwiftUI commits the new state immediately. MotionEyes still sees interpolation because `Trace.value` is sampled through an animatable `GeometryEffect` and `Trace.geometry(..., source: .presentation)` reads the on-screen frame. A snap uses a transaction with animations disabled, so those probes jump too.

The orange card is the traced view. It uses the public API:

- `Trace.value` for `opacity`, `scale`, and `offset`
- `Trace.geometry("cardFrame", space: .screen, source: .presentation)` for on-screen motion

The bottom panel tails this process’s `subsystem == "MotionEyes"` logs via `OSLogStore`. If that store is empty, filter Xcode’s console the same way, or:

```bash
xcrun simctl spawn booted log stream \
  --style compact \
  --level debug \
  --predicate 'subsystem == "MotionEyes"'
```

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (MotionEyes’ package minimum)
