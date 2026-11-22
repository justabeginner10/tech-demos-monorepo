import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case api
    case view
    case modifier

    var id: String { rawValue }

    var title: String {
        switch self {
        case .api: "API"
        case .view: "View"
        case .modifier: "Modifier"
        }
    }

    var subtitle: String {
        switch self {
        case .api: "AlertKitAPI.present(title:icon:style:haptic:)"
        case .view: "AlertKitAPI.present(view:completion:)"
        case .modifier: ".alert(isPresent:view:completion:)"
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
    static let accent = Color(red: 1.0, green: 0.38, blue: 0.46)
    /// `AlertAppleMusic17View.defaultContentColor` in dark mode: rgb(127, 127, 129).
    static let packageInk = Color(red: 127 / 255, green: 127 / 255, blue: 129 / 255)
}

enum SketchStyle: Hashable {
    case banner
    case center
}

enum SketchIcon: Hashable {
    case done
    case error
    case heart
    case spinner
    case symbol
    case message
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

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(String(format: "%.1f", value))
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            Slider(value: $value, in: range, step: step)
                .tint(DemoPalette.accent)
        }
    }
}

/// Painted stand-in. The package draws its own check, cross, heart, and spinner.
struct AlertSketch: View {
    var style: SketchStyle
    var icon: SketchIcon
    var title: String
    var subtitle: String?
    var ink: Color = DemoPalette.packageInk

    var body: some View {
        ZStack {
            DemoPalette.canvas
            switch style {
            case .banner:
                banner
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 22)
            case .center:
                center
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 168)
    }

    private var banner: some View {
        HStack(alignment: .center, spacing: 12) {
            sketchIcon(side: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ink)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(ink)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, subtitle == nil ? 17 : 15)
        .frame(maxWidth: 270)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var center: some View {
        VStack(spacing: 8) {
            sketchIcon(side: icon == .heart ? 36 : 44)
            Text(title)
                .font(.title3.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(ink)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(ink)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, icon == .message ? 18 : 28)
        .padding(.bottom, 18)
        .frame(width: 180)
        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private func sketchIcon(side: CGFloat) -> some View {
        switch icon {
        case .message:
            EmptyView()
        case .spinner:
            ProgressView()
                .controlSize(.small)
                .tint(ink)
                .frame(width: side, height: side)
        case .done:
            Image(systemName: "checkmark")
                .font(.system(size: side * 0.72, weight: .semibold))
                .foregroundStyle(ink)
                .frame(width: side, height: side)
        case .error:
            Image(systemName: "xmark")
                .font(.system(size: side * 0.62, weight: .semibold))
                .foregroundStyle(ink)
                .frame(width: side, height: side)
        case .heart:
            Image(systemName: "heart.fill")
                .font(.system(size: side * 0.7, weight: .semibold))
                .foregroundStyle(ink)
                .frame(width: side, height: side * 0.8)
        case .symbol:
            Image(systemName: "star.fill")
                .font(.system(size: side * 0.72, weight: .semibold))
                .foregroundStyle(ink)
                .frame(width: side, height: side)
        }
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
