import DrafterCharts
import Foundation
import SwiftUI

/// One published snapshot so a tick never fans out into multiple `@Published` writes.
struct LiveSnapshot: Equatable {
    var latest: Float
    var linePoints: [ChartPoint] = []
    var candles: [Candle] = []
    var stream: StreamSnapshot = StreamSnapshot()
}

struct StreamSnapshot: Equatable {
    var series: [ChartSeries] = []
    var categories: [String] = []
}

/// Synthetic live feed for a single DrafterCharts family at a time.
///
/// Internal ring buffers are mutated in place. Only the active family's
/// fields are copied into `snapshot` each tick so SwiftUI rebuilds one Canvas.
@MainActor
final class LiveTape: ObservableObject {
    static let tickMilliseconds = 280
    static let lineCapacity = 28
    static let candleCapacity = 16
    static let streamCapacity = 18
    static let candleHoldTicks = 4

    @Published private(set) var snapshot: LiveSnapshot

    private var phase: Float = 0
    private var lastValue: Float
    private var tickIndex = 0
    private var candleHold = 0
    private var candleOpen: Float
    private var candleHigh: Float
    private var candleLow: Float

    private var lineBuffer: [ChartPoint] = []
    private var candleBuffer: [Candle] = []
    private var streamA: [Float] = []
    private var streamB: [Float] = []
    private var streamC: [Float] = []
    private var streamLabels: [String] = []

    init() {
        var value: Float = 48.2
        var localPhase: Float = 0
        var points: [ChartPoint] = []
        points.reserveCapacity(Self.lineCapacity)
        for index in 0..<Self.lineCapacity {
            localPhase += 0.11
            value = Self.step(value, phase: localPhase, tick: index)
            points.append(ChartPoint(Self.lineLabel(index), value))
        }

        lastValue = value
        phase = localPhase
        tickIndex = Self.lineCapacity
        candleOpen = value
        candleHigh = value
        candleLow = value
        lineBuffer = points
        snapshot = LiveSnapshot(latest: value)
        seedCandles(from: points)
        seedStream(from: points)
        publish(for: .line)
    }

    var latest: Float { snapshot.latest }
    var linePoints: [ChartPoint] { snapshot.linePoints }
    var candles: [Candle] { snapshot.candles }
    var stream: StreamSnapshot { snapshot.stream }

    func tick(family: LiveFamily) {
        phase += 0.09
        tickIndex += 1
        lastValue = Self.step(lastValue, phase: phase, tick: tickIndex)

        switch family {
        case .line, .area:
            absorbLine()
        case .candles:
            absorbCandle()
        case .stream:
            absorbStream()
        }
        publish(for: family)
    }

    func prepare(for family: LiveFamily) {
        publish(for: family)
    }

    // MARK: - Publish

    private func publish(for family: LiveFamily) {
        var next = snapshot
        next.latest = lastValue
        switch family {
        case .line, .area:
            next.linePoints = lineBuffer
        case .candles:
            next.candles = candleBuffer
        case .stream:
            next.stream = StreamSnapshot(
                series: [
                    ChartSeries(name: "Alpha", color: DrafterColors.blue, values: streamA),
                    ChartSeries(name: "Beta", color: DrafterColors.teal, values: streamB),
                    ChartSeries(name: "Gamma", color: DrafterColors.violet, values: streamC),
                ],
                categories: streamLabels
            )
        }
        snapshot = next
    }

    // MARK: - Walk

    private static func step(_ value: Float, phase: Float, tick: Int) -> Float {
        let drift = sin(phase) * 0.22 + sin(phase * 0.31) * 0.30 + cos(phase * 0.07) * 0.14
        let noise = sin(Float(tick) * 12.9898) * 0.08
        return min(max(value + drift + noise, 36), 64)
    }

    private static func lineLabel(_ index: Int) -> String {
        index % 4 == 0 ? "\(index)" : ""
    }

    // MARK: - Line / area

    private func absorbLine() {
        appendCapped(&lineBuffer, ChartPoint(Self.lineLabel(tickIndex), lastValue), capacity: Self.lineCapacity)
    }

    // MARK: - Candles

    private func seedCandles(from points: [ChartPoint]) {
        var buffer: [Candle] = []
        let chunk = max(1, points.count / Self.candleCapacity)
        var offset = 0
        var label = 1
        while offset < points.count {
            let slice = points[offset..<min(offset + chunk, points.count)]
            let values = slice.map(\.value)
            guard let first = values.first, let last = values.last else { break }
            buffer.append(
                Candle(
                    label: "\(label)",
                    open: first,
                    high: values.max() ?? first,
                    low: values.min() ?? first,
                    close: last
                )
            )
            offset += chunk
            label += 1
        }
        if buffer.count > Self.candleCapacity {
            buffer.removeFirst(buffer.count - Self.candleCapacity)
        }
        candleBuffer = buffer
        if let last = buffer.last {
            candleOpen = last.open
            candleHigh = last.high
            candleLow = last.low
            candleHold = 0
        }
    }

    private func absorbCandle() {
        candleHold += 1
        candleHigh = max(candleHigh, lastValue)
        candleLow = min(candleLow, lastValue)

        if candleHold >= Self.candleHoldTicks {
            let committed = Candle(
                label: "\(tickIndex)",
                open: candleOpen,
                high: candleHigh,
                low: candleLow,
                close: lastValue
            )
            appendCapped(&candleBuffer, committed, capacity: Self.candleCapacity)
            candleOpen = lastValue
            candleHigh = lastValue
            candleLow = lastValue
            candleHold = 0
        } else if !candleBuffer.isEmpty {
            candleBuffer[candleBuffer.count - 1] = Candle(
                label: candleBuffer[candleBuffer.count - 1].label,
                open: candleOpen,
                high: candleHigh,
                low: candleLow,
                close: lastValue
            )
        }
    }

    // MARK: - Stream

    private func seedStream(from points: [ChartPoint]) {
        let source = Array(points.suffix(Self.streamCapacity))
        streamA = source.enumerated().map { index, point in
            max(2, point.value * 0.18 + sin(Float(index) * 0.4) * 1.4)
        }
        streamB = source.enumerated().map { index, point in
            max(2, point.value * 0.14 + cos(Float(index) * 0.33) * 1.2)
        }
        streamC = source.enumerated().map { index, point in
            max(2, point.value * 0.11 + sin(Float(index) * 0.22 + 1) * 1.1)
        }
        streamLabels = source.enumerated().map { index, _ in
            index % 3 == 0 ? "\(index)" : ""
        }
    }

    private func absorbStream() {
        let index = Float(tickIndex)
        appendCapped(&streamA, max(2, lastValue * 0.18 + sin(index * 0.4) * 1.4), capacity: Self.streamCapacity)
        appendCapped(&streamB, max(2, lastValue * 0.14 + cos(index * 0.33) * 1.2), capacity: Self.streamCapacity)
        appendCapped(&streamC, max(2, lastValue * 0.11 + sin(index * 0.22 + 1) * 1.1), capacity: Self.streamCapacity)
        appendCapped(&streamLabels, tickIndex % 3 == 0 ? "\(tickIndex)" : "", capacity: Self.streamCapacity)
    }

    private func appendCapped<T>(_ buffer: inout [T], _ value: T, capacity: Int) {
        buffer.append(value)
        if buffer.count > capacity {
            buffer.removeFirst(buffer.count - capacity)
        }
    }
}
