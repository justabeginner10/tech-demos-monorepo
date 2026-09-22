import DrafterCharts
import SwiftUI

@main
struct DrafterChartsApp: App {
    var body: some Scene {
        WindowGroup {
            DemoScreen()
                .preferredColorScheme(.dark)
                .drafterTheme(.dark)
        }
    }
}
