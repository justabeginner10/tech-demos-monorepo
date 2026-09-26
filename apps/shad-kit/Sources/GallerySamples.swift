import AIElementsUI
import CanvasUI
import ShadcnUI
import SwiftUI

/// Frozen / one-shot samples. Live playground already owns the mock stream.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case tokens
    case buttons
    case badges
    case card
    case conversation
    case reasoning
    case tool
    case code
    case response
    case canvasStill

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tokens: "Tokens"
        case .buttons: "Buttons"
        case .badges: "Badges"
        case .card: "Card"
        case .conversation: "Conversation"
        case .reasoning: "Reasoning"
        case .tool: "Tool"
        case .code: "Code"
        case .response: "Response"
        case .canvasStill: "Canvas still"
        }
    }

    var subtitle: String {
        switch self {
        case .tokens: "Palette swatches"
        case .buttons: "Six variants"
        case .badges: "Pills · no input focus"
        case .card: "Title + footer"
        case .conversation: "Static AIMessage"
        case .reasoning: "Settled · no shimmer"
        case .tool: "Completed call"
        case .code: "Swift fence"
        case .response: "Static markdown"
        case .canvasStill: "Node cards · no CanvasView"
        }
    }

    @ViewBuilder
    var preview: some View {
        switch self {
        case .tokens:
            FrozenTokens()
        case .buttons:
            FrozenButtons()
        case .badges:
            FrozenBadges()
        case .card:
            FrozenCard()
        case .conversation:
            FrozenConversation()
        case .reasoning:
            AIReasoning(
                content: "Checked the matrix row sums; they come to 1.0, so achromatic input stays achromatic.",
                isStreaming: false,
                duration: 4,
                defaultOpen: true,
                autoClose: false
            )
            .padding(12)
        case .tool:
            AITool(name: "search_codebase", state: .outputAvailable, defaultOpen: true) {
                AIToolInput(json: #"{"query":"OKLCH"}"#)
                AIToolOutput(output: #"{"hits":3}"#)
            }
            .padding(12)
        case .code:
            AICodeBlock(
                code: """
                Button("Send") { }
                    .buttonStyle(.shadcn(.primary))
                """,
                language: "swift",
                showLineNumbers: true
            )
            .padding(12)
        case .response:
            AIResponse(
                """
                **OKLCH** is a cylindrical form of OKLab.

                1. Polar to Cartesian
                2. Cone response
                3. Linear sRGB + gamma
                """
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        case .canvasStill:
            FrozenCanvasNodes()
        }
    }
}

// MARK: - Frozen snapshots (no continuous animation)

private struct FrozenTokens: View {
    @Environment(\.shadcnPalette) private var palette
    @Environment(\.shadcnTheme) private var theme

    private var swatches: [(String, Color)] {
        [
            ("background", palette.background),
            ("card", palette.card),
            ("primary", palette.primary),
            ("secondary", palette.secondary),
            ("muted", palette.muted),
            ("destructive", palette.destructive),
        ]
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 8)], spacing: 8) {
            ForEach(swatches, id: \.0) { name, color in
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                        .fill(color)
                        .frame(height: 36)
                        .shadcnBorder(palette.border, cornerRadius: theme.radius.sm)
                    Text(name)
                        .font(theme.typography.mono(theme.typography.xs))
                        .foregroundStyle(palette.mutedForeground)
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
    }
}

private struct FrozenButtons: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Space.x3) {
            HStack(spacing: Space.x2) {
                ShadcnButton("Default") {}
                ShadcnButton("Secondary", variant: .secondary) {}
            }
            HStack(spacing: Space.x2) {
                ShadcnButton("Outline", variant: .outline) {}
                ShadcnButton("Ghost", variant: .ghost) {}
            }
            HStack(spacing: Space.x2) {
                ShadcnButton("Delete", systemImage: ShadcnIcon.trash, variant: .destructive) {}
                ShadcnButton(icon: ShadcnIcon.plus, variant: .outline, size: .icon) {}
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct FrozenBadges: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Space.x2) {
            HStack(spacing: Space.x2) {
                ShadcnBadge("Default")
                ShadcnBadge("Secondary", variant: .secondary)
                ShadcnBadge("Outline", variant: .outline)
            }
            HStack(spacing: Space.x2) {
                ShadcnBadge("Completed", systemImage: ShadcnIcon.checkCircle, iconTint: .green, variant: .secondary)
                ShadcnBadge("8 tokens", systemImage: ShadcnIcon.cpu, variant: .outline)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct FrozenCard: View {
    var body: some View {
        ShadcnCard {
            ShadcnCardHeader {
                ShadcnCardTitle("Theme tokens")
                ShadcnCardDescription("Neutral base, OKLCH → sRGB.")
            }
            ShadcnCardContent {
                Text("Apply `.shadcnSurface()` once near the root.")
            }
            ShadcnCardFooter {
                ShadcnButton("Apply", size: .small) {}
                ShadcnButton("Reset", variant: .ghost, size: .small) {}
            }
        }
        .padding(8)
    }
}

private struct FrozenConversation: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Space.x4) {
            AIMessage(.user) {
                AIMessageContent("Can you explain how OKLCH maps to sRGB?")
            }
            AIMessage(.assistant) {
                AIMessageContent(
                    "OKLCH is a **cylindrical** form of OKLab. Polar to Cartesian, then a 3×3 matrix into linear sRGB."
                )
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct FrozenCanvasNodes: View {
    var body: some View {
        HStack(alignment: .center, spacing: Space.x3) {
            CanvasNodeCard(width: 140) {
                CanvasNodeHeader {
                    CanvasNodeTitle("Prompt")
                    CanvasNodeDescription("user input")
                }
                CanvasNodeContentView {
                    Text("Summarise OKLCH.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                CanvasNodeFooter {
                    ShadcnBadge("ready", variant: .secondary)
                }
            }
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
            CanvasNodeCard(width: 140) {
                CanvasNodeHeader {
                    CanvasNodeTitle("Response")
                    CanvasNodeDescription("assistant")
                }
                CanvasNodeContentView {
                    Text("Three matrix multiplies.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                CanvasNodeFooter {
                    ShadcnBadge("done", variant: .outline)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
    }
}
