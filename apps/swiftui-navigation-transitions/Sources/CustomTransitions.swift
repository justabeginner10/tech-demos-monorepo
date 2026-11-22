import SwiftUI
import SwiftUINavigationTransitions
import UIKit

/// Swing from the package example at tag 0.19.1 (`Examples/Demo/Demo/Custom Transitions/Swing.swift`).
struct Swing: NavigationTransitionProtocol {
    var body: some NavigationTransitionProtocol {
        Slide(axis: .horizontal)
        MirrorPush {
            let angle = 70.0
            let offset = 150.0
            OnInsertion {
                ZPosition(1)
                Rotate(.degrees(-angle))
                Offset(x: offset)
                Opacity()
                Scale(0.5)
            }
            OnRemoval {
                Rotate(.degrees(angle))
                Offset(x: -offset)
            }
        }
    }
}

/// Zoom from the package example at tag 0.19.1.
struct Zoom: NavigationTransitionProtocol {
    var body: some NavigationTransitionProtocol {
        MirrorPush {
            Scale(0.5)
            OnInsertion {
                ZPosition(1)
                Opacity()
            }
        }
    }
}

/// Flip from the package example at tag 0.19.1.
struct Flip: NavigationTransitionProtocol {
    var axis: Axis

    var body: some NavigationTransitionProtocol {
        MirrorPush {
            Rotate3D(
                .degrees(180),
                axis: axis == .horizontal ? (x: 1, y: 0, z: 0) : (x: 0, y: 1, z: 0)
            )
        }
    }
}

/// Handler-style transition. `body` is `Never`, so the animator calls `transition(from:to:for:in:)`.
struct Drift: NavigationTransitionProtocol {
    typealias _Body = Never

    @MainActor
    func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
        let travel = container.frame.width * 0.28
        switch operation {
        case .push:
            toView.initial.alpha = 0
            toView.animation.alpha = 1
            toView.initial.transform.translate(x: travel)
            toView.animation.transform = .identity
            fromView.animation.transform.translate(x: -travel * 0.45)
            fromView.completion.transform = .identity
        case .pop:
            fromView.animation.alpha = 0
            fromView.completion.alpha = 1
            fromView.animation.transform.translate(x: travel)
            fromView.completion.transform = .identity
            toView.initial.transform.translate(x: -travel * 0.45)
            toView.animation.transform = .identity
        }
    }
}
