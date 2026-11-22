import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case load
    case process
    case retry
    case cache

    var id: String { rawValue }

    var title: String {
        switch self {
        case .load: "Load"
        case .process: "Process"
        case .retry: "Retry"
        case .cache: "Cache"
        }
    }

    var subtitle: String {
        switch self {
        case .load: "KFImage · placeholder · fade"
        case .process: "Downsampling · RoundCorner · Blur"
        case .retry: "DelayRetryStrategy · onFailureView"
        case .cache: "ImageCache · memory · disk"
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
                    .multilineTextAlignment(.trailing)
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

    static func placeholder(progress: Progress, caption: String) -> some View {
        ZStack {
            DemoPalette.canvas
            VStack(spacing: 8) {
                if progress.totalUnitCount > 0 {
                    ProgressView(value: min(max(progress.fractionCompleted, 0), 1))
                        .tint(DemoPalette.accent)
                        .padding(.horizontal, 36)
                } else {
                    ProgressView()
                        .tint(DemoPalette.accent)
                }
                Text(progress.totalUnitCount > 0
                    ? "\(Int((progress.fractionCompleted * 100).rounded()))%"
                    : caption)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    func photoFrame(height: CGFloat = 220) -> some View {
        frame(maxWidth: .infinity)
            .frame(height: height)
            .background(DemoPalette.canvas)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }
    }
}
