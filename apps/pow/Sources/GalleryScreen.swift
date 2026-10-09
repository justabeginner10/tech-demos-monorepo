import Pow
import SwiftUI

/// Frozen catalog of Pow effects and transitions. Tiles are paint; a sheet
/// mounts a single live demo.
struct GalleryScreen: View {
    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 12)]

    @State private var selection: GallerySelection?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    section(title: "Change effects", items: ChangeEffectKind.allCases.map(GallerySelection.change))
                    section(title: "Transitions", items: TransitionKind.allCases.map(GallerySelection.transition))
                }
                .padding()
            }
            .background(DemoPalette.page)
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
            .sheet(item: $selection) { item in
                GalleryLiveSheet(selection: item)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Change, then delight.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "High-contrast snapshots of every effect Live can fire. Tiles do not "
                    + "run Pow. Tap one to open a sheet with a single live target."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }

    private func section(title: String, items: [GallerySelection]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items) { item in
                    Button {
                        selection = item
                    } label: {
                        DemoChrome.chartCard(title: item.title, subtitle: item.subtitle) {
                            VStack(alignment: .leading, spacing: 8) {
                                item.frozenPreview
                                Text(item.summary)
                                    .font(.caption)
                                    .foregroundStyle(DemoPalette.inkMuted)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack(spacing: 6) {
                                    DemoChrome.chip(item.title)
                                    DemoChrome.chip("tap for live")
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(item.title). Opens a live demo.")
                }
            }
        }
    }
}

struct GalleryLiveSheet: View {
    var selection: GallerySelection

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(selection.summary)
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.inkMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)

                DemoChrome.chip(selection.subtitle)

                Group {
                    switch selection {
                    case .change(let kind):
                        GalleryChangeLive(kind: kind)
                    case .transition(let kind):
                        GalleryTransitionLive(kind: kind)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
            .background(DemoPalette.page)
            .navigationTitle(selection.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .particleLayer(name: DemoParticleLayer.name)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private struct GalleryChangeLive: View {
    var kind: ChangeEffectKind

    @State private var fireCount = 0
    private let params = ChangeEffectParams()

    var body: some View {
        VStack(spacing: 16) {
            Button {
                fireCount += 1
            } label: {
                DemoChrome.badge(title: kind.title, systemImage: kind.systemImage)
            }
            .buttonStyle(.plain)
            .powChangeEffect(kind, params: params, value: fireCount)
            .id(kind)

            Button {
                fireCount += 1
            } label: {
                Label("Fire \(kind.title)", systemImage: "hand.tap")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
        }
    }
}

private struct GalleryTransitionLive: View {
    var kind: TransitionKind

    @State private var isVisible = true
    private let params = TransitionParams()

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(DemoPalette.canvas)

                if isVisible {
                    DemoChrome.badge(title: kind.title, systemImage: kind.systemImage)
                        .padding(16)
                        .transition(kind.powTransition(params))
                } else {
                    Text("View removed")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(DemoPalette.inkMuted)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 220)
            .id(kind)

            Button {
                withAnimation(.default) {
                    isVisible.toggle()
                }
            } label: {
                Label(isVisible ? "Remove view" : "Insert view", systemImage: isVisible ? "eye.slash" : "eye")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
        }
    }
}

#Preview("Pow Gallery") {
    GalleryScreen()
}
