import Foundation
import Minted

/// Off-main mint + MainActor cache for bundled pin artwork.
///
/// `ArtworkCoin(sample:)` is not a cheap constructor. It decodes the JPEG and
/// runs `ArtworkAnalyzer`: a full-frame RGBA pass, morphological open/close,
/// hole fill, contour trace, then 512px gold / relief maps. That is seconds
/// of CPU. Calling it from a SwiftUI `body` freezes the Live tab.
///
/// Mutable cache / in-flight tasks live on the main actor so Swift 6 accepts
/// the shared state. The bake itself stays on a detached task. Dictionary
/// keys are `String` (the sample raw value) because `ArtworkCoin.Sample` is
/// a public package enum and is not `Sendable`.
@MainActor
enum PinMinting {
    private struct Box: @unchecked Sendable {
        let coin: ArtworkCoin
    }

    private static var cache: [String: ArtworkCoin] = [:]
    private static var inFlight: [String: Task<Result<Box, Error>, Never>] = [:]

    static func cached(_ sample: ArtworkCoin.Sample) -> ArtworkCoin? {
        cache[sample.rawValue]
    }

    static func coin(for sample: ArtworkCoin.Sample) async -> Result<ArtworkCoin, Error> {
        let key = sample.rawValue
        if let cached = cache[key] {
            return .success(cached)
        }
        if let existing = inFlight[key] {
            return await existing.value.map(\.coin)
        }

        let task = Task.detached(priority: .userInitiated) {
            Self.mint(key: key)
        }
        inFlight[key] = task
        let result = await task.value
        inFlight[key] = nil
        if case .success(let box) = result {
            cache[key] = box.coin
        }
        return result.map(\.coin)
    }

    /// CPU work: JPEG decode, analyze, and ArtworkCoinScene env-map bake.
    /// Must not run on the main actor.
    nonisolated private static func mint(key: String) -> Result<Box, Error> {
        guard let sample = ArtworkCoin.Sample(rawValue: key) else {
            return .failure(ArtworkCoin.Failure.noPinFound("unknown sample"))
        }
        do {
            let coin = try ArtworkCoin(sample: sample)
            // Pay ArtworkCoinScene's lazy studio / orange-peel bake here
            // so the first SCNView mount on the main thread is cheaper.
            _ = ArtworkCoinScene.makeScene(coin: coin)
            return .success(Box(coin: coin))
        } catch {
            return .failure(error)
        }
    }

    /// Start the default pin while Award is on screen so the Pin tap is a cache hit.
    static func prefetch(_ sample: ArtworkCoin.Sample = .alhambra) async {
        _ = await coin(for: sample)
    }
}
