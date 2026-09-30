import FloatingPanel
import SwiftUI
import UIKit

struct Place: Identifiable {
    let id: String
    let name: String
    let detail: String
    let symbol: String
    let distance: String
    let x: CGFloat
    let y: CGFloat

    static let samples: [Place] = [
        Place(id: "ferry", name: "Ferry Building", detail: "Marketplace and waterfront", symbol: "ferry", distance: "0.2 mi", x: 0.72, y: 0.34),
        Place(id: "park", name: "Dolores Park", detail: "Lawn, skyline, picnic tables", symbol: "tree", distance: "1.1 mi", x: 0.28, y: 0.46),
        Place(id: "cafe", name: "Harbor Coffee", detail: "Espresso and bay windows", symbol: "cup.and.saucer", distance: "0.4 mi", x: 0.58, y: 0.58),
        Place(id: "books", name: "Tide Books", detail: "Used books, late hours", symbol: "books.vertical", distance: "0.8 mi", x: 0.40, y: 0.70),
        Place(id: "museum", name: "Civic Museum", detail: "Current exhibit: Coastlines", symbol: "building.columns", distance: "1.6 mi", x: 0.22, y: 0.28),
        Place(id: "pier", name: "Pier 39 Lookout", detail: "Sea lions and sunset", symbol: "binoculars", distance: "2.0 mi", x: 0.80, y: 0.22)
    ]
}

final class MapsPanelLayout: NSObject, FloatingPanelLayout {
    override init() {
        super.init()
    }

    var position: FloatingPanelPosition { .bottom }

    var initialState: FloatingPanelState { .half }

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.46, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 92, edge: .bottom, referenceGuide: .safeArea)
        ]
    }

    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        if state == .full { return 0.28 }
        if state == .half { return 0.08 }
        return 0
    }

    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        let inset: CGFloat = view.bounds.width > 700 ? 24 : 0
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: inset),
            surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -inset)
        ]
    }
}

struct MapsDemoView: View {
    @State private var panelState: FloatingPanelState?
    @State private var query = ""
    @State private var selectedPlaceID: String?
    @State private var layout = MapsPanelLayout()
    @State private var appearance = PanelStyle.opaque(cornerRadius: 18, shadowOpacity: 0.2)

    private var filteredPlaces: [Place] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return Place.samples }
        return Place.samples.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
                || $0.detail.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        MapCanvas(selectedPlaceID: selectedPlaceID, panelState: panelState) { next in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                panelState = next
            }
        }
        .floatingPanel { proxy in
            MapsPanel(
                proxy: proxy,
                query: $query,
                selectedPlaceID: $selectedPlaceID,
                places: filteredPlaces,
                panelState: panelState
            ) { next in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    panelState = next
                }
            }
        }
        .floatingPanelLayout(layout)
        .floatingPanelSurfaceAppearance(appearance)
        .floatingPanelState($panelState)
        .floatingPanelBehavior(MapsSpringBehavior())
        .floatingPanelContentMode(.fitToBounds)
        .floatingPanelContentInsetAdjustmentBehavior(.never)
        .floatingPanelGrabberHandlePadding(10)
    }
}

private final class MapsSpringBehavior: NSObject, FloatingPanelBehavior {
    var springDecelerationRate: CGFloat { UIScrollView.DecelerationRate.fast.rawValue + 0.001 }
    var springResponseTime: CGFloat { 0.4 }

    func shouldProjectMomentum(
        _ fpc: FloatingPanelController,
        to proposedState: FloatingPanelState
    ) -> Bool {
        true
    }
}

private struct MapCanvas: View {
    var selectedPlaceID: String?
    var panelState: FloatingPanelState?
    var move: (FloatingPanelState) -> Void

    var body: some View {
        ZStack {
            mapLayers
            pins
            VStack {
                controls
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    private var mapLayers: some View {
        ZStack {
            LinearGradient(
                colors: [DemoPalette.deep, DemoPalette.tide, DemoPalette.foam],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Canvas { context, size in
                var grid = Path()
                let step: CGFloat = 42
                var x: CGFloat = 0
                while x < size.width {
                    grid.move(to: CGPoint(x: x, y: 0))
                    grid.addLine(to: CGPoint(x: x, y: size.height))
                    x += step
                }
                var y: CGFloat = 0
                while y < size.height {
                    grid.move(to: CGPoint(x: 0, y: y))
                    grid.addLine(to: CGPoint(x: size.width, y: y))
                    y += step
                }
                context.stroke(grid, with: .color(.white.opacity(0.08)), lineWidth: 1)

                let avenue = Path { path in
                    path.move(to: CGPoint(x: size.width * 0.08, y: size.height * 0.18))
                    path.addQuadCurve(
                        to: CGPoint(x: size.width * 0.92, y: size.height * 0.78),
                        control: CGPoint(x: size.width * 0.55, y: size.height * 0.28)
                    )
                }
                context.stroke(avenue, with: .color(DemoPalette.sand.opacity(0.85)), style: StrokeStyle(lineWidth: 18, lineCap: .round))

                let cross = Path { path in
                    path.move(to: CGPoint(x: size.width * 0.12, y: size.height * 0.72))
                    path.addLine(to: CGPoint(x: size.width * 0.88, y: size.height * 0.40))
                }
                context.stroke(cross, with: .color(.white.opacity(0.55)), style: StrokeStyle(lineWidth: 10, lineCap: .round))
            }

            Circle()
                .fill(DemoPalette.park.opacity(0.55))
                .frame(width: 150, height: 110)
                .offset(x: -90, y: -20)
            Circle()
                .fill(DemoPalette.park.opacity(0.4))
                .frame(width: 90, height: 70)
                .offset(x: 120, y: 80)
        }
        .ignoresSafeArea()
    }

    private var pins: some View {
        GeometryReader { proxy in
            ForEach(Place.samples) { place in
                MapPin(place: place, selected: place.id == selectedPlaceID)
                    .position(
                        x: proxy.size.width * place.x,
                        y: proxy.size.height * place.y
                    )
            }
        }
        .allowsHitTesting(false)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .foregroundStyle(DemoPalette.coral)
                Text("North Beach")
                    .font(.headline)
                Spacer()
                Text(panelStateTitle(panelState))
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial, in: Capsule())
            }

            HStack(spacing: 8) {
                stateButton("Tip", state: .tip, symbol: "chevron.down")
                stateButton("Half", state: .half, symbol: "rectangle.split.1x2")
                stateButton("Full", state: .full, symbol: "chevron.up")
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func stateButton(_ title: String, state: FloatingPanelState, symbol: String) -> some View {
        let selected = panelState == state
        return Button {
            move(state)
        } label: {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .foregroundStyle(selected ? Color.white : DemoPalette.deep)
                .background(selected ? DemoPalette.tide : Color.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct MapPin: View {
    var place: Place
    var selected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: place.symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: selected ? 46 : 36, height: selected ? 46 : 36)
                .background(selected ? DemoPalette.coral : DemoPalette.deep, in: Circle())
                .overlay(Circle().stroke(.white, lineWidth: 2))
            if selected {
                Text(place.name)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
    }
}

private struct MapsPanel: View {
    var proxy: FloatingPanelProxy
    @Binding var query: String
    @Binding var selectedPlaceID: String?
    var places: [Place]
    var panelState: FloatingPanelState?
    var move: (FloatingPanelState) -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Nearby")
                        .font(.title2.weight(.bold))
                    Spacer()
                    Text(panelStateTitle(panelState))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search places", text: $query)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.search)
                    if !query.isEmpty {
                        Button {
                            query = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)

            List {
                if places.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    ForEach(places) { place in
                        Button {
                            selectedPlaceID = place.id
                            move(.full)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: place.symbol)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(DemoPalette.tide)
                                    .frame(width: 36, height: 36)
                                    .background(DemoPalette.foam, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(place.name)
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text(place.detail)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(place.distance)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(place.id == selectedPlaceID ? DemoPalette.foam.opacity(0.45) : Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .floatingPanelScrollTracking(proxy: proxy)
        }
        .background(alignment: .top) {
            Color(.systemBackground)
                .frame(height: 1600)
        }
    }
}
