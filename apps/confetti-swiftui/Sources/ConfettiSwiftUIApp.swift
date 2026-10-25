import SwiftUI

@main
struct ConfettiSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            DemoScreen()
                .preferredColorScheme(.dark)
        }
    }
}
