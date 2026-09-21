# LazyState

SwiftUI playground for **lazy `@State` initialized from parent data**.

Apple’s `@State` macro (Xcode 27) is lazy only for inline defaults. The moment you write `State(wrappedValue:)` in a view `init` so you can pass parent data in, the macro falls back to eager allocation: a new model is created on every parent re-render and immediately discarded.

[Point-Free: Beta Preview: LazyState](https://www.pointfree.co/blog/posts/223-beta-preview-lazystate) packages SwiftUI’s public (undocumented) `LazyState` type as `@LazyState`. This demo does **not** depend on the private Point-Free Max GitHub repo. It wraps `SwiftUI.LazyState` with the same public shape:

```swift
@LazyState private var session: SearchSession

init(region: Region) {
  _session = LazyState { SearchSession(region: region) }
}
```

The thunk runs once per view identity. No optionals, no `onAppear` init, and `$session.query` is a normal `Binding`.

Context: [Edward Sanchez on LazyState](https://x.com/edwardsanchez/status/2094910146006979002).

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this PR. Capture both on a Mac as a follow-up.

1. Open `apps/lazy-state/LazyState.xcodeproj` in Xcode 16+ (iOS 17 SDK or newer).
2. Pick an iPhone simulator.
3. Run the **LazyState** scheme.

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/lazy-state
xcodegen generate
```

The app target sets `PRODUCT_MODULE_NAME = LazyStateDemo` so the module is not named `LazyState` (the property-wrapper type).

## What to tap

| Control | What happens | What the counter should show |
| --- | --- | --- |
| **Re-render parent** on **LazyState** | Parent body runs; child view value is reconstructed; identity is unchanged | `SearchSession.init` stays **1** |
| **Re-render parent** on **Eager @State** | Same reconstruction, but `State(wrappedValue:)` evaluates immediately | Count **climbs**; extra models are thrown away |
| **Re-render parent** on **Optional + onAppear** | `onAppear` does not fire again | Count stays **1**, but the model is optional and bindings use `Binding(get:set:)` |
| **Parent region** without remount | New region is passed into `init`; stored state is not rewritten | Model region stays the original seed (same as `onAppear`) |
| **Remount child** | New `.id`, new identity | LazyState / onAppear run the initializer **once more** |
| **Filter places** | `$session.query` (or the optional workaround) | Live list filter; proves bindings work |

The large number is `SearchSession.init` count **for the selected pattern**. The three chips underneath keep a running total for all patterns.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 17 or newer (SwiftUI’s `LazyState` type has been public since the iOS 17 SDK)
