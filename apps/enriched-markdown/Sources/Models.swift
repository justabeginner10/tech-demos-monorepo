import EnrichedMarkdown
import EnrichedMarkdownLaTeX
import SwiftUI

/// Light Paper and dark Ink. Explicit colors so text stays readable in both.
enum DocumentTheme: String, CaseIterable, Identifiable {
    case paper
    case ink

    var id: String { rawValue }

    var title: String {
        switch self {
        case .paper: "Paper"
        case .ink: "Ink"
        }
    }

    var subtitle: String {
        switch self {
        case .paper: "Light · MarkdownTheme"
        case .ink: "Dark · MarkdownTheme"
        }
    }

    var colorScheme: ColorScheme {
        switch self {
        case .paper: .light
        case .ink: .dark
        }
    }

    var page: Color {
        switch self {
        case .paper: Color(red: 250 / 255, green: 247 / 255, blue: 240 / 255)
        case .ink: Color(red: 12 / 255, green: 14 / 255, blue: 18 / 255)
        }
    }

    var markdown: MarkdownTheme {
        switch self {
        case .paper: Self.paperTheme
        case .ink: Self.inkTheme
        }
    }

    private static let paperInk = Color(red: 17 / 255, green: 24 / 255, blue: 39 / 255)
    private static let paperMuted = Color(red: 55 / 255, green: 65 / 255, blue: 81 / 255)
    private static let paperLink = Color(red: 29 / 255, green: 78 / 255, blue: 216 / 255)
    private static let paperMark = Color(red: 254 / 255, green: 240 / 255, blue: 138 / 255)
    private static let paperCode = Color(red: 15 / 255, green: 23 / 255, blue: 42 / 255)
    private static let paperCodeBg = Color(red: 226 / 255, green: 232 / 255, blue: 240 / 255)
    private static let paperFence = Color(red: 248 / 255, green: 250 / 255, blue: 252 / 255)
    private static let paperQuote = Color(red: 219 / 255, green: 234 / 255, blue: 254 / 255)
    private static let paperNote = Color(red: 29 / 255, green: 78 / 255, blue: 216 / 255)
    private static let paperWarn = Color(red: 180 / 255, green: 83 / 255, blue: 9 / 255)
    private static let paperTip = Color(red: 4 / 255, green: 120 / 255, blue: 87 / 255)
    private static let paperTableHeader = Color(red: 226 / 255, green: 232 / 255, blue: 240 / 255)
    private static let paperTableEven = Color(red: 248 / 255, green: 250 / 255, blue: 252 / 255)
    private static let paperBorder = Color(red: 148 / 255, green: 163 / 255, blue: 184 / 255)

    private static let inkBody = Color(red: 244 / 255, green: 244 / 255, blue: 245 / 255)
    private static let inkMuted = Color(red: 196 / 255, green: 201 / 255, blue: 210 / 255)
    private static let inkLink = Color(red: 125 / 255, green: 211 / 255, blue: 252 / 255)
    private static let inkMark = Color(red: 120 / 255, green: 53 / 255, blue: 15 / 255)
    private static let inkMarkText = Color(red: 254 / 255, green: 243 / 255, blue: 199 / 255)
    private static let inkCode = Color(red: 253 / 255, green: 230 / 255, blue: 138 / 255)
    private static let inkCodeBg = Color(red: 30 / 255, green: 41 / 255, blue: 59 / 255)
    private static let inkFence = Color(red: 15 / 255, green: 23 / 255, blue: 42 / 255)
    private static let inkQuote = Color(red: 23 / 255, green: 37 / 255, blue: 84 / 255)
    private static let inkNote = Color(red: 147 / 255, green: 197 / 255, blue: 253 / 255)
    private static let inkWarn = Color(red: 253 / 255, green: 186 / 255, blue: 116 / 255)
    private static let inkTip = Color(red: 110 / 255, green: 231 / 255, blue: 183 / 255)
    private static let inkTableHeader = Color(red: 30 / 255, green: 41 / 255, blue: 59 / 255)
    private static let inkTableEven = Color(red: 17 / 255, green: 24 / 255, blue: 39 / 255)
    private static let inkBorder = Color(red: 71 / 255, green: 85 / 255, blue: 105 / 255)
    private static let inkMath = Color(red: 21 / 255, green: 28 / 255, blue: 42 / 255)

    private static let paperTheme = MarkdownTheme {
        Paragraph()
            .font(.body)
            .foregroundStyle(paperInk)
            .lineHeight(24)
            .marginBottom(12)

        Heading(1)
            .font(.title.weight(.bold))
            .foregroundStyle(paperInk)
            .marginBottom(8)

        Heading(2)
            .font(.title2.weight(.semibold))
            .foregroundStyle(paperInk)
            .marginBottom(8)

        Link()
            .foregroundStyle(paperLink)
            .underline(true)

        Strong()
            .foregroundStyle(paperInk)
            .bold()

        Emphasis()
            .foregroundStyle(paperMuted)

        Code()
            .foregroundStyle(paperCode)
            .background(paperCodeBg)

        CodeBlock()
            .font(.system(.footnote, design: .monospaced))
            .foregroundStyle(paperCode)
            .background(paperFence)
            .borderColor(paperBorder)
            .borderWidth(1)
            .cornerRadius(8)
            .padding(12)
            .marginBottom(12)

        Blockquote()
            .foregroundStyle(paperMuted)
            .background(paperQuote)
            .borderColor(paperNote)
            .borderWidth(3)
            .gapWidth(12)
            .marginBottom(12)

        Admonition(.note)
            .foregroundStyle(paperNote)
            .background(paperQuote)
        Admonition(.tip)
            .foregroundStyle(paperTip)
            .background(Color(red: 209 / 255, green: 250 / 255, blue: 229 / 255))
        Admonition(.warning)
            .foregroundStyle(paperWarn)
            .background(Color(red: 254 / 255, green: 243 / 255, blue: 199 / 255))
        Admonition(.important)
            .foregroundStyle(Color(red: 109 / 255, green: 40 / 255, blue: 217 / 255))
        Admonition(.caution)
            .foregroundStyle(Color(red: 185 / 255, green: 28 / 255, blue: 28 / 255))

        Highlight()
            .foregroundStyle(paperInk)
            .background(paperMark)

        Underline()
            .foregroundStyle(paperInk)

        List()
            .foregroundStyle(paperInk)
            .bulletColor(paperMuted)
            .markerColor(paperMuted)

        TaskList()
            .checkedColor(paperLink)
            .borderColor(paperBorder)
            .checkmarkColor(Color.white)
            .checkedTextColor(paperMuted)
            .checkboxSize(18)
            .checkboxBorderRadius(4)
            .checkedStrikethrough(true)

        Table()
            .foregroundStyle(paperInk)
            .headerTextColor(paperInk)
            .headerBackground(paperTableHeader)
            .rowEvenBackground(paperTableEven)
            .rowOddBackground(Color.white)
            .borderColor(paperBorder)
            .borderWidth(1)
            .cornerRadius(8)
            .cellPaddingHorizontal(8)
            .cellPaddingVertical(6)

        Spoiler()
            .color(paperMuted)
            .background(Color.white)
            .solidBorderRadius(4)

        ThematicBreak()
            .color(paperBorder)
            .height(1)

        BlockImage()
            .height(44)
            .borderRadius(6)
            .marginBottom(12)

        MathBlock()
            .fontSize(20)
            .foregroundStyle(paperInk)
            .background(paperFence)
            .padding(12)
            .marginBottom(12)
            .textAlignment(.center)

        InlineMath()
            .foregroundStyle(paperLink)
    }

    private static let inkTheme = MarkdownTheme {
        Paragraph()
            .font(.body)
            .foregroundStyle(inkBody)
            .lineHeight(24)
            .marginBottom(12)

        Heading(1)
            .font(.title.weight(.bold))
            .foregroundStyle(inkBody)
            .marginBottom(8)

        Heading(2)
            .font(.title2.weight(.semibold))
            .foregroundStyle(inkBody)
            .marginBottom(8)

        Link()
            .foregroundStyle(inkLink)
            .underline(true)

        Strong()
            .foregroundStyle(Color.white)
            .bold()

        Emphasis()
            .foregroundStyle(inkMuted)

        Code()
            .foregroundStyle(inkCode)
            .background(inkCodeBg)

        CodeBlock()
            .font(.system(.footnote, design: .monospaced))
            .foregroundStyle(inkCode)
            .background(inkFence)
            .borderColor(inkBorder)
            .borderWidth(1)
            .cornerRadius(8)
            .padding(12)
            .marginBottom(12)

        Blockquote()
            .foregroundStyle(inkMuted)
            .background(inkQuote)
            .borderColor(inkNote)
            .borderWidth(3)
            .gapWidth(12)
            .marginBottom(12)

        Admonition(.note)
            .foregroundStyle(inkNote)
            .background(inkQuote)
        Admonition(.tip)
            .foregroundStyle(inkTip)
            .background(Color(red: 6 / 255, green: 46 / 255, blue: 36 / 255))
        Admonition(.warning)
            .foregroundStyle(inkWarn)
            .background(Color(red: 67 / 255, green: 32 / 255, blue: 6 / 255))
        Admonition(.important)
            .foregroundStyle(Color(red: 196 / 255, green: 181 / 255, blue: 253 / 255))
        Admonition(.caution)
            .foregroundStyle(Color(red: 252 / 255, green: 165 / 255, blue: 165 / 255))

        Highlight()
            .foregroundStyle(inkMarkText)
            .background(inkMark)

        Underline()
            .foregroundStyle(inkBody)

        List()
            .foregroundStyle(inkBody)
            .bulletColor(inkMuted)
            .markerColor(inkMuted)

        TaskList()
            .checkedColor(inkLink)
            .borderColor(inkBorder)
            .checkmarkColor(Color.black)
            .checkedTextColor(inkMuted)
            .checkboxSize(18)
            .checkboxBorderRadius(4)
            .checkedStrikethrough(true)

        Table()
            .foregroundStyle(inkBody)
            .headerTextColor(inkBody)
            .headerBackground(inkTableHeader)
            .rowEvenBackground(inkTableEven)
            .rowOddBackground(Color(red: 12 / 255, green: 14 / 255, blue: 18 / 255))
            .borderColor(inkBorder)
            .borderWidth(1)
            .cornerRadius(8)
            .cellPaddingHorizontal(8)
            .cellPaddingVertical(6)

        Spoiler()
            .color(Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255))
            .background(Color(red: 12 / 255, green: 14 / 255, blue: 18 / 255))
            .solidBorderRadius(4)

        ThematicBreak()
            .color(inkBorder)
            .height(1)

        BlockImage()
            .height(44)
            .borderRadius(6)
            .marginBottom(12)

        MathBlock()
            .fontSize(20)
            .foregroundStyle(inkBody)
            .background(inkMath)
            .padding(12)
            .marginBottom(12)
            .textAlignment(.center)

        InlineMath()
            .foregroundStyle(inkLink)
    }
}

enum SampleDocuments {
    /// Bundled 66×44 "EM" badge. Data URL so the simulator never hits the network.
    static let badgeURI =
        "data:image/png;base64,"
        + "iVBORw0KGgoAAAANSUhEUgAAAEIAAAAsCAIAAABeyPmVAAAAfElEQVR42u3YwQmAMAwF0A7gCB4dxJGdxSk8ePXuBhJa1Fgf"
        + "/FMppa8QUlKGceogBQMDAwMjBePY1+pcnxa5XHw/BsabjPZCjIDjj4KB0SejZR0DIxejruVhYPTPuK/EP/w1xMDAwMAwGcHA"
        + "MFHHeIqxLXPy/ImhNjDacgL9ZW14G3LvowAAAABJRU5ErkJggg=="

    /// Live document: every surface `Text(markdown)` does not offer.
    static let live = """
        # Flight notes

        Native SwiftUI — not `Text(markdown)`. Source: [enriched-markdown-ios](https://github.com/software-mansion-labs/enriched-markdown-ios).

        ![Enriched Markdown badge](\(badgeURI))

        Tap ||hold short of 04:00 UTC|| to reveal the window.

        > [!NOTE]
        > Checkboxes toggle in place. `onTaskListItemPress` reports index, the new checked state, and the item text.

        > [!WARNING]
        > `$…$` stays plain text unless the app links **EnrichedMarkdownLaTeX** and calls `.markdownLaTeX()`.

        ## Preflight

        - [x] Pin `EnrichedMarkdown` from 0.1.0
        - [ ] Link `EnrichedMarkdownLaTeX`
        - [ ] Turn on highlight, super, sub, underline, admonitions

        Water is H~2~O. A square of side 4.2 has area 4.2^2^. Mark ==this clause==. Paths use __underlines__.

        | Syntax | Flag | Reads as |
        | :--- | :---: | :--- |
        | `==hi==` | highlight | mark |
        | `^2^` | superscript | power |
        | `~2~` | subscript | index |
        | `__hi__` | underline | line |

        ```swift
        EnrichedMarkdownText(source, flags: .demo)
            .markdownLaTeX()
        ```

        Inline energy $E = mc^2$, and the Gaussian integral:

        $$
        \\int_{-\\infty}^{\\infty} e^{-x^2}\\,dx = \\sqrt{\\pi}
        $$
        """

    /// Shorter themed cards for Gallery. Same features, less scroll.
    static let gallery = """
        # Flight card

        Tap ||hold short||. Water is H~2~O, area 3^2^. ==Mark== this. Paths use __underlines__. Docs: [package](https://github.com/software-mansion-labs/enriched-markdown-ios).

        ![Enriched Markdown badge](\(badgeURI))

        - [x] Pin the package
        - [ ] Typeset math

        > [!TIP]
        > Link **EnrichedMarkdownLaTeX** and call `.markdownLaTeX()`.

        | Flag | On |
        | :--- | :---: |
        | highlight | yes |
        | admonitions | yes |

        Euler: $e^{i\\pi}+1=0$

        $$
        e^{i\\pi}+1=0
        $$
        """
}
