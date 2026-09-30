import SwiftUI

@main
struct BottomSheetsBackportDemoApp: App {
    var body: some Scene {
        WindowGroup {
            CatalogView()
                .tint(Theme.accent)
                .preferredColorScheme(.light)
        }
    }
}
