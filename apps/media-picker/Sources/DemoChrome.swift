import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case photos
    case albums
    case camera
    case theme

    var id: String { rawValue }

    var title: String {
        switch self {
        case .photos: "Photos"
        case .albums: "Albums"
        case .camera: "Camera"
        case .theme: "Theme"
        }
    }

    var subtitle: String {
        switch self {
        case .photos: "limit · style · liveCameraCell"
        case .albums: "pickerMode · albums"
        case .camera: "camera · orientationHandler"
        case .theme: "mediaPickerTheme · cellStyle"
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
    static let accent = Color(red: 0.98, green: 0.78, blue: 0.28)
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

struct DemoSlider: View {
    var title: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double
    var format: String = "%.0f"

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
            Slider(value: $value, in: range, step: step)
                .tint(DemoPalette.accent)
        }
    }
}

struct OpenPickerButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.page)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(DemoPalette.accent, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func demoCard() -> some View {
        padding(14)
            .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
            }
    }
}
