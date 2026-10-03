import EnrichedMarkdown
import EnrichedMarkdownLaTeX
import SwiftUI

/// Frozen themed documents. Live owns the interactive handlers.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case paper
    case ink
    case libraryDefault
    case plainText

    var id: String { rawValue }

    var title: String {
        switch self {
        case .paper: "Paper"
        case .ink: "Ink"
        case .libraryDefault: "Library default"
        case .plainText: "SwiftUI Text"
        }
    }

    var subtitle: String {
        switch self {
        case .paper: "MarkdownTheme · light"
        case .ink: "MarkdownTheme · dark"
        case .libraryDefault: "MarkdownTheme.default"
        case .plainText: "Text(AttributedString)"
        }
    }

    var chips: [String] {
        switch self {
        case .paper:
            ["Paper", "markdownTheme", "markdownLaTeX"]
        case .ink:
            ["Ink", "dark canvas", "spoilers"]
        case .libraryDefault:
            ["default", "semantic colors"]
        case .plainText:
            ["no GFM", "no LaTeX", "no spoiler"]
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
        case .paper:
            StaticMarkdownCard(theme: .paper)
        case .ink:
            StaticMarkdownCard(theme: .ink)
        case .libraryDefault:
            DefaultMarkdownCard()
        case .plainText:
            PlainSwiftUICard()
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

/// Enriched document with toggles off. Theme is the only variable.
private struct StaticMarkdownCard: View {
    var theme: DocumentTheme

    var body: some View {
        EnrichedMarkdownText(SampleDocuments.gallery, flags: .demo)
            .markdownLaTeX()
            .markdownTheme(theme.markdown)
            .markdownSpoilerOverlay(.solid)
            .markdownTaskListItemToggleEnabled(false)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(theme.page)
            .preferredColorScheme(theme.colorScheme)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct DefaultMarkdownCard: View {
    var body: some View {
        EnrichedMarkdownText(SampleDocuments.gallery, flags: .demo)
            .markdownLaTeX()
            .markdownSpoilerOverlay(.solid)
            .markdownTaskListItemToggleEnabled(false)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(red: 12 / 255, green: 14 / 255, blue: 18 / 255))
            .preferredColorScheme(.dark)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

/// What `Text` does with the same source: no GFM table, no task boxes, no spoiler, no math.
private struct PlainSwiftUICard: View {
    var body: some View {
        Text(plainAttributed)
            .font(.body)
            .foregroundStyle(Color(red: 17 / 255, green: 24 / 255, blue: 39 / 255))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(red: 250 / 255, green: 247 / 255, blue: 240 / 255))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var plainAttributed: AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .full
        )
        if let parsed = try? AttributedString(
            markdown: SampleDocuments.gallery,
            options: options
        ) {
            return parsed
        }
        return AttributedString(SampleDocuments.gallery)
    }
}
