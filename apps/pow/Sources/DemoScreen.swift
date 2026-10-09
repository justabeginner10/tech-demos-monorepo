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
    @State private var fireCount = 0
    @State private var isTransitionVisible = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    playgroundControls
                    if isSelected {
                        primaryAction
                        activeSurface
                    } else {
                        parkedCard
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, DemoChrome.scrollTabClearance)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(DemoPalette.page)
            .navigationTitle("Pow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .particleLayer(name: DemoParticleLayer.name)
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

            Text("One target. Tap Fire or Insert/Remove, then the badge below.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(12)
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
            ChangeEffectSurface(kind: $effect, params: $effectParams, fireCount: $fireCount)
        case .transitions:
            TransitionSurface(kind: $transition, params: $transitionParams, isVisible: $isTransitionVisible)
        }
    }

    @ViewBuilder
    private var primaryAction: some View {
        switch family {
        case .effects:
            Button {
                fireCount += 1
            } label: {
                Label("Fire effect", systemImage: "hand.tap")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
            .controlSize(.large)
            .accessibilityIdentifier("fire-effect")
        case .transitions:
            Button {
                withAnimation(.default) {
                    isTransitionVisible.toggle()
                }
            } label: {
                Label(
                    isTransitionVisible ? "Remove view" : "Insert view",
                    systemImage: isTransitionVisible ? "eye.slash" : "eye"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
            .controlSize(.large)
            .accessibilityIdentifier("toggle-transition")
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
