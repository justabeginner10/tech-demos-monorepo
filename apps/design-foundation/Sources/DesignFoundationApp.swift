import DesignFoundation
import SwiftUI

@main
struct DesignFoundationApp: App {
    var body: some Scene {
        WindowGroup {
            DemoScreen()
                .dfToast(style: .filled)
                .dfTheme(.slateDark)
                .demoChromeScheme()
        }
    }
}
