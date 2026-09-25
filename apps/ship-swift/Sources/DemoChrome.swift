import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case shimmer
    case typewriter
    case line
    case thinking

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shimmer: "Shimmer"
        case .typewriter: "Writer"
        case .line: "Line"
        case .thinking: "Think"
        }
    }

    var subtitle: String {
        switch self {
        case .shimmer: "SWShimmer · light band"
        case .typewriter: "SWTypewriterText · spring"
        case .line: "SWLineChart · one-shot reveal"
        case .thinking: "SWThinkingIndicator · TimelineView"
        }
    }
}

enum DemoPalette {
    static let page = Color(red: 8 / 255, green: 8 / 255, blue: 10 / 255)
    static let card = Color(red: 16 / 255, green: 16 / 255, blue: 18 / 255)
    static let canvas = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)
    static let stroke = Color.white.opacity(0.08)
    static let accent = Color(red: 107 / 255, green: 153 / 255, blue: 214 / 255)
}

enum DemoChrome {
    static func chartCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            content()
                .padding(.horizontal, 4)
                .padding(.bottom, 6)
                .background(DemoPalette.canvas)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }
}
