import AdaptiveSheets
import SwiftUI

struct BasicSheetScreen: View {
    @State private var isPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DemoScreenHeader(
                    message: "Two resting heights. The sheet opens at medium, and you can drag it to large. The grabber is visible, and a downward swipe dismisses it."
                )
                PresentButton(title: "Show basic sheet") {
                    isPresented = true
                }
                DetentLegend(stops: [
                    "Opens at medium",
                    "Also rests at large",
                    "Grabber visible",
                    "Swipe dismiss allowed"
                ])
            }
            .padding(20)
        }
        .background(DemoPalette.paper)
        .navigationTitle("Basic sheet")
        .navigationBarTitleDisplayMode(.inline)
        .adaptiveSheets(
            isPresented: $isPresented,
            detents: [.medium, .large],
            startDetent: .medium,
            backgroundInteraction: .automatic,
            grabberIndicator: .visible,
            disableDismissOnSwipe: false,
            cornerRardius: 16
        ) {
            SheetBody(
                title: "Medium, then large",
                detail: "Drag the grabber. Medium is about half the screen. Large fills it."
            ) {
                DetentLegend(stops: ["medium", "large"])
            }
        }
    }
}
