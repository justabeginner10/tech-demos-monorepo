import BottomSheet
import SwiftUI

struct MapsSheetView: View {
    private static let collapsed = BottomSheetPosition.relativeBottom(0.125)
    private static let half = BottomSheetPosition.relative(0.4)
    private static let expanded = BottomSheetPosition.relativeTop(0.975)

    @State private var position: BottomSheetPosition = half
    @State private var searchText = ""
    @FocusState private var searchFocused: Bool

    private let places: [Place] = [
        Place(id: "green", name: "Riverside Green", category: "Park", distance: "0.2 mi", symbol: "leaf.fill"),
        Place(id: "lantern", name: "Lantern Cafe", category: "Coffee", distance: "0.3 mi", symbol: "cup.and.saucer.fill"),
        Place(id: "market", name: "Cedar Market", category: "Grocery", distance: "0.4 mi", symbol: "basket.fill"),
        Place(id: "ink", name: "Paper & Ink", category: "Bookstore", distance: "0.5 mi", symbol: "books.vertical.fill"),
        Place(id: "harbor", name: "Harbor Steps", category: "Waterfront", distance: "0.6 mi", symbol: "ferry.fill"),
        Place(id: "oven", name: "North Oven", category: "Bakery", distance: "0.7 mi", symbol: "fork.knife"),
        Place(id: "station", name: "Loop Station", category: "Transit", distance: "0.8 mi", symbol: "tram.fill"),
        Place(id: "museum", name: "Old Post", category: "Museum", distance: "0.9 mi", symbol: "building.columns.fill")
    ]

    private var filteredPlaces: [Place] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return places }
        return places.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || $0.category.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        MapCanvas()
            .bottomSheet(
                bottomSheetPosition: $position,
                switchablePositions: [Self.collapsed, Self.half, Self.expanded],
                headerContent: { header }
            ) {
                placeList
            }
            .showDragIndicator(true)
            .dragIndicatorColor(DemoPalette.ink.opacity(0.35))
            .enableAppleScrollBehavior(true)
            .enableFlickThrough(true)
            .enableBackgroundBlur(true)
            .backgroundBlurMaterial(.adaptive(.thin))
            .enableAccountingForKeyboardHeight(true)
            .demoChrome()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Places")
                    .font(.title2.bold())
                    .foregroundStyle(DemoPalette.ink)
                Text("\(filteredPlaces.count) nearby · North Loop")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search places", text: $searchText)
                    .textFieldStyle(.plain)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($searchFocused)
                    .submitLabel(.done)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(DemoPalette.ink.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .onChange(of: searchFocused) { _, isFocused in
                if isFocused {
                    position = Self.expanded
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var placeList: some View {
        VStack(alignment: .leading, spacing: 0) {
            if filteredPlaces.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No places match “\(searchText)”")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .padding(.horizontal, 20)
            } else {
                ForEach(filteredPlaces) { place in
                    PlaceRow(place: place)
                    if place.id != filteredPlaces.last?.id {
                        Divider()
                            .padding(.leading, 72)
                    }
                }
            }
        }
        .padding(.bottom, 28)
        .animation(.easeInOut(duration: 0.2), value: filteredPlaces)
    }
}

private struct Place: Identifiable, Equatable {
    let id: String
    let name: String
    let category: String
    let distance: String
    let symbol: String
}

private struct PlaceRow: View {
    let place: Place

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: place.symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(DemoPalette.accent)
                .frame(width: 40, height: 40)
                .background(DemoPalette.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                Text(place.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Text(place.distance)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

private struct MapCanvas: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                DemoPalette.mapLand

                Canvas { context, size in
                    let step: CGFloat = 32
                    var cursor: CGFloat = 0
                    while cursor < size.width {
                        var path = Path()
                        path.move(to: CGPoint(x: cursor, y: 0))
                        path.addLine(to: CGPoint(x: cursor, y: size.height))
                        context.stroke(path, with: .color(.white.opacity(0.16)), lineWidth: 1)
                        cursor += step
                    }
                    cursor = 0
                    while cursor < size.height {
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: cursor))
                        path.addLine(to: CGPoint(x: size.width, y: cursor))
                        context.stroke(path, with: .color(.white.opacity(0.16)), lineWidth: 1)
                        cursor += step
                    }

                    var river = Path()
                    river.move(to: CGPoint(x: -20, y: size.height * 0.70))
                    river.addQuadCurve(
                        to: CGPoint(x: size.width + 20, y: size.height * 0.46),
                        control: CGPoint(x: size.width * 0.42, y: size.height * 0.82)
                    )
                    context.stroke(
                        river,
                        with: .color(DemoPalette.mapWater),
                        style: StrokeStyle(lineWidth: 34, lineCap: .round)
                    )
                }

                Ellipse()
                    .fill(DemoPalette.mapPark)
                    .frame(width: geo.size.width * 0.46, height: geo.size.height * 0.18)
                    .position(x: geo.size.width * 0.28, y: geo.size.height * 0.30)

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(DemoPalette.mapRoad)
                    .frame(width: 18, height: geo.size.height)
                    .position(x: geo.size.width * 0.64, y: geo.size.height * 0.5)

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(DemoPalette.mapRoad)
                    .frame(width: geo.size.width, height: 14)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.38)

                mapPin("Cedar Park", at: CGPoint(x: geo.size.width * 0.28, y: geo.size.height * 0.28))
                mapPin("Market", at: CGPoint(x: geo.size.width * 0.70, y: geo.size.height * 0.24))
                mapPin("Harbor", at: CGPoint(x: geo.size.width * 0.48, y: geo.size.height * 0.56))

                VStack(alignment: .leading, spacing: 4) {
                    Text("NORTH LOOP")
                        .font(.caption.weight(.bold))
                        .tracking(1.8)
                    Text("Drag the sheet between peek, half, and full.")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(DemoPalette.ink.opacity(0.72))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.leading, 68)
                .padding(.top, 18)
            }
        }
        .ignoresSafeArea()
    }

    private func mapPin(_ title: String, at point: CGPoint) -> some View {
        VStack(spacing: 3) {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, DemoPalette.accent)
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(DemoPalette.ink)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.white.opacity(0.92), in: Capsule())
        }
        .position(point)
    }
}

#Preview {
    NavigationStack {
        MapsSheetView()
    }
}
