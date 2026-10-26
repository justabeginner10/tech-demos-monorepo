import SwiftUI

@main
struct WaveApp: App {
    var body: some Scene {
        WindowGroup {
            DemoScreen()
                .preferredColorScheme(.dark)
        }
    }
}
