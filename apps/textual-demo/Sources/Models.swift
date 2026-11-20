import SwiftUI
import Textual

/// `.default` and `.gitHub` from Textual 0.5.0. Both are `StructuredText.Style` presets.
enum DocumentPreset: String, CaseIterable, Identifiable {
    case libraryDefault
    case gitHub

    var id: String { rawValue }

    var title: String {
        switch self {
        case .libraryDefault: "Default"
        case .gitHub: "GitHub"
        }
    }
}

/// Light and dark canvases. Textual's built-in styles read `DynamicColor` from the color scheme.
enum PreviewCanvas: String, CaseIterable, Identifiable {
    case dark
    case light

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dark: "Dark"
        case .light: "Light"
        }
    }

    var colorScheme: ColorScheme {
        switch self {
        case .dark: .dark
        case .light: .light
        }
    }

    var page: Color {
        switch self {
        case .dark: Color(red: 12 / 255, green: 14 / 255, blue: 18 / 255)
        case .light: Color(red: 250 / 255, green: 247 / 255, blue: 240 / 255)
        }
    }

    /// Body copy. Heading and paragraph styles inherit this; links and code use their own colors.
    var ink: Color {
        switch self {
        case .dark: Color(red: 244 / 255, green: 244 / 255, blue: 245 / 255)
        case .light: Color(red: 17 / 255, green: 24 / 255, blue: 39 / 255)
        }
    }
}

enum OverflowChoice: String, CaseIterable, Identifiable {
    case scroll
    case wrap

    var id: String { rawValue }

    var title: String {
        switch self {
        case .scroll: "Scroll"
        case .wrap: "Wrap"
        }
    }

    var mode: OverflowMode {
        switch self {
        case .scroll: .scroll
        case .wrap: .wrap
        }
    }
}

enum HighlighterChoice: String, CaseIterable, Identifiable {
    case tokens
    case plain

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tokens: "Tokens"
        case .plain: "Plain"
        }
    }

    var theme: StructuredText.HighlighterTheme {
        switch self {
        case .tokens: .default
        case .plain: .plain
        }
    }
}

/// Catalog images addressed as `resource://badge` and `resource://spark`.
enum DemoAttachments {
    static let spark = Emoji(
        shortcode: "spark",
        url: URL(string: "resource://spark")!
    )

    static let emoji: Set<Emoji> = [spark]

    /// `resource://badge` stores the asset name in the host. A path URL uses the last component.
    static func resourceName(for url: URL) -> String {
        if let host = url.host, !host.isEmpty {
            return host
        }
        let name = url.lastPathComponent
        if !name.isEmpty {
            return name
        }
        return "badge"
    }
}

enum DemoInline {
    /// The shape of the inline-style sample in the Textual 0.5.0 README.
    static let custom = InlineStyle()
        .code(
            .monospaced,
            .fontScale(0.85),
            .backgroundColor(Color(red: 0.36, green: 0.20, blue: 0.55)),
            .foregroundColor(.white)
        )
        .emphasis(.italic, .underlineStyle(.single))
        .strong(.fontWeight(.semibold))
        .link(.foregroundColor(Color(red: 0.45, green: 0.78, blue: 0.96)))
        .strikethrough(.strikethroughStyle(.single))
}

enum DemoMath {
    static let latinModern = MathProperties(
        fontName: .latinModern,
        fontScale: 1.2,
        textAlignment: .center
    )

    static let fira = MathProperties(
        fontName: .fira,
        fontScale: 1.15,
        textAlignment: .leading
    )
}

enum DemoEmojiMetrics {
    static let inline = EmojiProperties(
        size: .fontScaled(width: 1.15, height: 1.15),
        baselineOffset: .fontScaled(-0.1)
    )

    static let large = EmojiProperties(
        size: .fontScaled(width: 1.6, height: 1.6),
        baselineOffset: .fontScaled(-0.2)
    )
}

extension View {
    /// Both loaders map `resource://<asset>` onto the app asset catalog. No network.
    func demoResourceAttachments() -> some View {
        self
            .textual.imageAttachmentLoader(.image(named: { @Sendable url in
                DemoAttachments.resourceName(for: url)
            }))
            .textual.emojiAttachmentLoader(.emoji(named: { @Sendable url in
                DemoAttachments.resourceName(for: url)
            }))
    }
}

enum SampleDocuments {
    static let seed = #"""
    # Flight notes

    **Textual** renders structured Markdown in SwiftUI. This line has *emphasis*, `inline code`, and ~~a scratched plan~~. A custom emoji sits in the sentence :spark:.

    ![Textual badge](resource://badge)

    > Pin the package to the 0.5.0 tag. The badge is a catalog image, so the preview stays offline.

    ## Checklist

    - Headings, quotes, and lists
    - Nested markers
      - Disc, then circle, then square
    - A [package link](https://github.com/gonzalezreal/textual) stays in the app

    1. Choose Default or GitHub
    2. Flip the canvas between light and dark
    3. Wrap or scroll the fence

    The area of a circle is $A = \pi r^2$.

    $$
    \int_{0}^{1} x^2\,dx = \frac{1}{3}
    $$

    ```swift
    StructuredText(
        markdown: source,
        syntaxExtensions: [.emoji(emoji), .math]
    )
    .textual.structuredTextStyle(.gitHub)
    .textual.textSelection(.enabled)
    .textual.overflowMode(.scroll)
    // A long comment so overflowMode(.scroll) can pan, and overflowMode(.wrap) can fold this line onto the next row of the fence.
    ```

    | Control | API |
    | --- | --- |
    | Default / GitHub | `structuredTextStyle` |
    | Scroll / Wrap | `overflowMode` |
    | Tokens / Plain | `highlighterTheme` |

    ---

    *Leave this tab and the preview unmounts. The editor keeps the draft.*
    """#
}
