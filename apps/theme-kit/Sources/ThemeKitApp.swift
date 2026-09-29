import SwiftUI
import ThemeKit

@main
struct ThemeKitApp: App {
    init() {
        Theme.shared.applyPersistedConfig()
    }

    var body: some Scene {
        WindowGroup {
            DemoScreen()
                .themeKit(reactToRuntimeChanges: false)
        }
    }
}
