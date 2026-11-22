import SwiftUI
import UIKit
import WhatsNewKit

/// Controls for automatic presentation, the manual sheet, and the view / controller.
/// Gallery never mounts these.
struct LivePlaygroundView: View {
    var isSelected: Bool
    @Binding var appearance: DemoAppearance

    @State private var family: LiveFamily = .automatic
    @State private var installed: InstalledVersion = .twoTwo
    @State private var preset: ManualPreset = .harbor
    @State private var storeKind: ManualStore = .userDefaults
    @State private var knobs = LayoutKnobs()
    @State private var autoEpoch = 0
    @State private var storeTick = 0
    @State private var manualItem: WhatsNew?
    @State private var embeddedItem: WhatsNew?
    @State private var showEmbedded = false
    @State private var primaryNote = "Primary onDismiss has not run."
    @State private var customTaps = 0
    @State private var controllerNote = "Controller has not been presented."

    var body: some View {
        liveStack
            .sheet(
                whatsNew: $manualItem,
                versionStore: storeKind.versionStore,
                layout: knobs.layout,
                onDismiss: { storeTick += 1 }
            )
            .sheet(isPresented: $showEmbedded, onDismiss: { storeTick += 1 }) {
                if let embeddedItem {
                    WhatsNewView(
                        whatsNew: embeddedItem,
                        versionStore: storeKind.versionStore,
                        layout: knobs.layout
                    )
                }
            }
            .onChange(of: isSelected) { _, selected in
                guard !selected else { return }
                manualItem = nil
                showEmbedded = false
            }
            .onChange(of: family) { _, _ in
                manualItem = nil
                showEmbedded = false
            }
    }

    private var liveStack: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    playgroundControls
                    if isSelected {
                        layoutCard
                        switch family {
                        case .automatic:
                            automaticCard
                            automaticActions
                        case .manual:
                            manualCard
                            manualActions
                        case .view:
                            viewCard
                            viewActions
                        }
                        storeCard
                    } else {
                        parkedCard
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(DemoPalette.page)
            .background {
                if isSelected, family == .automatic {
                    AutomaticHost(
                        version: installed.version,
                        layout: knobs.layout,
                        onPrimary: { primaryNote = "Automatic primary onDismiss" },
                        onDismiss: { storeTick += 1 }
                    )
                    .id(automaticID)
                }
            }
            .navigationTitle("WhatsNewKit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
        }
    }

    private var automaticID: String {
        "\(installed.version.description)-\(autoEpoch)"
    }

    private var playgroundControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Playground")
                .font(.headline)
                .foregroundStyle(DemoPalette.ink)

            Picker("Family", selection: $family) {
                ForEach(LiveFamily.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Text(family.subtitle)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)

            Picker("Appearance", selection: $appearance) {
                ForEach(DemoAppearance.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Text(
                "Only the selected family presents. Automatic uses the environment. "
                    + "Manual uses the sheet modifier. View presents WhatsNewView and the view controller. "
                    + "Gallery is painted."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .demoCard()
    }

    private var layoutCard: some View {
        DemoChrome.chartCard(title: "Layout", subtitle: "WhatsNew.Layout") {
            VStack(alignment: .leading, spacing: 8) {
                DemoSlider(title: "Feature spacing", value: $knobs.featureListSpacing, range: 8...60, step: 1)
                DemoSlider(title: "Footer spacing", value: $knobs.footerActionSpacing, range: 4...40, step: 1)
                DemoSlider(title: "Image width", value: $knobs.featureImageWidth, range: 24...72, step: 1)
                DemoSlider(title: "Button radius", value: $knobs.cornerRadius, range: 0...28, step: 1)
                Toggle("Scroll indicators", isOn: $knobs.showIndicators)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DemoPalette.ink)
                    .tint(DemoPalette.accent)
                Text("Sliders write a layout value passed into the presentation. They do not assign Layout.default.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
    }

    private var automaticCard: some View {
        DemoChrome.chartCard(title: "Automatic", subtitle: installed.detail) {
            VStack(alignment: .leading, spacing: 8) {
                Picker("Installed", selection: $installed) {
                    ForEach(InstalledVersion.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                Text(automaticCopy)
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    DemoChrome.chip("bundle \(WhatsNew.Version.current().description)")
                    DemoChrome.chip("resolved \(resolvedLabel)")
                }
            }
        }
    }

    private var manualCard: some View {
        DemoChrome.chartCard(title: preset.title, subtitle: preset.version.description) {
            VStack(alignment: .leading, spacing: 8) {
                Picker("Preset", selection: $preset) {
                    ForEach(ManualPreset.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Store", selection: $storeKind) {
                    ForEach(ManualStore.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                Text(preset.subtitle)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)

                Text(manualCopy)
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                FrozenWhatsNewCard(
                    title: preset.title,
                    tint: preset.tint,
                    rows: preset.rows,
                    primaryTitle: preset.primaryTitle,
                    secondaryTitle: preset.secondaryTitle
                )
            }
        }
    }

    private var viewCard: some View {
        DemoChrome.chartCard(title: "View", subtitle: preset.version.description) {
            VStack(alignment: .leading, spacing: 8) {
                Picker("Preset", selection: $preset) {
                    ForEach(ManualPreset.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Store", selection: $storeKind) {
                    ForEach(ManualStore.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                Text("WhatsNewView is the SwiftUI screen. The failable controller init returns nil when the store already has this version. The plain controller init does not write the store.")
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text(controllerNote)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
    }

    private var storeCard: some View {
        DemoChrome.chartCard(title: "Versions", subtitle: DemoStores.suiteName) {
            VStack(alignment: .leading, spacing: 8) {
                Text(primaryNote)
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.ink)
                Text("Remind me taps \(customTaps)")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                DemoChrome.chip("UserDefaults \(DemoStores.descriptions(DemoStores.userDefaults))")
                DemoChrome.chip("Memory \(DemoStores.descriptions(DemoStores.memory))")
            }
            .id(storeTick)
        }
    }

    private var automaticActions: some View {
        VStack(spacing: 10) {
            Button(action: removeResolved) {
                Label("Remove resolved version", systemImage: "minus.circle")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
            .disabled(DemoCatalog.versionToClear(current: installed.version) == nil)

            Button(role: .destructive, action: resetStored) {
                Label("Reset stored versions", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(action: restoreLayout) {
                Label("Package layout defaults", systemImage: "arrow.uturn.backward")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private var manualActions: some View {
        VStack(spacing: 10) {
            Button(action: showManual) {
                Label("Show sheet", systemImage: "sparkles")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(preset.tint)

            Button(action: removeManualVersion) {
                Label("Remove this version", systemImage: "minus.circle")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(storeKind == .off)

            Button(role: .destructive, action: resetStored) {
                Label("Reset stored versions", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private var viewActions: some View {
        VStack(spacing: 10) {
            Button(action: showView) {
                Label("Show WhatsNewView", systemImage: "rectangle.portrait")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(preset.tint)

            Button(action: { presentController(failable: true) }) {
                Label("Controller if new", systemImage: "square.stack")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(storeKind == .off)

            Button(action: { presentController(failable: false) }) {
                Label("Controller anyway", systemImage: "macwindow")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(action: removeManualVersion) {
                Label("Remove this version", systemImage: "minus.circle")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(storeKind == .off)
        }
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: "Live", subtitle: "Hidden") {
            Text("Leave Gallery to mount the presenter again.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.ink)
        }
    }

    private var resolvedLabel: String {
        DemoCatalog.probe(current: installed.version)?.description ?? "nothing"
    }

    private var automaticCopy: String {
        let current = installed.version
        let presented = DemoStores.userDefaults.presentedVersions
        if presented.contains(current) {
            return "\(current.description) is already stored, so whatsNew() returns nil. Remove it to show the sheet again."
        }
        if let match = DemoCatalog.probe(current: current) {
            if match == current {
                return "Exact match. The sheet presents \(match.description) until Continue writes the store."
            }
            return "No entry for \(current.description). The environment falls back to \(match.description)."
        }
        let minor = WhatsNew.Version(major: current.major, minor: current.minor, patch: 0)
        if presented.contains(minor) {
            return "\(minor.description) is already stored, so the patch fallback is skipped."
        }
        return "The collection has no \(current.description) and no \(minor.description)."
    }

    private var manualCopy: String {
        let version = preset.version
        guard let store = storeKind.versionStore else {
            return "Store is off, so the sheet always presents and dismiss does not save \(version.description)."
        }
        if store.hasPresented(version) {
            return "\(version.description) is already in this store. The sheet modifier will not present it until the version is removed."
        }
        return "Show sheet presents \(version.description). Dismiss saves it in the \(storeKind.title) store."
    }

    private func showManual() {
        let item = makeManual()
        if let store = storeKind.versionStore, store.hasPresented(item) {
            primaryNote = "\(item.version.description) is already stored. Remove it to show the sheet."
            return
        }
        manualItem = item
    }

    private func showView() {
        embeddedItem = makeManual()
        showEmbedded = true
    }

    private func makeManual() -> WhatsNew {
        let note = $primaryNote
        let taps = $customTaps
        let name = preset.title
        return DemoCatalog.manual(preset: preset, onPrimary: {
            note.wrappedValue = "Primary onDismiss for \(name)"
        }, onCustom: {
            taps.wrappedValue += 1
        })
    }

    private func removeManualVersion() {
        let version = preset.version
        switch storeKind {
        case .userDefaults:
            DemoStores.userDefaults.remove(presentedVersion: version)
        case .memory:
            DemoStores.memory.remove(presentedVersion: version)
        case .off:
            break
        }
        primaryNote = "Removed \(version.description) from \(storeKind.title)"
        storeTick += 1
    }

    private func removeResolved() {
        guard let version = DemoCatalog.versionToClear(current: installed.version) else { return }
        DemoStores.userDefaults.remove(presentedVersion: version)
        autoEpoch += 1
        primaryNote = "Removed \(version.description)"
        storeTick += 1
    }

    private func resetStored() {
        DemoStores.userDefaults.removeAll()
        DemoStores.memory.removeAll()
        autoEpoch += 1
        manualItem = nil
        showEmbedded = false
        primaryNote = "Removed every stored version"
        storeTick += 1
    }

    private func restoreLayout() {
        var sample = WhatsNew.Layout(featureListSpacing: 48, footerActionSpacing: 4)
        sample.reset()
        knobs.featureListSpacing = sample.featureListSpacing
        knobs.footerActionSpacing = sample.footerActionSpacing
        knobs.featureImageWidth = sample.featureImageWidth
        knobs.cornerRadius = sample.footerPrimaryActionButtonCornerRadius
        knobs.showIndicators = sample.showsScrollViewIndicators
    }

    private func presentController(failable: Bool) {
        let item = makeManual()
        let controller: WhatsNewViewController
        if failable {
            guard let store = storeKind.versionStore else {
                controllerNote = "The failable init needs a version store."
                return
            }
            guard let made = WhatsNewViewController(
                whatsNew: item,
                versionStore: store,
                layout: knobs.layout
            ) else {
                controllerNote = "Failable init returned nil. \(item.version.description) is already stored."
                return
            }
            controller = made
        } else {
            controller = WhatsNewViewController(whatsNew: item, layout: knobs.layout)
        }
        controllerNote = DemoPresenter.present(controller)
    }
}

/// `.whatsNewSheet()` reads the `whatsNew` environment from a parent, matching the package sample.
private struct AutomaticHost: View {
    var version: WhatsNew.Version
    var layout: WhatsNew.Layout
    var onPrimary: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        AutomaticSheetRoot(layout: layout, onDismiss: onDismiss)
            .environment(\.whatsNew, DemoCatalog.environment(current: version, layout: layout, onPrimary: onPrimary))
    }
}

private struct AutomaticSheetRoot: View {
    var layout: WhatsNew.Layout
    var onDismiss: () -> Void

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
            .whatsNewSheet(layout: layout, onDismiss: onDismiss)
    }
}

@MainActor
enum DemoPresenter {
    static func present(_ controller: UIViewController) -> String {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        guard let root = scene?.keyWindow?.rootViewController else {
            return "No key window."
        }
        var top = root
        while let next = top.presentedViewController {
            top = next
        }
        top.present(controller, animated: true)
        return "Presented."
    }
}
