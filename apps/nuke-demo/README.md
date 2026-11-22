# Nuke

Dark SwiftUI playground for **[Nuke](https://github.com/kean/Nuke)** (`import Nuke` and `import NukeUI`, from **13.2.3**, lightweight tag **13.2.3**, commit **9e37a277**).

Products **`Nuke`** and **`NukeUI`**. `NukeVideo` and `NukeExtensions` are not linked. `Package.swift` at that tag (`swift-tools-version: 6.0`) declares iOS 15, tvOS 15, macOS 12, watchOS 8, and visionOS 1. This app targets iOS 18 to match sibling demos. The license is MIT.

Tag `13.2.3` is a lightweight tag. It points at commit `9e37a277bdb527bf3ae71156ded1423f495f5168` (2026-11-08 17:08:46 -0500, "Merge pull request #1115 from kean/prep/13.2.3"). That tag is also the GitHub Release **Nuke 13.2.3**, published 2026-11-08T22:09:34Z. Newer tags on the repo are `14.0.0-beta.1`, `14.0.0-beta.2`, and `14.0.0-rc.1`. Swift Package Manager requirement `from: 13.2.3` does not select those pre-releases. `swift package resolve` of that requirement selected tag `13.2.3` at `9e37a277bdb527bf3ae71156ded1423f495f5168`.

The calls in this demo were read from that commit: `LazyImage`, `FetchImage.Progress`, `ImagePipeline`, `ImageRequest`, `ImageProcessors` (resize, rounded corners, Gaussian blur, circle), `ImagePrefetcher`, `ImageCache`, and `DataCache`.

Two tabs:

- **Live** — picker among States, Grid, Process, and Cache. Only the selected surface keeps a `LazyImage`. Switching family or leaving the tab removes it. All four share one `ImagePipeline`, one `ImageCache`, and one `DataCache`.
- **Gallery** — frozen painted cards. No `LazyImage`, no pipeline, no prefetcher.

Live chrome uses hardcoded light ink on a near-black page.

Photos are public `images.unsplash.com` JPEGs. No API key. `picsum.photos` was not used: on 2026-11-14 that host timed out from this environment, and `fastly.picsum.photos` returned 503. The Unsplash URLs used here returned HTTP 200, except `photo-000000000000-000000000000`, which returned 404 and is the failure sample. Those checks were HTTP status codes, not an image decode on iOS.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator. This app was not compiled here.

`swiftc -parse` accepted the Swift sources. `swift package resolve` of requirement `from: 13.2.3` selected tag `13.2.3` (`9e37a277bdb527bf3ae71156ded1423f495f5168`). Those checks are not an iOS build.

1. Open `apps/nuke-demo/Nuke.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **Nuke** scheme. Xcode resolves the remote Swift package `https://github.com/kean/Nuke.git` (from 13.2.3 / tag `13.2.3`).

The Nuke 13 release table lists Swift 6.2 and Xcode 26. The package manifest is `swift-tools-version: 6.0`. This app was not compiled, so that table is noted here rather than treated as a result from this environment.

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/nuke-demo
xcodegen generate
```

`PRODUCT_MODULE_NAME = NukeDemo` so the app module is not named `Nuke` (the package product). Bundle id is `com.techdemos.nuke`. The home-screen name is **Nuke**.

The demo does not assign `ImagePipeline.shared`. Live builds its own pipeline and passes it to `LazyImage.pipeline(_:)`.

## What Nuke does

`ImagePipeline` downloads, decodes, processes, and caches. `LazyImage` is the SwiftUI view. It loads through `FetchImage` and the pipeline you pass in. A request's processors win over `LazyImage.processors(_:)`. That modifier writes processors only when the request's list is empty.

| API | Role |
| --- | --- |
| `LazyImage(url:transaction:content:)` / `LazyImage(request:transaction:content:)` | Custom content for each `LazyImageState`. Default transaction has no animation |
| `LazyImageState.image` / `.error` / `.isLoading` | SwiftUI image, the failure, or still loading |
| `LazyImageState.progress` | `FetchImage.Progress`: `completed`, `total`, `fraction` |
| `LazyImage.processors(_:)` | Applied only when the request has no processors |
| `LazyImage.pipeline(_:)` | Pipeline for this view. Applied in `onAppear` |
| `LazyImage.priority(_:)` | Writes `ImageRequest.Priority` on the request |
| `LazyImage.onDisappear(_:)` | `.cancel` (the default) or `.lowerPriority` |
| `LazyImage.onCompletion(_:)` | `Result<ImageResponse, Error>` on the main actor |
| `ImageRequest(url:processors:priority:options:)` | URL, processors, priority, cache options |
| `ImageRequest.Options.reloadIgnoringCachedData` | Skips `ImageCaching` and `DataCaching` reads. Does not skip `URLCache` |
| `ImageResponse.cacheType` | `.memory`, `.disk`, or `nil`. `nil` includes a `URLCache` hit |
| `ImageProcessors.Resize` | `size` in `.points` by default, times the screen scale. `crop: true` with `.aspectFill` crops to that size. `.aspectFit` ignores `crop` |
| `ImageProcessors.RoundedCorners` | Radius in `.points` by default. Bakes the corner alpha into the bitmap. Resize first |
| `ImageProcessors.GaussianBlur` | Accelerate `vImageBoxConvolve`. Radius is an `Int`, default 8. `0` returns the image unchanged. iOS, tvOS, macOS, visionOS |
| `ImageProcessors.Circle` | Crops to a square, then a circle. Optional border, default `nil` |
| `ImagePrefetcher(pipeline:destination:maxConcurrentRequestCount:)` | Default destination `.memoryCache`, priority `.low`, 2 at a time |
| `ImagePrefetcher.startPrefetching(with:)` / `stopPrefetching()` / `isPaused` | Start, cancel, or pause. Deinit cancels outstanding work |
| `ImagePrefetcher.didComplete` | Main-actor callback when nothing is left in flight, including a batch that started no task. `stopPrefetching` does not call it |
| `ImagePipeline.Cache` subscript | Memory image for a request, processors included |
| `ImagePipeline.Cache.containsData(for:)` / `removeAll(caches:)` | Disk lookup and clear. Disk here is `DataCaching`, not `URLCache` |
| `ImageCache.totalCount` / `totalCost` | Count, and cost in approximate bitmap bytes (`bytesPerRow * height`, plus any attached data) |
| `DataCache(name:)` / `sizeLimit` / `totalCount` / `totalSize` / `flush()` | Directory under caches. `totalCount` and `totalSize` read the disk. `storeData` returns before the write finishes. `flush()` waits |

`ImagePrefetcher.Destination.diskCache` is not used. At this tag it is incompatible with `DataCachePolicy.automatic` for requests that have processors, and with `storeEncodedImages`. The grid prefetches with `.memoryCache` and the same `ImageProcessors.Resize` the cell's `ImageRequest` uses, so a finished prefetch can satisfy the cell from the memory cache.

`ImagePipeline.Configuration.withURLCache` is `Configuration()`. `withDataCache(name:sizeLimit:)` builds its own `DataCache`. This demo does not call those helpers. It keeps the `ImageCache` and `DataCache` instances so the readout can see them.

- **URL cache** — `Configuration()` with this session's `ImageCache`. `dataCache` stays `nil`. The default `DataLoader` uses `URLCache` (0 MB memory, 150 MB disk). `ImagePipeline.Cache` does not read or clear that `URLCache`.
- **Data cache** — `URLSessionConfiguration.urlCache` is `nil`, `dataCache` is `DataCache(name: "com.techdemos.nuke")` with `sizeLimit` 150 MB, and `dataCachePolicy` is `.automatic`. The configuration default is `.storeOriginalData`. `.automatic` stores original data for a request with no processors, and stores the processed image for a request that has processors.

Switching kind or progressive decoding builds a new pipeline and invalidates the previous one. The same `ImageCache` and `DataCache` stay attached. `isProgressiveDecodingEnabled` is read when the pipeline is created (`false` by default). A preview is produced only when the decoder can make one. `ImageDecoders.Default` does that for progressive JPEG.

`ImageCache` drops everything on a system memory-pressure warning, and on iOS it trims to about a tenth of its limits when the app enters the background. This session uses its own `ImageCache`, not `ImageCache.shared`.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **States** | **Photo** is a 1600×1200 JPEG at `.high`. The placeholder shows until `image` is set. The bar is `FetchImage.Progress` (`completed`, `total`, `fraction`). **Missing** is the 404 URL. `DataLoader` rejects a status outside `200..<300`, and `ImagePipeline.Error.dataLoadingFailed` wraps that. The line under the image is `ImageResponse.cacheType` (`nil` reads as network or URLCache). A completion also refreshes the cache counts. |
| **Grid** | Eighteen cells. Each request is `ImageProcessors.Resize` 160×160, `.aspectFill`, `crop: true`. **Prefetch ahead** starts `ImagePrefetcher` for the next four URLs with that same resize. Turning it off sets `isPaused` and calls `stopPrefetching()`. `didComplete` counts the times the prefetcher ran out of work. |
| **Process** | One photo. **Resize**, **Corners** (resize, then `RoundedCorners(radius: 28)`), **Blur** (resize, then `GaussianBlur(radius: 12)`), **Circle** (square resize, then `Circle()`). Processors go through `LazyImage.processors(_:)`. The monospaced lines are each processor's `identifier`. |
| **Cache** | **URL cache** / **Data cache** and **Progressive decoding** rebuild the pipeline. **Reload** toggles `.reloadIgnoringCachedData`. **Read caches**, and a finished load, call `DataCache.flush()` off the main actor, then `totalCount` / `totalSize`, and check the probe with `pipeline.cache[request]` and `containsData(for:)`. **Clear memory** is `removeAll(caches: .memory)`. **Clear disk** is `removeAll(caches: .disk)` plus `DataCache.removeAll()` and `flush()`, including when this pipeline's `dataCache` is `nil`. **Clear both** is `removeAll()`. Clearing does not remove the image already on screen. |
| **Leave the tab / family** | The active `LazyImage` unmounts. The prefetcher is stopped. Gallery never loads an image. |

### Gallery

Lazy grid of painted cards for the placeholder, the progress bar, the failure mark, the grid, prefetch, the four processors, memory, disk, and the pipeline switch. Chips name the APIs. Nothing on this tab constructs Nuke.

**Skipped:** `NukeExtensions`, `NukeVideo`, `ImagePipeline.shared`, `ImagePrefetcher.Destination.diskCache`, `ImageProcessors.Anonymous`, Core Image filters, `ImageRequest.ThumbnailOptions`, and the closure-based `loadImage` methods (soft-deprecated in Nuke 12.9). `LazyImage` still reaches loading through `FetchImage`, which calls that closure API internally.

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the other demos; package floor is iOS 15)
- Network on first resolve for Swift Package `Nuke` **13.2.3** (tag `13.2.3`, pin `9e37a277bdb527bf3ae71156ded1423f495f5168`), and again at runtime for the Unsplash JPEGs
