import Observation
import SwiftUI
import Wave

/// Builds the closure stored on `SpringAnimator.valueChanged` / `completion`.
/// Those properties are nonisolated. A closure born in a `@MainActor` init would be
/// main-actor isolated and would not match. The package calls back on the main
/// display link, so `MainActor.assumeIsolated` is the synchronous hop.
enum AnimatorSink {
    nonisolated static func values<T>(
        _ body: @escaping @MainActor (T) -> Void
    ) -> (T) -> Void {
        { value in
            MainActor.assumeIsolated {
                body(value)
            }
        }
    }
}

// MARK: - Drag

/// Drag and fling, matching the package's `SwiftUIView` sample, plus `project(point:velocity:)`.
/// Position uses `Spring(dampingRatio: 0.72, response: 0.70)` from that sample.
/// Scale uses `Spring.defaultInteractive` while tracking and `Spring.defaultAnimated` on release.
@MainActor
@Observable
final class DragSession {
    var offset: CGPoint = .zero
    var scale: CGFloat = 1
    var aim: CGPoint = .zero
    var positionState: String = "inactive"
    var scaleState: String = "inactive"

    let releaseSpring: WaveSpring
    let position: SpringAnimator<CGPoint>
    let scaleAnimator: SpringAnimator<CGFloat>

    init() {
        let release = WaveSpring(dampingRatio: 0.72, response: 0.70)
        releaseSpring = release
        position = SpringAnimator(spring: release, value: .zero, target: .zero)
        scaleAnimator = SpringAnimator(
            spring: WaveSpring.defaultAnimated,
            value: 1,
            target: 1
        )
        position.valueChanged = AnimatorSink.values { [weak self] value in
            self?.offset = value
            self?.refreshStatus()
        }
        position.completion = AnimatorSink.values { [weak self] (_: SpringAnimator<CGPoint>.Event) in
            self?.refreshStatus()
        }
        scaleAnimator.valueChanged = AnimatorSink.values { [weak self] value in
            self?.scale = value
            self?.refreshStatus()
        }
        scaleAnimator.completion = AnimatorSink.values { [weak self] (_: SpringAnimator<CGFloat>.Event) in
            self?.refreshStatus()
        }
        refreshStatus()
    }

    func beginScale() {
        scaleAnimator.mode = .animated
        scaleAnimator.spring = .defaultInteractive
        scaleAnimator.target = 1.16
        if scaleAnimator.state != .running {
            scaleAnimator.velocity = 0
            scaleAnimator.start()
        }
    }

    /// `AnimationMode.nonAnimated` so the puck tracks the finger instead of springing behind it.
    func track(from origin: CGPoint, translation: CGSize) {
        let target = CGPoint(
            x: origin.x + translation.width,
            y: origin.y + translation.height
        )
        aim = target
        position.mode = .nonAnimated
        position.target = target
        position.start()
    }

    /// Injects the gesture velocity, then settles on Wave's projected point clamped into the stage.
    func fling(velocity: CGPoint, in stage: CGSize) {
        let current = position.value ?? offset
        let projected = project(point: current, velocity: velocity)
        let landing = Self.clamp(projected, in: stage)
        aim = landing
        position.mode = .animated
        position.spring = releaseSpring
        position.velocity = velocity
        position.target = landing
        if position.state != .running {
            position.start()
        }

        scaleAnimator.mode = .animated
        scaleAnimator.spring = .defaultAnimated
        scaleAnimator.velocity = 0
        scaleAnimator.target = 1
        if scaleAnimator.state != .running {
            scaleAnimator.start()
        }
        refreshStatus()
    }

    /// Retargets to the origin without clearing velocity, so an in-flight fling arcs home.
    func sendHome() {
        aim = .zero
        position.mode = .animated
        position.spring = releaseSpring
        position.target = .zero
        if position.state != .running {
            position.start()
        }
        scaleAnimator.mode = .animated
        scaleAnimator.spring = .defaultAnimated
        scaleAnimator.target = 1
        if scaleAnimator.state != .running {
            scaleAnimator.velocity = 0
            scaleAnimator.start()
        }
        refreshStatus()
    }

    func stopAll() {
        position.stop(immediately: true)
        scaleAnimator.stop(immediately: true)
    }

    private func refreshStatus() {
        positionState = WaveFormat.state(position.state)
        scaleState = WaveFormat.state(scaleAnimator.state)
    }

    /// Keeps the landing, and a typical overshoot, inside the clipped stage.
    private static func clamp(_ point: CGPoint, in stage: CGSize) -> CGPoint {
        let inset: CGFloat = 88
        let limitX = max(0, stage.width / 2 - inset)
        let limitY = max(0, stage.height / 2 - inset)
        let x = min(max(point.x, -limitX), limitX)
        let y = min(max(point.y, -limitY), limitY)
        return CGPoint(x: x, y: y)
    }
}

struct DragSurface: View {
    @State private var session = DragSession()
    @State private var dragging = false
    @State private var dragOrigin: CGPoint = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            stage
        }
        .onDisappear {
            session.stopAll()
        }
    }

    /// A non-animated drag finishes inside each `start()`, so `state` is `.ended` while the finger is down.
    private var statusLine: String {
        if dragging {
            return "position tracking · scale \(session.scaleState)"
        }
        return "position \(session.positionState) · scale \(session.scaleState)"
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Drag and fling")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text("CGPoint · CGFloat")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Button("Spring home") {
                session.sendHome()
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
            .foregroundStyle(Color.black)

            Text(statusLine)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(
                "Drag uses AnimationMode.nonAnimated. Release copies the gesture velocity "
                    + "(points per second) onto the animator and aims at project(point:velocity:). "
                    + "Spring home changes target and keeps velocity."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    private var stage: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .strokeBorder(DemoPalette.inkMuted.opacity(0.7), lineWidth: 1)
                    .frame(width: 16, height: 16)
                    .offset(x: session.aim.x, y: session.aim.y)
                    .allowsHitTesting(false)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(DemoPalette.accent)
                    .frame(width: 72, height: 72)
                    .overlay {
                        Text("Wave")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.black)
                    }
                    .scaleEffect(session.scale)
                    .offset(x: session.offset.x, y: session.offset.y)
                    .allowsHitTesting(false)

                Text("Drag the stage. The ring is the target.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(DemoPalette.card.opacity(0.88), in: Capsule())
                    .allowsHitTesting(false)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 12)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !dragging {
                            dragging = true
                            dragOrigin = session.position.value ?? session.offset
                            session.beginScale()
                        }
                        session.track(from: dragOrigin, translation: value.translation)
                    }
                    .onEnded { value in
                        dragging = false
                        let velocity = CGPoint(x: value.velocity.width, y: value.velocity.height)
                        session.fling(velocity: velocity, in: proxy.size)
                    }
            )
        }
        .motionStage()
    }
}

// MARK: - Springs

/// One `SpringAnimator<CGFloat>` whose spring and mode follow the selected preset.
@MainActor
@Observable
final class SpringsSession {
    var travel: CGFloat = 0
    var metrics: String = ""
    var lastEvent: String = "No event yet."
    private(set) var preset: SpringPreset = .bouncy

    let animator: SpringAnimator<CGFloat>
    private var ignoreNextEvent = false

    init() {
        animator = SpringAnimator(
            spring: SpringPreset.bouncy.spring,
            value: 0,
            target: 0
        )
        animator.mode = SpringPreset.bouncy.mode
        animator.valueChanged = AnimatorSink.values { [weak self] value in
            self?.travel = value
            self?.refreshMetrics()
        }
        animator.completion = AnimatorSink.values { [weak self] event in
            self?.note(event)
        }
        refreshMetrics()
    }

    func select(_ newPreset: SpringPreset) {
        let current = animator.value ?? travel
        let destination = animator.target ?? 0
        let wasRunning = animator.state == .running
        if wasRunning {
            ignoreNextEvent = true
            animator.stop(immediately: true)
            animator.value = current
            animator.velocity = 0
        }
        preset = newPreset
        animator.spring = newPreset.spring
        animator.mode = newPreset.mode
        animator.target = destination
        if wasRunning {
            animator.start()
        }
        refreshMetrics()
    }

    /// Flips the target. An in-flight run retargets and keeps its velocity.
    func run() {
        let currentTarget = animator.target ?? 0
        let destination: CGFloat = currentTarget >= 0.5 ? 0 : 1
        animator.spring = preset.spring
        animator.mode = preset.mode
        animator.target = destination
        if animator.state != .running {
            animator.velocity = 0
            animator.start()
        }
        refreshMetrics()
    }

    func stopAll() {
        ignoreNextEvent = true
        animator.stop(immediately: true)
    }

    private func note(_ event: SpringAnimator<CGFloat>.Event) {
        if ignoreNextEvent {
            ignoreNextEvent = false
            refreshMetrics()
            return
        }
        switch event {
        case .finished(let value):
            lastEvent = "finished at \(WaveFormat.decimal(value))"
        case .retargeted(let from, let to):
            let fromText = WaveFormat.decimal(from)
            let toText = WaveFormat.decimal(to)
            lastEvent = "retargeted \(fromText) → \(toText)"
        }
        refreshMetrics()
    }

    private func refreshMetrics() {
        let spring = animator.spring
        let damping = WaveFormat.decimal(spring.dampingRatio)
        let response = WaveFormat.decimal(spring.response)
        let stiffness = WaveFormat.decimal(spring.stiffness)
        let mass = WaveFormat.decimal(spring.mass)
        let settling = WaveFormat.decimal(CGFloat(spring.settlingDuration))
        let mode = WaveFormat.mode(animator.mode)
        let state = WaveFormat.state(animator.state)
        metrics = "damping \(damping) · response \(response) · stiffness \(stiffness) · mass \(mass) · settling \(settling)s · \(mode) · \(state)"
    }
}

struct SpringsSurface: View {
    @State private var session = SpringsSession()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            track
        }
        .onDisappear {
            session.stopAll()
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(session.preset.title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(session.preset.api)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .lineLimit(1)
            }

            Picker("Spring", selection: Binding(
                get: { session.preset },
                set: { session.select($0) }
            )) {
                ForEach(SpringPreset.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .tint(DemoPalette.ink)

            Button("Run") {
                session.run()
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
            .foregroundStyle(Color.black)

            Text(session.preset.detail)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            Text(session.metrics)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(session.lastEvent)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    private var track: some View {
        GeometryReader { proxy in
            let travel = max(0, proxy.size.width - 36)
            // 0 sits on the left, 1 on the right. Values outside that range show overshoot.
            let x = (session.travel - 0.5) * travel
            ZStack {
                Capsule()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: travel, height: 4)

                Circle()
                    .fill(DemoPalette.accent)
                    .frame(width: 28, height: 28)
                    .offset(x: x)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .motionStage()
    }
}

// MARK: - Retarget

private enum Dock: String, CaseIterable, Identifiable, Hashable {
    case leading
    case center
    case trailing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .leading: "Leading"
        case .center: "Center"
        case .trailing: "Trailing"
        }
    }

    func point(in stage: CGSize) -> CGPoint {
        let reach = max(0, stage.width / 2 - 64)
        switch self {
        case .leading:
            return CGPoint(x: -reach, y: 0)
        case .center:
            return .zero
        case .trailing:
            return CGPoint(x: reach, y: 0)
        }
    }
}

/// Taps change `target` while the animator is running. Velocity is left alone.
@MainActor
@Observable
final class RetargetSession {
    var offset: CGPoint = .zero
    var status: String = "inactive"
    var events: [String] = []

    let animator: SpringAnimator<CGPoint>
    private let spring = WaveSpring(dampingRatio: 0.62, response: 0.90)
    private var ignoreNextEvent = false

    init() {
        animator = SpringAnimator(spring: spring, value: .zero, target: .zero)
        animator.mode = .animated
        animator.valueChanged = AnimatorSink.values { [weak self] value in
            self?.offset = value
            self?.refreshStatus()
        }
        animator.completion = AnimatorSink.values { [weak self] event in
            self?.note(event)
        }
        refreshStatus()
    }

    func retarget(to point: CGPoint) {
        animator.mode = .animated
        animator.spring = spring
        animator.target = point
        if animator.state != .running {
            animator.start()
        }
        refreshStatus()
    }

    /// Kicks the animator without changing `target`, so the spring pulls it back.
    /// Stopping a running animator restarts the settling clock; otherwise a late toss
    /// would cross `settlingDuration` on the next tick and snap to the target.
    func toss() {
        let destination = animator.target ?? .zero
        let current = animator.value ?? offset
        if animator.state == .running {
            ignoreNextEvent = true
            animator.stop(immediately: true)
        }
        animator.value = current
        animator.mode = .animated
        animator.spring = spring
        animator.velocity = CGPoint(x: 1100, y: 260)
        animator.target = destination
        animator.start()
        refreshStatus()
    }

    func stopAll() {
        ignoreNextEvent = true
        animator.stop(immediately: true)
    }

    private func note(_ event: SpringAnimator<CGPoint>.Event) {
        if ignoreNextEvent {
            ignoreNextEvent = false
            refreshStatus()
            return
        }
        let line: String
        switch event {
        case .finished(let value):
            line = "finished at \(WaveFormat.point(value))"
        case .retargeted(let from, let to):
            line = "retargeted \(WaveFormat.point(from)) → \(WaveFormat.point(to))"
        }
        events.insert(line, at: 0)
        if events.count > 4 {
            events.removeLast()
        }
        refreshStatus()
    }

    private func refreshStatus() {
        status = WaveFormat.state(animator.state)
    }
}

struct RetargetSurface: View {
    @State private var session = RetargetSession()
    @State private var dock: Dock = .center
    @State private var stageSize: CGSize = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            stage
        }
        .onDisappear {
            session.stopAll()
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Retarget")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(session.status)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Picker("Dock", selection: $dock) {
                ForEach(Dock.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: dock) { _, newValue in
                session.retarget(to: newValue.point(in: stageSize))
            }

            Button("Toss") {
                session.toss()
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
            .foregroundStyle(Color.black)

            Text(
                "Spring(dampingRatio: 0.62, response: 0.90). Changing target while running "
                    + "keeps velocity and emits Event.retargeted. Toss writes velocity and leaves target put."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 4) {
                if session.events.isEmpty {
                    Text("Events land here.")
                        .font(.caption.monospaced())
                        .foregroundStyle(DemoPalette.inkMuted)
                } else {
                    ForEach(Array(session.events.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.caption.monospaced())
                            .foregroundStyle(DemoPalette.ink)
                    }
                }
            }
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    private var stage: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Dock.allCases) { item in
                    let point = item.point(in: proxy.size)
                    Circle()
                        .strokeBorder(
                            item == dock ? DemoPalette.accent : DemoPalette.inkMuted,
                            lineWidth: item == dock ? 2 : 1
                        )
                        .frame(width: 22, height: 22)
                        .offset(x: point.x, y: point.y)
                        .allowsHitTesting(false)
                }

                Circle()
                    .fill(DemoPalette.accent)
                    .frame(width: 28, height: 28)
                    .offset(x: session.offset.x, y: session.offset.y)
                    .allowsHitTesting(false)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .onAppear {
                stageSize = proxy.size
            }
            .onChange(of: proxy.size) { _, newValue in
                stageSize = newValue
            }
        }
        .motionStage()
    }
}
