import SwiftUI

@main
struct ScalingHeaderScrollViewApp: App {
    var body: some Scene {
        WindowGroup {
            DemoScreen()
                .preferredColorScheme(.dark)
        }
    }
}
