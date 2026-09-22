import Foundation
import Liveline
import SwiftUI

/// Synthetic live feed: a `LivelineDataStream` plus derived candles and series.
///
/// Only the active live family is published each tick so a single Canvas is
/// driving SwiftUI updates at ~220ms.
@MainActor
final class LiveTape: ObservableObject {
    static let candleWidth: TimeInterval = 20

    let stream = LivelineDataStream(capacity: 900, retention: 480)

    @Published private(set) var latest: Double
    @Published private(set) var candles: [LivelineCandle] = []
    @Published private(set) var liveCandle: LivelineCandle
    @Published private(set) var series: [LivelineSeries] = []

    private var phase = 0.0
    private var lastValue: Double
    private var companionIndex = 0
    private var driftPoints: [LivelinePoint] = []
    private var echoPoints: [LivelinePoint] = []
    private var candleOpen = 0.0
    private var candleHigh = 0.0
    private var candleLow = 0.0
    private var candleBucket: TimeInterval = 0

    init() {
        let now = Date().timeIntervalSince1970
        var value = 48.25
        var points: [LivelinePoint] = []
        var localPhase = 0.0
        var time = now - 240
        while time <= now {
            localPhase += 0.11
            value = Self.step(value, phase: localPhase)
            points.append(LivelinePoint(time: time, value: value))
            time += 1
        }

        stream.replace(points)
        lastValue = value
        latest = value
        phase = localPhase
        liveCandle = LivelineCandle(time: Self.bucket(now), open: value, high: value, low: value, close: value)
        rememberLiveCandle(liveCandle)
        rebuildCandles(from: points, now: now)
        seedCompanions(from: points)
        publishSeries()
    }

    func tick(now: TimeInterval = Date().timeIntervalSince1970, family: LiveFamily) {
        phase += 0.09
        lastValue = Self.step(lastValue, phase: phase)
        let point = LivelinePoint(time: now, value: lastValue)
        stream.append(point)

        switch family {
        case .line:
            latest = lastValue
        case .candles:
            absorbCandle(point)
            latest = lastValue
        case .compare:
            absorbCompanions(point)
            latest = lastValue
        }
    }

    func prepare(for family: LiveFamily) {
        switch family {
        case .line:
            latest = lastValue
        case .candles:
            rebuildCandles(from: stream.points, now: Date().timeIntervalSince1970)
            latest = lastValue
        case .compare:
            seedCompanions(from: stream.points)
            publishSeries()
            latest = lastValue
        }
    }

    var points: [LivelinePoint] { stream.points }

    /// Newest samples covering `window` seconds, for the visible chart only.
    func visiblePoints(covering window: TimeInterval) -> [LivelinePoint] {
        Self.windowed(stream.points, covering: window)
    }

    // MARK: - Walk

    private static func step(_ value: Double, phase: Double) -> Double {
        let drift = sin(phase) * 0.18 + sin(phase * 0.31) * 0.27 + cos(phase * 0.07) * 0.12
        let noise = Double.random(in: -0.11 ... 0.11)
        return min(max(value + drift + noise, 36), 64)
    }

    private static func bucket(_ time: TimeInterval) -> TimeInterval {
        floor(time / candleWidth) * candleWidth
    }

    // MARK: - Candles

    private func rebuildCandles(from points: [LivelinePoint], now: TimeInterval) {
        let groups = Dictionary(grouping: points) { Self.bucket($0.time) }
        var committed: [LivelineCandle] = []
        for key in groups.keys.sorted() {
            guard let candle = Self.candle(from: groups[key] ?? [], time: key) else { continue }
            if key + Self.candleWidth <= now {
                committed.append(candle)
            } else {
                liveCandle = candle
                rememberLiveCandle(candle)
            }
        }
        candles = Array(committed.suffix(80))
    }

    private func absorbCandle(_ point: LivelinePoint) {
        let key = Self.bucket(point.time)
        if candleBucket != key {
            let committed = LivelineCandle(
                time: candleBucket,
                open: candleOpen,
                high: candleHigh,
                low: candleLow,
                close: liveCandle.close
            )
            candles.append(committed)
            if candles.count > 80 {
                candles.removeFirst(candles.count - 80)
            }
            liveCandle = LivelineCandle(
                time: key,
                open: point.value,
                high: point.value,
                low: point.value,
                close: point.value
            )
            rememberLiveCandle(liveCandle)
        } else {
            liveCandle = LivelineCandle(
                time: liveCandle.time,
                open: liveCandle.open,
                high: max(liveCandle.high, point.value),
                low: min(liveCandle.low, point.value),
                close: point.value
            )
            candleHigh = liveCandle.high
            candleLow = liveCandle.low
        }
    }

    private func rememberLiveCandle(_ candle: LivelineCandle) {
        candleBucket = candle.time
        candleOpen = candle.open
        candleHigh = candle.high
        candleLow = candle.low
    }

    private static func candle(from points: [LivelinePoint], time: TimeInterval) -> LivelineCandle? {
        let ordered = points.sorted { $0.time < $1.time }
        guard let first = ordered.first, let last = ordered.last else { return nil }
        let values = ordered.map(\.value)
        return LivelineCandle(
            time: time,
            open: first.value,
            high: values.max() ?? first.value,
            low: values.min() ?? first.value,
            close: last.value
        )
    }

    // MARK: - Companion series

    private func seedCompanions(from points: [LivelinePoint]) {
        driftPoints = points.enumerated().map { index, point in
            LivelinePoint(time: point.time, value: point.value + sin(Double(index) * 0.07) * 1.8)
        }
        echoPoints = points.enumerated().map { index, point in
            LivelinePoint(time: point.time, value: point.value - 2.4 + cos(Double(index) * 0.05) * 1.4)
        }
        companionIndex = points.count
    }

    private func absorbCompanions(_ point: LivelinePoint) {
        companionIndex += 1
        let index = Double(companionIndex)
        appendCapped(&driftPoints, LivelinePoint(time: point.time, value: point.value + sin(index * 0.07) * 1.8))
        appendCapped(&echoPoints, LivelinePoint(time: point.time, value: point.value - 2.4 + cos(index * 0.05) * 1.4))
        publishSeries()
    }

    private func publishSeries() {
        let tape = Self.windowed(stream.points, covering: 200)
        let drift = Self.windowed(driftPoints, covering: 200)
        let echo = Self.windowed(echoPoints, covering: 200)
        series = [
            LivelineSeries(id: "tape", data: tape, value: tape.last?.value ?? latest, color: .cyan, label: "Tape"),
            LivelineSeries(
                id: "drift",
                data: drift,
                value: drift.last?.value ?? latest,
                color: .mint,
                label: "Drift"
            ),
            LivelineSeries(
                id: "echo",
                data: echo,
                value: echo.last?.value ?? latest,
                color: .orange,
                label: "Echo"
            ),
        ]
    }

    private static func windowed(_ points: [LivelinePoint], covering window: TimeInterval) -> [LivelinePoint] {
        guard let newest = points.last?.time else { return points }
        let cutoff = newest - max(window, 1)
        var low = 0
        var high = points.count
        while low < high {
            let mid = (low + high) / 2
            if points[mid].time < cutoff {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return Array(points[low...])
    }

    private func appendCapped(_ buffer: inout [LivelinePoint], _ point: LivelinePoint) {
        buffer.append(point)
        if buffer.count > 480 {
            buffer.removeFirst(buffer.count - 480)
        }
    }
}
