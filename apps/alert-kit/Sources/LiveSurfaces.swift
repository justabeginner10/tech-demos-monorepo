import AlertKit
import SwiftUI

struct APISurface: View {
    @State private var draft = AlertDraft()
    @State private var status = "Idle"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            sketch
            readout
            buttons
            ScrollView {
                controls
                    .padding(.bottom, 12)
            }
        }
        .onChange(of: draft.icon) { _, _ in
            status = "Idle"
        }
        .onDisappear {
            AlertKitAPI.dismissAllAlerts()
        }
    }

    private var sketch: some View {
        AlertSketch(
            style: draft.style.sketch,
            icon: draft.icon.sketch,
            title: draft.icon.alertTitle,
            subtitle: draft.subtitle,
            ink: draft.whiteInk ? .white : DemoPalette.packageInk
        )
    }

    private var readout: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(draft.apiCall)
            Text(status)
        }
        .font(.caption.monospaced())
        .foregroundStyle(DemoPalette.inkMuted)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var buttons: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Button("Show", action: show)
                    .buttonStyle(.borderedProminent)
                    .tint(DemoPalette.accent)
                    .disabled(draft.blocksCenterSpinner)
                Button("Dismiss all", action: dismissAll)
                    .buttonStyle(.bordered)
                    .tint(DemoPalette.ink)
            }
            if draft.blocksCenterSpinner {
                Text(
                    "An iOS 16 spinner from present(title:) has no handle, and dismissAllAlerts "
                        + "does not see AlertAppleMusic16View. Use View for that pair."
                )
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            MenuRow(title: "Icon", selection: $draft.icon, options: Array(IconChoice.allCases), name: \.name)
            MenuRow(title: "Style", selection: $draft.style, options: Array(StyleChoice.allCases), name: \.name)
            MenuRow(title: "Haptic", selection: $draft.haptic, options: Array(HapticChoice.allCases), name: \.name)
            Toggle("Subtitle", isOn: $draft.showsSubtitle)
                .tint(DemoPalette.accent)
                .foregroundStyle(DemoPalette.ink)
            Button("README sample", action: applySample)
                .buttonStyle(.bordered)
                .tint(DemoPalette.ink)
            Text(
                "present(title:) builds the view for you. iOS 17 sits on the bottom edge. "
                    + "iOS 16 sits in the center. Spinners start with timed dismiss and tap dismiss off. "
                    + "Leaving this tab calls dismissAllAlerts, which only removes iOS 17 views."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
            .fixedSize(horizontal: false, vertical: true)
        }
        .demoCard()
    }

    private func show() {
        guard !draft.blocksCenterSpinner else { return }
        switch draft.iconValue() {
        case .missingSymbol:
            status = "UIImage(systemName: \"star.fill\") was nil. Nothing presented."
        case .ready(let icon):
            AlertKitAPI.present(
                title: draft.icon.alertTitle,
                subtitle: draft.subtitle,
                icon: icon,
                style: draft.style.value,
                haptic: draft.haptic.value
            )
            status = draft.style == .banner
                ? "Presented. dismissAllAlerts can remove this banner."
                : "Presented. dismissAllAlerts does not see this center alert. It times out."
        }
    }

    private func dismissAll() {
        AlertKitAPI.dismissAllAlerts(completion: AlertEventSink.finished {
            status = "dismissAllAlerts completion"
        })
    }

    private func applySample() {
        draft.icon = .done
        draft.style = .banner
        draft.haptic = .success
        draft.showsSubtitle = false
        status = "Idle"
    }
}

struct ViewSurface: View {
    @State private var draft = AlertDraft()
    @State private var mounted: MountedAlert?
    @State private var status = "Idle"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            sketch
            readout
            buttons
            ScrollView {
                controls
                    .padding(.bottom, 12)
            }
        }
        .onChange(of: draft.icon) { _, icon in
            applySpinnerDefaults(icon)
        }
        .onDisappear {
            mounted?.dismiss()
        }
    }

    private var sketch: some View {
        AlertSketch(
            style: draft.style.sketch,
            icon: draft.icon.sketch,
            title: draft.icon.alertTitle,
            subtitle: draft.subtitle,
            ink: draft.whiteInk ? .white : DemoPalette.packageInk
        )
    }

    private var readout: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(draft.viewCall)
            Text(detailLine)
            Text(status)
        }
        .font(.caption.monospaced())
        .foregroundStyle(DemoPalette.inkMuted)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var detailLine: String {
        let duration = String(format: "%.1f", draft.duration)
        return "duration \(duration) · tap \(draft.dismissByTap) · time \(draft.dismissInTime) · haptic \(draft.haptic.call)"
    }

    private var buttons: some View {
        HStack(spacing: 8) {
            Button("Show", action: show)
                .buttonStyle(.borderedProminent)
                .tint(DemoPalette.accent)
                .disabled(mounted != nil)
            Button("Dismiss", action: dismissHeld)
                .buttonStyle(.bordered)
                .tint(DemoPalette.ink)
                .disabled(mounted == nil)
            Button("Dismiss all", action: dismissAll)
                .buttonStyle(.bordered)
                .tint(DemoPalette.ink)
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                MenuRow(title: "Icon", selection: $draft.icon, options: Array(IconChoice.allCases), name: \.name)
                MenuRow(title: "Style", selection: $draft.style, options: Array(StyleChoice.allCases), name: \.name)
                MenuRow(title: "Haptic", selection: $draft.haptic, options: Array(HapticChoice.allCases), name: \.name)
            }
            Toggle("Subtitle", isOn: $draft.showsSubtitle)
                .tint(DemoPalette.accent)
                .foregroundStyle(DemoPalette.ink)
            Toggle("Dismiss by tap", isOn: $draft.dismissByTap)
                .tint(DemoPalette.accent)
                .foregroundStyle(DemoPalette.ink)
            Toggle("Dismiss in time", isOn: $draft.dismissInTime)
                .tint(DemoPalette.accent)
                .foregroundStyle(DemoPalette.ink)
            DemoSlider(title: "Duration", value: $draft.duration, range: 0.4...4, step: 0.1)
            Toggle("White ink", isOn: $draft.whiteInk)
                .tint(DemoPalette.accent)
                .foregroundStyle(DemoPalette.ink)
            Toggle("Title 21 pt", isOn: $draft.largeTitle)
                .tint(DemoPalette.accent)
                .foregroundStyle(DemoPalette.ink)
            Button("README sample", action: applySample)
                .buttonStyle(.bordered)
                .tint(DemoPalette.ink)
            Text(
                "Show keeps the view and calls AlertKitAPI.present(view:). "
                    + "Spinner inits turn both dismiss flags off; changing the icon writes those defaults, "
                    + "then these toggles overwrite them. Dismiss calls view.dismiss(). "
                    + "Dismiss all only finds iOS 17 views."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
            .fixedSize(horizontal: false, vertical: true)
        }
        .demoCard()
    }

    private func show() {
        guard mounted == nil else { return }
        switch draft.style {
        case .banner:
            guard let view = draft.makeBanner() else {
                status = "UIImage(systemName: \"star.fill\") was nil. Nothing presented."
                return
            }
            mounted = .banner(view)
            present(view, token: ObjectIdentifier(view))
        case .center:
            guard let view = draft.makeCenter() else {
                status = "UIImage(systemName: \"star.fill\") was nil. Nothing presented."
                return
            }
            mounted = .center(view)
            present(view, token: ObjectIdentifier(view))
        }
    }

    private func present(_ view: AlertViewProtocol, token: ObjectIdentifier) {
        AlertKitAPI.present(view: view, completion: AlertEventSink.finished {
            guard mounted?.token == token else { return }
            mounted = nil
            status = "Dismissed"
        })
        status = "Presented"
    }

    private func dismissHeld() {
        mounted?.dismiss()
    }

    /// `dismissAllAlerts` calls `dismiss(customCompletion:)` and does not run the completion
    /// stored by `present(view:)`. A held banner is cleared here. A held center view is not
    /// in that search, so this calls `dismiss()` on it instead.
    private func dismissAll() {
        switch mounted {
        case .banner:
            AlertKitAPI.dismissAllAlerts(completion: AlertEventSink.finished {
                mounted = nil
                status = "dismissAllAlerts completion"
            })
        case .center:
            mounted?.dismiss()
        case nil:
            AlertKitAPI.dismissAllAlerts(completion: AlertEventSink.finished {
                status = "dismissAllAlerts completion"
            })
        }
    }

    private func applySample() {
        draft = AlertDraft()
        status = mounted == nil ? "Idle" : status
    }

    private func applySpinnerDefaults(_ icon: IconChoice) {
        draft.dismissByTap = !icon.isSpinner
        draft.dismissInTime = !icon.isSpinner
    }
}

struct ModifierSurface: View {
    @State private var draft = AlertDraft()
    @State private var isPresent = false
    @State private var mounted: MountedAlert?
    @State private var status = "Idle"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            sketch
            anchor
            readout
            buttons
            ScrollView {
                controls
                    .padding(.bottom, 12)
            }
        }
        .onChange(of: draft.icon) { _, icon in
            draft.dismissByTap = !icon.isSpinner
            draft.dismissInTime = !icon.isSpinner
        }
        .onDisappear {
            mounted?.dismiss()
        }
    }

    private var sketch: some View {
        AlertSketch(
            style: draft.style.sketch,
            icon: draft.icon.sketch,
            title: draft.icon.alertTitle,
            subtitle: draft.subtitle,
            ink: draft.whiteInk ? .white : DemoPalette.packageInk
        )
    }

    /// The modifier presents from inside `body`. Equatable skips later body calls
    /// while `isPresent` and the view identity stay put, so a slider does not present again.
    @ViewBuilder
    private var anchor: some View {
        switch mounted {
        case .banner(let view):
            ModifierAnchor(
                isPresent: isPresent,
                alert: view,
                onPresentFlag: { isPresent = $0 },
                onDismiss: { clear(ObjectIdentifier(view)) }
            )
            .equatable()
        case .center(let view):
            ModifierAnchor(
                isPresent: isPresent,
                alert: view,
                onPresentFlag: { isPresent = $0 },
                onDismiss: { clear(ObjectIdentifier(view)) }
            )
            .equatable()
        case nil:
            EmptyView()
        }
    }

    private var readout: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(".alert(isPresent:view:) · \(draft.viewCall)")
            Text(status)
        }
        .font(.caption.monospaced())
        .foregroundStyle(DemoPalette.inkMuted)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var buttons: some View {
        HStack(spacing: 8) {
            Button("Show", action: show)
                .buttonStyle(.borderedProminent)
                .tint(DemoPalette.accent)
                .disabled(mounted != nil)
            Button("Dismiss", action: dismissHeld)
                .buttonStyle(.bordered)
                .tint(DemoPalette.ink)
                .disabled(mounted == nil)
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            MenuRow(title: "Icon", selection: $draft.icon, options: Array(IconChoice.allCases), name: \.name)
            MenuRow(title: "Style", selection: $draft.style, options: Array(StyleChoice.allCases), name: \.name)
            MenuRow(title: "Haptic", selection: $draft.haptic, options: Array(HapticChoice.allCases), name: \.name)
            Toggle("Subtitle", isOn: $draft.showsSubtitle)
                .tint(DemoPalette.accent)
                .foregroundStyle(DemoPalette.ink)
            Toggle("Dismiss by tap", isOn: $draft.dismissByTap)
                .tint(DemoPalette.accent)
                .foregroundStyle(DemoPalette.ink)
            Toggle("Dismiss in time", isOn: $draft.dismissInTime)
                .tint(DemoPalette.accent)
                .foregroundStyle(DemoPalette.ink)
            DemoSlider(title: "Duration", value: $draft.duration, range: 0.4...4, step: 0.1)
            Toggle("White ink", isOn: $draft.whiteInk)
                .tint(DemoPalette.accent)
                .foregroundStyle(DemoPalette.ink)
            Toggle("Title 21 pt", isOn: $draft.largeTitle)
                .tint(DemoPalette.accent)
                .foregroundStyle(DemoPalette.ink)
            Text(
                "Show stores the view and sets isPresent. The next body of the anchor calls "
                    + ".alert(isPresent:view:). The package sets the binding false, then the completion. "
                    + "Dismiss calls view.dismiss(), which is what runs that completion."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
            .fixedSize(horizontal: false, vertical: true)
        }
        .demoCard()
    }

    private func show() {
        guard mounted == nil else { return }
        switch draft.style {
        case .banner:
            guard let view = draft.makeBanner() else {
                status = "UIImage(systemName: \"star.fill\") was nil. Nothing presented."
                return
            }
            mounted = .banner(view)
        case .center:
            guard let view = draft.makeCenter() else {
                status = "UIImage(systemName: \"star.fill\") was nil. Nothing presented."
                return
            }
            mounted = .center(view)
        }
        isPresent = true
        status = "isPresent true"
    }

    private func dismissHeld() {
        mounted?.dismiss()
    }

    private func clear(_ token: ObjectIdentifier) {
        guard mounted?.token == token else { return }
        mounted = nil
        isPresent = false
        status = "Modifier completion"
    }
}

/// Presents once per `isPresent` / identity change. See `SwiftUIExtension.swift` at tag 5.1.10:
/// the modifier calls `present` while `body` is evaluated.
struct ModifierAnchor<Alert: AlertViewProtocol & AnyObject>: View, Equatable {
    nonisolated(unsafe) var isPresent: Bool
    nonisolated(unsafe) var alert: Alert
    var onPresentFlag: @MainActor (Bool) -> Void
    var onDismiss: @MainActor () -> Void

    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.isPresent == rhs.isPresent && lhs.alert === rhs.alert
    }

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
            .alert(
                isPresent: Binding(
                    get: { isPresent },
                    set: { newValue in
                        MainActor.assumeIsolated {
                            onPresentFlag(newValue)
                        }
                    }
                ),
                view: alert,
                completion: AlertEventSink.finished(onDismiss)
            )
    }
}

struct MenuRow<Selection: Hashable>: View {
    var title: String
    @Binding var selection: Selection
    var options: [Selection]
    var name: KeyPath<Selection, String>

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Spacer()
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { item in
                    Text(item[keyPath: name]).tag(item)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.ink)
        }
    }
}
