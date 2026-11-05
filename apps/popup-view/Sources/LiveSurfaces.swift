import PopupView
import SwiftUI

// MARK: - Shared stage

/// Card the modifier is attached to. Overlay mode positions against this view.
/// Window and sheet modes cover the screen; the button still shows whether taps pass through.
private struct PopupStage: View {
    var note: String
    @Binding var taps: Int
    var height: CGFloat = 300

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DemoPalette.canvas)

            VStack(spacing: 8) {
                Button("Stage \(taps)") {
                    taps += 1
                }
                .buttonStyle(.bordered)
                .tint(DemoPalette.ink)

                Text(note)
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }
}

private struct HostModeControl: View {
    @Binding var host: HostMode

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("displayMode")
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
            Picker("Display", selection: $host) {
                ForEach(HostMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            Text(host.detail)
                .font(.caption2)
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

private struct PresentButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
    }
}

/// Knob changes clear `presented` in the same update so a window-mode popup is dismissed
/// before `displayMode` swaps the modifier branch that owns `WindowManager`.
private func resetsPresentation<Value>(
    _ presented: Binding<Bool>,
    _ source: Binding<Value>
) -> Binding<Value> {
    Binding {
        source.wrappedValue
    } set: { newValue in
        presented.wrappedValue = false
        source.wrappedValue = newValue
    }
}

private func popupDisplayMode(_ host: HostMode) -> Popup.DisplayMode {
    switch host {
    case .overlay: .overlay
    case .window: .window
    case .sheet: .sheet
    }
}

private func popupPosition(_ slot: FloaterSlot) -> Popup.Position {
    switch slot {
    case .topLeading: .topLeading
    case .top: .top
    case .topTrailing: .topTrailing
    case .leading: .leading
    case .center: .center
    case .trailing: .trailing
    case .bottomLeading: .bottomLeading
    case .bottom: .bottom
    case .bottomTrailing: .bottomTrailing
    }
}

private func applyScrim(
    _ params: Popup.PopupTypeParameters,
    _ scrim: ScrimStyle
) -> Popup.PopupTypeParameters {
    switch scrim {
    case .clear:
        params
    case .color:
        params.backgroundColor(Color.black.opacity(0.4))
    case .material:
        params.backgroundView {
            Rectangle().fill(.ultraThinMaterial)
        }
    }
}

// MARK: - Toasts

struct ToastSurface: View {
    @State private var presented = false
    @State private var edge: ToastEdge = .top
    @State private var autohide: AutohideChoice = .two
    @State private var closeOnTap = true
    @State private var closeOnTapOutside = false
    @State private var passThrough = false
    @State private var dim = false
    @State private var spring = false
    @State private var host: HostMode = .overlay
    @State private var taps = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            stage
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Toast")
                .font(.headline)
                .foregroundStyle(DemoPalette.ink)

            Picker("Edge", selection: resetsPresentation($presented, $edge)) {
                ForEach(ToastEdge.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Picker("Autohide", selection: resetsPresentation($presented, $autohide)) {
                ForEach(AutohideChoice.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Toggle("Close on tap", isOn: resetsPresentation($presented, $closeOnTap))
            Toggle("Close on tap outside", isOn: resetsPresentation($presented, $closeOnTapOutside))
            Toggle("Allow tap through background", isOn: resetsPresentation($presented, $passThrough))
            Toggle("Scrim", isOn: resetsPresentation($presented, $dim))
            Toggle("Spring", isOn: resetsPresentation($presented, $spring))
                .tint(DemoPalette.accent)

            HostModeControl(host: resetsPresentation($presented, $host))

            HStack {
                PresentButton(title: presented ? "Hide" : "Show") {
                    presented.toggle()
                }
                Text(presented ? "isPresented true" : "isPresented false")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Text(
                "type .toast ignores safe area and has no padding. Content reads popupSafeAreaInsets. "
                    + "Drag follows appearFrom: up at the top, down at the bottom. "
                    + "becomesKeyWindow(false) so a window toast does not take the key window. "
                    + "A control inside the toast would replace closeOnTap — this one is text only."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .tint(DemoPalette.accent)
        .foregroundStyle(DemoPalette.ink)
        .demoCard()
    }

    private var stage: some View {
        PopupStage(note: host.stageNote, taps: $taps)
            .popup(isPresented: $presented) {
                EdgeToast(pinnedToTop: edge == .top, autohide: autohide.title)
            } customize: { params in
                toastParameters(params)
            }
            .id(host)
    }

    private func toastParameters(_ params: Popup.PopupTypeParameters) -> Popup.PopupTypeParameters {
        let styled = params
            .type(.toast)
            .position(edge == .top ? .top : .bottom)
            .displayMode(popupDisplayMode(host))
            .animation(spring ? .spring : .easeOut(duration: 0.3))
            .autohideIn(autohide.seconds)
            .closeOnTap(closeOnTap)
            .closeOnTapOutside(closeOnTapOutside)
            .allowTapThroughBG(passThrough)
            .dragToDismiss(true)
            .becomesKeyWindow(false)
        if dim {
            return styled.backgroundColor(Color.black.opacity(0.4))
        }
        return styled
    }
}

private struct EdgeToast: View {
    @Environment(\.popupSafeAreaInsets) private var insets

    var pinnedToTop: Bool
    var autohide: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(pinnedToTop ? "Couldn't save" : "Saved")
                .font(.subheadline.weight(.semibold))
            Text("Autohide \(autohide). Drag \(pinnedToTop ? "up" : "down") to dismiss.")
                .font(.caption)
                .opacity(0.85)
        }
        .foregroundStyle(pinnedToTop ? Color.white : DemoPalette.paperInk)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 14 + (pinnedToTop ? insets.top : 0))
        .padding(.bottom, 14 + (pinnedToTop ? 0 : insets.bottom))
        .padding(.leading, 20 + insets.leading)
        .padding(.trailing, 20 + insets.trailing)
        .background(pinnedToTop ? DemoPalette.accent : DemoPalette.paper)
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Floaters

private struct Notice: Equatable {
    var title: String
    var message: String
}

struct FloaterSurface: View {
    @State private var notice: Notice?
    @State private var slot: FloaterSlot = .top
    @State private var padding: Double = 10
    @State private var useSafeArea = true
    @State private var passThrough = false
    @State private var closeOnTapOutside = true
    @State private var autohide = false
    @State private var spring = true
    @State private var host: HostMode = .overlay
    @State private var taps = 0

    private static let invite = Notice(
        title: "Session invite",
        message: "A floater keeps its own padding and can sit inside the safe area."
    )
    private static let gift = Notice(
        title: "A gift",
        message: "Same modifier, different item. The package copies the item while it dismisses."
    )
    private static let sent = Notice(
        title: "Message sent",
        message: "Tap the card to close. closeOnTap is still the default."
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            stage
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Floater")
                .font(.headline)
                .foregroundStyle(DemoPalette.ink)

            Picker("Position", selection: clearsNotice($slot)) {
                ForEach(FloaterSlot.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.menu)

            DemoSlider(
                title: "Padding",
                value: clearsNotice($padding),
                range: 0...40,
                step: 1,
                format: "%.0f"
            )

            Toggle("useSafeAreaInset", isOn: clearsNotice($useSafeArea))
            Toggle("Close on tap outside", isOn: clearsNotice($closeOnTapOutside))
            Toggle("Allow tap through background", isOn: clearsNotice($passThrough))
            Toggle("Autohide 3s", isOn: clearsNotice($autohide))
            Toggle("Spring", isOn: clearsNotice($spring))
                .tint(DemoPalette.accent)

            HostModeControl(host: clearsNotice($host))

            HStack(spacing: 8) {
                noticeButton("Invite", Self.invite)
                noticeButton("Gift", Self.gift)
                noticeButton("Sent", Self.sent)
            }

            Button("Clear item") {
                notice = nil
            }
            .buttonStyle(.bordered)
            .tint(DemoPalette.ink)

            Text(notice.map { "item \($0.title)" } ?? "item nil")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)

            Text(
                "item: drives this one — nil hides it. Padding is passed as both verticalPadding "
                    + "and horizontalPadding (the parameters are independent; the package default is 10). "
                    + "On an overlay, passthrough disables background hit testing, so outside-tap dismiss "
                    + "does not also fire. A window can dismiss and then return the hit."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .tint(DemoPalette.accent)
        .foregroundStyle(DemoPalette.ink)
        .demoCard()
    }

    private func noticeButton(_ title: String, _ value: Notice) -> some View {
        Button(title) {
            notice = value
        }
        .buttonStyle(.borderedProminent)
        .tint(DemoPalette.accent)
    }

    private var stage: some View {
        PopupStage(note: host.stageNote, taps: $taps, height: 320)
            .popup(item: $notice) { item in
                FloaterCard(title: item.title, message: item.message)
            } customize: { params in
                floaterParameters(params)
            }
            .id(host)
    }

    private func floaterParameters(_ params: Popup.PopupTypeParameters) -> Popup.PopupTypeParameters {
        params
            .type(
                .floater(
                    verticalPadding: CGFloat(padding),
                    horizontalPadding: CGFloat(padding),
                    useSafeAreaInset: useSafeArea
                )
            )
            .position(popupPosition(slot))
            .displayMode(popupDisplayMode(host))
            .animation(spring ? .spring : .easeOut(duration: 0.3))
            .autohideIn(autohide ? 3 : nil)
            .closeOnTap(true)
            .closeOnTapOutside(closeOnTapOutside)
            .allowTapThroughBG(passThrough)
            .dragToDismiss(true)
    }

    private func clearsNotice<Value>(_ source: Binding<Value>) -> Binding<Value> {
        Binding {
            source.wrappedValue
        } set: { newValue in
            notice = nil
            source.wrappedValue = newValue
        }
    }
}

private struct FloaterCard: View {
    var title: String
    var message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(message)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .foregroundStyle(DemoPalette.ink)
        .padding(16)
        .frame(maxWidth: 260, alignment: .leading)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Sheets

struct SheetSurface: View {
    @State private var presented = false
    @State private var kind: SheetKind = .center
    @State private var motion: CenterMotion = .zoom
    @State private var scrim: ScrimStyle = .color
    @State private var allowDrag = true
    @State private var customDistance = false
    @State private var lockDismiss = false
    @State private var dismissEnabled = true
    @State private var scrollAtCenter = false
    @State private var closeOnTapOutside = true
    @State private var host: HostMode = .overlay
    @State private var taps = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            stage
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sheet")
                .font(.headline)
                .foregroundStyle(DemoPalette.ink)

            Picker("Kind", selection: resetsPresentation($presented, $kind)) {
                ForEach(SheetKind.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Text(kind.subtitle)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)

            kindControls

            Toggle("Close on tap outside", isOn: resetsPresentation($presented, $closeOnTapOutside))

            HostModeControl(host: resetsPresentation($presented, $host))

            HStack {
                PresentButton(title: presented ? "Hide" : "Show") {
                    if !presented {
                        dismissEnabled = lockDismiss ? false : true
                    }
                    presented.toggle()
                }
                Text(statusLine)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Text(kindHelp)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .tint(DemoPalette.accent)
        .foregroundStyle(DemoPalette.ink)
        .demoCard()
    }

    @ViewBuilder
    private var kindControls: some View {
        switch kind {
        case .center:
            Picker("Motion", selection: resetsPresentation($presented, $motion)) {
                ForEach(CenterMotion.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
            Text(motion.detail)
                .font(.caption2)
                .foregroundStyle(DemoPalette.inkMuted)
            Picker("Background", selection: resetsPresentation($presented, $scrim)) {
                ForEach(ScrimStyle.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
        case .card:
            Toggle("Drag to dismiss", isOn: resetsPresentation($presented, $allowDrag))
            Toggle("Distance 120", isOn: resetsPresentation($presented, $customDistance))
            Toggle("Lock dismiss 1.5s", isOn: resetsPresentation($presented, $lockDismiss))
        case .scroll:
            Toggle("Drag to dismiss", isOn: resetsPresentation($presented, $allowDrag))
            Toggle("Center position", isOn: resetsPresentation($presented, $scrollAtCenter))
        }
    }

    private var statusLine: String {
        if kind == .card, lockDismiss {
            return presented
                ? (dismissEnabled ? "dismiss open" : "dismiss locked")
                : "isPresented false"
        }
        return presented ? "isPresented true" : "isPresented false"
    }

    private var kindHelp: String {
        switch kind {
        case .center:
            "type .default is the centered dialog. closeOnTap is false because the button would eat the tap — it calls popupDismiss. Drag is off: .centerScale and .none do not move."
        case .card:
            "The README sheet is a bottom toast with dragToDismiss. The default distance is one third of the card. dismissibleIn blocks outside tap and drag until the binding flips true. Close sets the binding itself, so it waits on that same flag."
        case .scroll:
            "scrollPopup is its own modifier. The header stays out of the scroll. Once the scroll offset is 0, the same pan continues into the dismiss drag."
        }
    }

    @ViewBuilder
    private var stage: some View {
        switch kind {
        case .center:
            baseStage
                .popup(isPresented: $presented) {
                    CenterDialog()
                } customize: { params in
                    centerParameters(params)
                }
                .id(stageIdentity)
        case .card:
            baseStage
                .popup(isPresented: $presented) {
                    DragSheetCard(dismissEnabled: $dismissEnabled)
                } customize: { params in
                    cardParameters(params)
                }
                .id(stageIdentity)
        case .scroll:
            baseStage
                .scrollPopup(isPresented: $presented) {
                    ScrollSheetBody()
                } header: {
                    ScrollGrabber()
                } customize: { params in
                    scrollParameters(params)
                }
                .id(stageIdentity)
        }
    }

    private var baseStage: some View {
        PopupStage(note: host.stageNote, taps: $taps, height: 420)
    }

    private var stageIdentity: String {
        "\(kind.rawValue)-\(host.rawValue)"
    }

    private func centerParameters(_ params: Popup.PopupTypeParameters) -> Popup.PopupTypeParameters {
        applyScrim(applyMotion(baseDialog(params)), scrim)
    }

    private func baseDialog(_ params: Popup.PopupTypeParameters) -> Popup.PopupTypeParameters {
        params
            .type(.default)
            .position(.center)
            .displayMode(popupDisplayMode(host))
            .closeOnTap(false)
            .closeOnTapOutside(closeOnTapOutside)
            .dragToDismiss(false)
            .animation(.easeOut(duration: 0.3))
    }

    private func applyMotion(_ params: Popup.PopupTypeParameters) -> Popup.PopupTypeParameters {
        switch motion {
        case .zoom:
            params.appearFrom(.centerScale).disappearTo(.centerScale)
        case .slide:
            params
        case .leaveUp:
            params.appearFrom(.centerScale).disappearTo(.topSlide)
        case .none:
            params.appearFrom(.none).disappearTo(.none)
        }
    }

    private func cardParameters(_ params: Popup.PopupTypeParameters) -> Popup.PopupTypeParameters {
        let styled = params
            .type(.toast)
            .position(.bottom)
            .displayMode(popupDisplayMode(host))
            .closeOnTap(false)
            .closeOnTapOutside(closeOnTapOutside)
            .dragToDismiss(allowDrag)
            .backgroundColor(Color.black.opacity(0.4))
            .animation(.spring)
            .dismissibleIn(lockDismiss ? 1.5 : nil, $dismissEnabled)
        if customDistance {
            return styled.dragToDismissDistance(120)
        }
        return styled
    }

    private func scrollParameters(_ params: Popup.ScrollPopupParameters) -> Popup.ScrollPopupParameters {
        params
            .position(scrollAtCenter ? .center(24) : .bottom(64))
            .displayMode(popupDisplayMode(host))
            .closeOnTap(false)
            .closeOnTapOutside(closeOnTapOutside)
            .dragToDismiss(allowDrag)
            .backgroundColor(Color.black.opacity(0.4))
            .animation(.easeOut(duration: 0.3))
    }
}

private struct CenterDialog: View {
    @Environment(\.popupDismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Centered")
                .font(.title3.weight(.semibold))
                .foregroundStyle(DemoPalette.paperInk)
            Text("Thanks calls popupDismiss. The package sets that environment for overlay, sheet, and window.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.paperMuted)
            Button("Thanks") {
                dismiss?()
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
        }
        .padding(24)
        .frame(maxWidth: 320, alignment: .leading)
        .background(DemoPalette.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 28)
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct DragSheetCard: View {
    @Environment(\.popupDismiss) private var dismiss
    @Binding var dismissEnabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Capsule()
                .fill(Color.black.opacity(0.2))
                .frame(width: 36, height: 5)
                .frame(maxWidth: .infinity)

            HStack {
                Text("Drag card")
                    .font(.title3.weight(.semibold))
                Spacer()
                Button("Close") {
                    if dismissEnabled {
                        dismiss?()
                    }
                }
                .buttonStyle(.bordered)
                .tint(DemoPalette.accent)
                .disabled(!dismissEnabled)
            }

            ForEach(SheetRow.samples) { row in
                HStack(spacing: 12) {
                    Image(systemName: row.symbol)
                        .frame(width: 28)
                    Text(row.title)
                    Spacer()
                    if row.marked {
                        Image(systemName: "checkmark")
                            .foregroundStyle(DemoPalette.accent)
                    }
                }
                .font(.subheadline)
            }
        }
        .foregroundStyle(DemoPalette.paperInk)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DemoPalette.paper)
        .clipShape(topCorners)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var topCorners: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 28,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 28,
            style: .continuous
        )
    }
}

private struct SheetRow: Identifiable {
    var id: String { title }
    var symbol: String
    var title: String
    var marked: Bool

    static let samples = [
        SheetRow(symbol: "figure.run", title: "Run", marked: true),
        SheetRow(symbol: "figure.yoga", title: "Yoga", marked: false),
        SheetRow(symbol: "bicycle", title: "Cycling", marked: false),
    ]
}

private struct ScrollGrabber: View {
    var body: some View {
        Capsule()
            .fill(Color.black.opacity(0.2))
            .frame(width: 36, height: 5)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(DemoPalette.paper)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 28,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 28,
                    style: .continuous
                )
            )
    }
}

private struct ScrollSheetBody: View {
    @Environment(\.popupDismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Scroll sheet")
                .font(.title3.weight(.semibold))

            Text("The header grabber is not in this scroll. Drag it, or pull down once the text is at the top.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.paperMuted)

            ForEach(Array(scrollLines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(.subheadline)
            }

            Button("Dismiss") {
                dismiss?()
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
        }
        .foregroundStyle(DemoPalette.paperInk)
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DemoPalette.paper)
    }
}

private let scrollLines = [
    "Position .bottom(64) leaves 64 points above the sheet. .center(24) pads both vertical edges instead.",
    "dragToDismiss is true by default on every popup, including this one.",
    "When the text is taller than the room left on screen, the package watches the scroll view.",
    "At content offset 0 the pan becomes the dismiss gesture. A third of the sheet height commits it.",
    "closeOnTap stays false so reading the text does not dismiss.",
    "The Dismiss button uses popupDismiss, the same environment as the centered dialog.",
    "displayMode still applies: overlay stays on the stage, window and sheet cover the app.",
    "Stacking several popups works for overlay and window. Sheet presents one full-screen cover.",
]
