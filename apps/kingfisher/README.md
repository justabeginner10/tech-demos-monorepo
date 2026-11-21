# Kingfisher

Dark SwiftUI playground for **[Kingfisher](https://github.com/onevcat/Kingfisher)** (`import Kingfisher`, from **8.16.0**, tag **8.16.0**, revision **21caad7**).

Product **`Kingfisher` only**. The package is MIT. `Package.swift` at that tag (`swift-tools-version:6.2`) declares iOS 15, macOS 12, tvOS 15, watchOS 9, and visionOS 1, and sets `swiftLanguageModes: [.v5]`. This app targets iOS 18 to match sibling demos. `loadTransition(_:animation:)` for the SwiftUI `Transition` protocol is marked iOS 17+.

Tag `8.16.0` is an annotated tag. It points at `21caad71af5d1cb34ab174786e75c864fd2417bd` (2026-11-14, "Bump version to 8.16.0"). Swift Package Manager requirement `from: 8.16.0` resolves that tag. The manifest needs Swift tools 6.2, so open the project in Xcode 26 (or any Xcode whose Swift tools are 6.2 or newer). Xcode 16 cannot parse this `Package.swift`.

Photos are HTTPS URLs on [picsum.photos](https://picsum.photos) (no API key). picsum redirects to `fastly.picsum.photos`. The Retry tab uses `https://picsum.photos/id/999999/400/300`, which responds HTTP 404. `DelayRetryStrategy` retries `KingfisherError.responseError` only, and a non-2xx status is that case (`SessionDelegate` raises `invalidHTTPStatusCode`).

`PRODUCT_MODULE_NAME = KingfisherDemo` so the app module is not named `Kingfisher`. Bundle id is `com.techdemos.kingfisher`.

Two tabs:

- **Live** — picker among Load, Process, Retry, and Cache. Only the selected surface keeps a `KFImage`. Switching family or leaving the tab removes it.
- **Gallery** — `ImagePrefetcher` for eight picsum URLs, then a `KFImage` grid of those same URLs. Leaving the tab stops the prefetcher and unmounts the grid. Painted cards under the grid do not import Kingfisher.

Live chrome uses hardcoded light ink on a near-black page.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator. This app was not compiled and was not launched.

Checked here, without an iOS SDK: `swiftc -parse` accepted the app sources, and `swift package resolve` of requirement `from: 8.16.0` selected tag `8.16.0` (`21caad71af5d1cb34ab174786e75c864fd2417bd`). Those checks are not an iOS build.

1. Open `apps/kingfisher/Kingfisher.xcodeproj` in Xcode 26+ (Swift tools 6.2, iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **Kingfisher** scheme. Xcode resolves `https://github.com/onevcat/Kingfisher.git` (from 8.16.0 / tag `8.16.0`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/kingfisher
xcodegen generate
```

Keep `KFImage` and `ImagePrefetcher` off a tab that is not selected. Leave the upstream `Demo` target out of this app.

## What Kingfisher does

Kingfisher downloads remote images, processes them, and stores the results in memory and on disk. SwiftUI uses `KFImage`. The calls below are the ones this app makes. Signatures were read from tag `8.16.0`, not from a later `main`.

| API | Role |
| --- | --- |
| `KFImage.init(_:)` | `KFImageProtocol` initializer. `nil` is an empty source. The URL's `absoluteString` is the default cache key |
| `placeholder(_:)` | View shown until a renderable image exists. The `Progress` overload reads `completedUnitCount` / `totalUnitCount` updated from the download |
| `onProgress(_:)` | `DownloadProgressBlock`. Called when the response has `expectedContentLength`. Not main-isolated in `ImageBinder` |
| `onSuccess(_:)` / `onFailure(_:)` | Main queue via `CallbackQueueMain`. Success carries `RetrieveImageResult.cacheType` (`.none`, `.memory`, `.disk`) |
| `onFailureView(_:)` | SwiftUI view after the load fails. Replaces the deprecated `onFailureImage` |
| `fade(duration:)` | UIKit-style fade. Runs for a network load. A cache hit does not fade unless `forceRefresh` or `forceTransition` is set |
| `loadTransition(_:animation:)` | SwiftUI transition. The `AnyTransition` overload covers `.opacity` and `.scale`. The iOS 17 `Transition` overload covers `.blurReplace(.downUp)`. When both `loadTransition` and `fade` are set, `loadTransition` wins. This app sets only one |
| `forceRefresh(_:)` | Ignores memory and disk and downloads again. `KFImage.Context` equality is source plus processor identifier, so a reload also changes the view `id` |
| `cancelOnDisappear(_:)` | Cancels the download task when the view disappears |
| `DownsamplingImageProcessor(size:)` | Decodes to a smaller point size. Target here is 200×200, under the 900×700 source |
| `RoundCornerImageProcessor(cornerRadius:targetSize:roundingCorners:backgroundColor:)` | Point radius. This app uses 36 pt and the defaults (all corners, original size, no background color) |
| `BlurImageProcessor(blurRadius:)` | Simulated Gaussian blur. Radius 0 omits the processor |
| `|>` | Concatenates two `ImageProcessor` values. `setProcessor(_:)` replaces the pipeline |
| `cacheOriginalImage()` | Stores the unprocessed download so a later processor can reuse it |
| `retry(maxCount:interval:)` | Builds a `DelayRetryStrategy`. This app uses `maxCount: 2` and `.seconds(1)` |
| `ImagePrefetcher(urls:progressBlock:completionHandler:)` | Downloads and caches a fixed URL list. `maxConcurrentDownloads` is set to 4 before `start()`. The same instance cannot be started twice. Progress and completion run on the main queue. Already cached URLs are reported as skipped |
| `ImageCache.default` | Shared cache. `memoryStorageCacheCost` is the synchronous memory total. `memoryStorage.config.totalCostLimit` is the cap (a quarter of physical memory by default). `diskStorageSize` is the async disk total. `diskStorage.config.sizeLimit` is 0, which means no cap |
| `clearMemoryCache()` | Synchronous. Removes memory entries |
| `clearDiskCache()` | Async. Removes the disk folder, then calls back on the main queue |

`onSuccess` / `onFailure` hop back with `MainActor.assumeIsolated` because those callbacks are already on the main queue. `onProgress` hops with `Task { @MainActor in }` because the download callback is not.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Load** | One `KFImage` of picsum id 1015. The placeholder shows `Progress` while the download is in flight. The segmented control picks Fade, Opacity, Scale, or Blur replace. Changing the transition, or tapping **Reload**, bumps the view id and sets `forceRefresh`, so the transition runs on a new download. The readout is `CacheType`. |
| **Process** | Original and processed copies of picsum id 1025. The pipeline is downsample 200×200, then round corner 36, then `BlurImageProcessor` when the slider is above 0. Dragging the slider changes the processor identifier. |
| **Retry** | picsum id 999999 (HTTP 404) with `retry(maxCount: 2, interval: .seconds(1))`. The placeholder stays up through the retries. `onFailureView` replaces it, and the line says 404. **Load a real photo** swaps in id 1069. **Fail again** returns to the 404. |
| **Cache** | picsum id 1043 stored in `ImageCache.default`, plus memory cost, memory limit, disk size, and disk limit. **Clear memory** and **Clear disk** call `clearMemoryCache()` and `clearDiskCache()`. **Refresh sizes** reads them again. |
| **Leave the tab / family** | The active `KFImage` is removed (`cancelOnDisappear`). Gallery's prefetcher is stopped. |

### Gallery

`ImagePrefetcher` starts when the tab opens (`maxConcurrentDownloads` 4) for eight 400×300 picsum URLs. Counts are skipped, failed, and completed. The grid mounts only after the completion handler. **Prefetch again** allocates a new prefetcher; cached URLs come back as skipped. The cards under the grid are SwiftUI paint for the same four families.

## Requirements

- Xcode 26 or newer, so Swift tools can read `swift-tools-version:6.2`
- iOS 18 simulator (same floor as the Wave / Vortex / Inferno demos)
- Network on first resolve for Swift Package `Kingfisher` at tag `8.16.0` (`21caad71af5d1cb34ab174786e75c864fd2417bd`), and network at runtime for picsum.photos
