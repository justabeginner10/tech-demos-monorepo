# Enriched Markdown

Dark SwiftUI playground for **[enriched-markdown-ios](https://github.com/software-mansion-labs/enriched-markdown-ios)** (`import EnrichedMarkdown` + `import EnrichedMarkdownLaTeX`, from **0.1.0**, tagged **0.3.0**, revision **b5e6da7**).

Products **`EnrichedMarkdown`** and **`EnrichedMarkdownLaTeX`**. Without the LaTeX product, `$…$` stays plain text. Package floor is iOS 16; this app targets iOS 18 to match sibling demos.

Two tabs:

- **Live** — one scrollable `EnrichedMarkdownText`. Paper / Ink restyle it. Spoilers reveal on tap; task boxes toggle and report through `onTaskListItemPress`; links report through `onLinkPress`.
- **Gallery** — the same short card in Paper, Ink, and `MarkdownTheme.default`, plus SwiftUI `Text` on that source. Task toggles are off.

Live chrome uses hardcoded light ink on a near-black page so a light Paper document cannot wash out labels. Document text itself is high-contrast in both themes.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on a Mac as a follow-up. A Linux VM cannot run the Simulator.

1. Open `apps/enriched-markdown/EnrichedMarkdown.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **EnrichedMarkdown** scheme. Xcode resolves the remote Swift package `https://github.com/software-mansion-labs/enriched-markdown-ios.git` (from 0.1.0 / tag `0.3.0`) and the RaTeX binary used by `EnrichedMarkdownLaTeX`.

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/enriched-markdown
xcodegen generate
```

`PRODUCT_MODULE_NAME = EnrichedMarkdownDemo` so the app module is not named `EnrichedMarkdown` (the package product). Bundle id is `com.techdemos.enrichedmarkdown`.

Do not vendor the package source. Images are data URLs; the simulator does not need the network after the package resolve.

## What Enriched Markdown does

`EnrichedMarkdownText` paints native text — not a WebView, and not SwiftUI `Text(markdown)`. GFM tables, task lists, spoilers, GitHub alerts, highlight / super / subscript / underline, and (with the LaTeX product) typeset math are first-class.

| API | Role |
| --- | --- |
| `EnrichedMarkdownText(_:flags:)` | Render markdown with `Md4cFlags` |
| `Md4cFlags` | underline, superscript, subscript, highlight, admonitions |
| `.markdownTheme` | Layer a `MarkdownTheme` builder |
| `.markdownLaTeX()` | Parse and typeset `$…$` / `$$…$$` |
| `.onTaskListItemPress` | Checkbox tap: index, new checked state, text |
| `.onLinkPress` | Tappable links |
| `.markdownSpoilerOverlay` | `.particles` (default) or `.solid` |
| `Admonition(.note)` … | GitHub alerts (`> [!NOTE]`) |
| `MathBlock()` / `InlineMath()` | LaTeX theme elements |

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Paper / Ink** | The same document restyles. Paper is cream + dark ink; Ink is near-black + light ink. |
| **Particles / Solid** | `\|\|spoiler\|\|` overlay. Tap the concealed span to reveal. |
| **Checkboxes** | Visual toggle. The event row shows `index · checked · text`. The markdown string is not mutated. |
| **Package link** | `onLinkPress` writes the URL into the event row. Nothing leaves the app. |
| **Math** | Inline $E=mc^2$ and a display Gaussian integral. Needs `EnrichedMarkdownLaTeX`. |
| **Leave the tab** | Live `EnrichedMarkdownText` unmounts. Gallery never attaches the live handlers. |

### Gallery

Lazy grid of static cards: Paper, Ink, library default, and SwiftUI `Text` on the same source. Chips name the APIs. Task-list taps are inert (`markdownTaskListItemToggleEnabled(false)`).

**Skipped:** custom `SpoilerOverlayProvider`, `markdownImageRequestHeaders`, `markdownSelectionMenu`, `rememberMarkdownTheme`, `MarkdownRenderer.renderLaTeX` outside SwiftUI.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the Minted / Foldy / Rehearsal demos; package floor is iOS 16)
- Network on first resolve for Swift Package `EnrichedMarkdown` **0.1.0+** (tagged `0.3.0`, pin `b5e6da71d9197842b242e4a0096d63d249bf364a`) and the RaTeX xcframework
