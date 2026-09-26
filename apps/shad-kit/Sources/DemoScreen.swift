import AIElementsUI
import ShadcnUI
import SwiftUI

/// Dark playground for ShadKit: one live surface, plus a static gallery.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live)
                .tabItem { Label("Live", systemImage: "sparkles") }
                .tag(DemoTab.live)

            GalleryScreen()
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
    }
}

/// One live recipe at a time: theme primitives, mock AI chat, or AI Elements.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @State private var family: LiveFamily = .theme
    @State private var baseColor = ShadcnBaseColor.neutral
    @StateObject private var chat: AIChat

    init(isSelected: Bool) {
        self.isSelected = isSelected
        _chat = StateObject(wrappedValue: LiveChatFactory.make())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    storyHeader
                    playgroundControls
                    if isSelected {
                        activeRecipe
                    } else {
                        parkedCard
                    }
                    howItWorks
                }
                .padding()
            }
            .background(DemoPalette.page)
            .navigationTitle("ShadKit")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: family) { _, newFamily in
            if newFamily != .chat {
                chat.stop()
            }
        }
        .onChange(of: isSelected) { _, selected in
            if !selected {
                chat.stop()
            }
        }
    }

    // MARK: - Header

    private var storyHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("shadcn + AI Elements in SwiftUI")
                .font(.title3.weight(.semibold))

            Text(
                "ShadKit ports shadcn/ui tokens and Vercel AI Elements with no extra "
                    + "dependencies. This playground mounts one live surface at a time: "
                    + "theme primitives, a mock `AIChat`, or static AI Elements samples."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Text("SKT")
                    .font(.caption.weight(.semibold).monospaced())
                Text("·")
                Text(family.title.lowercased())
                    .font(.caption)
                Text("·")
                Text("no network")
                    .font(.caption)
            }
            .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Controls

    private var playgroundControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Playground")
                .font(.headline)

            Picker("Family", selection: $family) {
                ForEach(LiveFamily.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            if family == .theme {
                Picker("Base color", selection: $baseColor) {
                    ForEach(ShadcnBaseColor.all) { color in
                        Text(color.name).tag(color)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    // MARK: - Recipes

    @ViewBuilder
    private var activeRecipe: some View {
        DemoChrome.chartCard(title: family.title, subtitle: family.subtitle) {
            switch family {
            case .theme:
                LiveThemeSurface(baseColor: baseColor)
            case .chat:
                LiveChatSurface(chat: chat)
            case .elements:
                LiveElementsSurface()
            }
        }
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: family.title, subtitle: "Unmounted") {
            Text("Live surface is unmounted while Gallery is open.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
        }
    }

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How it works")
                .font(.headline)

            Text(
                "The family picker keeps a single recipe in the view tree. "
                    + "**Theme** applies `.shadcnSurface` plus Button / Input / Badge / Card. "
                    + "**Chat** is `AIChatbot` driven by `AIMockChatTransport` — no network. "
                    + "**Elements** is a static Reasoning / Tool / CodeBlock / Response stack. "
                    + "Leaving this tab unmounts the active piece and stops any mock stream. "
                    + "Gallery is paused snapshots — no live chat, no CanvasView, no forever timers."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }
}

// MARK: - Live surfaces

private struct LiveThemeSurface: View {
    var baseColor: ShadcnBaseColor

    @State private var name = "Ada"

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x4) {
            tokenRow
            buttonRow
            ShadcnTextField("Name", text: $name)
            badgeRow
            ShadcnCard {
                ShadcnCardHeader {
                    ShadcnCardTitle("Card")
                    ShadcnCardDescription("shadcn primitive on the selected base color.")
                }
                ShadcnCardContent {
                    Text("Hello, \(name.isEmpty ? "there" : name).")
                }
                ShadcnCardFooter {
                    ShadcnButton("Primary") {}
                    ShadcnButton("Ghost", variant: .ghost) {}
                }
            }
        }
        .padding(12)
        .shadcnSurface(baseColor.theme)
    }

    private var tokenRow: some View {
        HStack(spacing: Space.x2) {
            TokenSwatch(name: "bg", color: { $0.background })
            TokenSwatch(name: "card", color: { $0.card })
            TokenSwatch(name: "primary", color: { $0.primary })
            TokenSwatch(name: "muted", color: { $0.muted })
            TokenSwatch(name: "destructive", color: { $0.destructive })
        }
    }

    private var buttonRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Space.x2) {
                ShadcnButton("Default") {}
                ShadcnButton("Secondary", variant: .secondary) {}
                ShadcnButton("Outline", variant: .outline) {}
                ShadcnButton("Ghost", variant: .ghost) {}
            }
        }
    }

    private var badgeRow: some View {
        HStack(spacing: Space.x2) {
            ShadcnBadge("Default")
            ShadcnBadge("Secondary", variant: .secondary)
            ShadcnBadge("Outline", variant: .outline)
            ShadcnBadge("Verified", systemImage: ShadcnIcon.check, variant: .secondary)
        }
    }
}

private struct TokenSwatch: View {
    let name: String
    let color: (ShadcnPalette) -> Color

    @Environment(\.shadcnPalette) private var palette
    @Environment(\.shadcnTheme) private var theme

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .fill(color(palette))
                .frame(height: 28)
                .shadcnBorder(palette.border, cornerRadius: theme.radius.sm)
            Text(name)
                .font(theme.typography.mono(theme.typography.xs))
                .foregroundStyle(palette.mutedForeground)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct LiveChatSurface: View {
    @ObservedObject var chat: AIChat

    var body: some View {
        AIChatbot(
            chat: chat,
            suggestions: [
                "What is ShadKit?",
                "Explain OKLCH tokens",
                "Show a tool call",
            ],
            composer: { text, status in
                AIPromptInput(
                    text: text,
                    status: status,
                    style: .compact,
                    onSubmit: { chat.sendMessage() },
                    onStop: { chat.stop() }
                )
            }
        )
        .frame(maxWidth: .infinity)
        .frame(height: 420)
        .padding(8)
    }
}

private struct LiveElementsSurface: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Space.x4) {
            AIReasoning(
                content: "Map the OKLCH token to sRGB, then pick a badge variant.",
                isStreaming: false,
                duration: 2,
                defaultOpen: true,
                autoClose: false
            )

            AITool(name: "search_codebase", state: .outputAvailable, defaultOpen: true) {
                AIToolInput(json: #"{"query":"shadcnSurface"}"#)
                AIToolOutput(output: #"{"file":"Environment.swift","hits":1}"#)
            }

            AICodeBlock(
                code: """
                ContentView()
                    .shadcnSurface()
                """,
                language: "swift",
                showLineNumbers: true
            )

            AIResponse(
                """
                **ShadKit** applies theme tokens once near the root.

                - `.shadcnSurface()` paints `background`
                - Components read `\\.shadcnPalette`
                """
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
    }
}

/// Builds the mock `AIChat` used by the Live Chat surface.
/// Isolated on the main actor so Swift 6 accepts the `@StateObject` seed.
@MainActor
private enum LiveChatFactory {
    static func make() -> AIChat {
        let toolID = "tool-search-1"
        return AIChat(
            transport: AIMockChatTransport(tokenDelay: 0.05) { _ in
                [
                    .reasoningDelta("Check the tokens, then answer."),
                    .reasoningDone(duration: 1),
                    .toolCall(
                        UIToolPart(
                            id: toolID,
                            type: "tool-search_codebase",
                            state: .inputAvailable,
                            input: #"{"query":"shadcnSurface"}"#
                        )
                    ),
                    .toolResult(
                        id: toolID,
                        output: #"{"file":"Environment.swift","hits":1}"#,
                        errorText: nil
                    ),
                    .textDelta("ShadKit "),
                    .textDelta("is "),
                    .textDelta("a "),
                    .textDelta("pure "),
                    .textDelta("SwiftUI "),
                    .textDelta("port "),
                    .textDelta("of "),
                    .textDelta("shadcn/ui "),
                    .textDelta("and "),
                    .textDelta("Vercel "),
                    .textDelta("AI "),
                    .textDelta("Elements. "),
                    .textDelta("This "),
                    .textDelta("reply "),
                    .textDelta("is "),
                    .textDelta("AIMockChatTransport "),
                    .textDelta("— "),
                    .textDelta("no "),
                    .textDelta("network."),
                    .finish,
                ]
            }
        )
    }
}

#Preview("ShadKit Demo") {
    DemoScreen()
        .preferredColorScheme(.dark)
        .shadcnSurface()
}
