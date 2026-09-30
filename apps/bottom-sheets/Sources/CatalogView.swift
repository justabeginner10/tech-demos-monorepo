import SwiftUI

struct CatalogView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sheets with detents")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(Theme.ink)
                        Text("BottomSheets 1.0.0 mirrors SwiftUI presentation detents. On iOS 16.4 and later the package presents the system sheet unless you turn that path off.")
                            .font(.body)
                            .foregroundStyle(Theme.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom, 6)

                    NavigationLink {
                        BasicDetentsScreen()
                    } label: {
                        DemoRow(
                            title: "Basic detents",
                            subtitle: "Height, medium, fraction, and large, with a selection binding.",
                            symbol: "rectangle.bottomhalf.inset.filled"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        MapsLikeScreen()
                    } label: {
                        DemoRow(
                            title: "Maps-like",
                            subtitle: "Keep the map live up through a detent, then block it.",
                            symbol: "map.fill"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        StyledSheetScreen()
                    } label: {
                        DemoRow(
                            title: "Styled sheet",
                            subtitle: "Background, corner radius, shadow, dimming, and overdrag.",
                            symbol: "paintpalette.fill"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        FormSheetScreen()
                    } label: {
                        DemoRow(
                            title: "Form and scrolling",
                            subtitle: "Text fields and a list inside the sheet.",
                            symbol: "list.bullet.rectangle.portrait.fill"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        NativePathScreen()
                    } label: {
                        DemoRow(
                            title: "Native or custom",
                            subtitle: "nativeBottomSheetDisabled compares both implementations.",
                            symbol: "arrow.triangle.2.circlepath"
                        )
                    }
                    .buttonStyle(.plain)

                    Text("Library floor is iOS 14. This demo targets iOS 17 so the native path is the default.")
                        .font(.footnote)
                        .foregroundStyle(Theme.secondary)
                        .padding(.top, 8)
                }
                .padding(20)
                .frame(maxWidth: 560, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.canvas)
            .navigationTitle("BottomSheets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.canvas, for: .navigationBar)
        }
    }
}

#Preview {
    CatalogView()
        .tint(Theme.accent)
}
