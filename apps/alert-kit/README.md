# Alert Kit

Dark SwiftUI playground for **[AlertKit](https://github.com/sparrowcode/AlertKit)** (`import AlertKit`, from **5.1.10**, lightweight tag **5.1.10**, commit **b8f3dff**).

Product **`AlertKit` only**. `Package.swift` at that tag (`swift-tools-version: 5.9`) declares iOS 13 and visionOS 1, and sets `swiftLanguageVersions: [.v5]`. The license is MIT. This app targets iOS 17. The package floor is iOS 13. Live uses the iOS 17 `onChange` form, so the screens are an iOS 17+ demo.

Tag `5.1.10` is a lightweight tag. It points at commit `b8f3dff07a75437ba26dbbffa62f303aaabfaec3` (2026-10-31, "Bump podspec version to 5.1.10"). `SPAlert.podspec` at that commit has `s.version = '5.1.10'`. That tag is also the latest GitHub Release (31 Oct 2026). The previous release is 5.1.9 (11 Apr 2026). There is no `refs/tags/5.1.10^{}` peel, so the tag is not annotated. Swift Package Manager requirement `from: 5.1.10` resolves the tag.

The public surface this demo calls was read from `Sources/AlertKit` at that commit. `ALERTKIT_SPM` is set by the package manifest and is not referenced in the sources.

Two tabs:

- **Live** — picker among API, View, and Modifier. Only the selected surface presents. Switching family or leaving the tab dismisses what that surface can reach.
- **Gallery** — frozen painted cards. No `AlertAppleMusic16View`, no `AlertAppleMusic17View`, and no `AlertKitAPI` call.

Live chrome uses hardcoded light ink on a near-black page. The sketch under the controls is SwiftUI paint, not the HUD. The HUD is the package view on the window after **Show**.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. The Simulator build, screenshots, and video are still to be done on Aditya's Mac. A Linux VM cannot run the Simulator. This app was not compiled for iOS and was not run.

What was checked here:

- `swiftc -parse` (Swift 6.0.3) accepted the seven app sources.
- `swift package resolve` of requirement `from: 5.1.10` selected tag `5.1.10` (`b8f3dff07a75437ba26dbbffa62f303aaabfaec3`). That pin is the checked-in `Package.resolved`.
- The same sources were typechecked against stand-in SwiftUI, UIKit, and AlertKit modules whose AlertKit signatures were copied from that tag. `#Preview` was left out of that check. The stand-in `ViewBuilder` stops at 10 children, same as SwiftUI. That is not an iOS build of this app.

1. Open `apps/alert-kit/AlertKit.xcodeproj` in Xcode 16+ (iOS 17 SDK).
2. Pick an iPhone simulator.
3. Run the **AlertKit** scheme. Xcode resolves the remote Swift package `https://github.com/sparrowcode/AlertKit.git` (from 5.1.10 / tag `5.1.10`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/alert-kit
xcodegen generate
```

`PRODUCT_MODULE_NAME = AlertKitDemo` so the app module is not named `AlertKit` (the package product). Bundle id is `com.techdemos.alertkit`. The home-screen name is **Alert Kit**.

Keep the package presenter on the Live tab. Keep Gallery free of it. Leave the upstream example out of this app.

## What AlertKit does

Both styles are `UIView` subclasses. `present` adds the view to a host, fades and scales it in over 0.2s from scale 0.8, then plays an icon animation if the icon view conforms to `AlertIconAnimatable`. `AlertKitAPI` looks up the key window with `UIApplication.shared.windows` and presents there. If that list has no key window, `present` returns and does not call the completion.

| API | Role |
| --- | --- |
| `AlertKitAPI.present(title:subtitle:icon:style:haptic:)` | Builds the view for `style` and presents it. `style` is required. The others default to `nil`. No completion and no returned view |
| `AlertKitAPI.present(view:completion:)` | Presents an existing `AlertViewProtocol`. Completion runs from `dismiss()` |
| `AlertKitAPI.dismissAllAlerts(completion:)` | Dismisses direct window subviews that conform to the internal dismiss protocol. Only `AlertAppleMusic17View` declares that conformance |
| `AlertAppleMusic17View(title:subtitle:icon:)` | Bottom banner. Icon is 20×20 on the leading side. Corner radius 14. Blur is `systemMaterial`. Drawn icons use line thickness 3 |
| `AlertAppleMusic16View(title:subtitle:icon:)` | Center card, 250 pt wide. Text is centered. Corner radius 8. Blur is `systemThickMaterial`. Drawn icons use line thickness 9. `icon == nil` uses the message margins |
| `AlertIcon` | `.done`, `.error`, `.heart`, `.spinnerSmall`, `.spinnerLarge`, `.custom(UIImage)` |
| `AlertHaptic` | `.success`, `.warning`, `.error`, `.none`. `nil` skips `impact()`. `AlertHaptic.none` calls `impact()` and returns. A bare `.none` where the type is `AlertHaptic?` is `nil`, so this app spells the case out |
| `dismissByTap` / `dismissInTime` / `duration` | Read at present time. Defaults: tap on, timed on, duration 1.5. Spinners set both flags off inside `init` |
| `titleLabel` / `subtitleLabel` / `iconView` | Public optionals. The package README writes `titleLabel.font` without unwrapping. The stored type is `UILabel?`, so this app uses `?.` |
| `.alert(isPresent:view:completion:)` | SwiftUI modifier. While `isPresent` is true, `body` calls `present`. The wrapper completion sets the binding to `false`, then calls yours |
| `present(on:completion:)` / `dismiss()` | `AlertViewProtocol`. `AlertKitAPI` is the path this app uses, so it does not need a host `UIView` |

`AlertIconDoneView` and `AlertIconErrorView` conform to `AlertIconAnimatable`. Done strokes a check over 0.3s. Error strokes two lines over 0.22s. Heart is a static fill and does not conform, so `present` does not animate it. `AlertSpinnerView` is internal. It starts `UIActivityIndicatorView` in `init` (`.medium` or `.large`) and does not conform either. The center layout gives both spinner sizes a 16×16 box. The banner gives every icon a 20×20 box.

`duration` is read when the present animation finishes, and the dismiss is scheduled for that many seconds later. It is not read again. `dismissByTap` is read only while the gesture is being added. `haptic?.impact()` runs at the start of `present`.

`dismiss()` runs the completion stored by `present`. `dismissAllAlerts` does not. It calls the internal `dismiss(customCompletion:)` and passes its own completion to the first match only. `AlertAppleMusic16View` implements that method but does not declare the protocol, so a center alert stays up until its own `dismiss()` or its timer.

The modifier presents as a side effect of `body`. A later body pass while `isPresent` is still true presents again. This demo keeps the modifier on an `Equatable` anchor whose equality is `isPresent` plus the view identity, so slider changes do not present a second copy.

`defaultContentColor` in dark mode is rgb(127, 127, 129). This app does not assign that static property. **White ink** sets `titleLabel`, `subtitleLabel`, and `iconView` tint on the one view. **Title 21 pt** sets `titleLabel?.font = UIFont.systemFont(ofSize: 21)` before present. The spinner's indicator is internal, so tint on the container does not recolor it.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **API** | `AlertKitAPI.present(title:subtitle:icon:style:haptic:)`. **README sample** is the package sample: title "Added to Library", icon `.done`, style `.iOS17AppleMusic`, haptic `.success`, no subtitle. **Subtitle** passes `"Favorites"`. **Unset** passes haptic `nil`. **None** passes `AlertHaptic.none`. **Star** passes `.custom` with `UIImage(systemName: "star.fill")`. **Message** passes icon `nil`. **iOS 17** is the bottom banner. **iOS 16** is the center card. **Dismiss all** calls `dismissAllAlerts`. It removes banners. It does not remove center cards; those use the timer. An iOS 16 spinner from this call has no handle, so **Show** is disabled for that pair. |
| **View** | Builds `AlertAppleMusic17View` or `AlertAppleMusic16View`, then `AlertKitAPI.present(view:completion:)`. **Show** stays disabled until that view's `dismiss()` runs. Changing the icon writes the spinner defaults (both dismiss flags off, otherwise both on). The toggles then overwrite those properties. **Duration** is `0.4...4` and is written to `duration` (package default 1.5). **White ink** and **Title 21 pt** run before present. **Dismiss** calls `view.dismiss()`, which runs the present completion. **Dismiss all** uses `dismissAllAlerts` for a banner, because that path does not run the present completion, and calls `dismiss()` for a center view. |
| **Modifier** | Same view setup as View. **Show** sets `isPresent` and stores the view. The anchor's body calls `.alert(isPresent:view:completion:)`. The package sets the binding false, then the completion. **Dismiss** calls `view.dismiss()` so that completion runs. `dismissAllAlerts` is not the dismiss button here, because it would remove a banner without running the modifier completion. |
| **Leave the tab / family** | The surface disappears. API calls `dismissAllAlerts`. View and Modifier call `dismiss()` on the held view. A center alert presented from API is not held, so it stays until `duration` elapses. Gallery never presents. |

The sketch uses SF Symbols and materials. It is not the package's check, cross, heart, or blur.

### Gallery

Lazy grid of painted cards: the banner, the center card, the icon cases, haptics, dismiss rules, and which Live family calls which API. Chips name the cases. Nothing on the card presents an alert.

**Skipped:** `present(on:)` (same present path `AlertKitAPI` uses once it has a window), assigning `defaultContentColor`, and `AlertIconAnimatable.animate()` called by hand. The package calls `animate()` after the present animation when the icon view conforms. Heart and the spinners do not.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 17 simulator (this demo's floor; package floor is iOS 13)
- Network on first resolve for Swift Package `AlertKit` **5.1.10** (tag `5.1.10`, pin `b8f3dff07a75437ba26dbbffa62f303aaabfaec3`)
