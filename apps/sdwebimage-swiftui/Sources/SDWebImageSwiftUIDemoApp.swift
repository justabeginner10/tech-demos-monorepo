import SDWebImageSwiftUI
import SwiftUI

@main
struct SDWebImageSwiftUIDemoApp: App {
    init() {
        WebPRegistration.register()
    }

    var body: some Scene {
        WindowGroup {
            DemoScreen()
                .preferredColorScheme(.dark)
        }
    }
}
