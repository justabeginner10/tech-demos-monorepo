import BottomSheet
import SwiftUI

struct DynamicSheetView: View {
    private static let fit = BottomSheetPosition.dynamic
    private static let headerOnly = BottomSheetPosition.dynamicBottom

    @State private var position: BottomSheetPosition = fit
    @State private var stops: [Stop] = Array(Stop.catalog.prefix(3))

    var body: some View {
        stage
            .bottomSheet(
                bottomSheetPosition: $position,
                switchablePositions: [Self.headerOnly, Self.fit],
                headerContent: { header }
            ) {
                stopList
            }
            .showDragIndicator(true)
            .dragIndicatorColor(DemoPalette.ink.opacity(0.35))
            .demoChrome()
    }

    private var stage: some View {
        ZStack(alignment: .topLeading) {
            DemoPalette.paper
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 8) {
                Text("Field notes")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(DemoPalette.ink)
                Text("The sheet’s height is the header plus these rows. Add or remove a stop and it animates to fit.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 64)
            .padding(.trailing, 24)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Itinerary")
                        .font(.title3.bold())
                        .foregroundStyle(DemoPalette.ink)
                    Text("\(stops.count) \(stops.count == 1 ? "stop" : "stops") · hugs content")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                circleButton(
                    symbol: "minus",
                    label: "Remove stop",
                    enabled: !stops.isEmpty,
                    action: removeStop
                )
                circleButton(
                    symbol: "plus",
                    label: "Add stop",
                    enabled: stops.count < Stop.catalog.count,
                    action: addStop
                )
            }

            HStack(spacing: 8) {
                SnapButton(title: "Fit", isSelected: position == Self.fit) {
                    position = Self.fit
                }
                SnapButton(title: "Header", isSelected: position == Self.headerOnly) {
                    position = Self.headerOnly
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stopList: some View {
        VStack(alignment: .leading, spacing: 0) {
            if stops.isEmpty {
                Text("Nothing to hug yet. Add a stop and the sheet grows.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            } else {
                ForEach(stops) { stop in
                    HStack(spacing: 12) {
                        Image(systemName: stop.symbol)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(DemoPalette.accent)
                            .frame(width: 36, height: 36)
                            .background(
                                DemoPalette.accent.opacity(0.12),
                                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(stop.name)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(DemoPalette.ink)
                            Text(stop.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
            }

            Text("Tap the handle to swap Fit and Header. Dynamic positions measure this stack, so it stays free of scroll views and vertical spacers.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 16)
        }
    }

    private func circleButton(symbol: String, label: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.body.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(DemoPalette.accent, in: Circle())
                .opacity(enabled ? 1 : 0.35)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityLabel(label)
    }

    private func addStop() {
        guard stops.count < Stop.catalog.count else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            stops.append(Stop.catalog[stops.count])
        }
    }

    private func removeStop() {
        guard !stops.isEmpty else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            _ = stops.removeLast()
        }
    }
}

private struct Stop: Identifiable, Equatable {
    let id: String
    let name: String
    let detail: String
    let symbol: String

    static let catalog: [Stop] = [
        Stop(id: "ferry", name: "Ferry Terminal", detail: "8 min walk", symbol: "ferry.fill"),
        Stop(id: "market", name: "Cedar Market", detail: "Open until 8", symbol: "basket.fill"),
        Stop(id: "lookout", name: "North Lookout", detail: "City view", symbol: "binoculars.fill"),
        Stop(id: "books", name: "Paper & Ink", detail: "Bookshop", symbol: "books.vertical.fill"),
        Stop(id: "cafe", name: "Lantern Cafe", detail: "Espresso", symbol: "cup.and.saucer.fill"),
        Stop(id: "path", name: "River Path", detail: "Shaded trail", symbol: "figure.walk"),
        Stop(id: "post", name: "Old Post", detail: "Museum", symbol: "building.columns.fill"),
        Stop(id: "bus", name: "Night Bus", detail: "Stop 14", symbol: "bus.fill")
    ]
}

#Preview {
    NavigationStack {
        DynamicSheetView()
    }
}
