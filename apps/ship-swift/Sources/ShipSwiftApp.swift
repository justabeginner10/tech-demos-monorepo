import SwiftUI

@main
struct ShipSwiftApp: App {
    var body: some Scene {
        WindowGroup {
            DemoScreen()
                .preferredColorScheme(.dark)
        }
    }
}
