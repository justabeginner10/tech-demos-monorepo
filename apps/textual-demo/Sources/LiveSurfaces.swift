import SwiftUI
import Textual

/// The live document. `mathEnabled` is part of the view identity because `StructuredText`
/// reparses only when `markup` changes, and the math syntax extension lives on the parser.
struct LivePreview: View {
    var source: String
    var preset: DocumentPreset
    var canvas: PreviewCanvas
    var overflow: OverflowChoice
    var highlighter: HighlighterChoice
    var selectionEnabled: Bool
    var mathEnabled: Bool

    @State private var lastLink: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Preview")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(preset.title)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            linkLine

            ScrollView {
                styledDocument()
                    .environment(\.openURL, OpenURLAction { url in
                        lastLink = url
                        return .handled
                    })
                    .font(.body)
                    .foregroundStyle(canvas.ink)
                    .environment(\.colorScheme, canvas.colorScheme)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            }
            .background(canvas.page)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var linkLine: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("openURL")
                .font(.caption2.weight(.semibold).monospaced())
                .foregroundStyle(DemoPalette.accent)
            Text(linkCaption)
                .font(.caption)
                .foregroundStyle(DemoPalette.ink)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }

    private var linkCaption: String {
        guard let lastLink else {
            return "Tap the package link. The handler reports the URL and returns .handled."
        }
        return lastLink.absoluteString
    }

    private var syntaxExtensions: [AttributedStringMarkdownParser.SyntaxExtension] {
        var items: [AttributedStringMarkdownParser.SyntaxExtension] = [.emoji(DemoAttachments.emoji)]
        if mathEnabled {
            items.append(.math)
        }
        return items
    }

    @ViewBuilder
    private func styledDocument() -> some View {
        let base = StructuredText(markdown: source, syntaxExtensions: syntaxExtensions)
            .id(mathEnabled)
            .textual.overflowMode(overflow.mode)
            .textual.highlighterTheme(highlighter.theme)
            .textual.mathProperties(DemoMath.latinModern)
            .textual.emojiProperties(DemoEmojiMetrics.inline)
            .demoResourceAttachments()

        switch preset {
        case .libraryDefault:
            selected(base.textual.structuredTextStyle(.default))
        case .gitHub:
            selected(base.textual.structuredTextStyle(.gitHub))
        }
    }

    @ViewBuilder
    private func selected<V: View>(_ view: V) -> some View {
        if selectionEnabled {
            view.textual.textSelection(.enabled)
        } else {
            view.textual.textSelection(.disabled)
        }
    }
}
