import ExyteGrid
import SwiftUI

enum DemoPalette {
    static let page = Color(red: 8 / 255, green: 8 / 255, blue: 10 / 255)
    static let card = Color(red: 16 / 255, green: 16 / 255, blue: 18 / 255)
    static let canvas = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)
    static let stroke = Color.white.opacity(0.12)
    static let ink = Color(red: 245 / 255, green: 245 / 255, blue: 247 / 255)
    static let inkMuted = Color(red: 198 / 255, green: 198 / 255, blue: 204 / 255)
    static let accent = Color(red: 0.32, green: 0.74, blue: 0.70)
}

enum DemoChrome {
    static func chartCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Text(subtitle)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
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
    var caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(String(Int(value.rounded())))
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            Slider(value: $value, in: range, step: step)
                .tint(DemoPalette.accent)
            Text(caption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// One cell. The text is what `.fit` and scroll-mode growing tracks measure.
/// `gridCellBackground` paints the positioned cell, which is how the package examples fill a track.
struct TileFace: View {
    var title: String
    var fill: Color

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold).monospaced())
            .foregroundStyle(Color.white)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .gridCellBackground { _ in
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(fill)
            }
            .gridCellOverlay { _ in
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
            }
    }
}

/// Fixed height so `.fill` receives a real proposal. Inside the page `ScrollView`, an open
/// height is about 10 pt and Grid falls back to scroll-sized tracks.
struct GridWell<Content: View>: View {
    var isMounted: Bool
    var height: CGFloat
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            if isMounted {
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Unmounted")
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
