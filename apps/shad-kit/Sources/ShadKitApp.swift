import ShadcnUI
import SwiftUI

@main
struct ShadKitApp: App {
    var body: some Scene {
        WindowGroup {
            DemoScreen()
                .preferredColorScheme(.dark)
                .shadcnSurface()
        }
    }
}
