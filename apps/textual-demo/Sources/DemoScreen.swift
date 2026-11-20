import SwiftUI

/// Dark playground for Textual: one live editor and preview, plus a static gallery.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live)
                .tabItem { Label("Live", systemImage: "text.word.spacing") }
                .tag(DemoTab.live)

            GalleryScreen()
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
        .toolbarBackground(DemoPalette.page, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

/// Editor plus one StructuredText. Leaving the tab unmounts the preview and keeps the draft.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @State private var source = SampleDocuments.seed
    @State private var preset: DocumentPreset = .gitHub
    @State private var canvas: PreviewCanvas = .dark
    @State private var overflow: OverflowChoice = .scroll
    @State private var highlighter: HighlighterChoice = .tokens
    @State private var selectionEnabled = true
    @State private var mathEnabled = true

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                playgroundControls
                editor
                if isSelected {
                    LivePreview(
                        source: source,
                        preset: preset,
                        canvas: canvas,
                        overflow: overflow,
                        highlighter: highlighter,
                        selectionEnabled: selectionEnabled,
                        mathEnabled: mathEnabled
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    parkedCard
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DemoPalette.page)
            .navigationTitle("Textual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
        }
    }

    private var playgroundControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Playground")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Button("Reset") {
                    source = SampleDocuments.seed
                }
                .font(.caption.weight(.semibold))
                .buttonStyle(.bordered)
                .tint(DemoPalette.accent)
            }

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)],
                spacing: 8
            ) {
                labeledPicker("Style", selection: $preset, cases: Array(DocumentPreset.allCases), titleOf: \.title)
                labeledPicker("Canvas", selection: $canvas, cases: Array(PreviewCanvas.allCases), titleOf: \.title)
                labeledPicker("Overflow", selection: $overflow, cases: Array(OverflowChoice.allCases), titleOf: \.title)
                labeledPicker("Highlighter", selection: $highlighter, cases: Array(HighlighterChoice.allCases), titleOf: \.title)
            }

            HStack(spacing: 16) {
                Toggle("Select", isOn: $selectionEnabled)
                Toggle("Math", isOn: $mathEnabled)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(DemoPalette.ink)
            .tint(DemoPalette.accent)

            Text(
                "StructuredText parses on each edit. Math rebuilds the parser. "
                    + "Default and GitHub are the two StructuredText.Style presets."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    private var editor: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Markdown")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(DemoPalette.inkMuted)
            TextEditor(text: $source)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(DemoPalette.ink)
                .scrollContentBackground(.hidden)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .frame(height: 132)
                .padding(8)
                .background(DemoPalette.canvas, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                        .allowsHitTesting(false)
                }
        }
    }

    private func labeledPicker<T: Hashable & Identifiable>(
        _ title: String,
        selection: Binding<T>,
        cases: [T],
        titleOf: (T) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(DemoPalette.inkMuted)
            Picker(title, selection: selection) {
                ForEach(cases) { item in
                    Text(titleOf(item)).tag(item)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: preset.title, subtitle: "Unmounted") {
            Text("Live StructuredText is unmounted while Gallery is open. The editor draft stays.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
        }
    }
}

#Preview("Textual Demo") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
