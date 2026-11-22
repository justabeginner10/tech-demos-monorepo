import SwiftUI

@main
struct AnchoredPopupApp: App {
    var body: some Scene {
        WindowGroup {
            DemoScreen()
                .preferredColorScheme(.dark)
        }
    }
}
