import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(DemoScreen.allCases) { screen in
                NavigationLink(value: screen) {
                    Label {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(screen.title)
                                .font(.system(.body, design: .rounded, weight: .semibold))
                                .foregroundStyle(DemoPalette.ink)
                            Text(screen.blurb)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    } icon: {
                        Image(systemName: screen.symbol)
                            .foregroundStyle(DemoPalette.tide)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(DemoPalette.paper)
            .navigationTitle("AdaptiveSheets")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: DemoScreen.self) { screen in
                destination(for: screen)
            }
            .safeAreaInset(edge: .bottom) {
                Text("On iOS 16.4 and later this is presentationDetents. Earlier systems use the library’s UIKit sheet.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DemoPalette.paper)
            }
        }
        .tint(DemoPalette.tide)
    }

    @ViewBuilder
    private func destination(for screen: DemoScreen) -> some View {
        switch screen {
        case .basic:
            BasicSheetScreen()
        case .heights:
            CustomHeightsScreen()
        case .background:
            BackgroundInteractionScreen()
        case .styled:
            StyledSheetScreen()
        case .items:
            ItemSheetScreen()
        }
    }
}

#Preview {
    ContentView()
}
