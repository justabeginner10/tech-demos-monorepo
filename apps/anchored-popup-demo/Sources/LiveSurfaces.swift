import AnchoredPopup
import SwiftUI

// MARK: - Corners

struct CornersSurface: View {
    @State private var bounds: BoundsChoice = .free
    @State private var closeOutside = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                controls
                stage
                caption
            }
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bounds")
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)

            Picker("Bounds", selection: $bounds) {
                ForEach(BoundsChoice.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Toggle("closeOnTapOutside", isOn: $closeOutside)
                .font(.subheadline)
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
        }
        .demoCard()
    }

    private var stage: some View {
        AnchorStage {
            ZStack {
                MinimalAnchor()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topLeading) {
                CornerAnchor(spot: .topLeading, bounds: bounds, closeOutside: closeOutside)
            }
            .overlay(alignment: .topTrailing) {
                CornerAnchor(spot: .topTrailing, bounds: bounds, closeOutside: closeOutside)
            }
            .overlay(alignment: .bottomLeading) {
                CornerAnchor(spot: .bottomLeading, bounds: bounds, closeOutside: closeOutside)
            }
            .overlay(alignment: .bottomTrailing) {
                CornerAnchor(spot: .bottomTrailing, bounds: bounds, closeOutside: closeOutside)
            }
        }
    }

    private var caption: some View {
        Text(
            "Each corner disc uses useAsPopupAnchor(id:contentBuilder:customize:) and "
                + ".position(.anchorRelative(same corner, boundsMode: \(bounds.call))). "
                + "Defaults, in the middle, uses the two-argument overload: .screenRelative() "
                + "at .center, .blur(), closeOnTap true, closeOnTapOutside false, .window. "
                + "The bounds toggle does not apply to Defaults. Window mode can show more than one popup."
        )
        .font(.caption)
        .foregroundStyle(DemoPalette.inkMuted)
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct CornerAnchor: View {
    var spot: CornerSpot
    var bounds: BoundsChoice
    var closeOutside: Bool

    var body: some View {
        SourceDisc(title: spot.shortTitle, systemImage: spot.systemImage)
            .useAsPopupAnchor(id: PopupAnchor.corner(spot)) {
                PopupCard(
                    title: spot.title,
                    line: spot.call(bounds: bounds),
                    hint: "Tap the card"
                )
            } customize: { params in
                params
                    .position(.anchorRelative(spot.unitPoint, boundsMode: bounds.mode))
                    .background(.blur(radius: 6))
                    .openOnTap(true)
                    .closeOnTap(true)
                    .closeOnTapOutside(closeOutside)
                    .displayMode(.window)
            }
    }
}

private struct MinimalAnchor: View {
    var body: some View {
        SourceDisc(title: "Defaults", systemImage: "circle")
            .useAsPopupAnchor(id: PopupAnchor.minimal) {
                PopupCard(
                    title: "Defaults",
                    line: "useAsPopupAnchor(id:contentBuilder:)",
                    hint: "Tap the card"
                )
            }
    }
}

// MARK: - Placement

struct PlacementSurface: View {
    @State private var kind: PlacementKind = .auto
    @State private var seat: StageSeat = .topLeading
    @State private var point: ScreenPoint = .top
    @State private var bounds: BoundsChoice = .safeArea
    @State private var align: ScreenPoint = .topLeading
    @State private var absoluteX: Double = 48
    @State private var absoluteY: Double = 140

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                controls
                stage
                Text(callLine)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
                caption
            }
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Placement", selection: $kind) {
                ForEach(PlacementKind.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            menuPicker("Source", selection: $seat) { item in
                Text(item.title).tag(item)
            }

            if kind == .screen {
                menuPicker("Unit point", selection: $point) { item in
                    Text(item.title).tag(item)
                }
                menuPicker("Bounds", selection: $bounds) { item in
                    Text(item.title).tag(item)
                }
            }

            if kind == .absolute {
                menuPicker("Popup point", selection: $align) { item in
                    Text(item.title).tag(item)
                }
                DemoSlider(title: "Window x", value: $absoluteX, range: 0...390, step: 2)
                DemoSlider(title: "Window y", value: $absoluteY, range: 40...720, step: 2)
            }
        }
        .demoCard()
    }

    private var stage: some View {
        AnchorStage {
            SourceDisc(title: "Anchor", systemImage: "scope")
                .useAsPopupAnchor(id: PopupAnchor.placement) {
                    PopupCard(title: kind.title, line: callLine, hint: "Tap the card")
                } customize: { params in
                    params
                        .position(position)
                        .background(.blur(radius: 6))
                        .openOnTap(true)
                        .closeOnTap(true)
                        .closeOnTapOutside(false)
                        .displayMode(.window)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: seat.alignment)
        }
    }

    private var position: AnchoredPopupPosition {
        switch kind {
        case .auto:
            return .auto
        case .screen:
            return .screenRelative(point.unitPoint, boundsMode: bounds.mode)
        case .absolute:
            return .absolute(
                align.unitPoint,
                position: CGPoint(x: absoluteX, y: absoluteY)
            )
        }
    }

    private var callLine: String {
        switch kind {
        case .auto:
            return ".auto"
        case .screen:
            return ".screenRelative(\(point.call), boundsMode: \(bounds.call))"
        case .absolute:
            let x = Int(absoluteX)
            let y = Int(absoluteY)
            return ".absolute(\(align.call), position: CGPoint(x: \(x), y: \(y)))"
        }
    }

    private var caption: some View {
        Text(
            "Auto picks a corner of the anchor (topLeading, topTrailing, bottomLeading, "
                + "bottomTrailing) that keeps the card inside the safe area, preferring the "
                + "half of the screen the source is on. Screen places a unit point of the card "
                + "on that unit point of the bounds. Absolute uses window coordinates. "
                + "Move the source while a popup is displayed and the card follows the new frame."
        )
        .font(.caption)
        .foregroundStyle(DemoPalette.inkMuted)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func menuPicker<Item: Hashable, Row: View>(
        _ title: String,
        selection: Binding<Item>,
        row: @escaping (Item) -> Row
    ) -> some View where Item: CaseIterable, Item.AllCases: RandomAccessCollection {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
            Picker(title, selection: selection) {
                ForEach(Array(Item.allCases), id: \.self) { item in
                    row(item)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.accent)
        }
    }
}

// MARK: - Behavior

struct BehaviorSurface: View {
    @State private var display: DisplayChoice = .window
    @State private var motion: PopupMotion = .easeIn
    @State private var backdrop: BackdropChoice = .blur
    @State private var openOnTap = true
    @State private var closeOnTap = false
    @State private var closeOutside = true
    @State private var passthrough = false
    @State private var note = NoteCycle.names[0]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                controls
                stage
                Text("Parent note: \(note)")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.ink)
                Text(callLine)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
                caption
            }
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Display", selection: $display) {
                ForEach(DisplayChoice.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            menuPicker("Animation", selection: $motion) { item in
                Text(item.title).tag(item)
            }
            menuPicker("Background", selection: $backdrop) { item in
                Text(item.title).tag(item)
            }

            toggle("openOnTap", isOn: $openOnTap)
            toggle("closeOnTap", isOn: $closeOnTap)
            toggle("closeOnTapOutside", isOn: $closeOutside)
            toggle("isBackgroundPassthrough", isOn: $passthrough)

            if !openOnTap {
                Button("Grow") {
                    AnchoredPopup.launchGrowingAnimation(id: PopupAnchor.behavior(display))
                }
                .buttonStyle(.borderedProminent)
                .tint(DemoPalette.accent)
                .foregroundStyle(DemoPalette.page)
            }
        }
        .demoCard()
    }

    private var stage: some View {
        AnchorStage {
            ZStack {
                ForEach(DisplayChoice.allCases) { mode in
                    BehaviorAnchor(
                        mode: mode,
                        motion: motion,
                        backdrop: backdrop,
                        openOnTap: openOnTap,
                        closeOnTap: closeOnTap,
                        closeOutside: closeOutside,
                        passthrough: passthrough,
                        note: $note
                    )
                    .familyVisibility(display == mode)
                }
            }
        }
    }

    private var callLine: String {
        ".displayMode(\(display.call)) .animation(\(motion.call)) .background(\(backdrop.call))"
    }

    private var caption: some View {
        Text(
            "The card takes a Binding. Window mode does not refresh a parent @State that the "
                + "builder captured directly. Sheet is the package's other presenter and shows one "
                + "popup at a time. Both discs stay mounted when you switch. isBackgroundPassthrough "
                + "is read by the window hit test only. Close the popup before you rely on a new "
                + "animation, background, or flag — the open presenter keeps the values from when it grew. "
                + "Shrink and Environment dismiss call launchShrinkingAnimation and anchoredPopupDismiss."
        )
        .font(.caption)
        .foregroundStyle(DemoPalette.inkMuted)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func toggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .font(.subheadline)
            .foregroundStyle(DemoPalette.ink)
            .tint(DemoPalette.accent)
    }

    private func menuPicker<Item: Hashable, Row: View>(
        _ title: String,
        selection: Binding<Item>,
        row: @escaping (Item) -> Row
    ) -> some View where Item: CaseIterable, Item.AllCases: RandomAccessCollection {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
            Picker(title, selection: selection) {
                ForEach(Array(Item.allCases), id: \.self) { item in
                    row(item)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.accent)
        }
    }
}

private struct BehaviorAnchor: View {
    var mode: DisplayChoice
    var motion: PopupMotion
    var backdrop: BackdropChoice
    var openOnTap: Bool
    var closeOnTap: Bool
    var closeOutside: Bool
    var passthrough: Bool
    @Binding var note: String

    var body: some View {
        SourceDisc(title: mode.title, systemImage: mode == .window ? "macwindow" : "rectangle.bottomthird.inset.filled")
            .useAsPopupAnchor(id: PopupAnchor.behavior(mode)) {
                BehaviorCard(id: PopupAnchor.behavior(mode), note: $note, closeOnTap: closeOnTap)
            } customize: { params in
                params
                    .displayMode(mode.mode)
                    .position(.anchorRelative(.bottom, boundsMode: .safeArea))
                    .animation(motion.animation)
                    .background(backdrop.background)
                    .openOnTap(openOnTap)
                    .closeOnTap(closeOnTap)
                    .closeOnTapOutside(closeOutside)
                    .isBackgroundPassthrough(passthrough)
            }
    }
}

// MARK: - Popup bodies

private struct PopupCard: View {
    var title: String
    var line: String
    var hint: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(line)
                .font(.caption.monospaced())
                .fixedSize(horizontal: false, vertical: true)
            Text(hint)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(DemoPalette.paperInk)
        .padding(16)
        .frame(width: 228, alignment: .leading)
        .background(DemoPalette.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct BehaviorCard: View {
    var id: String
    @Binding var note: String
    var closeOnTap: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Note")
                .font(.caption.weight(.semibold))
            Text(note)
                .font(.title3.weight(.semibold))
            Button("Next name") {
                note = NoteCycle.next(after: note)
            }
            .buttonStyle(.plain)
            Button("Shrink") {
                AnchoredPopup.launchShrinkingAnimation(id: id)
            }
            .buttonStyle(.plain)
            EnvironmentDismissButton()
            Text(closeOnTap ? "closeOnTap is on. A tap on this card also shrinks." : "closeOnTap is off.")
                .font(.caption2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(DemoPalette.paperInk)
        .padding(16)
        .frame(width: 240, alignment: .leading)
        .background(DemoPalette.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct EnvironmentDismissButton: View {
    @Environment(\.anchoredPopupDismiss) private var dismiss

    var body: some View {
        Button("Environment dismiss") {
            dismiss?()
        }
        .buttonStyle(.plain)
    }
}
