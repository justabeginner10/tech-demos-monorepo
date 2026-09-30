import AdaptiveSheets
import SwiftUI

struct CustomHeightsScreen: View {
    @State private var isPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DemoScreenHeader(
                    message: "A fixed height, a fraction of the screen, and the standard medium detent. The sheet starts at 180 points."
                )
                PresentButton(title: "Show custom heights") {
                    isPresented = true
                }
                DetentLegend(stops: [
                    "Starts at height 180",
                    "Also rests at 55% and medium",
                    "Background interaction disabled"
                ])
            }
            .padding(20)
        }
        .background(DemoPalette.paper)
        .navigationTitle("Custom heights")
        .navigationBarTitleDisplayMode(.inline)
        .adaptiveSheets(
            isPresented: $isPresented,
            detents: [.height(180), .fraction(0.55), .medium],
            startDetent: .height(180),
            backgroundInteraction: .disabled,
            grabberIndicator: .visible,
            disableDismissOnSwipe: false,
            cornerRardius: 20
        ) {
            SheetBody(
                title: "Three measured stops",
                detail: "180 points is a short peek. 55% sits between that and medium. Drag the grabber to move between them."
            ) {
                DetentLegend(stops: [
                    "height(180)",
                    "fraction(0.55)",
                    "medium"
                ])
            }
        }
    }
}
