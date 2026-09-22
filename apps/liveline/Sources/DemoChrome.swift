import Liveline
import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case line
    case candles
    case compare

    var id: String { rawValue }

    var title: String {
        switch self {
        case .line: "Line"
        case .candles: "Candles"
        case .compare: "Compare"
        }
    }
}

enum DitherVariant: String, CaseIterable, Identifiable, Hashable {
    case gradient
    case dotted
    case hatched
    case solid

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gradient: "Gradient"
        case .dotted: "Dotted"
        case .hatched: "Hatched"
        case .solid: "Solid"
        }
    }

    var liveline: LivelineDitherVariant {
        switch self {
        case .gradient: .gradient
        case .dotted: .dotted
        case .hatched: .hatched
        case .solid: .solid
        }
    }
}

enum DemoPalette {
    static let page = Color(red: 8 / 255, green: 8 / 255, blue: 10 / 255)
    static let card = Color(red: 16 / 255, green: 16 / 255, blue: 18 / 255)
    static let canvas = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)
    static let stroke = Color.white.opacity(0.08)

    static func money(_ value: Double) -> String {
        "$" + value.formatted(.number.precision(.fractionLength(2)))
    }

    static func compact(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)))
    }
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
