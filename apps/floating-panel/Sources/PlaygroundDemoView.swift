import FloatingPanel
import SwiftUI
import UIKit

struct PlaygroundChrome: Equatable {
    var showsGrabber = true
    var backdropOpacity = 0.4
    var tapToDismiss = false
    var tracksScroll = true
    var scrollsInHalf = false
}

private struct PlaygroundChromeKey: EnvironmentKey {
    static let defaultValue = PlaygroundChrome()
}

extension EnvironmentValues {
    var playgroundChrome: PlaygroundChrome {
        get { self[PlaygroundChromeKey.self] }
        set { self[PlaygroundChromeKey.self] = newValue }
    }
}

struct PlaygroundDemoView: View {
    @State private var showPanel = true
    @State private var panelState: FloatingPanelState?
    @State private var layout = PlaygroundLayout(backdropOpacity: 0.4)
    @State private var cornerRadius = 22.0
    @State private var translucent = false
    @State private var appearance = PanelStyle.opaque(cornerRadius: 22, shadowOpacity: 0.18)
    @State private var grabberPadding = 10.0
    @State private var fitToBounds = false
    @State private var adjustInsets = true
    @State private var springResponse = 0.4
    @State private var springDeceleration = 0.991
    @State private var projectMomentum = true
    @State private var rubberBanding = false
    @State private var chrome = PlaygroundChrome()

    var body: some View {
        Group {
            if showPanel {
                canvas
                    .floatingPanel(
                        coordinator: PlaygroundCoordinator.self,
                        onEvent: handle(_:)
                    ) { proxy in
                        PlaygroundPanel(
                            proxy: proxy,
                            tracksScroll: chrome.tracksScroll,
                            translucent: translucent,
                            panelState: panelState,
                            cornerRadius: $cornerRadius,
                            grabberPadding: $grabberPadding,
                            springResponse: $springResponse,
                            springDeceleration: $springDeceleration,
                            chrome: $chrome,
                            translucentSurface: $translucent,
                            fitToBounds: $fitToBounds,
                            adjustInsets: $adjustInsets,
                            projectMomentum: $projectMomentum,
                            rubberBanding: $rubberBanding,
                            move: move(to:)
                        )
                    }
                    .floatingPanelLayout(layout)
                    .floatingPanelState($panelState)
                    .floatingPanelSurfaceAppearance(appearance)
                    .floatingPanelBehavior(currentBehavior)
                    .floatingPanelContentMode(fitToBounds ? .fitToBounds : .static)
                    .floatingPanelContentInsetAdjustmentBehavior(adjustInsets ? .always : .never)
                    .floatingPanelGrabberHandlePadding(chrome.showsGrabber ? grabberPadding : 0)
                    .environment(\.playgroundChrome, chrome)
            } else {
                canvas
            }
        }
        .onChange(of: cornerRadius) { _, _ in
            refreshAppearance()
        }
        .onChange(of: translucent) { _, _ in
            refreshAppearance()
        }
        .onChange(of: chrome.backdropOpacity) { _, newValue in
            layout.backdropOpacity = CGFloat(newValue)
        }
    }

    private var canvas: some View {
        ZStack {
            LinearGradient(
                colors: [DemoPalette.coral.opacity(0.85), DemoPalette.tide, DemoPalette.deep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "slider.horizontal.3")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                Text("Customization canvas")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                Text(showPanel
                     ? "Drag the panel. Backdrop opacity follows the layout for half and full."
                     : "The panel was removed. Show it again to keep tuning.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 32)

                if !showPanel {
                    Button {
                        showPanel = true
                        panelState = .half
                    } label: {
                        Label("Show panel", systemImage: "rectangle.bottomthird.inset.filled")
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(.white, in: Capsule())
                            .foregroundStyle(DemoPalette.deep)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.top, 28)
        }
    }

    private var currentBehavior: DemoSpringBehavior {
        DemoSpringBehavior(
            responseTime: springResponse,
            decelerationRate: springDeceleration,
            projectsMomentum: projectMomentum,
            allowsRubberBand: rubberBanding
        )
    }

    private func move(to state: FloatingPanelState) {
        withAnimation(.spring(response: springResponse, dampingFraction: 0.86)) {
            panelState = state
        }
    }

    private func refreshAppearance() {
        if translucent {
            appearance = PanelStyle.translucent(cornerRadius: cornerRadius)
        } else {
            appearance = PanelStyle.opaque(cornerRadius: cornerRadius)
        }
    }

    private func handle(_ event: PlaygroundCoordinator.Event) {
        if case .removed = event {
            Task { @MainActor in
                showPanel = false
            }
        }
    }
}

final class PlaygroundLayout: NSObject, FloatingPanelLayout {
    var backdropOpacity: CGFloat

    init(backdropOpacity: CGFloat) {
        self.backdropOpacity = backdropOpacity
        super.init()
    }

    var position: FloatingPanelPosition { .bottom }
    var initialState: FloatingPanelState { .half }

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 12, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.62, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 148, edge: .bottom, referenceGuide: .safeArea)
        ]
    }

    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        if state == .full { return backdropOpacity }
        if state == .half { return backdropOpacity * 0.45 }
        return 0
    }
}

final class PlaygroundCoordinator: NSObject, FloatingPanelCoordinator, FloatingPanelControllerDelegate {
    enum Event {
        case removed
    }

    let action: (Event) -> Void
    let proxy: FloatingPanelProxy

    private var appliedChrome: PlaygroundChrome?
    private var tracksScroll = true
    private var scrollsInHalf = false

    init(action: @escaping (Event) -> Void) {
        self.action = action
        self.proxy = FloatingPanelProxy(controller: FloatingPanelController())
        super.init()
    }

    func setupFloatingPanel<Main, Content>(
        mainHostingController: UIHostingController<Main>,
        contentHostingController: UIHostingController<Content>
    ) where Main: View, Content: View {
        controller.delegate = self
        contentHostingController.view.backgroundColor = .clear
        controller.set(contentViewController: contentHostingController)
        controller.addPanel(toParent: mainHostingController, animated: false)
        controller.surfaceView.grabberHandle.barColor = .secondaryLabel
    }

    func onUpdate<Representable>(
        context: UIViewControllerRepresentableContext<Representable>
    ) where Representable: UIViewControllerRepresentable {
        let chrome = context.environment.playgroundChrome
        tracksScroll = chrome.tracksScroll
        scrollsInHalf = chrome.scrollsInHalf

        if appliedChrome != chrome {
            controller.surfaceView.grabberHandle.isHidden = !chrome.showsGrabber
            controller.backdropView.dismissalTapGestureRecognizer.isEnabled = chrome.tapToDismiss
            if let layout = controller.layout as? PlaygroundLayout {
                layout.backdropOpacity = CGFloat(chrome.backdropOpacity)
            }
            if !chrome.tracksScroll, let scrollView = controller.trackingScrollView {
                controller.untrack(scrollView: scrollView)
            }
            appliedChrome = chrome
            controller.backdropView.alpha = backdropAlpha(for: controller.state, opacity: CGFloat(chrome.backdropOpacity))
        }
    }

    func floatingPanel(
        _ fpc: FloatingPanelController,
        shouldAllowToScroll scrollView: UIScrollView,
        in state: FloatingPanelState
    ) -> Bool {
        guard tracksScroll else { return false }
        if state == .full { return true }
        return scrollsInHalf && state == .half
    }

    func floatingPanelDidRemove(_ fpc: FloatingPanelController) {
        action(.removed)
    }

    private func backdropAlpha(for state: FloatingPanelState, opacity: CGFloat) -> CGFloat {
        if state == .full { return opacity }
        if state == .half { return opacity * 0.45 }
        return 0
    }
}

private struct PlaygroundPanel: View {
    var proxy: FloatingPanelProxy
    var tracksScroll: Bool
    var translucent: Bool
    var panelState: FloatingPanelState?
    @Binding var cornerRadius: Double
    @Binding var grabberPadding: Double
    @Binding var springResponse: Double
    @Binding var springDeceleration: Double
    @Binding var chrome: PlaygroundChrome
    @Binding var translucentSurface: Bool
    @Binding var fitToBounds: Bool
    @Binding var adjustInsets: Bool
    @Binding var projectMomentum: Bool
    @Binding var rubberBanding: Bool
    var move: (FloatingPanelState) -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            trackingContainer
        }
        .background(panelBackground)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Playground")
                    .font(.title3.weight(.bold))
                Spacer()
                Text(panelStateTitle(panelState))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                anchorButton("Tip", state: .tip)
                anchorButton("Half", state: .half)
                anchorButton("Full", state: .full)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private var trackingContainer: some View {
        if tracksScroll {
            controlsScroll
                .floatingPanelScrollTracking(proxy: proxy)
        } else {
            controlsScroll
        }
    }

    private var controlsScroll: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                surfaceSection
                backdropSection
                interactionSection
                springSection
                sampleRows
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
    }

    private var surfaceSection: some View {
        section("Surface") {
            Picker("Fill", selection: $translucentSurface) {
                Text("Opaque").tag(false)
                Text("Translucent").tag(true)
            }
            .pickerStyle(.segmented)

            labeledSlider("Corner radius", value: cornerRadius, range: "0–36") {
                Slider(value: $cornerRadius, in: 0...36, step: 1)
            }

            Toggle("Show grabber", isOn: $chrome.showsGrabber)
            labeledSlider("Grabber padding", value: grabberPadding, range: "0–28") {
                Slider(value: $grabberPadding, in: 0...28, step: 1)
            }
            .disabled(!chrome.showsGrabber)
        }
    }

    private var backdropSection: some View {
        section("Backdrop") {
            labeledSlider("Opacity at full", value: chrome.backdropOpacity, range: "0–0.75") {
                Slider(value: $chrome.backdropOpacity, in: 0...0.75, step: 0.01)
            }
            Toggle("Tap backdrop to dismiss", isOn: $chrome.tapToDismiss)
            Text("Tap-to-dismiss removes the panel. Use Show panel on the canvas to present it again.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var interactionSection: some View {
        section("Content") {
            Toggle("Scroll tracking", isOn: $chrome.tracksScroll)
            Toggle("Allow scroll at half", isOn: $chrome.scrollsInHalf)
                .disabled(!chrome.tracksScroll)
            Toggle("Fit content to bounds", isOn: $fitToBounds)
            Toggle("Adjust scroll insets", isOn: $adjustInsets)
            Text("Scroll tracking links the list to the panel. Scrolling is allowed at full, and at half when that toggle is on.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var springSection: some View {
        section("Spring behavior") {
            labeledSlider("Response time", value: springResponse, range: "seconds") {
                Slider(value: $springResponse, in: 0.2...0.9, step: 0.01)
            }
            labeledSlider("Deceleration", value: springDeceleration, range: "0.979–1") {
                Slider(value: $springDeceleration, in: 0.979...0.999, step: 0.001)
            }
            Text("0.979 is nearly critically damped. Values closer to 1 bounce more. The library ignores rates under 0.979.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Toggle("Project momentum", isOn: $projectMomentum)
            Toggle("Rubber banding", isOn: $rubberBanding)
        }
    }

    private var sampleRows: some View {
        section("Scroll sample") {
            ForEach(1...18, id: \.self) { index in
                HStack(spacing: 12) {
                    Image(systemName: index.isMultiple(of: 2) ? "mappin.circle.fill" : "star.circle.fill")
                        .font(.title3)
                        .foregroundStyle(DemoPalette.tide)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sample row \(index)")
                            .font(.body.weight(.semibold))
                        Text("Tracked with the panel when scroll tracking is on.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var panelBackground: some View {
        Group {
            if translucent {
                Rectangle().fill(.regularMaterial)
            } else {
                Color(.systemBackground)
            }
        }
        .frame(height: 1800)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func anchorButton(_ title: String, state: FloatingPanelState) -> some View {
        let selected = panelState == state
        return Button {
            move(state)
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .foregroundStyle(selected ? Color.white : Color.primary)
                .background(
                    selected ? DemoPalette.tide : Color(.secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
        }
        .buttonStyle(.plain)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func labeledSlider<SliderControl: View>(
        _ title: String,
        value: Double,
        range: String,
        @ViewBuilder slider: () -> SliderControl
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(value.formatted(.number.precision(.fractionLength(value < 2 ? 3 : 0))))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Text(range)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            slider()
        }
    }
}
