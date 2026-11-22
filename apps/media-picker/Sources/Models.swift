import ExyteMediaPicker
import SwiftUI
import UIKit

enum LibraryKind: String, CaseIterable, Identifiable, Hashable {
    case photoAndVideo
    case photo
    case video

    var id: String { rawValue }

    var title: String {
        switch self {
        case .photoAndVideo: "Both"
        case .photo: "Photos"
        case .video: "Videos"
        }
    }

    var call: String {
        switch self {
        case .photoAndVideo: ".photoAndVideo"
        case .photo: ".photo"
        case .video: ".video"
        }
    }

    var value: MediaSelectionType {
        switch self {
        case .photoAndVideo: .photoAndVideo
        case .photo: .photo
        case .video: .video
        }
    }
}

enum SelectionMark: String, CaseIterable, Identifiable, Hashable {
    case checkmark
    case count

    var id: String { rawValue }

    var title: String {
        switch self {
        case .checkmark: "Check"
        case .count: "Count"
        }
    }

    var call: String {
        switch self {
        case .checkmark: ".checkmark"
        case .count: ".count"
        }
    }

    var value: MediaSelectionStyle {
        switch self {
        case .checkmark: .checkmark
        case .count: .count
        }
    }
}

/// Package case `.prominant` is spelled that way at tag 3.4.7.
enum CameraCell: String, CaseIterable, Identifiable, Hashable {
    case none
    case small
    case prominant

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none: "None"
        case .small: "Small"
        case .prominant: "Tall"
        }
    }

    var call: String {
        switch self {
        case .none: ".none"
        case .small: ".small"
        case .prominant: ".prominant"
        }
    }

    var value: LiveCameraCellStyle {
        switch self {
        case .none: .none
        case .small: .small
        case .prominant: .prominant
        }
    }
}

enum ThemeAccent: String, CaseIterable, Identifiable, Hashable {
    case gold
    case teal
    case violet

    var id: String { rawValue }

    var title: String { rawValue.capitalized }

    var color: Color {
        switch self {
        case .gold: DemoPalette.accent
        case .teal: Color(red: 0.32, green: 0.76, blue: 0.70)
        case .violet: Color(red: 0.58, green: 0.48, blue: 0.95)
        }
    }
}

enum MediaFormat {
    static func kind(_ type: MediaType) -> String {
        switch type {
        case .image: "Photo"
        case .video: "Video"
        }
    }

    /// Photos report a duration of 0. Hide that. Keep a real video length.
    static func duration(_ seconds: CGFloat?) -> String? {
        guard let seconds, seconds > 0.05 else { return nil }
        let total = Int(seconds.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    static func mode(_ mode: MediaPickerMode) -> String {
        switch mode {
        case .photos: ".photos"
        case .albums: ".albums"
        case .album(let album): ".album(\(album.title ?? "Untitled"))"
        case .camera: ".camera"
        case .cameraSelection: ".cameraSelection"
        }
    }
}

struct LoadedMedia: Identifiable {
    var id: UUID
    var type: MediaType
    var image: UIImage?
    var url: URL?
    var duration: CGFloat?
}

/// Picks returned by `onChange` and `selectedMedia`. Thumbnails load after the array lands.
@MainActor
@Observable
final class SelectionStore {
    private(set) var medias: [Media] = []
    private(set) var items: [LoadedMedia] = []
    private(set) var isLoading = false
    private var loadTask: Task<Void, Never>?

    /// Binding write from the picker. The matching `onChange` is what starts a load.
    func replace(_ medias: [Media]) {
        self.medias = medias
    }

    func apply(_ medias: [Media]) {
        self.medias = medias
        loadTask?.cancel()
        guard !medias.isEmpty else {
            items = []
            isLoading = false
            return
        }
        isLoading = true
        items = []
        loadTask = Task { [weak self] in
            await self?.load(medias)
        }
    }

    private func load(_ medias: [Media]) async {
        var loaded: [LoadedMedia] = []
        loaded.reserveCapacity(medias.count)
        for media in medias {
            if Task.isCancelled { return }
            let url = await media.getURL()
            let seconds = await media.duration
            let image = await thumbnail(for: media)
            loaded.append(
                LoadedMedia(
                    id: media.id,
                    type: media.type,
                    image: image,
                    url: url,
                    duration: seconds
                )
            )
        }
        if Task.isCancelled { return }
        items = loaded
        isLoading = false
    }

    /// Image `getThumbnailData()` calls `getData()`, and that path traps unless the
    /// Photos result is marked degraded. Image cells use `getThumbnailURL()` instead.
    /// Video frames use `getThumbnailData()`, which reads an `AVAsset` image.
    private func thumbnail(for media: Media) async -> UIImage? {
        switch media.type {
        case .image:
            guard let thumbURL = await media.getThumbnailURL() else { return nil }
            let data = await Task.detached(priority: .userInitiated) {
                try? Data(contentsOf: thumbURL)
            }.value
            return data.flatMap { UIImage(data: $0) }
        case .video:
            let data = await media.getThumbnailData()
            return data.flatMap { UIImage(data: $0) }
        }
    }
}

/// `MediaPickerCompletionClosure` and `MediaPickerOrientationHandler` are nonisolated.
/// A closure born in a `@MainActor` view would be main-actor isolated and would not match.
/// The package calls both from SwiftUI `onChange` / `onAppear` / `onDisappear`, on the main thread,
/// so `MainActor.assumeIsolated` is the synchronous hop back to SwiftUI state.
enum PickerSink {
    nonisolated static func changed(
        _ body: @escaping @MainActor ([Media]) -> Void
    ) -> MediaPickerCompletionClosure {
        { medias in
            MainActor.assumeIsolated {
                body(medias)
            }
        }
    }

    nonisolated static func orientation(
        _ body: @escaping @MainActor (String) -> Void
    ) -> MediaPickerOrientationHandler {
        { lock in
            let name: String
            switch lock {
            case .lock: name = "lock"
            case .unlock: name = "unlock"
            }
            MainActor.assumeIsolated {
                body(name)
            }
        }
    }
}
