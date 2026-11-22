import Foundation

/// A picsum.photos photo. The URL is the cache key Kingfisher derives from `URL`.
struct DemoPhoto: Identifiable, Hashable {
    let id: Int
    let width: Int
    let height: Int

    var url: URL {
        URL(string: "https://picsum.photos/id/\(id)/\(width)/\(height)")!
    }

    var caption: String {
        "picsum \(id) · \(width)×\(height)"
    }
}

enum PhotoLibrary {
    /// Hero for the Load tab. HTTPS, no API key. picsum redirects to fastly.picsum.photos.
    static let hero = DemoPhoto(id: 1015, width: 800, height: 600)

    /// Larger than the downsampler's target so `DownsamplingImageProcessor` has work to do.
    static let process = DemoPhoto(id: 1025, width: 900, height: 700)

    /// Sample stored in `ImageCache.default` by the Cache tab.
    static let cache = DemoPhoto(id: 1043, width: 600, height: 400)

    /// A real photo the Retry tab can swap in after the 404.
    static let recovery = DemoPhoto(id: 1069, width: 600, height: 400)

    /// picsum returns HTTP 404 for this id. `DelayRetryStrategy` retries response errors.
    static let failure = URL(string: "https://picsum.photos/id/999999/400/300")!

    /// Gallery grid. Same URLs are handed to `ImagePrefetcher`, so cache keys match.
    static let gallery: [DemoPhoto] = [
        DemoPhoto(id: 1016, width: 400, height: 300),
        DemoPhoto(id: 1018, width: 400, height: 300),
        DemoPhoto(id: 1035, width: 400, height: 300),
        DemoPhoto(id: 1039, width: 400, height: 300),
        DemoPhoto(id: 1074, width: 400, height: 300),
        DemoPhoto(id: 1080, width: 400, height: 300),
        DemoPhoto(id: 1036, width: 400, height: 300),
        DemoPhoto(id: 1044, width: 400, height: 300),
    ]
}

enum LoadTransition: String, CaseIterable, Identifiable, Hashable {
    case fade
    case opacity
    case scale
    case blurReplace

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fade: "Fade"
        case .opacity: "Opacity"
        case .scale: "Scale"
        case .blurReplace: "Blur"
        }
    }

    var api: String {
        switch self {
        case .fade: "fade(duration: 0.45)"
        case .opacity: "loadTransition(.opacity)"
        case .scale: "loadTransition(.scale)"
        case .blurReplace: "loadTransition(.blurReplace(.downUp))"
        }
    }
}

enum ByteCount {
    static func string(_ bytes: Int) -> String {
        string(UInt(max(bytes, 0)))
    }

    static func string(_ bytes: UInt) -> String {
        let value = Double(bytes)
        if value < 1024 {
            return "\(bytes) B"
        }
        if value < 1_048_576 {
            return String(format: "%.1f KB", value / 1024)
        }
        if value < 1_073_741_824 {
            return String(format: "%.1f MB", value / 1_048_576)
        }
        return String(format: "%.2f GB", value / 1_073_741_824)
    }
}
