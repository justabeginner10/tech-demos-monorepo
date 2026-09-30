import SwiftUI

enum DemoPalette {
    static let ink = Color(red: 0.110, green: 0.141, blue: 0.188)
    static let paper = Color(red: 0.945, green: 0.953, blue: 0.949)
    static let brass = Color(red: 0.769, green: 0.631, blue: 0.353)
    static let tide = Color(red: 0.184, green: 0.435, blue: 0.416)
    static let street = Color(red: 0.816, green: 0.855, blue: 0.875)
}

enum DemoScreen: String, CaseIterable, Identifiable, Hashable {
    case basic
    case heights
    case background
    case styled
    case items

    var id: String { rawValue }

    var title: String {
        switch self {
        case .basic: "Basic sheet"
        case .heights: "Custom heights"
        case .background: "Background taps"
        case .styled: "Locked sheet"
        case .items: "From a list"
        }
    }

    var blurb: String {
        switch self {
        case .basic: "Medium and large, grabber visible"
        case .heights: "Points, a fraction, and medium"
        case .background: "The map stays tappable under a short sheet"
        case .styled: "Corner radius, no swipe dismiss, dismiss callback"
        case .items: "Open a sheet for the row you tap"
        }
    }

    var symbol: String {
        switch self {
        case .basic: "rectangle.bottomhalf.inset.filled"
        case .heights: "ruler"
        case .background: "hand.tap"
        case .styled: "lock"
        case .items: "list.bullet"
        }
    }
}

struct DemoScreenHeader: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.body)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PresentButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(DemoPalette.tide)
    }
}

struct SheetBody<Content: View>: View {
    let title: String
    let detail: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.system(.title2, design: .rounded, weight: .semibold))
                    .foregroundStyle(DemoPalette.ink)
                Text(detail)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .background(Color(.systemBackground))
    }
}

struct DetentLegend: View {
    let stops: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(stops, id: \.self) { stop in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(DemoPalette.brass)
                        .frame(width: 14, height: 3)
                    Text(stop)
                        .font(.subheadline)
                        .foregroundStyle(DemoPalette.ink)
                }
            }
        }
        .padding(.top, 4)
    }
}
