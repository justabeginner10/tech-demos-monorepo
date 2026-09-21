import SwiftUI

/// Shared padding / type / corner metrics so every custom style
/// respects `.controlSize` the way system button styles do.
struct DemoControlMetrics {
    var horizontalPadding: CGFloat
    var verticalPadding: CGFloat
    var font: Font
    var cornerRadius: CGFloat

    static func resolve(_ size: ControlSize) -> DemoControlMetrics {
        switch size {
        case .mini:
            DemoControlMetrics(
                horizontalPadding: 10,
                verticalPadding: 5,
                font: .caption.weight(.semibold),
                cornerRadius: 8
            )
        case .small:
            DemoControlMetrics(
                horizontalPadding: 14,
                verticalPadding: 8,
                font: .subheadline.weight(.semibold),
                cornerRadius: 10
            )
        case .regular:
            DemoControlMetrics(
                horizontalPadding: 18,
                verticalPadding: 11,
                font: .body.weight(.semibold),
                cornerRadius: 12
            )
        case .large, .extraLarge:
            DemoControlMetrics(
                horizontalPadding: 22,
                verticalPadding: 14,
                font: .title3.weight(.semibold),
                cornerRadius: 14
            )
        @unknown default:
            DemoControlMetrics(
                horizontalPadding: 18,
                verticalPadding: 11,
                font: .body.weight(.semibold),
                cornerRadius: 12
            )
        }
    }
}
