import Combine
import Foundation
import SwiftUI

enum InitTechnique: String, CaseIterable, Identifiable {
    case lazyState = "LazyState"
    case eagerState = "Eager @State"
    case onAppear = "Optional + onAppear"

    var id: String { rawValue }

    var shortTitle: String {
        switch self {
        case .lazyState: return "Lazy"
        case .eagerState: return "Eager"
        case .onAppear: return "onAppear"
        }
    }

    var headline: String {
        switch self {
        case .lazyState:
            return "Thunk runs once per view identity"
        case .eagerState:
            return "State(wrappedValue:) is eager — inits are thrown away"
        case .onAppear:
            return "Optional + onAppear avoids extra inits, but infects the view"
        }
    }

    var snippet: String {
        switch self {
        case .lazyState:
            return "_session = LazyState { SearchSession(region: region) }"
        case .eagerState:
            return "_session = State(wrappedValue: SearchSession(region: region))"
        case .onAppear:
            return "onAppear { session = SearchSession(region: region) }"
        }
    }

    var badgeSymbol: String {
        switch self {
        case .lazyState: return "checkmark.seal.fill"
        case .eagerState: return "exclamationmark.triangle.fill"
        case .onAppear: return "questionmark.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .lazyState: return .green
        case .eagerState: return .orange
        case .onAppear: return .blue
        }
    }
}

enum Region: String, CaseIterable, Identifiable {
    case bayArea = "Bay Area"
    case nyc = "New York"
    case london = "London"
    case tokyo = "Tokyo"

    var id: String { rawValue }

    var seed: String {
        switch self {
        case .bayArea: return "sfo"
        case .nyc: return "nyc"
        case .london: return "lon"
        case .tokyo: return "tyo"
        }
    }

    var symbol: String {
        switch self {
        case .bayArea: return "water.waves"
        case .nyc: return "building.2"
        case .london: return "clock"
        case .tokyo: return "tram.fill"
        }
    }

    var places: [String] {
        switch self {
        case .bayArea:
            return ["Ferry Building", "Golden Gate", "Muir Woods", "Apple Park"]
        case .nyc:
            return ["Central Park", "Brooklyn Bridge", "MoMA", "Katz's Deli"]
        case .london:
            return ["British Museum", "Hyde Park", "Borough Market", "Tate Modern"]
        case .tokyo:
            return ["Shibuya Crossing", "Meiji Jingu", "Tsukiji", "teamLab"]
        }
    }
}

/// Non-optional child model, configured from parent-passed region data.
@MainActor
struct SearchSession {
    let region: Region
    let createdAt: Date
    var query: String

    init(region: Region, technique: InitTechnique) {
        self.region = region
        self.createdAt = Date()
        self.query = ""
        ModelInitLog.shared.record(technique: technique, region: region)
    }

    var matches: [String] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return region.places }
        return region.places.filter { $0.localizedCaseInsensitiveContains(needle) }
    }
}

@MainActor
final class ModelInitLog: ObservableObject {
    static let shared = ModelInitLog()

    struct Event: Identifiable {
        let id = UUID()
        let technique: InitTechnique
        let region: Region
        let at: Date
    }

    @Published private(set) var events: [Event] = []

    func record(technique: InitTechnique, region: Region) {
        events.append(Event(technique: technique, region: region, at: Date()))
    }

    func count(for technique: InitTechnique) -> Int {
        events.filter { $0.technique == technique }.count
    }

    func reset() {
        events = []
    }
}
