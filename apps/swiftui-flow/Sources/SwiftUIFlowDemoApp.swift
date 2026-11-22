import SwiftUI

@main
struct SwiftUIFlowDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoScreen()
                .preferredColorScheme(.dark)
        }
    }
}
