# RichTextKit

SwiftUI playground for **[RichTextKit](https://github.com/danielsaidi/RichTextKit)** (`import RichTextKit`, from **1.2.0**, git tag **1.2**, commit **8aa44cf**).

Product **`RichTextKit` only**. `Package.swift` at that tag (`swift-tools-version: 5.9`) declares iOS 15, macOS 12, tvOS 15, watchOS 8, and visionOS 1. The app targets iOS 17. The package does not set `swiftLanguageVersions`. `MockingKit` is a test-only dependency.

Tag `1.2` is a lightweight tag. `git ls-remote --tags` shows `refs/tags/1.2` pointing at commit `8aa44cfa645404ad84e52e3ab7723ecf4b82f92b` (2025-04-18, "Add trailing whitespace ignore to SwiftLint") and there is no `refs/tags/1.2^{}` peel. That tag is also the latest GitHub Release (published 2025-04-18). The previous release is 1.1.2. Swift Package Manager accepts the two-component tag as version **1.2.0**. Requirement `from: 1.2.0` resolves that revision.

`main` (`0caef55`) is 13 commits ahead of the tag and those commits edit `Sources/`. This demo is written against tag `1.2`, not `main`.

The public surface this demo calls was read from `Sources/` at that commit.

Two tabs:

- **Live** — picker among Editor, Format, and Preview. Editor and Format share one `RichTextEditor`. Preview replaces it with a `RichTextViewer`.
- **Gallery** — three `RichTextViewer` cards. No editable `RichTextEditor`.

Chrome uses semantic grouped backgrounds and primary / secondary ink. The text view sits on white paper. Seeded strings use dark ink so they stay readable on that paper in light and dark.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. The Simulator build, screenshots, and video are still to be done on Aditya's Mac. A Linux VM cannot run the Simulator. This app was not compiled for iOS and was not run.

What was checked here:

- `swiftc -parse` (Swift 6.0.3) accepted the seven app sources.
- `swift package resolve` of requirement `from: 1.2.0` selected version `1.2.0` (`8aa44cfa645404ad84e52e3ab7723ecf4b82f92b`), which is git tag `1.2`. That pin is the checked-in `Package.resolved`.
- Call sites were checked against the package source at that commit (initializers, config structs, and the keyboard / format / viewer types). That is not an iOS build of this app.

1. Open `apps/rich-text-kit/RichTextKit.xcodeproj` in Xcode 16+ (iOS 17 SDK).
2. Pick an iPhone simulator.
3. Run the **RichTextKit** scheme. Xcode resolves the remote Swift package `https://github.com/danielsaidi/RichTextKit.git` (from 1.2.0 / tag `1.2`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/rich-text-kit
xcodegen generate
```

`PRODUCT_MODULE_NAME = RichTextKitDemo` so the app module is not named `RichTextKit` (the package product). Bundle id is `com.techdemos.richtextkit`. The home-screen name is **RichTextKit**.

Do not vendor the package source. Do not clone the package `Demo` target.

## What RichTextKit does

A `RichTextEditor` wraps a platform text view. It takes a `Binding<NSAttributedString>`, a `RichTextContext`, a `RichTextDataFormat` (this app passes `.archivedData`), and a view-configuration closure. The comment on the type says writing the binding from outside does not refresh a mounted editor. `RichTextContext.setAttributedString(to:)` publishes `.setAttributedString`, and the coordinator applies that to the text view.

`RichTextViewer` is the read-only path. `init(_: NSAttributedString)` builds a context, sets `isEditable = false`, and hosts a `RichTextEditor` with a constant binding. `updateUIView` is empty, so a viewer does not pick up later edits unless SwiftUI recreates it.

`RichTextView.setup(_:)` returns before applying `theme.backgroundColor` when the string is not empty. This app sets `textContentInset` and `UITextView.backgroundColor` in the editor's view configuration. The viewer has no configuration closure, so gallery cards rely on the white paper behind the default text view.

| API | Role |
| --- | --- |
| `RichTextEditor(text:context:format:viewConfiguration:)` | Editable view. Format default is `.archivedData` |
| `RichTextContext` | `ObservableObject`. `init()` is empty. `handle(_:)` sends a `RichTextAction` |
| `RichTextContext.setAttributedString(to:)` | Replaces the text view's string. Plain `String` overload wraps `NSAttributedString` |
| `canUndoLatestChange` / `canRedoLatestChange` | Published from the text view's undo manager after a sync |
| `RichTextAction.undo` / `.redo` | Aliases of `.undoLatestChange` and `.redoLatestChange` |
| `RichTextAction.Button(action:context:)` | Button. Disabled when `canHandle` is false |
| `RichTextKeyboardToolbar(context:leadingButtons:trailingButtons:formatSheet:)` | Sits under the editor. Return `$0` to keep the standard buttons and sheet |
| `RichTextKeyboardToolbarConfig` | `alwaysDisplayToolbar`, `displayFormatSheetButton`, `leadingActions` (default undo/redo), `trailingActions` (default dismiss) |
| `RichTextFormat.Toolbar(context:)` | Styles, size, alignment, indent, and the configured color pickers |
| `RichTextFormat.Sheet(context:)` | `RichTextFont.ListPicker` plus a format toolbar. iOS uses a stack navigation view |
| `RichTextFormat.Sidebar(context:)` | Same controls in a column. Compiled for iOS. The type comment says it is aimed at macOS and iPad |
| `RichTextFormat.ToolbarConfig` | `alignments` defaults to `NSTextAlignment.defaultPickerValues` (left, center, right, justified). `styles` defaults to `.all` |
| `RichTextStyle` | `.bold`, `.italic`, `.underlined`, `.strikethrough` |
| `RichTextColor` | `.foreground`, `.background`, `.strikethrough`, `.stroke`, `.underline` |
| `RichTextFont.SizePicker` / `.ListPicker` | Size menu and the font list inside the format sheet |
| `RichTextViewer(_:)` | `String` or `NSAttributedString`. Editing is off |

On a compact width the keyboard toolbar hides the style toggles and the alignment picker (`keyboardShortcutsOnly(if: isCompact)`). `RichTextFont.SizePickerStack` on that toolbar is always shortcut-only. The format toolbar is what shows bold, italic, underline, strikethrough, size, alignment, and colors on iPhone. The format-sheet button is `displayFormatSheetButton`.

`ToolbarConfig` forces `superscriptButtons` to `false` when the platform is not macOS. This app passes `false`. `lineSpacingPicker` stays `false` because the sidebar's line-spacing control is `RichTextLine.SpacingPickerStack`, and `RichTextLine` is deprecated at this tag.

The undo stack belongs to the mounted text view. Leaving Live, or switching to Preview, drops that view and the stack with it. **Restore sample** assigns the binding and calls `setAttributedString(to:)`.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Editor** | Seeded note: bold title, italic, underline, strikethrough, a centered Georgia line, a right-aligned line with a background wash. The format toolbar edits the selection. The keyboard toolbar shows undo, redo, the format sheet, and dismiss. **Keep keyboard toolbar visible** sets `alwaysDisplayToolbar`. The chips read `fontName`, `fontSize`, and the undo flags after the text view syncs |
| **Format** | Same editor. `.inspector` presents `RichTextFormat.Sidebar`. Dismissing the inspector returns to Editor. **Format sheet** presents `RichTextFormat.Sheet`, which is where `RichTextFont.ListPicker` lives |
| **Preview** | `RichTextViewer` of the current string. The editor is not in the hierarchy |
| **Restore sample** | Puts the Harbor note back through `setAttributedString(to:)` |
| **Leave the tab** | The editor unmounts. Gallery viewers unmount when Live is open |

### Gallery

Lazy grid of Harbor, Field note, and Margin. Each card is a `RichTextViewer`. Chips name the styles in that string.

**Skipped:** image paste, PDF and file export, share menus, `RichTextCommand` menu commands, `.print` (`canHandle` is false), `RichTextAlignment`, `RichTextLine`, and superscript (the toolbar config turns it off on iOS). The package Demo app is not copied in.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 17 simulator (this demo's floor; package floor is iOS 15)
- Network on first resolve for Swift Package `RichTextKit` **1.2.0** (tag `1.2`, pin `8aa44cfa645404ad84e52e3ab7723ecf4b82f92b`)
