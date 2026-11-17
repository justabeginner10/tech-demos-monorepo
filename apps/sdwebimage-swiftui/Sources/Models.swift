import SDWebImageSwiftUI
import SwiftUI

/// Built-in animated WebP is not in the default coder list at SDWebImage 5.21.
/// `addCoder` appends, and the manager walks that list in reverse, so AWebP is tried before the IO coder.
enum WebPRegistration {
    private static let registerOnce: Void = {
        SDImageCodersManager.shared.addCoder(SDImageAWebPCoder.shared)
    }()

    static func register() {
        _ = registerOnce
    }
}

/// SDWebImage calls the manager completion on the main queue unless a context callback queue is set.
/// `onSuccess` / `onFailure` / `onProgress` store a nonisolated closure.
/// A closure written in a view would be main-actor isolated and would not match.
enum ImageLoadSink {
    nonisolated static func success(
        _ body: @escaping @MainActor (PlatformImage, Data?, SDImageCacheType) -> Void
    ) -> (PlatformImage, Data?, SDImageCacheType) -> Void {
        { image, data, cacheType in
            MainActor.assumeIsolated {
                body(image, data, cacheType)
            }
        }
    }

    nonisolated static func failure(
        _ body: @escaping @MainActor (Error) -> Void
    ) -> (Error) -> Void {
        { error in
            MainActor.assumeIsolated {
                body(error)
            }
        }
    }

    nonisolated static func progress(
        _ body: @escaping @MainActor (Int, Int) -> Void
    ) -> (Int, Int) -> Void {
        { received, expected in
            MainActor.assumeIsolated {
                body(received, expected)
            }
        }
    }
}

/// `calculateSize` and `clearDisk(onCompletion:)` hop back to the main queue inside SDImageCache.
enum CacheSink {
    /// The trailing closure is formed here, outside a view, so it stays nonisolated.
    /// `calculateSizeWithCompletionBlock:` imports as a single-closure method. The label is not required in trailing form.
    nonisolated static func refresh(
        _ body: @escaping @MainActor (UInt, UInt) -> Void
    ) {
        SDImageCache.shared.calculateSize { count, bytes in
            MainActor.assumeIsolated {
                body(count, bytes)
            }
        }
    }

    nonisolated static func done(
        _ body: @escaping @MainActor () -> Void
    ) -> () -> Void {
        {
            MainActor.assumeIsolated {
                body()
            }
        }
    }
}

enum ByteFormat {
    static func string(_ bytes: UInt) -> String {
        let value = Double(bytes)
        if value < 1024 {
            return "\(bytes) B"
        }
        if value < 1024 * 1024 {
            return String(format: "%.1f KB", value / 1024)
        }
        return String(format: "%.1f MB", value / (1024 * 1024))
    }
}

enum CacheKind {
    static func line(image: PlatformImage, data: Data?, cacheType: SDImageCacheType) -> String {
        let width = Int(image.size.width.rounded())
        let height = Int(image.size.height.rounded())
        let origin = name(cacheType)
        if let data {
            return "\(origin) · \(ByteFormat.string(UInt(data.count))) · \(width)×\(height)"
        }
        return "\(origin) · no data · \(width)×\(height)"
    }

    static func name(_ cacheType: SDImageCacheType) -> String {
        switch cacheType {
        case .none:
            "network"
        case .memory:
            "memory"
        case .disk:
            "disk"
        case .all:
            "all"
        @unknown default:
            "unknown"
        }
    }
}

enum RemoteURL {
    static func make(_ string: String) -> URL {
        guard let url = URL(string: string) else {
            preconditionFailure("Bad demo URL \(string)")
        }
        return url
    }
}

/// Still images. HTTPS, no API key. Picsum redirects to a JPEG. The others are direct files.
struct RemoteStill: Identifiable, Hashable {
    var title: String
    var host: String
    var url: URL

    var id: String { url.absoluteString }

    static let river = RemoteStill(
        title: "Picsum 1015",
        host: "picsum.photos",
        url: RemoteURL.make("https://picsum.photos/id/1015/800/600")
    )
    static let dog = RemoteStill(
        title: "Picsum 1025",
        host: "picsum.photos",
        url: RemoteURL.make("https://picsum.photos/id/1025/800/600")
    )
    static let ridge = RemoteStill(
        title: "Picsum 1036",
        host: "picsum.photos",
        url: RemoteURL.make("https://picsum.photos/id/1036/800/600")
    )
    static let bird = RemoteStill(
        title: "Picsum 106",
        host: "picsum.photos",
        url: RemoteURL.make("https://picsum.photos/id/106/800/600")
    )
    static let pug = RemoteStill(
        title: "Picsum 237",
        host: "picsum.photos",
        url: RemoteURL.make("https://picsum.photos/id/237/800/600")
    )
    static let shore = RemoteStill(
        title: "Picsum 29",
        host: "picsum.photos",
        url: RemoteURL.make("https://picsum.photos/id/29/800/600")
    )
    static let webpOne = RemoteStill(
        title: "WebP 1",
        host: "gstatic.com",
        url: RemoteURL.make("https://www.gstatic.com/webp/gallery/1.webp")
    )
    static let webpTwo = RemoteStill(
        title: "WebP 2",
        host: "gstatic.com",
        url: RemoteURL.make("https://www.gstatic.com/webp/gallery/2.webp")
    )
    static let logo = RemoteStill(
        title: "Logo PNG",
        host: "github.com",
        url: RemoteURL.make("https://raw.githubusercontent.com/SDWebImage/SDWebImage/5.21.7/SDWebImage_logo.png")
    )

    static let loadChoices: [RemoteStill] = [river, webpOne, logo]
    static let gallery: [RemoteStill] = [river, dog, ridge, bird, pug, shore, webpOne, webpTwo]
}

/// Animated GIF and animated WebP. HTTPS, no API key.
enum AnimatedClip: String, CaseIterable, Identifiable, Hashable {
    case gif
    case webp

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gif: "GIF"
        case .webp: "WebP"
        }
    }

    var host: String {
        switch self {
        case .gif: "upload.wikimedia.org"
        case .webp: "mathiasbynens.be"
        }
    }

    var url: URL {
        switch self {
        case .gif:
            RemoteURL.make("https://upload.wikimedia.org/wikipedia/commons/d/d3/Newtons_cradle_animation_book_2.gif")
        case .webp:
            RemoteURL.make("https://mathiasbynens.be/demo/animated-webp-supported.webp")
        }
    }
}

enum LoadPolicy: String, CaseIterable, Identifiable, Hashable {
    case standard
    case progressive
    case refresh
    case scaleDown
    case cacheOnly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard: "Default"
        case .progressive: "Progressive"
        case .refresh: "Refresh"
        case .scaleDown: "Scale down"
        case .cacheOnly: "Cache only"
        }
    }

    var options: SDWebImageOptions {
        switch self {
        case .standard:
            []
        case .progressive:
            .progressiveLoad
        case .refresh:
            .refreshCached
        case .scaleDown:
            .scaleDownLargeImages
        case .cacheOnly:
            .fromCacheOnly
        }
    }

    var call: String {
        switch self {
        case .standard: "[]"
        case .progressive: ".progressiveLoad"
        case .refresh: ".refreshCached"
        case .scaleDown: ".scaleDownLargeImages"
        case .cacheOnly: ".fromCacheOnly"
        }
    }
}

enum IndicatorChoice: String, CaseIterable, Identifiable, Hashable {
    case activity
    case progress

    var id: String { rawValue }

    var title: String {
        switch self {
        case .activity: "Activity"
        case .progress: "Progress"
        }
    }

    /// SwiftUI indicator used by `WebImage.indicator(_:)`.
    var call: String {
        switch self {
        case .activity: ".activity"
        case .progress: ".progress"
        }
    }
}

enum LoadTransition: String, CaseIterable, Identifiable, Hashable {
    case fade
    case flipFromLeft
    case flipFromBottom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fade: "Fade"
        case .flipFromLeft: "Left"
        case .flipFromBottom: "Bottom"
        }
    }

    /// `AnyTransition` members added by SDWebImageSwiftUI. `WebImage` has no transition method of its own.
    var transition: AnyTransition {
        switch self {
        case .fade:
            .fade(duration: 0.5)
        case .flipFromLeft:
            .flipFromLeft(duration: 0.45)
        case .flipFromBottom:
            .flipFromBottom(duration: 0.45)
        }
    }

    var call: String {
        switch self {
        case .fade: ".fade(duration: 0.5)"
        case .flipFromLeft: ".flipFromLeft(duration: 0.45)"
        case .flipFromBottom: ".flipFromBottom(duration: 0.45)"
        }
    }
}

enum PlaybackChoice: String, CaseIterable, Identifiable, Hashable {
    case normal
    case reverse
    case bounce
    case reversed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .normal: "Normal"
        case .reverse: "Reverse"
        case .bounce: "Bounce"
        case .reversed: "Back"
        }
    }

    var mode: SDAnimatedImagePlaybackMode {
        switch self {
        case .normal: .normal
        case .reverse: .reverse
        case .bounce: .bounce
        case .reversed: .reversedBounce
        }
    }

    var call: String {
        switch self {
        case .normal: ".normal"
        case .reverse: ".reverse"
        case .bounce: ".bounce"
        case .reversed: ".reversedBounce"
        }
    }
}

enum LoopChoice: String, CaseIterable, Identifiable, Hashable {
    case file
    case once
    case thrice

    var id: String { rawValue }

    var title: String {
        switch self {
        case .file: "File"
        case .once: "Once"
        case .thrice: "Thrice"
        }
    }

    /// `nil` keeps `animatedImageLoopCount` from the file.
    var count: UInt? {
        switch self {
        case .file: nil
        case .once: 1
        case .thrice: 3
        }
    }

    var call: String {
        switch self {
        case .file: "nil"
        case .once: "1"
        case .thrice: "3"
        }
    }
}

enum BufferChoice: String, CaseIterable, Identifiable, Hashable {
    case automatic
    case none
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .automatic: "Auto"
        case .none: "None"
        case .all: "All"
        }
    }

    /// `nil` and `0` auto-size. `1` keeps no frame cache. `.max` caches every frame.
    var size: UInt? {
        switch self {
        case .automatic: nil
        case .none: 1
        case .all: .max
        }
    }

    var call: String {
        switch self {
        case .automatic: "nil"
        case .none: "1"
        case .all: ".max"
        }
    }
}

enum PlayerTransition: String, CaseIterable, Identifiable, Hashable {
    case fade
    case flip
    case curl

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fade: "Fade"
        case .flip: "Flip"
        case .curl: "Curl"
        }
    }

    /// `NS_SWIFT_NAME` factories on `SDWebImageTransition`. These are UIKit transitions for `AnimatedImage`.
    var transition: SDWebImageTransition {
        switch self {
        case .fade:
            SDWebImageTransition.fade(duration: 0.5)
        case .flip:
            SDWebImageTransition.flipFromLeft(duration: 0.45)
        case .curl:
            SDWebImageTransition.curlUp(duration: 0.45)
        }
    }

    var call: String {
        switch self {
        case .fade: "SDWebImageTransition.fade(duration: 0.5)"
        case .flip: "SDWebImageTransition.flipFromLeft(duration: 0.45)"
        case .curl: "SDWebImageTransition.curlUp(duration: 0.45)"
        }
    }
}
