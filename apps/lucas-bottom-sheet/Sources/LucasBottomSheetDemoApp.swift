import SwiftUI

@main
struct LucasBottomSheetDemoApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .tint(DemoPalette.accent)
                .preferredColorScheme(.light)
        }
    }
}
