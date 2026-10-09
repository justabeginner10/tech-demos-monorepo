import Pow
import SwiftUI

/// Adaptive playground for Pow: one live effect target, plus a static gallery.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live
    @State private var appearance: DemoAppearance = .system

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live, appearance: $appearance)
                .tabItem { Label("Live", systemImage: "sparkles") }
                .tag(DemoTab.live)

            GalleryScreen()
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
        .toolbarBackground(DemoPalette.page, for: .tabBar)
        .preferredColorScheme(appearance.colorScheme)
    }
}

/// One live Pow target at a time. Leaving the tab unmounts it.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @Binding var appearance: DemoAppearance

    @State private var family: LiveFamily = .effects
    @State private var effect: ChangeEffectKind = .spray
    @State private var transition: TransitionKind = .pop
    @State private var effectParams = ChangeEffectParams()
    @State private var transitionParams = TransitionParams()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    playgroundControls
                    if isSelected {
                        activeSurface
                    } else {
                        parkedCard
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(DemoPalette.page)
            .navigationTitle("Pow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .particleLayer(name: DemoParticleLayer.name)
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

            Picker("Family", selection: $family) {
                ForEach(LiveFamily.allCases) { item in
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
                "Only one target is mounted. Effects fire from `.changeEffect`. "
                    + "Transitions insert or remove with `.movingParts`. Gallery tiles are paint; "
                    + "a sheet hosts a single live demo."
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

    @ViewBuilder
    private var activeSurface: some View {
        switch family {
        case .effects:
            ChangeEffectSurface(kind: $effect, params: $effectParams)
        case .transitions:
            TransitionSurface(kind: $transition, params: $transitionParams)
        }
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: family.title, subtitle: "Unmounted") {
            Text("Live Pow target is unmounted while Gallery is open.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
        }
    }
}

#Preview("Pow Demo") {
    DemoScreen()
}
