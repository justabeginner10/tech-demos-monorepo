import AdaptiveSheets
import SwiftUI

struct StyledSheetScreen: View {
    @State private var isPresented = false
    @State private var showGrabber = true
    @State private var dismissNote = "The sheet has not been dismissed yet."
    @State private var showDismissAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DemoScreenHeader(
                    message: "Corner radius is 32. Swipe-to-dismiss is off, so the sheet stays until you tap Close. That path runs onDismiss."
                )
                Toggle("Show grabber", isOn: $showGrabber)
                    .font(.system(.body, design: .rounded))
                    .tint(DemoPalette.tide)
                    .disabled(isPresented)
                PresentButton(title: "Show locked sheet") {
                    isPresented = true
                }
                Text(dismissNote)
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
        }
        .background(DemoPalette.paper)
        .navigationTitle("Locked sheet")
        .navigationBarTitleDisplayMode(.inline)
        .adaptiveSheets(
            isPresented: $isPresented,
            detents: [.medium, .large],
            startDetent: .medium,
            backgroundInteraction: .disabled,
            grabberIndicator: showGrabber ? .visible : .hidden,
            disableDismissOnSwipe: true,
            cornerRardius: 32,
            onDismiss: {
                dismissNote = "Dismissed at \(Date.now.formatted(date: .omitted, time: .standard))."
                showDismissAlert = true
            }
        ) {
            SheetBody(
                title: "Close it from inside",
                detail: "A downward swipe does nothing. The corners are cut to 32 points. Hide the grabber from the screen behind this sheet, then present it again."
            ) {
                Button("Close sheet") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .tint(DemoPalette.tide)
            }
        }
        .alert("Sheet dismissed", isPresented: $showDismissAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(dismissNote)
        }
    }
}
