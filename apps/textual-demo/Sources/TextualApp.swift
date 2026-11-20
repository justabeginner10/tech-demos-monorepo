import SwiftUI

@main
struct TextualApp: App {
    var body: some Scene {
        WindowGroup {
            DemoScreen()
                .preferredColorScheme(.dark)
        }
    }
}
