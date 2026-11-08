# Transitions

Dark SwiftUI playground for **[SwiftUINavigationTransitions](https://github.com/davdroman/swiftui-navigation-transitions)** (`import SwiftUINavigationTransitions`, exact **0.19.1**, git tag **0.19.1**, commit **d70e86a**).

Product **`SwiftUINavigationTransitions` only**. `Package.swift` at that tag (`swift-tools-version: 6.2`) declares iOS 13, Mac Catalyst 13, tvOS 13, and visionOS 1. This app targets iOS 18 to match sibling demos.

Tag `0.19.1` is a lightweight tag. `git cat-file -t 0.19.1` is `commit`. It points at `d70e86a04250e096dbe96e3372cc9db10c7ff160` (2026-10-20 00:24:01 +0100, "fix(ios): preserve keyboard focus after navigation transitions"). The license is MIT.

The calls in this demo were read from that commit. As of 0.18.0 the erased type is `CustomNavigationTransition` and the SwiftUI modifier is `customNavigationTransition(_:interactivity:)`. `AnyNavigationTransition` and `navigationTransition(_:interactivity:)` remain as deprecated spellings because `AnyNavigationTransition` collided with SwiftUI. This app does not call the deprecated spellings. `Interactivity.pan` is deprecated and renamed to `contentPan`. This app does not call `pan`.

Two tabs:

- **Live** — picker among Presets, Custom, and Gesture. Only the selected surface keeps a `NavigationStack` with `customNavigationTransition`. Switching family or leaving the tab removes it.
- **Gallery** — frozen painted cards. No `customNavigationTransition` and no `CustomNavigationTransition` value.

Live chrome uses hardcoded light ink on a near-black page. Pushed pages are flat color and a serif title so the push and pop read clearly.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator. This app was not compiled here.

`swiftc -parse` accepted the Swift sources. `swift package resolve` of requirement `exact: 0.19.1` selected tag `0.19.1` (`d70e86a04250e096dbe96e3372cc9db10c7ff160`). Those checks are not an iOS build.

1. Open `apps/swiftui-navigation-transitions/SwiftUINavigationTransitions.xcodeproj` in Xcode with Swift 6.2 or newer (the package manifest is `swift-tools-version: 6.2`).
2. Pick an iPhone simulator.
3. Run the **SwiftUINavigationTransitions** scheme. Xcode resolves the remote Swift package `https://github.com/davdroman/swiftui-navigation-transitions.git` (exact 0.19.1 / tag `0.19.1`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/swiftui-navigation-transitions
xcodegen generate
```

`PRODUCT_MODULE_NAME = SwiftUINavigationTransitionsDemo` so the app module is not named `SwiftUINavigationTransitions` (the package product). Bundle id is `com.techdemos.swiftuinavigationtransitions`. The home-screen name is **Transitions**.

Keep the modified stack on the Live tab. Keep Gallery free of the package types. Leave the upstream `Examples/Demo` target out of this app.

## What the package does

`customNavigationTransition(_:interactivity:)` introspects a stack-style `NavigationView` or a `NavigationStack` (receiver or ancestor) and calls `UINavigationController.setNavigationTransition(_:interactivity:)`. The modifier's interactivity argument defaults to `.default`.

`CustomNavigationTransition` erases either a `NavigationTransitionProtocol` (transient views) or a `PrimitiveNavigationTransition` (raw UIKit context). Both initializers store `animation = .default`. `animation(_:)` replaces that value. The navigation-controller swizzle passes `animated: transition.animation != nil`, so `animation(nil)` pushes and pops without animation. The note on `.default` says that transition's curve cannot be changed through `animation(_:)`.

| API | Role |
| --- | --- |
| `customNavigationTransition(_:interactivity:)` | SwiftUI modifier. Default interactivity is `.default` |
| `navigationTransition(_:interactivity:)` | Deprecated. Renamed to `customNavigationTransition`. Marked `@_disfavoredOverload` |
| `CustomNavigationTransition` | Erased transition. `init(some NavigationTransitionProtocol)` and `init(some PrimitiveNavigationTransition)` |
| `AnyNavigationTransition` | Deprecated typealias of `CustomNavigationTransition` |
| `animation(_:)` | Stores a package `Animation` on the erased value. `nil` clears it |
| `.slide` / `.slide(axis:)` | Horizontal (default) or vertical. Built from `Slide` |
| `.fade(.in)` / `.fade(.out)` / `.fade(.cross)` | `Fade.Style`. In and out fade one side. Cross fades both |
| `.default` | System transition (`PrimitiveNavigationTransition` no-op). Use it to change interactivity only |
| `combined(with:)` | Runs two transient transitions. Mixing in a primitive transition reports an issue and keeps the left-hand value |
| `Interactivity.edgePan` | Pop from the screen edge |
| `Interactivity.contentPan` | Pop from the content area, back to iOS 13 |
| `Interactivity.disabled` | Turns the pop gestures off |
| `Interactivity.default` | `contentPan` on iOS 26 and later, `edgePan` before that |
| `Interactivity.pan` | Deprecated. Returns `.contentPan` |
| `NavigationTransitionProtocol` | `body` composed with `NavigationTransitionBuilder`, or `transition(from:to:for:in:)` when `Body` is `Never` |
| `MirrorPush` / `MirrorPop` | One atomic transition on push, its `mirrored()` form on pop, or the reverse |
| `OnPush` / `OnPop` | Run an atomic transition for one navigation operation |
| `OnInsertion` / `OnRemoval` | Run an atomic transition for one phase |
| `PickPush` / `PickPop` | Keep one side of a full `NavigationTransitionProtocol` |
| `Move`, `Offset`, `Opacity`, `Scale`, `Rotate`, `Rotate3D`, `ZPosition` | Atomic building blocks. `Move` uses `initial` / `animation` / `completion` transform |
| `BringToFront`, `SendToBack` | Reorder the real `UIView` in the container |
| `Group`, `Identity` | Atomic grouping and a no-op. `Identity` also exists internally on the navigation side |
| `MirrorInsertion` / `MirrorRemoval` | Phase that swaps when mirrored |
| `Animation.default` | Ease-in-out, 0.35s |
| `easeIn` / `easeOut` / `easeInOut` / `linear` | `duration` argument, or the 0.35s static |
| `interpolatingSpring(mass:stiffness:damping:initialVelocity:)` | Mass defaults to 1, velocity to 0. The stored duration is still 0.35 |
| `timingCurve(_:_:_:_:duration:)` | Cubic control points |
| `speed(_:)` | Divides the stored duration |
| `PrimitiveNavigationTransition` | `transition(with:for:in:)` and a UIKit context. The package asks you to prefer `NavigationTransitionProtocol` |
| `UINavigationController.setNavigationTransition` | Called by the SwiftUI modifier |
| `UISplitViewController.setNavigationTransition(_:forColumns:interactivity:)` | Same idea per column. This app does not call it |

For a transition whose `isDefault` is false, `.edgePan` enables the package `UIScreenEdgePanGestureRecognizer` (`edges: .left`) and `.contentPan` enables the package `UIPanGestureRecognizer`. Both call `handleInteraction`. That handler finishes the pop when horizontal velocity is above 675, or when progress is at least 0.2 and velocity is above -200. It cancels otherwise. The recognizer begins only when the stack has more than one view controller and nothing is presented.

For `.default`, `.edgePan` keeps `interactivePopGestureRecognizer`. `.contentPan` on iOS 26 enables that edge recognizer plus the system content pop gesture. On earlier systems it copies the edge recognizer's targets onto a full-screen pan. Those system gestures keep the system's finish behavior.

Tag `0.19.1` still has the iOS 16 workaround that reparents the surviving view after a cancelled or finished transition. On iOS 17, tvOS 17, and visionOS 1 and later that reparent is skipped, because it resigns first responder and dismisses the keyboard.

`TransientView` on both protocols is a typealias of `AnimatorTransientView`. Stages are `initial`, `animation`, and `completion`. The animatable properties are `alpha`, `transform`, and `zPosition`.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Presets** | Slide, Rise (`.slide(axis: .vertical)`), Fade in, Fade out, Crossfade, Slide + fade (`.slide.combined(with: .fade(.in))`), and System (`.default`). Motion attaches `easeInOut`, `linear`, or `interpolatingSpring`, or leaves the initializer's `.default`. **Faster** calls `speed(1.6)`. **Force fade**, and the system Reduce Motion setting, switch to `.fade(.in).animation(.linear)`, which is the README branch. |
| **Custom** | `Swing`, `Zoom`, and `Flip` follow the package example at tag 0.19.1 (`MirrorPush`, `OnInsertion`, `OnRemoval`, `Rotate`, `Offset`, `Opacity`, `Scale`, `ZPosition`, `Rotate3D`). **Drift** implements `transition(from:to:for:in:)` with `typealias _Body = Never`. |
| **Gesture** | Slide or System, then Edge, Content, Off, or Auto. Push first. Drag right on the pushed page. Off leaves the back button and **Pop**. |
| **Page Two on Presets** | A text field sits on that page so a cancelled interactive pop has a first responder. |
| **Leave the tab / family** | The modified stack unmounts. Gallery never builds one. |

Changing a control rebuilds that stack and clears its path, so the modifier runs again on a new controller.

### Gallery

Lazy grid of painted cards: slide and rise, the three fade styles, a combined pair, swing / zoom / flip, the handler drift, edge versus content versus off, and ease / linear / spring strokes. Chips name the APIs. Nothing on this tab constructs the package.

## Requirements

- Xcode with Swift 6.2 or newer (package manifest `swift-tools-version: 6.2`)
- iOS 18 simulator (same floor as the other recent demos; package floor is iOS 13)
- Network on first resolve for Swift Package `SwiftUINavigationTransitions` **0.19.1** (tag `0.19.1`, pin `d70e86a04250e096dbe96e3372cc9db10c7ff160`)
