import SwiftUI
import WelcomeKit

/// Adaptive playground for WelcomeKit: one live first-launch sheet, plus a static gallery.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live
    @State private var preset: LivePreset = .harbor
    @State private var appearance: DemoAppearance = .system
    @State private var showAgain = false
    @State private var firstLaunchEpoch = 0
    @State private var hasSeenFirstLaunch = WelcomeStore.hasSeenWelcome(id: LivePreset.firstLaunchID)

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(
                preset: $preset,
                appearance: $appearance,
                showAgain: $showAgain,
                hasSeenFirstLaunch: hasSeenFirstLaunch,
                onResetFirstLaunch: resetFirstLaunch
            )
            .tabItem { Label("Live", systemImage: "sparkles") }
            .tag(DemoTab.live)

            GalleryScreen()
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
        .toolbarBackground(DemoPalette.page, for: .tabBar)
        .preferredColorScheme(appearance.colorScheme)
        .welcomeSheet(
            isPresented: $showAgain,
            headline: preset.headline,
            features: preset.features,
            configuration: preset.configuration,
            presentation: .dismissible,
            onContinue: refreshSeen
        )
        .welcomeSheetOnFirstLaunch(
            id: LivePreset.firstLaunchID,
            headline: preset.headline,
            features: preset.features,
            configuration: preset.configuration,
            onContinue: refreshSeen
        )
        .id(firstLaunchEpoch)
    }

    private func refreshSeen() {
        hasSeenFirstLaunch = WelcomeStore.hasSeenWelcome(id: LivePreset.firstLaunchID)
    }

    private func resetFirstLaunch() {
        WelcomeStore.reset(id: LivePreset.firstLaunchID)
        hasSeenFirstLaunch = false
        firstLaunchEpoch += 1
    }
}

/// Controls for the two public modifiers. The real sheet is presented from `DemoScreen`.
struct LivePlaygroundView: View {
    @Binding var preset: LivePreset
    @Binding var appearance: DemoAppearance
    @Binding var showAgain: Bool
    var hasSeenFirstLaunch: Bool
    var onResetFirstLaunch: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    playgroundControls
                    LiveStatusCard(preset: preset, hasSeenFirstLaunch: hasSeenFirstLaunch)
                    LivePreviewCard(preset: preset)
                    liveActions
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(DemoPalette.page)
            .navigationTitle("WelcomeKit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
        }
    }

    private var playgroundControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Playground")
                .font(.headline)
                .foregroundStyle(DemoPalette.ink)

            Picker("Preset", selection: $preset) {
                ForEach(LivePreset.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Picker("Appearance", selection: $appearance) {
                ForEach(DemoAppearance.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Text(
                "First launch uses `.welcomeSheetOnFirstLaunch`. Show again uses "
                    + "`.welcomeSheet` with `.dismissible`. Reset calls `WelcomeStore.reset` "
                    + "and remounts the live tree so the first-launch sheet returns."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    private var liveActions: some View {
        VStack(spacing: 10) {
            Button {
                showAgain = true
            } label: {
                Label("Show welcome again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(preset.tint)

            Button(role: .destructive, action: onResetFirstLaunch) {
                Label("Reset first-launch state", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview("WelcomeKit Demo") {
    DemoScreen()
}
