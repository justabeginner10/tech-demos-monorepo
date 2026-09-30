import FloatingPanel
import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            MapsDemoView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            ModalDemoView()
                .tabItem {
                    Label("Modal", systemImage: "rectangle.portrait.on.rectangle.portrait.angled")
                }

            PlaygroundDemoView()
                .tabItem {
                    Label("Playground", systemImage: "slider.horizontal.3")
                }
        }
        .tint(DemoPalette.tide)
    }
}

enum DemoPalette {
    static let deep = Color(red: 0.04, green: 0.16, blue: 0.20)
    static let tide = Color(red: 0.09, green: 0.42, blue: 0.45)
    static let foam = Color(red: 0.74, green: 0.89, blue: 0.86)
    static let park = Color(red: 0.45, green: 0.68, blue: 0.52)
    static let coral = Color(red: 0.90, green: 0.40, blue: 0.32)
    static let sand = Color(red: 0.93, green: 0.89, blue: 0.80)
}

func panelStateTitle(_ state: FloatingPanelState?) -> String {
    state?.rawValue.capitalized ?? "Settling"
}
