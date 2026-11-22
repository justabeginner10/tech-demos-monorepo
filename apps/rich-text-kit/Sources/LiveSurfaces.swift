import RichTextKit
import SwiftUI
import UIKit

/// One live editor at a time. Leaving the tab, or opening Preview, unmounts it.
struct LivePlaygroundView: View {
    var isSelected: Bool
    @Binding var appearance: DemoAppearance

    @State private var family: LiveFamily = .editor
    /// Nil until the editor writes back or Restore runs. The seed is a main-actor
    /// `NSAttributedString`, so it is not stored in the property's default value.
    @State private var text: NSAttributedString?
    @State private var revision = 0
    @State private var keepToolbarVisible = true
    @State private var showFormatSheet = false
    @StateObject private var context = RichTextContext()

    private var document: NSAttributedString {
        text ?? SampleRichText.harbor
    }

    private var textBinding: Binding<NSAttributedString> {
        Binding(
            get: { document },
            set: { text = $0 }
        )
    }

    private var showsEditor: Bool {
        isSelected && family != .preview
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                playgroundControls
                if isSelected {
                    activeSurface
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
            .navigationTitle("RichTextKit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
            .richTextFormatToolbarConfig(DemoFormat.toolbar)
            .richTextFormatSheetConfig(DemoFormat.toolbar)
            .richTextFormatSidebarConfig(DemoFormat.toolbar)
            .richTextKeyboardToolbarConfig(
                .init(
                    alwaysDisplayToolbar: keepToolbarVisible,
                    displayFormatSheetButton: true,
                    leadingActions: [.undo, .redo],
                    trailingActions: [.dismissKeyboard]
                )
            )
            .sheet(isPresented: $showFormatSheet) {
                RichTextFormat.Sheet(context: context)
            }
            .inspector(isPresented: inspectorPresented) {
                RichTextFormat.Sidebar(context: context)
            }
        }
    }

    private var inspectorPresented: Binding<Bool> {
        Binding(
            get: { showsEditor && family == .format },
            set: { presented in
                if !presented, family == .format {
                    family = .editor
                }
            }
        )
    }

    private var playgroundControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Playground")
                .font(.headline)
                .foregroundStyle(DemoPalette.ink)

            Picker("Family", selection: $family) {
                ForEach(LiveFamily.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Text(family.subtitle)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)

            Picker("Appearance", selection: $appearance) {
                ForEach(DemoAppearance.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Text(
                "Editor and Format share one RichTextEditor. Preview and Gallery "
                    + "mount RichTextViewer instead. Leaving Live unmounts the editor."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .demoCard()
    }

    @ViewBuilder
    private var activeSurface: some View {
        switch family {
        case .editor, .format:
            editorStack
        case .preview:
            previewStack
        }
    }

    private var editorStack: some View {
        VStack(spacing: 0) {
            statusRow
                .padding(.bottom, 8)
            RichTextFormat.Toolbar(context: context)
            RichTextEditor(
                text: textBinding,
                context: context,
                format: .archivedData
            ) { component in
                component.textContentInset = CGSize(width: 16, height: 12)
                guard let view = component as? UITextView else { return }
                view.backgroundColor = .white
            }
            .paperSurface()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if family == .editor {
                RichTextKeyboardToolbar(
                    context: context,
                    leadingButtons: { $0 },
                    trailingButtons: { $0 },
                    formatSheet: { $0 }
                )
            }
        }
    }

    private var previewStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Read only")
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.inkMuted)
            RichTextViewer(document)
                .id(revision)
                .paperSurface()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var statusRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                RichTextAction.Button(action: .undo, context: context)
                RichTextAction.Button(action: .redo, context: context)
                if family == .format {
                    Button("Format sheet") {
                        showFormatSheet = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                Spacer()
                Button("Restore sample") {
                    restoreSample()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .tint(DemoPalette.accent)

            if family == .editor {
                Toggle("Keep keyboard toolbar visible", isOn: $keepToolbarVisible)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.ink)
            }

            HStack(spacing: 6) {
                DemoChrome.chip(context.fontName.isEmpty ? "font" : context.fontName)
                DemoChrome.chip("\(Int(context.fontSize)) pt")
                DemoChrome.chip(context.canUndoLatestChange ? "undo" : "no undo")
                DemoChrome.chip(context.canRedoLatestChange ? "redo" : "no redo")
                DemoChrome.chip("\(document.string.count) chars")
            }
        }
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: family.title, subtitle: "Unmounted") {
            Text("The editor is unmounted while Gallery is open.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
        }
    }

    private func restoreSample() {
        text = SampleRichText.harbor
        revision += 1
        context.setAttributedString(to: SampleRichText.harbor)
    }
}
