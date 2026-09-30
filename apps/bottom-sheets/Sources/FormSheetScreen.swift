import BottomSheets
import SwiftUI

struct FormSheetScreen: View {
    private struct Place: Identifiable {
        let id: String
        let name: String
        let symbol: String
    }

    private let places: [Place] = [
        Place(id: "north", name: "North Beach", symbol: "cup.and.saucer.fill"),
        Place(id: "mission", name: "Mission", symbol: "fork.knife"),
        Place(id: "sunset", name: "Sunset", symbol: "sun.horizon.fill"),
        Place(id: "marina", name: "Marina", symbol: "sailboat.fill"),
        Place(id: "hayes", name: "Hayes Valley", symbol: "bag.fill")
    ]

    @State private var isPresented = false
    @State private var detent: BPresentationDetent = .large
    @State private var name = ""
    @State private var note = ""
    @State private var remind = true
    @State private var lockDismiss = false
    @State private var selectedPlace = "North Beach"

    private var detents: Set<BPresentationDetent> {
        [.height(340), .medium, .large]
    }

    var body: some View {
        PageScroll(title: "Form") {
            Text("Fields and a list live in the sheet. BottomSheets 1.0.0 does not backport presentationContentInteraction; the list scrolls on its own.")
                .foregroundStyle(Theme.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                summaryLine("Name", name.isEmpty ? "Not set" : name)
                summaryLine("Place", selectedPlace)
                summaryLine("Remind", remind ? "On" : "Off")
                summaryLine("Dismiss lock", lockDismiss ? "On" : "Off")
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            DemoButton(title: "Open form sheet", systemImage: "square.and.pencil") {
                isPresented = true
            }
        }
        .bottomSheet(
            isPresented: $isPresented,
            detents,
            selection: $detent
        ) {
            formList
                .bInteractiveDismissDisabled(lockDismiss)
                .bPresentationDragIndicator(.visible)
                .bPresentationBackground(Theme.card)
                .bPresentationCornerRadius(22)
        }
    }

    private var formList: some View {
        List {
            Section {
                HStack {
                    Text("Details")
                        .font(.headline)
                    Spacer()
                    SheetDismissButton { isPresented = false }
                }
                .listRowBackground(Theme.card)

                TextField("Name", text: $name)
                    .textInputAutocapitalization(.words)
                    .listRowBackground(Theme.card)
                TextField("Note", text: $note, axis: .vertical)
                    .lineLimit(2...4)
                    .listRowBackground(Theme.card)
                Toggle("Remind me", isOn: $remind)
                    .listRowBackground(Theme.card)
                Toggle("Lock interactive dismiss", isOn: $lockDismiss)
                    .listRowBackground(Theme.card)
            }

            Section("Places") {
                ForEach(places) { place in
                    Button {
                        selectedPlace = place.name
                    } label: {
                        HStack {
                            Image(systemName: place.symbol)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 24)
                            Text(place.name)
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            if selectedPlace == place.name {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Theme.accent)
                            }
                        }
                    }
                    .listRowBackground(Theme.card)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .frame(minHeight: 360)
    }

    private func summaryLine(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Theme.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        FormSheetScreen()
    }
    .tint(Theme.accent)
}
