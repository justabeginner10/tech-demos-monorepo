import FloatingPanel
import SwiftUI
import UIKit

enum PanelStyle {
    static func opaque(cornerRadius: CGFloat, shadowOpacity: Float = 0.16) -> SurfaceAppearance {
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = cornerRadius
        appearance.cornerCurve = .continuous
        appearance.backgroundColor = .systemBackground
        appearance.shadows = [shadow(opacity: shadowOpacity, radius: 16)]
        return appearance
    }

    static func translucent(cornerRadius: CGFloat) -> SurfaceAppearance {
        .transparent(
            borderColor: Color.primary.opacity(0.12),
            borderWidth: 0.6,
            cornerRadius: cornerRadius,
            shadows: [shadow(opacity: 0.22, radius: 18)]
        )
    }

    static func shadow(opacity: Float, radius: CGFloat) -> SurfaceAppearance.Shadow {
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = .black
        shadow.opacity = opacity
        shadow.radius = radius
        shadow.offset = CGSize(width: 0, height: 8)
        return shadow
    }
}

final class DemoSpringBehavior: NSObject, FloatingPanelBehavior {
    var springResponseTime: CGFloat
    var springDecelerationRate: CGFloat
    var projectsMomentum: Bool
    var allowsRubberBand: Bool

    init(
        responseTime: CGFloat,
        decelerationRate: CGFloat,
        projectsMomentum: Bool,
        allowsRubberBand: Bool
    ) {
        self.springResponseTime = responseTime
        self.springDecelerationRate = decelerationRate
        self.projectsMomentum = projectsMomentum
        self.allowsRubberBand = allowsRubberBand
        super.init()
    }

    var momentumProjectionRate: CGFloat {
        projectsMomentum
            ? UIScrollView.DecelerationRate.fast.rawValue
            : UIScrollView.DecelerationRate.normal.rawValue
    }

    func shouldProjectMomentum(
        _ fpc: FloatingPanelController,
        to proposedState: FloatingPanelState
    ) -> Bool {
        projectsMomentum
    }

    func allowsRubberBanding(for edge: UIRectEdge) -> Bool {
        guard allowsRubberBand else { return false }
        return edge == .top || edge == .bottom
    }
}
