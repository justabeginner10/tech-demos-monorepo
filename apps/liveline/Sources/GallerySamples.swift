import Foundation
import Liveline
import SwiftUI

/// Static 0.7.0 families that the live playground does not already show.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case bar
    case rangeBand
    case scatter
    case step
    case lollipop
    case bubble
    case boxPlot
    case waterfall
    case errorBar
    case dumbbell
    case stackedBar
    case stackedArea
    case streamgraph
    case timeline
    case heatmap
    case radar
    case donut
    case gauge
    case funnel
    case histogram
    case bullet
    case treemap
    case sunburst
    case sankey

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bar: "Bar"
        case .rangeBand: "Range band"
        case .scatter: "Scatter"
        case .step: "Step"
        case .lollipop: "Lollipop"
        case .bubble: "Bubble"
        case .boxPlot: "Box plot"
        case .waterfall: "Waterfall"
        case .errorBar: "Error bar"
        case .dumbbell: "Dumbbell"
        case .stackedBar: "Stacked bar"
        case .stackedArea: "Stacked area"
        case .streamgraph: "Streamgraph"
        case .timeline: "Timeline"
        case .heatmap: "Heatmap"
        case .radar: "Radar"
        case .donut: "Donut"
        case .gauge: "Gauge"
        case .funnel: "Funnel"
        case .histogram: "Histogram"
        case .bullet: "Bullet"
        case .treemap: "Treemap"
        case .sunburst: "Sunburst"
        case .sankey: "Sankey"
        }
    }

    var subtitle: String {
        switch self {
        case .bar: "Signed deltas"
        case .rangeBand: "Band + center"
        case .scatter: "Diamond · curved"
        case .step: "Centered"
        case .lollipop: "Baseline 0"
        case .bubble: "Area scale"
        case .boxPlot: "Five-number"
        case .waterfall: "Cumulative"
        case .errorBar: "p10–p90"
        case .dumbbell: "Before / after"
        case .stackedBar: "Three segments"
        case .stackedArea: "Standard stack"
        case .streamgraph: "Centered stack"
        case .timeline: "Three lanes"
        case .heatmap: "US / EU / APAC"
        case .radar: "0…100"
        case .donut: "Mix"
        case .gauge: "Target 80"
        case .funnel: "Stages"
        case .histogram: "20 bins"
        case .bullet: "KPI strip"
        case .treemap: "Squarified"
        case .sunburst: "Two rings"
        case .sankey: "Flows"
        }
    }

    @ViewBuilder
    var chart: some View {
        switch self {
        case .bar:
            LivelineChart(
                bars: Fixtures.signed,
                color: .mint,
                style: LivelineBarStyle(widthRatio: 0.62, cornerRadius: 3, baseline: 0, negativeColor: .red),
                configuration: Fixtures.cartesian(120)
            )
        case .rangeBand:
            LivelineChart(
                range: Fixtures.bands,
                color: .cyan,
                style: LivelineRangeStyle(fillOpacity: 0.22, showsCenterLine: true),
                configuration: Fixtures.cartesian(180)
            )
        case .scatter:
            LivelineChart(
                scatter: Fixtures.sparse,
                color: .orange,
                style: LivelineScatterStyle(symbol: .diamond, pointSize: 8, connection: .curved),
                configuration: Fixtures.cartesian(180)
            )
        case .step:
            LivelineChart(
                steps: Fixtures.levels,
                color: .mint,
                style: LivelineStepStyle(position: .center, fillOpacity: 0.12),
                configuration: Fixtures.cartesian(180)
            )
        case .lollipop:
            LivelineChart(
                lollipops: Fixtures.signed,
                color: .green,
                style: LivelineLollipopStyle(baseline: 0, headSize: 8, headSymbol: .diamond, negativeColor: .red),
                configuration: Fixtures.cartesian(120)
            )
        case .bubble:
            LivelineChart(
                bubbles: Fixtures.bubbles,
                color: .purple,
                style: LivelineBubbleStyle(minimumSize: 5, maximumSize: 22, scale: .area),
                configuration: Fixtures.cartesian(180)
            )
        case .boxPlot:
            LivelineChart(
                boxPlots: Fixtures.boxes,
                color: .indigo,
                style: LivelineBoxPlotStyle(fillOpacity: 0.2, medianLineWidth: 2),
                configuration: Fixtures.cartesian(240)
            )
        case .waterfall:
            LivelineChart(
                waterfall: Fixtures.deltas,
                color: .mint,
                style: LivelineWaterfallStyle(initialValue: 100, widthRatio: 0.62, showsConnectors: true),
                configuration: Fixtures.cartesian(120)
            )
        case .errorBar:
            LivelineChart(
                errorBars: Fixtures.errors,
                color: .cyan,
                style: LivelineErrorBarStyle(capWidth: 10, pointSymbol: .diamond),
                configuration: Fixtures.cartesian(180)
            )
        case .dumbbell:
            LivelineChart(
                dumbbells: Fixtures.pairs,
                color: .orange,
                style: LivelineDumbbellStyle(startColor: .orange, endColor: .cyan, showsDirection: true),
                configuration: Fixtures.cartesian(180)
            )
        case .stackedBar:
            LivelineChart(
                stackedBars: Fixtures.stacks,
                style: LivelineStackedBarStyle(mode: .standard, colors: Fixtures.stackColors),
                configuration: Fixtures.cartesian(180)
            )
        case .stackedArea:
            LivelineChart(
                stackedAreas: Fixtures.stacks,
                style: LivelineStackedAreaStyle(mode: .standard, colors: Fixtures.stackColors, fillOpacity: 0.55),
                configuration: Fixtures.cartesian(180)
            )
        case .streamgraph:
            LivelineChart(
                stackedAreas: Fixtures.stacks,
                style: LivelineStackedAreaStyle(
                    mode: .standard,
                    baseline: .centered,
                    colors: Fixtures.stackColors,
                    fillOpacity: 0.7
                ),
                configuration: Fixtures.cartesian(180)
            )
        case .timeline:
            LivelineChart(
                timeline: Fixtures.work,
                style: LivelineTimelineStyle(colors: Fixtures.stackColors, showsLabels: true),
                configuration: Fixtures.cartesian(300)
            )
        case .heatmap:
            LivelineChart(
                heatmap: Fixtures.cells,
                color: .cyan,
                style: LivelineHeatmapStyle(rowLabels: ["US", "EU", "APAC"], showsValues: false),
                configuration: Fixtures.heatmapConfig
            )
        case .radar:
            LivelineChart(
                radar: Fixtures.profile,
                color: .mint,
                style: LivelineRadarStyle(range: 0.0...100.0, gridLevels: 4, fillOpacity: 0.2),
                configuration: Fixtures.radial
            )
        case .donut:
            LivelineChart(
                donut: Fixtures.mix,
                style: LivelineDonutStyle(innerRadiusRatio: 0.62, gapDegrees: 3, showsValues: true),
                configuration: Fixtures.radial
            )
        case .gauge:
            LivelineChart(
                gauge: 72,
                range: 0.0...100.0,
                color: .cyan,
                style: LivelineGaugeStyle(target: 80, showsTicks: true),
                configuration: Fixtures.radial
            )
        case .funnel:
            LivelineChart(
                funnel: Fixtures.stages,
                style: LivelineFunnelStyle(showsLabels: true, showsValues: true),
                configuration: Fixtures.radial
            )
        case .histogram:
            LivelineChart(
                histogram: Fixtures.latencies,
                color: .purple,
                style: LivelineHistogramStyle(binning: .count(16), showsCounts: false),
                configuration: Fixtures.radial
            )
        case .bullet:
            LivelineChart(
                bullet: LivelineBulletStyle(
                    measure: 72,
                    target: 80,
                    ranges: [
                        LivelineBulletRange(value: 50, label: "Low"),
                        LivelineBulletRange(value: 75, label: "OK"),
                        LivelineBulletRange(value: 100, label: "Good"),
                    ],
                    label: "Fill"
                ),
                color: .mint,
                configuration: Fixtures.radial
            )
        case .treemap:
            LivelineChart(
                treemap: Fixtures.tree,
                style: LivelineTreemapStyle(showsLabels: true, showsValues: true),
                configuration: Fixtures.radial
            )
        case .sunburst:
            LivelineChart(
                sunburst: Fixtures.burst,
                style: LivelineSunburstStyle(showsLabels: true),
                configuration: Fixtures.radial
            )
        case .sankey:
            LivelineChart(
                sankey: Fixtures.flows,
                style: LivelineSankeyStyle(showsLabels: true, showsValues: false),
                configuration: Fixtures.radial
            )
        }
    }
}

private enum Fixtures {
    static let t0: TimeInterval = 1_720_000_000
    static let stackColors: [Color] = [.cyan, .purple, .orange]

    static func cartesian(_ window: TimeInterval) -> LivelineChartConfiguration {
        LivelineChartConfiguration(
            theme: .dark,
            window: window,
            badge: false,
            pulse: false,
            endpointDecorations: false,
            paused: true
        )
    }

    static let radial = LivelineChartConfiguration(
        theme: .dark,
        badge: false,
        pulse: false,
        endpointDecorations: false,
        paused: true
    )

    static var heatmapConfig: LivelineChartConfiguration {
        var configuration = cartesian(120)
        configuration.padding = LivelinePadding(left: 44)
        return configuration
    }

    static let signed: [LivelinePoint] = offsets([-4, 6, -2, 9, 3, -7, 5, 1, -3, 8], step: 12)

    static let sparse: [LivelinePoint] = offsets([12, 18, 11, 22, 16, 27, 19, 24, 15, 21], step: 18)

    static let levels: [LivelinePoint] = offsets([10, 10, 16, 16, 16, 22, 22, 14, 14, 18], step: 18)

    static let deltas: [LivelinePoint] = offsets([12, -4, 8, 6, -10, 5, 3, -2], step: 14)

    static let bands: [LivelineRangePoint] = {
        let mids = [40.0, 42, 41, 45, 44, 47, 43, 46, 44, 48]
        return mids.enumerated().map { index, mid in
            LivelineRangePoint(time: t0 + Double(index) * 18, lower: mid - 3.5, upper: mid + 3.2)
        }
    }()

    static let bubbles: [LivelineBubblePoint] = {
        let values = [18.0, 22, 16, 28, 20, 24, 19, 26]
        let mags = [40.0, 90, 30, 140, 55, 110, 70, 95]
        return zip(values, mags).enumerated().map { index, pair in
            LivelineBubblePoint(time: t0 + Double(index) * 22, value: pair.0, magnitude: pair.1)
        }
    }()

    static let boxes: [LivelineBoxPlotPoint] = (0..<6).map { index in
        let base = 18.0 + Double(index)
        return LivelineBoxPlotPoint(
            time: t0 + Double(index) * 36,
            minimum: base,
            lowerQuartile: base + 4,
            median: base + 7,
            upperQuartile: base + 11,
            maximum: base + 16
        )
    }

    static let errors: [LivelineErrorBarPoint] = {
        let means = [22.0, 24, 21, 27, 25, 23, 26, 28]
        return means.enumerated().map { index, mean in
            LivelineErrorBarPoint(time: t0 + Double(index) * 20, value: mean, lower: mean - 3.5, upper: mean + 4)
        }
    }()

    static let pairs: [LivelineDumbbellPoint] = {
        let before = [18.0, 22, 20, 16, 24, 19, 21]
        let after = [24.0, 20, 27, 19, 22, 26, 25]
        return zip(before, after).enumerated().map { index, pair in
            LivelineDumbbellPoint(time: t0 + Double(index) * 22, start: pair.0, end: pair.1)
        }
    }()

    static let stacks: [LivelineStackedPoint] = (0..<8).map { index in
        LivelineStackedPoint(
            time: t0 + Double(index) * 20,
            values: [
                8 + Double(index % 3),
                6 + Double((index + 1) % 4),
                4 + Double((index + 2) % 3),
            ]
        )
    }

    static let work: [LivelineTimelineItem] = [
        LivelineTimelineItem(id: "ingest", label: "Ingest", start: t0, end: t0 + 80, lane: 0),
        LivelineTimelineItem(id: "build", label: "Build", start: t0 + 40, end: t0 + 160, lane: 1),
        LivelineTimelineItem(id: "ship", label: "Ship", start: t0 + 140, end: t0 + 240, lane: 2),
        LivelineTimelineItem(id: "watch", label: "Watch", start: t0 + 180, end: t0 + 280, lane: 0),
    ]

    static let cells: [LivelineHeatmapCell] = {
        (0..<8).flatMap { column in
            (0..<3).map { row in
                let wave = sin(Double(column) * 0.7 + Double(row))
                return LivelineHeatmapCell(
                    time: t0 + Double(column) * 15,
                    row: row,
                    value: 0.35 + 0.5 * (wave * 0.5 + 0.5)
                )
            }
        }
    }()

    static let profile: [LivelineRadarPoint] = [
        LivelineRadarPoint(label: "Speed", value: 82),
        LivelineRadarPoint(label: "Fill", value: 64),
        LivelineRadarPoint(label: "Depth", value: 71),
        LivelineRadarPoint(label: "Hold", value: 55),
        LivelineRadarPoint(label: "Clip", value: 90),
    ]

    static let mix: [LivelineCategoryValue] = [
        LivelineCategoryValue(id: "tape", label: "Tape", value: 42),
        LivelineCategoryValue(id: "drift", label: "Drift", value: 27),
        LivelineCategoryValue(id: "echo", label: "Echo", value: 18),
        LivelineCategoryValue(id: "rest", label: "Rest", value: 13),
    ]

    static let stages: [LivelineCategoryValue] = [
        LivelineCategoryValue(id: "seen", label: "Seen", value: 1200),
        LivelineCategoryValue(id: "tap", label: "Tap", value: 540),
        LivelineCategoryValue(id: "hold", label: "Hold", value: 210),
        LivelineCategoryValue(id: "keep", label: "Keep", value: 86),
    ]

    static let latencies: [Double] = (0..<80).map { index in
        40 + sin(Double(index) * 0.23) * 12 + Double((index * 17) % 11)
    }

    static let tree: [LivelineTreemapNode] = [
        LivelineTreemapNode(label: "Tape", value: 180),
        LivelineTreemapNode(label: "Harbor", children: [
            LivelineTreemapNode(label: "Hot", value: 90),
            LivelineTreemapNode(label: "Cold", value: 40),
        ]),
        LivelineTreemapNode(label: "Ridge", value: 70),
    ]

    static let burst: [LivelineSunburstNode] = [
        LivelineSunburstNode(label: "Direct", value: 120),
        LivelineSunburstNode(label: "Search", children: [
            LivelineSunburstNode(label: "Organic", value: 80),
            LivelineSunburstNode(label: "Paid", value: 36),
        ]),
        LivelineSunburstNode(label: "Referral", value: 54),
    ]

    static let flows: [LivelineSankeyLink] = [
        LivelineSankeyLink(source: "Visits", target: "Tape", value: 420),
        LivelineSankeyLink(source: "Visits", target: "Bounce", value: 180),
        LivelineSankeyLink(source: "Tape", target: "Hold", value: 210),
        LivelineSankeyLink(source: "Tape", target: "Drop", value: 90),
        LivelineSankeyLink(source: "Hold", target: "Keep", value: 86),
    ]

    private static func offsets(_ values: [Double], step: TimeInterval) -> [LivelinePoint] {
        values.enumerated().map { index, value in
            LivelinePoint(time: t0 + Double(index) * step, value: value)
        }
    }
}
