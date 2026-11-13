import Observation
import SVGView
import SwiftUI

/// One parsed mark. Knobs write the node, then the observed properties re-render `SVGView(svg:)`.
@MainActor
@Observable
final class MarkSession {
    var source: MarkSource = .file
    var root: SVGNode?
    var radius: Double = 52
    var opacity: Double = 1
    var fill: MarkFill = .orange
    var pupilX: Double = 0
    var pupilY: Double = 0
    var taps: Int = 0
    var gesturesOn: Bool = true
    var animates: Bool = true
    var reduceMotion: Bool = false
    var hasLoaded: Bool = false

    func reload() {
        root = source.load()
        push()
        syncGestures()
        hasLoaded = true
    }

    func applyDefaults() {
        source = .file
        radius = 52
        opacity = 1
        fill = .orange
        pupilX = 0
        pupilY = 0
        taps = 0
        gesturesOn = true
        animates = true
        reload()
    }

    func setRadius(_ value: Double) {
        radius = value
        push()
    }

    func setOpacity(_ value: Double) {
        opacity = value
        push()
    }

    func setPupil(x: Double, y: Double) {
        pupilX = min(40, max(-40, x))
        pupilY = min(40, max(-40, y))
        push()
    }

    func select(_ newFill: MarkFill) {
        let change = {
            self.fill = newFill
            self.push()
        }
        if animates && !reduceMotion {
            withAnimation(.easeInOut(duration: 0.35), change)
        } else {
            change()
        }
    }

    func toggleDim() {
        let next = opacity > 0.5 ? 0.35 : 1.0
        let change = {
            self.opacity = next
            self.taps += 1
            self.push()
        }
        if animates && !reduceMotion {
            withAnimation(.easeInOut(duration: 0.35), change)
        } else {
            change()
        }
    }

    func syncGestures() {
        guard let disc = root?.getNode(byId: "disc") else { return }
        disc.removeAllGestures()
        guard gesturesOn else { return }
        disc.onTapGesture(tapClosure: NodeTap.perform { [weak self] in
            self?.toggleDim()
        })
    }

    private func push() {
        guard let root else { return }
        if let disc = root.getNode(byId: "disc") as? SVGCircle {
            disc.r = CGFloat(radius)
            disc.opacity = opacity
            disc.fill = fill.paint
        }
        if let pupil = root.getNode(byId: "pupil") {
            pupil.transform = CGAffineTransform(translationX: CGFloat(pupilX), y: CGFloat(pupilY))
        }
    }
}

/// One mark. Leaving the tab removes the `SVGView`. The node stays on the session.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var session = MarkSession()
    @State private var dragOrigin: CGPoint?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                stage
                callout
                ScrollView {
                    controls
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DemoPalette.page)
            .navigationTitle("SVGView")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
            .onAppear {
                session.reduceMotion = reduceMotion
                if session.root == nil {
                    session.reload()
                }
            }
            .onChange(of: reduceMotion) { _, value in
                session.reduceMotion = value
            }
        }
    }

    private var stage: some View {
        SVGWell(isMounted: isSelected, height: 260) {
            if let root = session.root {
                SVGView(svg: root)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .simultaneousGesture(stageDrag)
            } else if session.hasLoaded {
                Text(session.source.failure)
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.inkMuted)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("Loading")
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
    }

    private var stageDrag: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                let origin = dragOrigin ?? CGPoint(x: session.pupilX, y: session.pupilY)
                if dragOrigin == nil {
                    dragOrigin = origin
                }
                session.setPupil(
                    x: origin.x + value.translation.width,
                    y: origin.y + value.translation.height
                )
            }
            .onEnded { _ in
                dragOrigin = nil
            }
    }

    private var callout: some View {
        Text(readout)
            .font(.caption2.monospaced())
            .foregroundStyle(DemoPalette.ink)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var readout: String {
        let ids = ["plate", "spark", "disc", "pupil"].map { id -> String in
            if session.root?.getNode(byId: id) == nil {
                return "\(id) missing"
            }
            return id
        }.joined(separator: ", ")
        let disc = session.root?.getNode(byId: "disc") as? SVGCircle
        let pupil = session.root?.getNode(byId: "pupil")
        let discType = disc.map { String(describing: type(of: $0)) } ?? "missing"
        let radiusText = disc.map { String(format: "%.0f", Double($0.r)) } ?? "—"
        let opacityText = disc.map { String(format: "%.2f", $0.opacity) } ?? "—"
        let tx = pupil.map { String(format: "%.0f", Double($0.transform.tx)) } ?? "—"
        let ty = pupil.map { String(format: "%.0f", Double($0.transform.ty)) } ?? "—"
        let frameText = disc.map { circle in
            let box = circle.frame()
            return String(format: "%.0f×%.0f", Double(box.width), Double(box.height))
        } ?? "—"
        return """
        \(session.source.call)
        SVGView(svg:) · \(discType) · ids \(ids)
        r \(radiusText) opacity \(opacityText) frame \(frameText) · pupil tx \(tx) ty \(ty) · taps \(session.taps)
        """
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            segmented("Source", selection: sourceBinding) { Text($0.title) }
            Text("File, string, and data parse the same markup. Nodes builds that tree with SVGCircle, SVGRect, SVGPolygon, and SVGViewport.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            DemoSlider(
                title: "Disc radius",
                value: radiusBinding,
                range: 24...70,
                step: 1,
                caption: "getNode(byId: \"disc\") as SVGCircle, then r. r is @Published on SVGCircle."
            )
            DemoSlider(
                title: "Disc opacity",
                value: opacityBinding,
                range: 0.15...1,
                step: 0.05,
                caption: "SVGNode.opacity. A tap on the disc toggles 0.35 and 1 through onTapGesture."
            )
            DemoSlider(
                title: "Pupil x",
                value: pupilXBinding,
                range: -40...40,
                step: 1,
                caption: "CGAffineTransform(translationX:y:) on the pupil. Drag the stage to write the same transform."
            )
            DemoSlider(
                title: "Pupil y",
                value: pupilYBinding,
                range: -40...40,
                step: 1,
                caption: "addGesture drops the gesture value, so the drag is a SwiftUI DragGesture on the stage."
            )

            fillRow

            Toggle("Node tap", isOn: gesturesBinding)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            Text(gestureCaption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            Toggle("Animate tap and fill", isOn: animatesBinding)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            Text(animationCaption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            Button("Package defaults") {
                session.applyDefaults()
            }
            .buttonStyle(.bordered)
            .tint(DemoPalette.accent)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
        .padding(.bottom, 8)
    }

    private var fillRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Disc fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            HStack(spacing: 12) {
                ForEach(MarkFill.allCases) { swatch in
                    Button {
                        session.select(swatch)
                    } label: {
                        Circle()
                            .fill(swatch.color)
                            .frame(width: 28, height: 28)
                            .overlay {
                                Circle()
                                    .strokeBorder(
                                        DemoPalette.ink,
                                        lineWidth: swatch == session.fill ? 2 : 0
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(swatch.title)
                }
            }
            Text("SVGColor(hex:) assigned to SVGCircle.fill. The package README constructs SVGColor the same way.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var gestureCaption: String {
        if session.gesturesOn {
            return "onTapGesture is installed on disc. Off calls removeAllGestures. The gesture list is read on the next render."
        }
        return "removeAllGestures cleared the disc. The stage drag still moves the pupil."
    }

    private var animationCaption: String {
        if reduceMotion {
            return "Reduce Motion is on, so the tap and the fill swatches assign the new value directly."
        }
        if session.animates {
            return "withAnimation wraps the tap's opacity write and the fill swatch. Sliders and the drag assign directly."
        }
        return "Animate is off, so the tap and the fill swatches assign the new value directly."
    }

    private var sourceBinding: Binding<MarkSource> {
        Binding(
            get: { session.source },
            set: { newValue in
                session.source = newValue
                session.reload()
            }
        )
    }

    private var radiusBinding: Binding<Double> {
        Binding(get: { session.radius }, set: { session.setRadius($0) })
    }

    private var opacityBinding: Binding<Double> {
        Binding(get: { session.opacity }, set: { session.setOpacity($0) })
    }

    private var pupilXBinding: Binding<Double> {
        Binding(
            get: { session.pupilX },
            set: { session.setPupil(x: $0, y: session.pupilY) }
        )
    }

    private var pupilYBinding: Binding<Double> {
        Binding(
            get: { session.pupilY },
            set: { session.setPupil(x: session.pupilX, y: $0) }
        )
    }

    private var gesturesBinding: Binding<Bool> {
        Binding(
            get: { session.gesturesOn },
            set: { newValue in
                session.gesturesOn = newValue
                session.syncGestures()
            }
        )
    }

    private var animatesBinding: Binding<Bool> {
        Binding(get: { session.animates }, set: { session.animates = $0 })
    }

    private func segmented<Choice: Hashable, Label: View>(
        _ title: String,
        selection: Binding<Choice>,
        @ViewBuilder label: @escaping (Choice) -> Label
    ) -> some View where Choice: CaseIterable & Identifiable, Choice.AllCases: RandomAccessCollection {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Picker(title, selection: selection) {
                ForEach(Array(Choice.allCases)) { choice in
                    label(choice).tag(choice)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
