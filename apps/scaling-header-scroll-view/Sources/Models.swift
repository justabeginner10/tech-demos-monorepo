import Foundation

struct FieldNote: Identifiable, Hashable {
    let id: Int
    let title: String
    let place: String
    let symbol: String
}

enum Shelf: String, CaseIterable, Identifiable, Hashable {
    case notes
    case places
    case saved

    var id: String { rawValue }

    var title: String {
        switch self {
        case .notes: "Notes"
        case .places: "Places"
        case .saved: "Saved"
        }
    }

    var symbol: String {
        switch self {
        case .notes: "note.text"
        case .places: "mappin.and.ellipse"
        case .saved: "bookmark.fill"
        }
    }
}

enum SampleLibrary {
    static let profileNotes: [FieldNote] = make(prefix: "Ridge", start: 1, count: 14)
    static let refreshSeed: [FieldNote] = make(prefix: "Camp", start: 1, count: 8)

    static func freshNote(id: Int) -> FieldNote {
        FieldNote(
            id: id,
            title: "Pulled note \(id)",
            place: "Just now",
            symbol: "arrow.down.circle.fill"
        )
    }

    static func moreNotes(start: Int, count: Int) -> [FieldNote] {
        make(prefix: "Later", start: start, count: count)
    }

    static func shelfNotes(_ shelf: Shelf) -> [FieldNote] {
        switch shelf {
        case .notes:
            make(prefix: "Note", start: 1, count: 10)
        case .places:
            make(prefix: "Place", start: 1, count: 5)
        case .saved:
            make(prefix: "Saved", start: 1, count: 18)
        }
    }

    private static let symbols = [
        "mountain.2.fill",
        "sun.horizon.fill",
        "leaf.fill",
        "binoculars.fill",
        "map.fill",
        "tent.fill",
        "camera.fill",
        "book.fill",
    ]

    private static let places = [
        "North ridge",
        "Cedar lake",
        "Switchback",
        "Old fire road",
        "Granite shelf",
        "River bend",
        "Lookout",
        "Pine saddle",
    ]

    static func make(prefix: String, start: Int, count: Int) -> [FieldNote] {
        (0..<count).map { offset in
            let number = start + offset
            return FieldNote(
                id: number,
                title: "\(prefix) \(number)",
                place: places[offset % places.count],
                symbol: symbols[offset % symbols.count]
            )
        }
    }
}
