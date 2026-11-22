import Foundation
import Nuke

/// Public JPEGs on `images.unsplash.com`. No API key.
/// `picsum.photos` was not used: on 2026-11-14 the host timed out and `fastly.picsum.photos` returned 503.
struct DemoPhoto: Identifiable, Hashable, Sendable {
    let slug: String

    var id: String { slug }

    func url(width: Int, height: Int) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "images.unsplash.com"
        components.path = "/" + slug
        components.queryItems = [
            URLQueryItem(name: "auto", value: "format"),
            URLQueryItem(name: "fit", value: "crop"),
            URLQueryItem(name: "w", value: String(width)),
            URLQueryItem(name: "h", value: String(height)),
            URLQueryItem(name: "q", value: "60"),
        ]
        guard let url = components.url else {
            preconditionFailure("Unsplash URL could not be formed for \(slug)")
        }
        return url
    }
}

enum StateSample: String, CaseIterable, Identifiable, Hashable {
    case photo
    case missing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .photo: "Photo"
        case .missing: "Missing"
        }
    }

    var photo: DemoPhoto {
        switch self {
        case .photo:
            DemoPhoto(slug: "photo-1506744038136-46273834b3fb")
        case .missing:
            DemoPhoto(slug: "photo-000000000000-000000000000")
        }
    }

    /// Wide enough that a cold download reports `FetchImage.Progress` before it finishes.
    var request: ImageRequest {
        let size = self == .photo ? (width: 1600, height: 1200) : (width: 400, height: 400)
        return ImageRequest(url: photo.url(width: size.width, height: size.height), priority: .high)
    }

    var detail: String {
        switch self {
        case .photo:
            "LazyImage placeholder, then FetchImage.Progress, then the image. priority is .high."
        case .missing:
            "This URL returned 404 when checked. DataLoader rejects a status outside 200..<300."
        }
    }
}

enum ProcessorRecipe: String, CaseIterable, Identifiable, Hashable {
    case resize
    case rounded
    case blur
    case circle

    var id: String { rawValue }

    var title: String {
        switch self {
        case .resize: "Resize"
        case .rounded: "Corners"
        case .blur: "Blur"
        case .circle: "Circle"
        }
    }

    var processors: [any ImageProcessing] {
        switch self {
        case .resize:
            [
                ImageProcessors.Resize(
                    size: CGSize(width: 240, height: 160),
                    contentMode: .aspectFill,
                    crop: true
                ),
            ]
        case .rounded:
            [
                ImageProcessors.Resize(
                    size: CGSize(width: 240, height: 160),
                    contentMode: .aspectFill,
                    crop: true
                ),
                ImageProcessors.RoundedCorners(radius: 28),
            ]
        case .blur:
            [
                ImageProcessors.Resize(
                    size: CGSize(width: 240, height: 160),
                    contentMode: .aspectFill,
                    crop: true
                ),
                ImageProcessors.GaussianBlur(radius: 12),
            ]
        case .circle:
            [
                ImageProcessors.Resize(
                    size: CGSize(width: 240, height: 240),
                    contentMode: .aspectFill,
                    crop: true
                ),
                ImageProcessors.Circle(),
            ]
        }
    }

    var call: String {
        processors.map(\.identifier).joined(separator: "\n")
    }
}

enum PhotoCatalog {
    static let grid: [DemoPhoto] = [
        "photo-1469474968028-56623f02e42e",
        "photo-1441974231531-c6227db76b6e",
        "photo-1470071459604-3b5ec3a7fe05",
        "photo-1472214103451-9374bd1c798e",
        "photo-1500530855697-b586d89ba3ee",
        "photo-1518837695005-2083093ee35b",
        "photo-1465101162946-4377e57745c3",
        "photo-1470770841072-f978cf4d019e",
        "photo-1501785888041-af3ef285b470",
        "photo-1433086966358-54859d0ed716",
        "photo-1475924156734-496f6cac6ec1",
        "photo-1447752875215-b2761acb3c5d",
        "photo-1418065460487-3e41a6c84dc5",
        "photo-1426604966848-d7adac402bff",
        "photo-1470252649378-9c29740c9fa8",
        "photo-1493246507139-91e8fad9978e",
        "photo-1500534314209-a25ddb2bd429",
        "photo-1494500764479-0c8f2919a3d8",
    ].map { DemoPhoto(slug: $0) }

    /// Same processor the grid's `LazyImage` uses, so a prefetch can land in the memory cache.
    static let gridProcessors: [any ImageProcessing] = [
        ImageProcessors.Resize(
            size: CGSize(width: 160, height: 160),
            contentMode: .aspectFill,
            crop: true
        ),
    ]

    static func gridRequest(for photo: DemoPhoto) -> ImageRequest {
        ImageRequest(
            url: photo.url(width: 400, height: 400),
            processors: gridProcessors
        )
    }

    static func gridRequests(after index: Int, limit: Int) -> [ImageRequest] {
        guard index + 1 < grid.count else { return [] }
        let end = min(grid.count, index + 1 + limit)
        return grid[(index + 1)..<end].map { gridRequest(for: $0) }
    }

    static let processorPhoto = DemoPhoto(slug: "photo-1507525428034-b723cf961d3e")

    static let cachePhoto = DemoPhoto(slug: "photo-1519681393784-d120267933ba")

    static let cacheProcessors: [any ImageProcessing] = [
        ImageProcessors.Resize(
            size: CGSize(width: 180, height: 180),
            contentMode: .aspectFill,
            crop: true
        ),
    ]

    static func cacheRequest(ignoreCachedData: Bool) -> ImageRequest {
        var request = ImageRequest(
            url: cachePhoto.url(width: 600, height: 600),
            processors: cacheProcessors
        )
        if ignoreCachedData {
            request.options = .reloadIgnoringCachedData
        }
        return request
    }
}

enum CacheSourceLabel {
    /// `nil` means the response did not come from `ImageCaching` or `DataCaching`.
    /// A `URLCache` hit is reported as `nil`.
    static func make(_ cacheType: ImageResponse.CacheType?) -> String {
        switch cacheType {
        case .memory: "memory"
        case .disk: "disk"
        case nil: "network or URLCache"
        }
    }
}

func nukeErrorText(_ error: Error) -> String {
    if let pipeline = error as? ImagePipeline.Error {
        return pipeline.description
    }
    return String(describing: error)
}

private struct DiskRead: Sendable {
    var count: Int
    var bytes: Int
    var hit: Bool
}

/// One pipeline, one memory cache, and one disk cache for every Live surface.
/// The demo does not assign `ImagePipeline.shared`.
@MainActor
final class NukeSession: ObservableObject {
    enum Kind: String, CaseIterable, Identifiable {
        case urlCache
        case dataCache

        var id: String { rawValue }

        var title: String {
            switch self {
            case .urlCache: "URL cache"
            case .dataCache: "Data cache"
            }
        }
    }

    @Published var kind: Kind = .dataCache {
        didSet {
            if kind != oldValue { rebuild() }
        }
    }

    @Published var progressive = false {
        didSet {
            if progressive != oldValue { rebuild() }
        }
    }

    @Published private(set) var pipeline: ImagePipeline
    @Published private(set) var generation = UUID()
    @Published private(set) var memoryCount = 0
    @Published private(set) var memoryCost = 0
    @Published private(set) var diskCount = 0
    @Published private(set) var diskBytes = 0
    @Published private(set) var probeInMemory = false
    @Published private(set) var probeOnDisk = false
    @Published private(set) var prefetchWaves = 0
    @Published private(set) var lastSource = "—"

    let imageCache: ImageCache
    let dataCache: DataCache?
    let dataCacheError: String?
    private(set) var prefetcher: ImagePrefetcher

    init() {
        let imageCache = ImageCache()
        self.imageCache = imageCache
        let built = Self.openDataCache()
        self.dataCache = built.cache
        self.dataCacheError = built.error
        let pipeline = Self.make(
            kind: .dataCache,
            progressive: false,
            imageCache: imageCache,
            dataCache: built.cache
        )
        self.pipeline = pipeline
        self.prefetcher = Self.makePrefetcher(pipeline: pipeline)
        bindPrefetcher()
    }

    var dataCacheAttached: Bool {
        pipeline.configuration.dataCache != nil
    }

    func prefetch(after index: Int) {
        let requests = PhotoCatalog.gridRequests(after: index, limit: 4)
        guard !requests.isEmpty else { return }
        prefetcher.startPrefetching(with: requests)
    }

    func stopPrefetching() {
        prefetcher.stopPrefetching()
    }

    func record(_ result: Result<ImageResponse, Error>) {
        switch result {
        case .success(let response):
            lastSource = CacheSourceLabel.make(response.cacheType)
        case .failure(let error):
            if let pipelineError = error as? ImagePipeline.Error {
                switch pipelineError {
                case .cancelled, .pipelineInvalidated:
                    return
                default:
                    break
                }
            }
            lastSource = nukeErrorText(error)
        }
        refresh()
    }

    func clearMemory() {
        pipeline.cache.removeAll(caches: .memory)
        refresh()
    }

    func clearDisk() {
        pipeline.cache.removeAll(caches: .disk)
        let cache = dataCache
        Task {
            await Task.detached {
                cache?.removeAll()
                cache?.flush()
            }.value
            refresh()
        }
    }

    func clearAll() {
        pipeline.cache.removeAll()
        let cache = dataCache
        Task {
            await Task.detached {
                cache?.removeAll()
                cache?.flush()
            }.value
            refresh()
        }
    }

    /// Memory counts are read here. Disk counts run off the main actor, after `flush()`,
    /// because `DataCache.totalCount` and `totalSize` read the directory.
    func refresh() {
        let probe = PhotoCatalog.cacheRequest(ignoreCachedData: false)
        memoryCount = imageCache.totalCount
        memoryCost = imageCache.totalCost
        probeInMemory = pipeline.cache[probe] != nil
        let dataCache = self.dataCache
        let pipeline = self.pipeline
        Task {
            let disk = await Task.detached {
                dataCache?.flush()
                return DiskRead(
                    count: dataCache?.totalCount ?? 0,
                    bytes: dataCache?.totalSize ?? 0,
                    hit: pipeline.cache.containsData(for: probe)
                )
            }.value
            diskCount = disk.count
            diskBytes = disk.bytes
            probeOnDisk = disk.hit
        }
    }

    private func rebuild() {
        prefetcher.stopPrefetching()
        pipeline.invalidate()
        let next = Self.make(
            kind: kind,
            progressive: progressive,
            imageCache: imageCache,
            dataCache: dataCache
        )
        pipeline = next
        prefetcher = Self.makePrefetcher(pipeline: next)
        bindPrefetcher()
        generation = UUID()
        refresh()
    }

    private func bindPrefetcher() {
        prefetcher.didComplete = { [weak self] in
            self?.prefetchWaves += 1
        }
    }

    private static func makePrefetcher(pipeline: ImagePipeline) -> ImagePrefetcher {
        ImagePrefetcher(
            pipeline: pipeline,
            destination: .memoryCache,
            maxConcurrentRequestCount: 2
        )
    }

    private static func openDataCache() -> (cache: DataCache?, error: String?) {
        do {
            let cache = try DataCache(name: "com.techdemos.nuke")
            cache.sizeLimit = 150 * 1024 * 1024
            return (cache, nil)
        } catch {
            return (nil, String(describing: error))
        }
    }

    private static func make(
        kind: Kind,
        progressive: Bool,
        imageCache: ImageCache,
        dataCache: DataCache?
    ) -> ImagePipeline {
        var configuration = ImagePipeline.Configuration()
        configuration.isProgressiveDecodingEnabled = progressive
        configuration.imageCache = imageCache
        if kind == .dataCache, let dataCache {
            let session = URLSessionConfiguration.default
            session.urlCache = nil
            configuration.dataLoader = DataLoader(configuration: session)
            configuration.dataCache = dataCache
            configuration.dataCachePolicy = .automatic
        }
        return ImagePipeline(configuration: configuration)
    }
}
