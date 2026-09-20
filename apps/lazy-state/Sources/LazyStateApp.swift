import SwiftUI

@main
struct LazyStateApp: App {
    var body: some Scene {
        WindowGroup {
            DemoScreen()
        }
    }
}

#Preview("LazyState Demo") {
    DemoScreen()
}
