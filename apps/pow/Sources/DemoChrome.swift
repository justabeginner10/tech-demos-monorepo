import SwiftUI
import UIKit

enum DemoTab: Hashable {
    case live
    case gallery
}

enum DemoAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

/// Semantic colors so chrome stays readable in light and dark.
enum DemoPalette {
    static let page = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)
    static let canvas = Color(.tertiarySystemGroupedBackground)
    static let stroke = Color.primary.opacity(0.18)
    static let ink = Color.primary
    /// Opaque secondary label — `Color.secondary` is ~60% and fails contrast on grouped fills.
    static let inkMuted = Color(
        light: Color(red: 58 / 255, green: 58 / 255, blue: 60 / 255),
        dark: Color(red: 199 / 255, green: 199 / 255, blue: 204 / 255)
    )
    static let accent = Color(red: 0.82, green: 0.16, blue: 0.38)
    static let badge = Color(red: 0.72, green: 0.10, blue: 0.32)
    static let badgeInk = Color.white
    /// Particles on the rose badge (and as they leave it) stay readable.
    static let particle = Color.white
}

extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

enum DemoParticleLayer {
    static let name: String = "playground"
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
            .background(Color.primary.opacity(0.08), in: Capsule())
    }

    static func badge(title: String, systemImage: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 36, weight: .semibold))
            Text(title)
                .font(.headline)
        }
        .foregroundStyle(DemoPalette.badgeInk)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 168)
        .background(DemoPalette.badge, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
                .allowsHitTesting(false)
        }
        .shadow(color: DemoPalette.accent.opacity(0.35), radius: 16, y: 8)
        .accessibilityElement(children: .combine)
    }
}
