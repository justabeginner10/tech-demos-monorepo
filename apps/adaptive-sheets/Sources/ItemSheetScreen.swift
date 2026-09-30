import AdaptiveSheets
import SwiftUI

struct SheetSubject: Identifiable, Hashable {
    let id: String
    let name: String
    let note: String
    let symbol: String
}

struct ItemSheetScreen: View {
    @State private var selectedSubject: SheetSubject?
    @State private var lastClosed = "Tap a place to open its sheet."

    private let subjects: [SheetSubject] = [
        SheetSubject(id: "ferry", name: "Ferry building", note: "The clock tower faces the water. Boats leave on the hour.", symbol: "ferry.fill"),
        SheetSubject(id: "park", name: "Dolores park", note: "A grass slope with downtown in the distance.", symbol: "tree.fill"),
        SheetSubject(id: "bridge", name: "Bay bridge", note: "The east span, seen from the shoreline path.", symbol: "road.lanes"),
        SheetSubject(id: "market", name: "Market street", note: "Streetcars run the length of a wide sidewalk.", symbol: "tram.fill")
    ]

    var body: some View {
        List(subjects) { subject in
            Button {
                selectedSubject = subject
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: subject.symbol)
                        .frame(width: 28)
                        .foregroundStyle(DemoPalette.tide)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(subject.name)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(DemoPalette.ink)
                        Text(subject.note)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(DemoPalette.paper)
        .navigationTitle("From a list")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Text(lastClosed)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DemoPalette.paper)
        }
        .adaptiveSheets(
            item: $selectedSubject,
            detents: [.medium, .large],
            startDetent: .medium,
            backgroundInteraction: .automatic,
            grabberIndicator: .visible,
            disableDismissOnSwipe: false,
            cornerRardius: 24,
            onDismiss: {
                lastClosed = "Closed the place sheet."
            }
        ) { subject in
            if let subject {
                SheetBody(
                    title: subject.name,
                    detail: subject.note
                ) {
                    Image(systemName: subject.symbol)
                        .font(.system(size: 44))
                        .foregroundStyle(DemoPalette.tide)
                        .accessibilityHidden(true)
                    Text("This sheet is presented with the item binding. Clearing the selection, or swiping down, dismisses it.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
