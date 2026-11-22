# Textual

Dark SwiftUI playground for **[Textual](https://github.com/gonzalezreal/textual)** (`import Textual`, exact **0.5.0**, revision **01b51875**).

Product **`Textual` only**. The package manifest lists iOS 18, macOS 15, tvOS 18, watchOS 11, and visionOS 2. This app targets iOS 18, the same floor as the package and the sibling demos.

Tag `0.5.0` peels to `01b51875a5406eefc95f52a058cb059e7bc94dc4` (2026-06-15, "Enable link interaction in table"). Swift Package Manager requirement `exactVersion: 0.5.0` stays on that release. The library is MIT.

Two tabs:

- **Live** — a Markdown editor and one `StructuredText` preview. Style, canvas, overflow, highlighter, text selection, and math are live. Leaving the tab unmounts the preview. The editor draft stays.
- **Gallery** — frozen cards for headings, the GitHub preset, inline text, lists, quotes, code, a custom highlighter, tables, a catalog image, custom emoji, math, links, and a custom heading style. Text selection is off so the grid can scroll. Link taps return `.handled`.

Live chrome uses hardcoded light ink on a near-black page. The document canvas is separate, so a light preview cannot wash out the controls.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator, and this VM does not have a Swift toolchain, so nothing here was compiled.

1. Open `apps/textual-demo/Textual.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **Textual** scheme. Xcode resolves the remote Swift package `https://github.com/gonzalezreal/textual.git` at exact version `0.5.0`.

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/textual-demo
xcodegen generate
```

`PRODUCT_MODULE_NAME = TextualDemo` so the app module is not named `Textual` (the package product). Bundle id is `com.techdemos.textualdemo`. The home-screen name is **Textual**.

Keep the editor and the link readout on the Live tab. Gallery renders the same views with selection disabled and links handled. Leave the upstream example app (`Examples/TextualDemo`) out of this target.

## What Textual does

`StructuredText` lays out block Markdown: headings, paragraphs, lists, block quotes, thematic breaks, fenced code, tables, and math. `InlineText` is the flowing paragraph view. Both parse with Foundation's `AttributedString` Markdown parser (`AttributedStringMarkdownParser`) and then apply syntax extensions.

Images and custom emoji are attachments. This demo never hits the network. `resource://badge` and `resource://spark` resolve through `AttachmentLoader.image(named:)` and `AttachmentLoader.emoji(named:)` to images in the asset catalog. `:spark:` is an `Emoji` shortcode passed to `.emoji`.

Math is off until `.math` is in `syntaxExtensions`. `$...$` is inline, `$$...$$` is a block, and a fence tagged `math` is a math code block. `StructuredText` stores the parser and reparses when the markup string changes. Toggling math changes the parser, so Live sets `.id(mathEnabled)` to rebuild that view.

Links use SwiftUI's `openURL` environment. Live records the URL and returns `.handled`.

`StructuredText` ignores `.lineLimit` so a block cannot truncate the document. Body color is the surrounding `foregroundStyle`. Link, code, and highlighter colors come from the style.

| API | Role |
| --- | --- |
| `StructuredText(markdown:baseURL:syntaxExtensions:)` | Block document |
| `InlineText(markdown:baseURL:syntaxExtensions:)` | One flowing paragraph |
| `.textual.structuredTextStyle(_:)` | `.default` or `.gitHub` |
| `.textual.inlineStyle(_:)` | Code, emphasis, strong, link, strikethrough |
| `.textual.headingStyle(_:)` | Gallery's last card. Other block styles stay on the preset |
| `.textual.unorderedListMarker(_:)` / `.orderedListMarker(_:)` | Gallery lists: `.hierarchical(.disc, .circle, .square)` and `.lowerRoman` |
| `.textual.highlighterTheme(_:)` | `.default` (Prism tokens) or `.plain`. Gallery adds a small custom theme |
| `.textual.tableStyle` / `.tableCellStyle` | Included in the GitHub preset |
| `.textual.overflowMode(_:)` | `.scroll` (package default) or `.wrap` for code and tables |
| `.textual.textSelection(_:)` | `.enabled` or `.disabled`. Unavailable on tvOS and watchOS |
| `.textual.imageAttachmentLoader(_:)` / `.emojiAttachmentLoader(_:)` | Catalog lookup for `resource://` URLs |
| `.textual.emojiProperties(_:)` / `.mathProperties(_:)` | Font-relative emoji size, and math font / scale / alignment |
| `.textual.fontScale` / `.blockSpacing` / `.padding` | Font-relative layout, used by the custom heading style |
| `AttributedStringMarkdownParser.SyntaxExtension.emoji` / `.math` | Post-parse replacements |
| `Emoji(shortcode:url:)` | `:spark:` → `resource://spark` |
| `MathProperties.FontName` | Live uses `.latinModern`. Gallery uses `.fira` |

Other public math font names on 0.5.0: `.kpMathLight`, `.kpMathSans`, `.xits`, `.termes`, `.asana`, `.euler`, `.notoSans`, `.libertinus`, `.garamond`, `.leteSans`. Other ordered markers: `.decimal`, `.upperRoman`, `.upperAlpha`, `.lowerAlpha`. Other unordered markers: `.disc`, `.circle`, `.square`, `.dash`.

A thrown parse becomes an empty `AttributedString` (`try?` inside Textual). The preview goes blank until the markup parses again.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Editor** | The preview follows the draft. Reset restores the seed and does not leave the tab. |
| **Default / GitHub** | `.textual.structuredTextStyle`. GitHub draws rules under heading levels 1 and 2 and stripes the table. |
| **Dark / Light** | The document canvas and `colorScheme` change. Built-in `DynamicColor` values follow. Chrome stays dark. |
| **Scroll / Wrap** | `.textual.overflowMode` on the Swift fence and the table. Scroll pans the long comment. Wrap folds it. |
| **Tokens / Plain** | `.highlighterTheme(.default)` colors the Swift fence. `.plain` keeps the base code colors only. |
| **Select** | `.textual.textSelection(.enabled)` or `.disabled`. |
| **Math** | Adds or removes `.math`. Inline `$A = \pi r^2$`, the display integral, and no typesetting when the toggle is off. The font is Latin Modern, scale 1.2, centered. |
| **Package link** | `openURL` writes the URL into the readout. Nothing leaves the app. |
| **`:spark:` and the badge** | Catalog attachments. The spark is font-relative. The badge scales down to the column width. |
| **Leave the tab** | `StructuredText` unmounts. The editor text remains. Gallery never attaches the live link readout. |

### Gallery

Lazy grid of static cards. Chips name the APIs. Selection is `.disabled`. Every link returns `.handled`.

**Skipped:** a custom `MarkupParser`, `URLAttachmentLoader` (network, GIF, APNG, WebP), the deprecated `patternOptions` initializers, a full custom `StructuredText.Style`, calling `CodeBlockProxy.copyToPasteboard()` directly, `listItemSpacing` and document-level `fontScale` as knobs, and the upstream `Examples/TextualDemo` app. `tableBackground` / `tableOverlay` are how `GitHubTableStyle` draws; this app does not reimplement that style.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (package floor is iOS 18)
- Network on first resolve for Swift Package `Textual` **0.5.0** (tag `0.5.0`, pin `01b51875a5406eefc95f52a058cb059e7bc94dc4`)

Textual 0.5.0 also depends on `swift-concurrency-extras` and `swiftui-math` for the library target. Xcode records those transitive pins in `Package.resolved` on first resolve. The committed file pins Textual itself.
