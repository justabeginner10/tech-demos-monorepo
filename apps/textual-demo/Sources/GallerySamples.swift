import SwiftUI
import Textual

/// One frozen card per surface. Live owns the editor, the style toggles, and the link readout.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case headings
    case gitHub
    case inline
    case lists
    case quote
    case code
    case highlighter
    case table
    case image
    case emoji
    case math
    case links
    case customHeading

    var id: String { rawValue }

    var title: String {
        switch self {
        case .headings: "Headings"
        case .gitHub: "GitHub"
        case .inline: "Inline"
        case .lists: "Lists"
        case .quote: "Quote"
        case .code: "Code"
        case .highlighter: "Highlighter"
        case .table: "Table"
        case .image: "Image"
        case .emoji: "Emoji"
        case .math: "Math"
        case .links: "Links"
        case .customHeading: "Heading style"
        }
    }

    var subtitle: String {
        switch self {
        case .headings: "DefaultStyle"
        case .gitHub: "GitHubStyle · light"
        case .inline: "InlineText · InlineStyle"
        case .lists: "Markers"
        case .quote: "Block quote · rule"
        case .code: "HighlighterTheme.default"
        case .highlighter: "Custom tokens"
        case .table: "GitHub table"
        case .image: "resource://badge"
        case .emoji: ":spark:"
        case .math: "Fira · leading"
        case .links: "openURL · handled"
        case .customHeading: "HeadingStyle"
        }
    }

    var chips: [String] {
        switch self {
        case .headings:
            ["StructuredText", ".default", "h1–h3"]
        case .gitHub:
            [".gitHub", "DynamicColor", "light"]
        case .inline:
            ["InlineText", "inlineStyle", "emoji"]
        case .lists:
            ["hierarchical", "lowerRoman"]
        case .quote:
            ["blockQuote", "thematicBreak"]
        case .code:
            ["```swift", ".default", "scroll"]
        case .highlighter:
            ["keyword", "string-literal", "comment"]
        case .table:
            ["tableStyle", ".gitHub"]
        case .image:
            ["image(named:)", "badge"]
        case .emoji:
            ["SyntaxExtension.emoji", "emojiProperties"]
        case .math:
            [".math", "MathProperties", "fira"]
        case .links:
            ["openURL", ".handled"]
        case .customHeading:
            ["headingStyle", "fontScale", "Divider"]
        }
    }

    @ViewBuilder
    var preview: some View {
        VStack(alignment: .leading, spacing: 8) {
            snapshot
            chipRow
        }
    }

    @ViewBuilder
    private var snapshot: some View {
        switch self {
        case .headings:
            HeadingsCard()
        case .gitHub:
            GitHubCard()
        case .inline:
            InlineCard()
        case .lists:
            ListsCard()
        case .quote:
            QuoteCard()
        case .code:
            CodeCard()
        case .highlighter:
            HighlighterCard()
        case .table:
            TableCard()
        case .image:
            ImageCard()
        case .emoji:
            EmojiCard()
        case .math:
            MathCard()
        case .links:
            LinksCard()
        case .customHeading:
            CustomHeadingCard()
        }
    }

    private var chipRow: some View {
        HStack(spacing: 6) {
            ForEach(chips, id: \.self) { label in
                DemoChrome.chip(label)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

private struct SampleFrame<Content: View>: View {
    var canvas: PreviewCanvas
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .font(.body)
            .foregroundStyle(canvas.ink)
            .environment(\.colorScheme, canvas.colorScheme)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(canvas.page, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private extension View {
    func galleryQuiet() -> some View {
        self
            .textual.textSelection(.disabled)
            .environment(\.openURL, OpenURLAction { _ in .handled })
    }
}

/// H1 underline from the Textual 0.5.0 README, applied over `.default`.
private struct UnderlineHeadingStyle: StructuredText.HeadingStyle {
    private static let fontScales: [CGFloat] = [2, 1.5, 1.25, 1, 0.875, 0.85]

    func makeBody(configuration: Configuration) -> some View {
        let headingLevel = min(configuration.headingLevel, 6)
        let fontScale = Self.fontScales[headingLevel - 1]

        VStack(alignment: .leading, spacing: 0) {
            configuration.label
                .textual.fontScale(fontScale)
                .fontWeight(.semibold)

            if headingLevel == 1 {
                Divider()
                    .textual.padding(.top, .fontScaled(0.25))
            }
        }
        .textual.blockSpacing(.fontScaled(top: 1.5, bottom: 0.5))
    }
}

private enum MintCodeTheme {
    typealias Token = StructuredText.HighlighterTheme.TokenType

    static let theme = StructuredText.HighlighterTheme(
        foregroundColor: DynamicColor(
            light: Color(red: 0.07, green: 0.16, blue: 0.14),
            dark: Color(red: 0.86, green: 0.96, blue: 0.90)
        ),
        backgroundColor: DynamicColor(
            light: Color(red: 0.90, green: 0.96, blue: 0.93),
            dark: Color(red: 0.08, green: 0.16, blue: 0.13)
        ),
        tokenProperties: [
            Token.keyword: AnyTextProperty(
                .foregroundColor(Color(red: 0.05, green: 0.45, blue: 0.32)),
                .fontWeight(.semibold)
            ),
            Token.comment: AnyTextProperty(
                .foregroundColor(Color(red: 0.32, green: 0.42, blue: 0.36)),
                .italic
            ),
            Token.function: AnyTextProperty(
                .foregroundColor(Color(red: 0.10, green: 0.35, blue: 0.55))
            ),
            Token(rawValue: "string-literal"): AnyTextProperty(
                .foregroundColor(Color(red: 0.55, green: 0.28, blue: 0.08))
            ),
        ]
    )
}

private struct HeadingsCard: View {
    var body: some View {
        SampleFrame(canvas: .dark) {
            StructuredText(
                markdown: """
                # A calm start
                Paragraph under the first heading.

                ## Then the next size
                Still the default heading style.

                ### Third level
                Six levels exist. This card stops at three.
                """
            )
            .textual.structuredTextStyle(.default)
            .galleryQuiet()
        }
    }
}

private struct GitHubCard: View {
    var body: some View {
        SampleFrame(canvas: .light) {
            StructuredText(
                markdown: """
                # A calm start
                Paragraph under the first heading.

                ## Then the next size
                GitHub headings draw a rule under the first two levels.

                ### Third level
                Body color follows the light canvas.
                """
            )
            .textual.structuredTextStyle(.gitHub)
            .galleryQuiet()
        }
    }
}

private struct InlineCard: View {
    var body: some View {
        SampleFrame(canvas: .dark) {
            InlineText(
                markdown: "Use `git status` to check _uncommitted changes_, **ship** the [Textual](https://github.com/gonzalezreal/textual) release, and drop ~~the old plan~~ :spark:.",
                syntaxExtensions: [.emoji(DemoAttachments.emoji)]
            )
            .textual.inlineStyle(DemoInline.custom)
            .textual.emojiProperties(DemoEmojiMetrics.inline)
            .demoResourceAttachments()
            .galleryQuiet()
        }
    }
}

private struct ListsCard: View {
    var body: some View {
        SampleFrame(canvas: .dark) {
            StructuredText(
                markdown: """
                Nested markers change with indentation.

                - Open the project
                - Skim the diff
                  - Re-read the parser
                    - Then the styles
                - Commit

                1. Identify the block
                2. Pick a marker
                3. Leave the numbers as letters
                """
            )
            .textual.structuredTextStyle(.default)
            .textual.unorderedListMarker(.hierarchical(.disc, .circle, .square))
            .textual.orderedListMarker(.lowerRoman)
            .galleryQuiet()
        }
    }
}

private struct QuoteCard: View {
    var body: some View {
        SampleFrame(canvas: .dark) {
            StructuredText(
                markdown: """
                > Pin the package to the 0.5.0 tag. The quote bar comes from the block quote style.

                ---

                The rule under the quote is a thematic break.
                """
            )
            .textual.structuredTextStyle(.default)
            .galleryQuiet()
        }
    }
}

private struct CodeCard: View {
    private let markdown = #"""
    A fenced Swift block uses the bundled Prism grammar.

    ```swift
    func makeItWork(_ value: Int?) -> Int {
        guard let value else {
            return 42 // fallback when the optional is empty
        }
        return value * 2
    }
    ```
    """#

    var body: some View {
        SampleFrame(canvas: .dark) {
            StructuredText(markdown: markdown)
                .textual.structuredTextStyle(.default)
                .textual.highlighterTheme(.default)
                .textual.overflowMode(.scroll)
                .galleryQuiet()
        }
    }
}

private struct HighlighterCard: View {
    private let markdown = #"""
    Same fence, custom `HighlighterTheme`. Prism Swift emits `string-literal`.

    ```swift
    let greeting = "hello" // comment
    func ship() {}
    ```
    """#

    var body: some View {
        SampleFrame(canvas: .dark) {
            StructuredText(markdown: markdown)
                .textual.structuredTextStyle(.default)
                .textual.highlighterTheme(MintCodeTheme.theme)
                .textual.overflowMode(.wrap)
                .galleryQuiet()
        }
    }
}

private struct TableCard: View {
    var body: some View {
        SampleFrame(canvas: .dark) {
            StructuredText(
                markdown: """
                A short status board.

                | Area | Status | Notes |
                | --- | --- | --- |
                | Build | Passing | Swift 6 |
                | Styles | Two presets | Default and GitHub |
                | Images | Local | Asset catalog |
                """
            )
            .textual.structuredTextStyle(.gitHub)
            .textual.overflowMode(.scroll)
            .galleryQuiet()
        }
    }
}

private struct ImageCard: View {
    var body: some View {
        SampleFrame(canvas: .dark) {
            StructuredText(
                markdown: """
                The badge URL is `resource://badge`.

                ![Textual badge](resource://badge)
                """
            )
            .textual.structuredTextStyle(.default)
            .demoResourceAttachments()
            .galleryQuiet()
        }
    }
}

private struct EmojiCard: View {
    var body: some View {
        SampleFrame(canvas: .dark) {
            StructuredText(
                markdown: "Shipped :spark: from the asset catalog. The shortcode is `spark`.",
                syntaxExtensions: [.emoji(DemoAttachments.emoji)]
            )
            .textual.structuredTextStyle(.default)
            .textual.emojiProperties(DemoEmojiMetrics.large)
            .demoResourceAttachments()
            .galleryQuiet()
        }
    }
}

private struct MathCard: View {
    private let markdown = #"""
    Inline $E = mc^2$, a display equation, and a math fence.

    $$
    \int_{0}^{1} x^2\,dx = \frac{1}{3}
    $$

    ```math
    a^2 + b^2 = c^2
    ```
    """#

    var body: some View {
        SampleFrame(canvas: .dark) {
            StructuredText(markdown: markdown, syntaxExtensions: [.math])
                .textual.structuredTextStyle(.default)
                .textual.mathProperties(DemoMath.fira)
                .galleryQuiet()
        }
    }
}

private struct LinksCard: View {
    var body: some View {
        SampleFrame(canvas: .dark) {
            StructuredText(
                markdown: "Open [Textual](https://github.com/gonzalezreal/textual). This card handles the URL and stays put."
            )
            .textual.structuredTextStyle(.gitHub)
            .galleryQuiet()
        }
    }
}

private struct CustomHeadingCard: View {
    var body: some View {
        SampleFrame(canvas: .dark) {
            StructuredText(
                markdown: """
                # Underlined
                The first level keeps the README underline.

                ## Plain
                Lower levels skip the rule.
                """
            )
            .textual.structuredTextStyle(.default)
            .textual.headingStyle(UnderlineHeadingStyle())
            .galleryQuiet()
        }
    }
}
