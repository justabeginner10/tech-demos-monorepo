import BottomSheets
import MapKit
import SwiftUI

struct MapsLikeScreen: View {
    private struct Place: Identifiable {
        let id: String
        let name: String
        let detail: String
        let symbol: String
        let coordinate: CLLocationCoordinate2D
    }

    private static let peek = BPresentationDetent.height(180)
    private static let half = BPresentationDetent.medium
    private static let full = BPresentationDetent.large

    private let places: [Place] = [
        Place(id: "ferry", name: "Ferry Building", detail: "Embarcadero", symbol: "ferry.fill", coordinate: CLLocationCoordinate2D(latitude: 37.7955, longitude: -122.3937)),
        Place(id: "coit", name: "Coit Tower", detail: "Telegraph Hill", symbol: "building.columns.fill", coordinate: CLLocationCoordinate2D(latitude: 37.8024, longitude: -122.4058)),
        Place(id: "alcatraz", name: "Alcatraz", detail: "Across the bay", symbol: "water.waves", coordinate: CLLocationCoordinate2D(latitude: 37.8267, longitude: -122.4230))
    ]

    @State private var isPresented = true
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.802, longitude: -122.42),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )
    @State private var selectedID = "ferry"

    var body: some View {
        Map(position: $position) {
            ForEach(places) { place in
                Marker(place.name, systemImage: place.symbol, coordinate: place.coordinate)
            }
        }
        .mapStyle(.standard(elevation: .flat))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .ignoresSafeArea(edges: .bottom)
        .overlay(alignment: .top) {
            banner
        }
        .navigationTitle("Maps-like")
        .navigationBarTitleDisplayMode(.inline)
        .bottomSheet(
            isPresented: $isPresented,
            [Self.peek, Self.half, Self.full],
            interaction: .enabled(upThrough: Self.half)
        ) {
            placeCard
        }
    }

    private var banner: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Background stays live")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Text("Pan the map while the sheet is at 180 pt or medium. Large blocks the map and dims it.")
                    .font(.caption)
                    .foregroundStyle(Theme.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if !isPresented {
                Button("Show") { isPresented = true }
                    .font(.subheadline.weight(.semibold))
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var placeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Places")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                    Label("Drag indicator on", systemImage: "line.3.horizontal")
                        .font(.caption)
                        .foregroundStyle(Theme.secondary)
                }
                Spacer()
                SheetDismissButton { isPresented = false }
            }

            ForEach(places) { place in
                Button {
                    selectedID = place.id
                    position = .region(
                        MKCoordinateRegion(
                            center: place.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                        )
                    )
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: place.symbol)
                            .frame(width: 28)
                            .foregroundStyle(Theme.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(place.name)
                                .foregroundStyle(Theme.ink)
                            Text(place.detail)
                                .font(.caption)
                                .foregroundStyle(Theme.secondary)
                        }
                        Spacer()
                        if selectedID == place.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .bPresentationDragIndicator(.visible)
        .presentationContentOverlay(Color.black.opacity(0.28))
    }
}

#Preview {
    NavigationStack {
        MapsLikeScreen()
    }
}
