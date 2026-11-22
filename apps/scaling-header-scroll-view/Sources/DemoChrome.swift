import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case profile
    case refresh
    case tabs

    var id: String { rawValue }

    var title: String {
        switch self {
        case .profile: "Profile"
        case .refresh: "Refresh"
        case .tabs: "Tabs"
        }
    }

    var subtitle: String {
        switch self {
        case .profile: "height · progress · snap"
        case .refresh: "pullToRefresh · pullToLoadMore"
        case .tabs: "ScalingHeaderTabView"
        }
    }
}

enum HeaderAnchor: String, CaseIterable, Identifiable, Hashable {
    case top
    case center
    case bottom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .top: "Top"
        case .center: "Center"
        case .bottom: "Bottom"
        }
    }

    var alignment: Alignment {
        switch self {
        case .top: .top
        case .center: .center
        case .bottom: .bottom
        }
    }
}

/// Snap choices for `setHeaderSnapMode` and `headerSnappingPositions`.
/// Positions in the package are 0 = expanded and 1 = collapsed.
enum HeaderSnapChoice: String, CaseIterable, Identifiable, Hashable {
    case off
    case lift
    case coast
    case thirds

    var id: String { rawValue }

    var title: String {
        switch self {
        case .off: "Off"
        case .lift: "Lift"
        case .coast: "Coast"
        case .thirds: "Thirds"
        }
    }
}

enum DemoPalette {
    static let page = Color(red: 8 / 255, green: 8 / 255, blue: 10 / 255)
    static let card = Color(red: 16 / 255, green: 16 / 255, blue: 18 / 255)
    static let canvas = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)
    static let stroke = Color.white.opacity(0.12)
    /// Hardcoded so the system scheme cannot paint black-on-black chrome.
    static let ink = Color(red: 245 / 255, green: 245 / 255, blue: 247 / 255)
    static let inkMuted = Color(red: 198 / 255, green: 198 / 255, blue: 204 / 255)
    static let accent = Color(red: 1, green: 0.55, blue: 0.22)
    static let duskTop = Color(red: 0.16, green: 0.18, blue: 0.42)
    static let duskMid = Color(red: 0.93, green: 0.45, blue: 0.28)
    static let duskBottom = Color(red: 0.10, green: 0.08, blue: 0.12)
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
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
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
                .allowsHitTesting(false)
        }
    }

    static func chip(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.medium).monospaced())
            .foregroundStyle(DemoPalette.ink)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.12), in: Capsule())
    }
}

struct InspectorCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }
}

struct DemoSlider: View {
    var title: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double?
    var format: String = "%.2f"

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(String(format: format, value))
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            slider
        }
    }

    @ViewBuilder
    private var slider: some View {
        if let step {
            Slider(value: $value, in: range, step: step)
                .tint(DemoPalette.accent)
        } else {
            Slider(value: $value, in: range)
                .tint(DemoPalette.accent)
        }
    }
}

struct NoteRow: View {
    var note: FieldNote

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: note.symbol)
                .font(.body)
                .foregroundStyle(DemoPalette.accent)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(note.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                Text(note.place)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}

struct HeaderArtwork: View {
    var progress: CGFloat

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [DemoPalette.duskTop, DemoPalette.duskMid, DemoPalette.duskBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            Image(systemName: "mountain.2.fill")
                .font(.system(size: 120))
                .foregroundStyle(.white.opacity(0.18))
                .offset(y: 24 - 36 * progress)

            Image(systemName: "sun.max.fill")
                .font(.system(size: 34))
                .foregroundStyle(.white.opacity(0.9))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(24)
                .opacity(1 - progress)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}
