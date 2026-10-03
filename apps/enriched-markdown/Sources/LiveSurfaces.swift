import EnrichedMarkdown
import EnrichedMarkdownLaTeX
import SwiftUI

/// The live document: restyle, tap spoilers, toggle tasks, follow links.
struct LiveDocumentSurface: View {
    var theme: DocumentTheme
    var spoilerOverlay: DemoSpoilerOverlay

    @State private var lastTask: TaskListItemPressEvent?
    @State private var lastLink: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Document")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(theme.subtitle)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            eventLine

            ScrollView {
                EnrichedMarkdownText(SampleDocuments.live, flags: .demo)
                    .markdownLaTeX()
                    .markdownTheme(theme.markdown)
                    .markdownSpoilerOverlay(spoilerOverlay.provider)
                    .onLinkPress { url in
                        lastLink = url
                    }
                    .onTaskListItemPress { event in
                        lastTask = event
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            }
            .background(theme.page)
            .preferredColorScheme(theme.colorScheme)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var eventLine: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("onTaskListItemPress")
                .font(.caption2.weight(.semibold).monospaced())
                .foregroundStyle(DemoPalette.accent)
            Text(taskCaption)
                .font(.caption)
                .foregroundStyle(DemoPalette.ink)

            Text("onLinkPress")
                .font(.caption2.weight(.semibold).monospaced())
                .foregroundStyle(DemoPalette.accent)
                .padding(.top, 4)
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

    private var taskCaption: String {
        guard let lastTask else {
            return "Tap a checkbox. The view toggles visually; persist from this event if you need the source updated."
        }
        let state = lastTask.checked ? "checked" : "unchecked"
        return "index \(lastTask.index) · \(state) · \(lastTask.text)"
    }

    private var linkCaption: String {
        guard let lastLink else {
            return "Tap the package link. The handler reports the URL; this demo stays offline."
        }
        return lastLink.absoluteString
    }
}
