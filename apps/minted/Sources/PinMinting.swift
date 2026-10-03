import Foundation
import Minted

/// Off-main mint + cache for bundled pin artwork.
///
/// `ArtworkCoin(sample:)` is not a cheap constructor. It decodes the JPEG and
/// runs `ArtworkAnalyzer`: a full-frame RGBA pass, morphological open/close,
/// hole fill, contour trace, then 512px gold / relief maps. That is seconds
/// of CPU. Calling it from a SwiftUI `body` freezes the Live tab.
enum PinMinting {
    fileprivate struct Box: @unchecked Sendable {
        let coin: ArtworkCoin
    }

    private static let lock = NSLock()
    private static var cache: [ArtworkCoin.Sample: ArtworkCoin] = [:]
    private static var waiters: [ArtworkCoin.Sample: [CheckedContinuation<Result<Box, Error>, Never>]] = [:]

    static func cached(_ sample: ArtworkCoin.Sample) -> ArtworkCoin? {
        lock.lock()
        defer { lock.unlock() }
        return cache[sample]
    }

    static func coin(for sample: ArtworkCoin.Sample) async -> Result<ArtworkCoin, Error> {
        let boxed: Result<Box, Error> = await withCheckedContinuation { continuation in
            lock.lock()
            if let cached = cache[sample] {
                lock.unlock()
                continuation.resume(returning: .success(Box(coin: cached)))
                return
            }
            if waiters[sample] != nil {
                waiters[sample]?.append(continuation)
                lock.unlock()
                return
            }
            waiters[sample] = [continuation]
            lock.unlock()

            DispatchQueue.global(qos: .userInitiated).async {
                let outcome: Result<Box, Error>
                do {
                    let coin = try ArtworkCoin(sample: sample)
                    // Pay ArtworkCoinScene's lazy studio / orange-peel bake here
                    // so the first SCNView mount on the main thread is cheaper.
                    _ = ArtworkCoinScene.makeScene(coin: coin)
                    outcome = .success(Box(coin: coin))
                } catch {
                    outcome = .failure(error)
                }

                lock.lock()
                if case .success(let box) = outcome {
                    cache[sample] = box.coin
                }
                let pending = waiters.removeValue(forKey: sample) ?? []
                lock.unlock()
                for waiter in pending {
                    waiter.resume(returning: outcome)
                }
            }
        }
        return boxed.map(\.coin)
    }

    /// Start the default pin while Award is on screen so the Pin tap is a cache hit.
    static func prefetch(_ sample: ArtworkCoin.Sample = .alhambra) {
        Task(priority: .utility) {
            _ = await coin(for: sample)
        }
    }
}
