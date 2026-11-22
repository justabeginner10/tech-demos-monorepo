import SwiftUI

@main
struct SwiftUINavigationTransitionsApp: App {
    var body: some Scene {
        WindowGroup {
            DemoScreen()
                .preferredColorScheme(.dark)
        }
    }
}
