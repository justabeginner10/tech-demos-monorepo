import FloatingButton
import SwiftUI

/// Straight line of icon buttons. Layout knobs that `calculateCoordsStraight` reads
/// remount the menu. Motion knobs are read in `body` and update without a remount.
struct StraightSurface: View {
    @State private var isOpen = false
    @State private var usesBinding = true
    @State private var lastTapped = "—"
    @State private var count = 3
    @State private var direction: StraightDirection = .left
    @State private var rowAlignment: RowAlignment = .center
    @State private var spacing = 10.0
    @State private var offsetX = 0.0
    @State private var offsetY = 0.0
    @State private var stack: StackAnchor = .center
    @State private var initialScaling = 1.0
    @State private var initialOpacity = 1.0
    @State private var curve: MotionCurve = .easeInOut
    @State private var delayChoice: DelayChoice = .none
    @State private var delayDelta = 0.1
    @State private var inverseZIndex = false
    @State private var wholeSize = CGSize.zero
    @State private var buttonsSize = CGSize.zero

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MenuStage(anchor: direction.anchor) {
                menu
            }
            .onChange(of: layoutToken) { _, _ in
                wholeSize = .zero
                buttonsSize = .zero
            }
            .onChange(of: usesBinding) { _, bindingOn in
                if !bindingOn {
                    isOpen = false
                }
            }

            MenuReadout(
                isOpen: usesBinding ? isOpen : false,
                lastTapped: lastTapped,
                whole: wholeSize,
                buttons: buttonsSize,
                note: sizeNote
            )

            ScrollView {
                controls
                    .padding(.bottom, 12)
            }
        }
    }

    private var menu: some View {
        applyShared(
            applyRowAlignment(
                applyDirection(
                    base
                        .straight()
                        .initialOffset(x: CGFloat(offsetX), y: CGFloat(offsetY))
                        .mainZStackAlignment(stack.value),
                    direction
                ),
                rowAlignment
            ),
            spacing: spacing,
            initialScaling: initialScaling,
            initialOpacity: initialOpacity,
            curve: curve,
            delayChoice: delayChoice,
            delayDelta: delayDelta,
            count: count,
            inverseZIndex: inverseZIndex,
            wholeSize: $wholeSize,
            buttonsSize: $buttonsSize
        )
        .id(layoutToken)
    }

    private var base: FloatingButton<MainDisc, SubmenuDisc> {
        let main = MainDisc(isOpen: usesBinding && isOpen)
        if usesBinding {
            return FloatingButton(mainButtonView: main, buttons: discs, isOpen: $isOpen)
        }
        return FloatingButton(mainButtonView: main, buttons: discs)
    }

    private var discs: [SubmenuDisc] {
        MenuCatalog.actions.prefix(count).map { action in
            SubmenuDisc(action: action) {
                lastTapped = action.title
                if usesBinding {
                    isOpen = false
                }
            }
        }
    }

    private var layoutToken: String {
        "\(usesBinding)-\(count)-\(direction.rawValue)-\(rowAlignment.rawValue)-\(spacing)-\(offsetX)-\(offsetY)"
    }

    private var sizeNote: String {
        let verticalAlign = rowAlignment == .top || rowAlignment == .bottom
        let verticalDirection = direction == .top || direction == .bottom
        let axis = verticalAlign == verticalDirection
            ? "wholeMenuSize includes the main button. menuButtonsSize does not."
            : "Reported size uses alignment for its axis. Positions use direction."
        if usesBinding {
            return axis
        }
        return axis + " No binding, so this line's isOpen stays false."
    }

    private var chain: String {
        var parts = [
            usesBinding
                ? "FloatingButton(mainButtonView:buttons:isOpen:)"
                : "FloatingButton(mainButtonView:buttons:)",
            ".straight()",
            ".direction(.\(direction.rawValue))",
            ".alignment(.\(rowAlignment.rawValue))",
            ".spacing(\(MenuFormat.points(CGFloat(spacing))))",
            ".initialOffset(x: \(MenuFormat.points(CGFloat(offsetX))), y: \(MenuFormat.points(CGFloat(offsetY))))",
            ".mainZStackAlignment(.\(stack.rawValue))",
            ".animation(\(curve.call))",
        ]
        parts.append(delayCall(count: count, choice: delayChoice, delta: delayDelta))
        if inverseZIndex {
            parts.append(".inverseZIndex(true)")
        }
        return parts.joined(separator: "\n")
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle("Open", isOn: $isOpen)
                .disabled(!usesBinding)
            Toggle("isOpen binding", isOn: $usesBinding)
            Text(usesBinding
                ? "Three-argument init. A submenu tap sets the binding to false."
                : "Two-argument init. The package keeps a private @State. This screen cannot read it.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            Stepper(value: $count, in: 1...4) {
                Text("Buttons \(count)")
                    .foregroundStyle(DemoPalette.ink)
            }

            actionChips(MenuCatalog.actions.prefix(count))

            labeled("Direction") {
                Picker("Direction", selection: $direction) {
                    ForEach(StraightDirection.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }

            labeled("Alignment") {
                Picker("Alignment", selection: $rowAlignment) {
                    ForEach(RowAlignment.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .tint(DemoPalette.ink)
            }

            DemoSlider(title: "Spacing", value: $spacing, range: -8...20, step: 1)
            Text("Negative spacing overlaps. inverseZIndex changes which submenu is in front. The main button stays above them.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            DemoSlider(title: "Offset X", value: $offsetX, range: -240...240, step: 10)
            DemoSlider(title: "Offset Y", value: $offsetY, range: -240...240, step: 10)
            Text("Closed buttons sit at the open position plus this offset. The README sample uses x: -1000.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            labeled("ZStack alignment") {
                Picker("ZStack alignment", selection: $stack) {
                    ForEach(StackAnchor.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .tint(DemoPalette.ink)
            }
            Text("mainZStackAlignment is SwiftUI.Alignment. Default is center. It is read in body.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            MotionControls(
                initialScaling: $initialScaling,
                initialOpacity: $initialOpacity,
                curve: $curve,
                delayChoice: $delayChoice,
                delayDelta: $delayDelta,
                inverseZIndex: $inverseZIndex,
                buttonCount: count
            )

            chainBlock(chain)
            Text("Direction, alignment, spacing, offset, and count are read in calculateCoords. Changing them remounts the menu so the coordinates are measured again.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            restoreButton { restoreDefaults() }
        }
        .foregroundStyle(DemoPalette.ink)
        .tint(DemoPalette.accent)
        .demoCard()
    }

    private func restoreDefaults() {
        isOpen = false
        usesBinding = true
        lastTapped = "—"
        count = 3
        direction = .left
        rowAlignment = .center
        spacing = 10
        offsetX = 0
        offsetY = 0
        stack = .center
        initialScaling = 1
        initialOpacity = 1
        curve = .easeInOut
        delayChoice = .none
        delayDelta = 0.1
        inverseZIndex = false
        wholeSize = .zero
        buttonsSize = .zero
    }
}

/// Arc of icon buttons. `count` stays at 2 or more because the angle step divides by `count - 1`.
struct CircleSurface: View {
    @State private var isOpen = false
    @State private var lastTapped = "—"
    @State private var count = 4
    @State private var turn: CircleTurn = .clockwise
    @State private var startDegrees = 180.0
    @State private var endDegrees = 360.0
    @State private var usesPackageRadius = true
    @State private var radius = 70.0
    @State private var spacing = 10.0
    @State private var initialScaling = 1.0
    @State private var initialOpacity = 1.0
    @State private var curve: MotionCurve = .easeInOut
    @State private var delayChoice: DelayChoice = .none
    @State private var delayDelta = 0.1
    @State private var inverseZIndex = false
    @State private var wholeSize = CGSize.zero
    @State private var buttonsSize = CGSize.zero

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MenuStage(anchor: .center) {
                menu
            }
            .onChange(of: layoutToken) { _, _ in
                wholeSize = .zero
                buttonsSize = .zero
            }

            MenuReadout(
                isOpen: isOpen,
                lastTapped: lastTapped,
                whole: wholeSize,
                buttons: buttonsSize,
                note: "Circle writes the same finalFrame.size into both size bindings. initialOffset is not applied."
            )

            ScrollView {
                controls
                    .padding(.bottom, 12)
            }
        }
    }

    private var menu: some View {
        let turned = applyTurn(
            FloatingButton(
                mainButtonView: MainDisc(isOpen: isOpen),
                buttons: discs,
                isOpen: $isOpen
            )
            .circle()
            .startAngle(startDegrees * .pi / 180)
            .endAngle(endDegrees * .pi / 180),
            turn
        )
        let sized = usesPackageRadius ? turned : turned.radius(radius)
        return applyShared(
            sized,
            spacing: spacing,
            initialScaling: initialScaling,
            initialOpacity: initialOpacity,
            curve: curve,
            delayChoice: delayChoice,
            delayDelta: delayDelta,
            count: count,
            inverseZIndex: inverseZIndex,
            wholeSize: $wholeSize,
            buttonsSize: $buttonsSize
        )
        .id(layoutToken)
    }

    private var discs: [SubmenuDisc] {
        MenuCatalog.actions.prefix(count).map { action in
            SubmenuDisc(action: action) {
                lastTapped = action.title
                isOpen = false
            }
        }
    }

    private var layoutToken: String {
        "\(count)-\(turn.rawValue)-\(startDegrees)-\(endDegrees)-\(usesPackageRadius)-\(radius)-\(spacing)"
    }

    private var chain: String {
        var parts = [
            "FloatingButton(mainButtonView:buttons:isOpen:)",
            ".circle()",
            ".startAngle(\(MenuFormat.radians(startDegrees)))",
            ".endAngle(\(MenuFormat.radians(endDegrees)))",
            ".layoutDirection(\(turn.call))",
        ]
        if usesPackageRadius {
            parts.append("radius nil")
        } else {
            parts.append(".radius(\(MenuFormat.points(CGFloat(radius))))")
        }
        parts.append(".spacing(\(MenuFormat.points(CGFloat(spacing))))")
        parts.append(".animation(\(curve.call))")
        parts.append(delayCall(count: count, choice: delayChoice, delta: delayDelta))
        return parts.joined(separator: "\n")
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle("Open", isOn: $isOpen)
                .tint(DemoPalette.accent)

            Stepper(value: $count, in: 2...4) {
                Text("Buttons \(count)")
                    .foregroundStyle(DemoPalette.ink)
            }
            Text("The angle step divides by count − 1. One button is not a valid circle.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            actionChips(MenuCatalog.actions.prefix(count))

            labeled("Layout direction") {
                Picker("Layout direction", selection: $turn) {
                    ForEach(CircleTurn.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }

            DemoSlider(title: "Start °", value: $startDegrees, range: 0...360, step: 15)
            DemoSlider(title: "End °", value: $endDegrees, range: 0...360, step: 15)
            Text("0° is +x (right). y grows downward, so 90° is down and 270° is up.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            HStack(spacing: 8) {
                presetButton("Defaults") { applyDefaults() }
                presetButton("Quarter") { applyQuarter() }
                presetButton("Lower") { applyLower() }
            }

            Toggle("Package radius", isOn: $usesPackageRadius)
                .tint(DemoPalette.accent)
            DemoSlider(title: "Radius", value: $radius, range: 48...110, step: 2)
                .disabled(usesPackageRadius)
                .opacity(usesPackageRadius ? 0.45 : 1)
            Text(usesPackageRadius
                ? "radius is nil. The package uses (main + first button) / 2 + spacing. Here that is 50 + spacing."
                : "Explicit radius is the distance between centers. Spacing is ignored.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            DemoSlider(title: "Spacing", value: $spacing, range: 0...20, step: 1)

            MotionControls(
                initialScaling: $initialScaling,
                initialOpacity: $initialOpacity,
                curve: $curve,
                delayChoice: $delayChoice,
                delayDelta: $delayDelta,
                inverseZIndex: $inverseZIndex,
                buttonCount: count
            )

            chainBlock(chain)
            Text("Angles, radius, spacing, turn, and count remount the menu. calculateCoordsCircle is what reads them.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            restoreButton { restoreDefaults() }
        }
        .foregroundStyle(DemoPalette.ink)
        .tint(DemoPalette.accent)
        .demoCard()
    }

    private func applyDefaults() {
        turn = .clockwise
        startDegrees = 180
        endDegrees = 360
        usesPackageRadius = true
        spacing = 10
    }

    private func applyQuarter() {
        startDegrees = 270
        endDegrees = 360
        usesPackageRadius = false
        radius = 70
    }

    private func applyLower() {
        startDegrees = 0
        endDegrees = 180
        usesPackageRadius = true
    }

    private func restoreDefaults() {
        isOpen = false
        lastTapped = "—"
        count = 4
        initialScaling = 1
        initialOpacity = 1
        curve = .easeInOut
        delayChoice = .none
        delayDelta = 0.1
        inverseZIndex = false
        wholeSize = .zero
        buttonsSize = .zero
        applyDefaults()
        radius = 70
    }
}

/// Icon-and-title rows. Both the main view and the rows are `AnyView`, which is the
/// README's recipe when the array has to be one type.
struct LabelSurface: View {
    @State private var isOpen = false
    @State private var lastTapped = "—"
    @State private var direction: StraightDirection = .top
    @State private var rowAlignment: RowAlignment = .left
    @State private var spacing = 10.0
    @State private var offsetX = 0.0
    @State private var offsetY = 0.0
    @State private var initialScaling = 1.0
    @State private var initialOpacity = 0.0
    @State private var curve: MotionCurve = .spring
    @State private var delayChoice: DelayChoice = .delta
    @State private var delayDelta = 0.1
    @State private var inverseZIndex = false
    @State private var wholeSize = CGSize.zero
    @State private var buttonsSize = CGSize.zero

    private var labelCount: Int { MenuCatalog.labels.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MenuStage(anchor: direction.anchor) {
                menu
            }
            .onChange(of: layoutToken) { _, _ in
                wholeSize = .zero
                buttonsSize = .zero
            }

            MenuReadout(
                isOpen: isOpen,
                lastTapped: lastTapped,
                whole: wholeSize,
                buttons: buttonsSize,
                note: "A submenu tap sets isOpen to false. The package button action is empty."
            )

            ScrollView {
                controls
                    .padding(.bottom, 12)
            }
        }
    }

    private var menu: some View {
        applyShared(
            applyRowAlignment(
                applyDirection(
                    FloatingButton(
                        mainButtonView: AnyView(MainCapsule(isOpen: isOpen)),
                        buttons: rows,
                        isOpen: $isOpen
                    )
                    .straight()
                    .initialOffset(x: CGFloat(offsetX), y: CGFloat(offsetY)),
                    direction
                ),
                rowAlignment
            ),
            spacing: spacing,
            initialScaling: initialScaling,
            initialOpacity: initialOpacity,
            curve: curve,
            delayChoice: delayChoice,
            delayDelta: delayDelta,
            count: labelCount,
            inverseZIndex: inverseZIndex,
            wholeSize: $wholeSize,
            buttonsSize: $buttonsSize
        )
        .id(layoutToken)
    }

    private var rows: [AnyView] {
        MenuCatalog.labels.map { action in
            AnyView(
                LabelRow(action: action) {
                    lastTapped = action.title
                    isOpen = false
                }
            )
        }
    }

    private var layoutToken: String {
        "\(direction.rawValue)-\(rowAlignment.rawValue)-\(spacing)-\(offsetX)-\(offsetY)"
    }

    private var chain: String {
        """
        FloatingButton(mainButtonView: AnyView, buttons: [AnyView], isOpen:)
        .straight()
        .direction(.\(direction.rawValue))
        .alignment(.\(rowAlignment.rawValue))
        .spacing(\(MenuFormat.points(CGFloat(spacing))))
        .initialOffset(x: \(MenuFormat.points(CGFloat(offsetX))), y: \(MenuFormat.points(CGFloat(offsetY))))
        .animation(\(curve.call))
        \(delayCall(count: labelCount, choice: delayChoice, delta: delayDelta))
        """
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle("Open", isOn: $isOpen)
                .tint(DemoPalette.accent)

            Text("Opens on the README text menu: spring, delayDelta 0.1, top, left, initialOpacity 0.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            actionChips(MenuCatalog.labels)

            labeled("Direction") {
                Picker("Direction", selection: $direction) {
                    ForEach(StraightDirection.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }

            labeled("Alignment") {
                Picker("Alignment", selection: $rowAlignment) {
                    ForEach(RowAlignment.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .tint(DemoPalette.ink)
            }
            Text("Left lines up the leading edges. The rows are 176 pt wide and the capsule is shorter.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            DemoSlider(title: "Spacing", value: $spacing, range: -8...20, step: 1)
            DemoSlider(title: "Offset X", value: $offsetX, range: -240...240, step: 10)
            DemoSlider(title: "Offset Y", value: $offsetY, range: -240...240, step: 10)

            MotionControls(
                initialScaling: $initialScaling,
                initialOpacity: $initialOpacity,
                curve: $curve,
                delayChoice: $delayChoice,
                delayDelta: $delayDelta,
                inverseZIndex: $inverseZIndex,
                buttonCount: labelCount
            )

            chainBlock(chain)
            restoreButton { restoreDefaults() }
        }
        .foregroundStyle(DemoPalette.ink)
        .tint(DemoPalette.accent)
        .demoCard()
    }

    private func restoreDefaults() {
        isOpen = false
        lastTapped = "—"
        direction = .top
        rowAlignment = .left
        spacing = 10
        offsetX = 0
        offsetY = 0
        initialScaling = 1
        initialOpacity = 0
        curve = .spring
        delayChoice = .delta
        delayDelta = 0.1
        inverseZIndex = false
        wholeSize = .zero
        buttonsSize = .zero
    }
}

struct MotionControls: View {
    @Binding var initialScaling: Double
    @Binding var initialOpacity: Double
    @Binding var curve: MotionCurve
    @Binding var delayChoice: DelayChoice
    @Binding var delayDelta: Double
    @Binding var inverseZIndex: Bool
    var buttonCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DemoSlider(title: "Initial scale", value: $initialScaling, range: 0.25...1, step: 0.05, format: "%.2f")
            DemoSlider(title: "Initial opacity", value: $initialOpacity, range: 0...1, step: 0.05, format: "%.2f")
            Text("Closed submenu buttons use these. The package defaults are scale 1 and opacity 1.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            labeled("Animation") {
                Picker("Animation", selection: $curve) {
                    ForEach(MotionCurve.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .tint(DemoPalette.ink)
            }
            Text(curve.call)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)

            labeled("Delays") {
                Picker("Delays", selection: $delayChoice) {
                    ForEach(DelayChoice.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }

            if delayChoice == .delta {
                DemoSlider(title: "Delay delta", value: $delayDelta, range: 0...0.3, step: 0.05, format: "%.2f")
                Text("delayDelta * index, one value per button. Opening plays that list in reverse.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            } else if delayChoice == .explicit {
                Text(".delays([\(MenuFormat.list(DelayList.explicit(count: buttonCount)))])")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                Text("The array length matches the button count. Opening uses delays[count - i - 1].")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Toggle("inverseZIndex", isOn: $inverseZIndex)
                .tint(DemoPalette.accent)
        }
    }
}

private func applyShared<T: DefaultFloatingButton, Main: View, Sub: View>(
    _ menu: FloatingButtonGeneric<T, Main, Sub>,
    spacing: Double,
    initialScaling: Double,
    initialOpacity: Double,
    curve: MotionCurve,
    delayChoice: DelayChoice,
    delayDelta: Double,
    count: Int,
    inverseZIndex: Bool,
    wholeSize: Binding<CGSize>,
    buttonsSize: Binding<CGSize>
) -> FloatingButtonGeneric<T, Main, Sub> {
    let shared = menu
        .spacing(CGFloat(spacing))
        .initialScaling(CGFloat(initialScaling))
        .initialOpacity(initialOpacity)
        .animation(curve.animation)
        .inverseZIndex(inverseZIndex)
        .wholeMenuSize(wholeSize)
        .menuButtonsSize(buttonsSize)
    switch delayChoice {
    case .none:
        return shared
    case .delta:
        return shared.delays(delayDelta: delayDelta)
    case .explicit:
        return shared.delays(DelayList.explicit(count: count))
    }
}

private func applyDirection<T: StraightFloatingButton, Main: View, Sub: View>(
    _ menu: FloatingButtonGeneric<T, Main, Sub>,
    _ direction: StraightDirection
) -> FloatingButtonGeneric<T, Main, Sub> {
    switch direction {
    case .left:
        menu.direction(.left)
    case .right:
        menu.direction(.right)
    case .top:
        menu.direction(.top)
    case .bottom:
        menu.direction(.bottom)
    }
}

private func applyRowAlignment<T: StraightFloatingButton, Main: View, Sub: View>(
    _ menu: FloatingButtonGeneric<T, Main, Sub>,
    _ alignment: RowAlignment
) -> FloatingButtonGeneric<T, Main, Sub> {
    switch alignment {
    case .left:
        menu.alignment(.left)
    case .right:
        menu.alignment(.right)
    case .top:
        menu.alignment(.top)
    case .bottom:
        menu.alignment(.bottom)
    case .center:
        menu.alignment(.center)
    }
}

private func applyTurn<Main: View, Sub: View>(
    _ menu: FloatingButtonGeneric<CircleFloatingButton, Main, Sub>,
    _ turn: CircleTurn
) -> FloatingButtonGeneric<CircleFloatingButton, Main, Sub> {
    switch turn {
    case .clockwise:
        menu.layoutDirection(.clockwise)
    case .counterClockwise:
        menu.layoutDirection(.counterClockwise)
    }
}

private func delayCall(count: Int, choice: DelayChoice, delta: Double) -> String {
    switch choice {
    case .none:
        "delays []"
    case .delta:
        ".delays(delayDelta: \(String(format: "%.2f", delta)))"
    case .explicit:
        ".delays([\(MenuFormat.list(DelayList.explicit(count: count)))])"
    }
}

private func actionChips<S: Sequence>(_ actions: S) -> some View where S.Element == MenuAction {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 6) {
            ForEach(Array(actions)) { action in
                DemoChrome.chip(action.symbol)
            }
        }
    }
}

private func labeled<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title)
            .font(.caption.weight(.medium))
            .foregroundStyle(DemoPalette.ink)
        content()
    }
}

private func chainBlock(_ text: String) -> some View {
    Text(text)
        .font(.caption.monospaced())
        .foregroundStyle(DemoPalette.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
}

private func restoreButton(_ action: @escaping () -> Void) -> some View {
    Button("Package defaults", action: action)
        .buttonStyle(.bordered)
        .tint(DemoPalette.accent)
}

private func presetButton(_ title: String, action: @escaping () -> Void) -> some View {
    Button(title, action: action)
        .buttonStyle(.bordered)
        .tint(DemoPalette.accent)
}
