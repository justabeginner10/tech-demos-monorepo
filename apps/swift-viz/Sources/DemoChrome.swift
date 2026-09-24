import SwiftViz
import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case stacked
    case simple

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stacked: "Stacked"
        case .simple: "Simple"
        }
    }

    var subtitle: String {
        switch self {
        case .stacked: "Tap a bar · spring detail"
        case .simple: "Single series · spring detail"
        }
    }
}

enum ValueFormat: String, CaseIterable, Identifiable, Hashable {
    case plain
    case currency
    case percent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .plain: "Plain"
        case .currency: "Currency"
        case .percent: "Percent"
        }
    }

    var formatter: SVValueFormatter? {
        switch self {
        case .plain:
            nil
        case .currency:
            { value, _, _ in
                "$" + value.formatted(.number.precision(.fractionLength(0)))
            }
        case .percent:
            { value, _, _ in
                value.formatted(.number.precision(.fractionLength(1))) + "%"
            }
        }
    }
}

enum DemoPalette {
    static let page = Color(red: 8 / 255, green: 8 / 255, blue: 10 / 255)
    static let card = Color(red: 16 / 255, green: 16 / 255, blue: 18 / 255)
    static let canvas = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)
    static let stroke = Color.white.opacity(0.08)
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
