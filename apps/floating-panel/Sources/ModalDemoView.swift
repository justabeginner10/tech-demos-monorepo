import FloatingPanel
import SwiftUI

struct ModalDemoView: View {
    @State private var isPresented = false
    @State private var layout = ModalPanelLayout()
    @State private var appearance = PanelStyle.opaque(cornerRadius: 24, shadowOpacity: 0.24)

    var body: some View {
        Group {
            if isPresented {
                modalStage
                    .floatingPanel(
                        coordinator: ModalPanelCoordinator.self,
                        onEvent: handle(_:)
                    ) { proxy in
                        ModalPanelContent {
                            dismissFromButton(proxy)
                        }
                    }
                    .floatingPanelLayout(layout)
                    .floatingPanelSurfaceAppearance(appearance)
                    .floatingPanelContentMode(.fitToBounds)
                    .floatingPanelContentInsetAdjustmentBehavior(.never)
                    .floatingPanelGrabberHandlePadding(12)
                    .floatingPanelBehavior(DemoSpringBehavior(
                        responseTime: 0.35,
                        decelerationRate: 0.99,
                        projectsMomentum: true,
                        allowsRubberBand: true
                    ))
            } else {
                modalStage
            }
        }
    }

    private var modalStage: some View {
        ZStack {
            LinearGradient(
                colors: [DemoPalette.deep, DemoPalette.tide],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "rectangle.portrait.bottomhalf.inset.filled")
                    .font(.system(size: 48))
                    .foregroundStyle(DemoPalette.foam)
                Text("Modal panel")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Text("Presents FloatingPanelController with the SwiftUI coordinator. Swipe down, tap the backdrop, or use Close. Removal interaction is enabled.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 28)

                Button {
                    isPresented = true
                } label: {
                    Label("Present panel", systemImage: "arrow.up.square")
                        .font(.headline)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(.white, in: Capsule())
                        .foregroundStyle(DemoPalette.deep)
                }
                .buttonStyle(.plain)
                .disabled(isPresented)
                .opacity(isPresented ? 0.45 : 1)
            }
        }
    }

    private func handle(_ event: ModalPanelCoordinator.Event) {
        if case .dismissed = event {
            Task { @MainActor in
                isPresented = false
            }
        }
    }

    private func dismissFromButton(_ proxy: FloatingPanelProxy) {
        proxy.controller.dismiss(animated: true) {
            Task { @MainActor in
                isPresented = false
            }
        }
    }
}

final class ModalPanelLayout: NSObject, FloatingPanelLayout {
    override init() {
        super.init()
    }

    var position: FloatingPanelPosition { .bottom }
    var initialState: FloatingPanelState { .half }

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 24, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.48, edge: .bottom, referenceGuide: .safeArea)
        ]
    }

    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        state == .full ? 0.5 : 0.32
    }
}

final class ModalPanelCoordinator: NSObject, FloatingPanelCoordinator, FloatingPanelControllerDelegate {
    enum Event {
        case dismissed
    }

    let action: (Event) -> Void
    let proxy: FloatingPanelProxy

    private weak var presenter: UIViewController?
    private var didPresent = false

    init(action: @escaping (Event) -> Void) {
        self.action = action
        self.proxy = FloatingPanelProxy(controller: FloatingPanelController())
        super.init()
    }

    func setupFloatingPanel<Main, Content>(
        mainHostingController: UIHostingController<Main>,
        contentHostingController: UIHostingController<Content>
    ) where Main: View, Content: View {
        contentHostingController.view.backgroundColor = .clear
        controller.set(contentViewController: contentHostingController)
        controller.isRemovalInteractionEnabled = true
        controller.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        controller.delegate = self
        presenter = mainHostingController

        Task { @MainActor [weak self] in
            for _ in 0..<8 {
                if self?.presentIfPossible() == true { return }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        }
    }

    func onUpdate<Representable>(
        context: UIViewControllerRepresentableContext<Representable>
    ) where Representable: UIViewControllerRepresentable {
        presentIfPossible()
    }

    @discardableResult
    private func presentIfPossible() -> Bool {
        guard !didPresent, let presenter, presenter.view.window != nil, presenter.presentedViewController == nil else {
            return didPresent
        }
        didPresent = true
        presenter.present(controller, animated: true)
        return true
    }

    func floatingPanelDidRemove(_ fpc: FloatingPanelController) {
        action(.dismissed)
    }
}

private struct ModalPanelContent: View {
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Coastal walk")
                        .font(.title2.weight(.bold))
                    Text("Presented modally over the stage")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.body.weight(.bold))
                        .frame(width: 32, height: 32)
                        .background(Color(.secondarySystemBackground), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }

            HStack(spacing: 10) {
                modalAction("Start", symbol: "figure.walk")
                modalAction("Save", symbol: "bookmark")
                modalAction("Share", symbol: "square.and.arrow.up")
            }

            VStack(alignment: .leading, spacing: 8) {
                Label("Swipe down to remove the panel", systemImage: "hand.draw")
                Label("Tap the dimmed backdrop to dismiss", systemImage: "hand.tap")
                Label("Half and full anchors, with grabber", systemImage: "rectangle.split.1x2")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text("The coordinator calls present on the main hosting controller and turns on isRemovalInteractionEnabled. floatingPanelDidRemove reports the dismissal back to SwiftUI.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
    }

    private func modalAction(_ title: String, symbol: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
            Text(title)
                .font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(DemoPalette.foam.opacity(0.7), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
