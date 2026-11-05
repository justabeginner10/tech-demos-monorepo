# WhatsNewKit

SwiftUI playground for **[WhatsNewKit](https://github.com/SvenTiigi/WhatsNewKit)** (`import WhatsNewKit`, from **2.2.1**, tag **2.2.1**, commit **6157c77**).

Product **`WhatsNewKit` only**. `Package.swift` at that tag (`swift-tools-version: 5.9`) declares iOS 13, macOS 11, and visionOS 1. The app targets iOS 17. The package does not set `swiftLanguageVersions`.

Tag `2.2.1` is a lightweight tag. `git ls-remote --tags` shows `refs/tags/2.2.1` pointing at commit `6157c77e8be9b3d2310bc680681b61a8d9e290ac` (2024-04-30, "Added PrivacyInfo.xcprivacy") and there is no `refs/tags/2.2.1^{}` peel. That tag is also the latest GitHub Release. The previous release is 2.2.0. Swift Package Manager requirement `from: 2.2.1` resolves the tag.

The public surface this demo calls was read from `Sources/` at that commit. Haptic cases are compiled only for iOS (not visionOS). This app is iOS, so those cases are available.

Two tabs:

- **Live** — picker among Automatic, Manual, and View. Only the selected family presents. Switching family or leaving the tab clears the manual and view sheets. The automatic host is mounted only while Automatic is selected and Live is visible.
- **Gallery** — frozen painted cards. No `.whatsNewSheet`, no `.sheet(whatsNew:)`, no `WhatsNewView`, no `WhatsNewViewController`.

Chrome uses semantic grouped backgrounds and primary / secondary ink so labels stay readable in light and dark.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. The Simulator build, screenshots, and video are still to be done on Aditya's Mac. A Linux VM cannot run the Simulator. This app was not compiled for iOS and was not run.

What was checked here:

- `swiftc -parse` (Swift 6.0.3) accepted the seven app sources.
- `swift package resolve` of requirement `from: 2.2.1` selected tag `2.2.1` (`6157c77e8be9b3d2310bc680681b61a8d9e290ac`). That pin is the checked-in `Package.resolved`.
- With `#Preview` removed, the sources were typechecked against stand-in SwiftUI, UIKit, and WhatsNewKit modules. WhatsNewKit signatures in that stand-in were copied from tag `2.2.1`. The stand-in `ViewBuilder` does not lower `if let` the way SwiftUI does, so the painted secondary-button branch in the gallery is the one diagnostic that check still reports. The WhatsNewKit call sites typechecked. That is not an iOS build of this app.

1. Open `apps/whats-new-kit/WhatsNewKit.xcodeproj` in Xcode 16+ (iOS 17 SDK).
2. Pick an iPhone simulator.
3. Run the **WhatsNewKit** scheme. Xcode resolves the remote Swift package `https://github.com/SvenTiigi/WhatsNewKit.git` (from 2.2.1 / tag `2.2.1`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/whats-new-kit
xcodegen generate
```

`PRODUCT_MODULE_NAME = WhatsNewKitDemo` so the app module is not named `WhatsNewKit` (the package product). Bundle id is `com.techdemos.whatsnewkit`. The home-screen name is **WhatsNewKit**. `MARKETING_VERSION` is `1.0`, so `WhatsNew.Version.current()` reads `1.0.0`. The automatic playground passes its own `currentVersion` and does not use the bundle version.

Do not vendor the package source. Do not clone `Example/Example.xcodeproj`.

## What WhatsNewKit does

A `WhatsNew` value is a version, a title, feature rows, a primary button, and an optional secondary button. `WhatsNewView` draws it. The sheet modifiers present that view. A version store remembers what has already been shown.

| API | Role |
| --- | --- |
| `.sheet(whatsNew:versionStore:layout:onDismiss:)` | Manual presentation. `versionStore` nil always presents. A non-nil store that already `hasPresented` the version shows the content and does not present |
| `.whatsNewSheet(layout:onDismiss:)` | Automatic presentation. Reads `WhatsNewEnvironment.whatsNew()` from the environment. After dismiss, an internal flag stays set until the modifier's view is recreated |
| `\.whatsNew` | `EnvironmentValues` key. The value is a `WhatsNewEnvironment` |
| `WhatsNewEnvironment` | `currentVersion`, `whatsNewVersionStore`, `defaultLayout`, `whatsNewCollection`. `whatsNew()` is `open` |
| `WhatsNewCollection` | `[WhatsNew]`. The result builder is `WhatsNewCollectionBuilder` |
| `UserDefaultsWhatsNewVersionStore` | Saves `version.description` under the key `WhatsNewKit.<version>`. `remove(presentedVersion:)` and `removeAll()` are on this type, not on the protocol |
| `InMemoryWhatsNewVersionStore` | A class. `versions` is a `Set`. Same `remove` / `removeAll` |
| `NSUbiquitousKeyValueWhatsNewVersionStore` | iCloud key-value store. `CloudKitWhatsNewVersionStore` is a typealias. Needs the iCloud key-value capability. This app does not construct it |
| `WhatsNew.Version` | `major` / `minor` / `patch`, string literal, or `.current(in:)` from `CFBundleShortVersionString`. Comparable, Hashable |
| `WhatsNew.Title` | `text` is `WhatsNew.Text`. `foregroundColor` defaults to `.primary`. The view at this tag does not read `foregroundColor` |
| `WhatsNew.Text` | Wraps `NSAttributedString`. `init(_ string:)`, plus iOS 15 `init(_ attributedString: AttributedString)` |
| `WhatsNew.Feature` | `image`, `title`, `subtitle`. Hashable uses title and subtitle only. The list's `ForEach` identifies rows that way |
| `WhatsNew.Feature.Image` | View builder, `init(image:)`, `init(name:bundle:renderingMode:foregroundColor:)`, `init(systemName:renderingMode:foregroundColor:)`, and the iOS 15 symbol-rendering overload |
| `WhatsNew.PrimaryAction` | Title, colors, optional haptic, `onDismiss`. The button calls haptic, then `dismiss()`, then `onDismiss` |
| `WhatsNew.SecondaryAction.Action` | `.present`, `.custom`, `.openURL(_:)`, `.dismiss`. `.dismiss` only dismisses. It does not run the primary `onDismiss` |
| `WhatsNew.HapticFeedback` | `.impact(style:intensity:)`, `.selection`, `.notification(_:)`. iOS only. Call-as-function runs the generator |
| `WhatsNew.Layout` | Spacing, padding, image width, scroll indicators, button radius. `static var default` is mutable. `reset()` assigns `self = .init()`, not `.default` |
| `WhatsNewView` | The SwiftUI screen. `onDisappear` saves `whatsNew.version` when a store was passed |
| `WhatsNewViewController` | `UIHostingController` subclass. The failable init returns nil when the store has already presented that version, and it passes the store through so dismiss saves. The non-failable init does not take a store and does not save |

`whatsNew()` walks the store in this order: if `currentVersion` is already stored, return nil. Else return the collection item whose version equals `currentVersion`. Else, if the same major.minor with patch 0 is not stored, return that item. A presented `1.0.0` does not block `2.2.0`. A presented `2.2.0` does block current `2.2.1`, because the fallback version is `2.2.0`. The view saves the `WhatsNew.version` it displayed, so the fallback writes `2.2.0`, not `2.2.1`.

The automatic collection in this app is `1.0.0` and `2.2.0`, built with `WhatsNewCollectionBuilder`. Manual presets use `1.1.0` (Harbor), `1.2.0` (Atelier), and `2.0.0` (Signal) so they do not share keys with the automatic sheet. Both UserDefaults-backed paths use suite `com.techdemos.whatsnewkit`.

Leaving the tab while a `WhatsNewView` is up runs `onDisappear`, which saves when a store is attached. Dismiss the sheet with its button before Reset if you want to watch the key appear first. Reset calls `removeAll()` on both stores and remounts the automatic host (`.id`) so the modifier's dismiss flag is cleared.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Automatic** | Installed version `1.0.0` or `2.2.0` presents that entry. `2.2.1` presents the `2.2.0` entry until `2.2.0` is stored. `3.0.0` presents nothing. The status line is `whatsNew()` plus the same checks the method makes. **Remove resolved version** deletes the stored version that is blocking the sheet, then remounts. **Reset stored versions** calls `removeAll()` on the UserDefaults suite and the memory store |
| **Manual** | Harbor opens the package URL (`.openURL`) and uses `.notification(.success)`. Atelier's title and one subtitle go through `AttributedString` markdown, and **Release notes** is `.present`. Signal's title colors the word Signal with an attributed run, sets `Title.foregroundColor` (the view does not apply that property), and **Remind me** is `.custom` so the sheet stays up and the tap count increments. **Show sheet** is refused when the selected store already has the preset version. **Off** passes `versionStore: nil` |
| **View** | **Show WhatsNewView** presents `WhatsNewView` in a SwiftUI sheet. It does not consult `hasPresented` before showing. **Controller if new** uses the failable `WhatsNewViewController` init. **Controller anyway** uses the non-failable init, so it does not write the store |
| **Layout** | Sliders and the scroll-indicator toggle build a `WhatsNew.Layout` passed into the active presentation. **Package layout defaults** mutates a local layout, calls `reset()`, and copies the fields back. It does not assign `Layout.default` |
| **Versions** | Chips list `presentedVersions` from each store. The suite name is `com.techdemos.whatsnewkit` |
| **Leave the tab / family** | Manual and view bindings clear. The automatic host unmounts, which dismisses its sheet |

The sketch under Manual is SwiftUI paint. The sheet behind **Show sheet** is the package view.

### Gallery

Lazy grid of painted cards: the automatic sheet, Harbor, Atelier, Signal, a wider layout, and the three stores. Chips name the APIs. Nothing on the card presents a sheet.

**Skipped:** `WhatsNew.Feature.Image` named-asset init (no image in the catalog), `NSUbiquitousKeyValueWhatsNewVersionStore` (needs the iCloud capability), assigning `WhatsNew.Layout.default`, subclassing `WhatsNewEnvironment`, and `Action.dismiss` (it only calls `presentationMode.wrappedValue.dismiss()`). The official Example app is not copied in.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 17 simulator (this demo's floor; package floor is iOS 13)
- Network on first resolve for Swift Package `WhatsNewKit` **2.2.1** (tag `2.2.1`, pin `6157c77e8be9b3d2310bc680681b61a8d9e290ac`)
