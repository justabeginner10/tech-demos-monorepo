import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sliding sheets with custom snap states.")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(DemoPalette.ink)
                        Text("Four screens for lucaszischka/BottomSheet: relative snaps, a sheet that hugs its content, the view modifiers, and absolute point heights.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(spacing: 12) {
                        demoLink(
                            title: "Nearby places",
                            subtitle: "Three relative snaps, a search header, and Apple-style scrolling.",
                            symbol: "map",
                            destination: MapsSheetView()
                        )
                        demoLink(
                            title: "Hug content",
                            subtitle: "Dynamic height that grows and shrinks with the rows.",
                            symbol: "arrow.up.and.down",
                            destination: DynamicSheetView()
                        )
                        demoLink(
                            title: "Modifier playground",
                            subtitle: "Drag indicator, dismiss, background, corners, shadow, and animation.",
                            symbol: "slider.horizontal.3",
                            destination: ModifierPlaygroundView()
                        )
                        demoLink(
                            title: "Point heights",
                            subtitle: "Absolute snaps at 150, 280, 440, and 620 points.",
                            symbol: "ruler",
                            destination: AbsoluteSheetView()
                        )
                    }
                }
                .padding(20)
            }
            .background(DemoPalette.paper)
            .navigationTitle("BottomSheet")
        }
    }

    private func demoLink<Destination: View>(
        title: String,
        subtitle: String,
        symbol: String,
        destination: Destination
    ) -> some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.title3)
                    .foregroundStyle(DemoPalette.accent)
                    .frame(width: 44, height: 44)
                    .background(DemoPalette.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(DemoPalette.ink)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .tint(DemoPalette.accent)
}
