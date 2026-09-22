import SwiftUI

@main
struct LivelineApp: App {
    var body: some Scene {
        WindowGroup {
            DemoScreen()
                .preferredColorScheme(.dark)
        }
    }
}

#Preview("Liveline Demo") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
