import DrafterCharts
import Foundation
import SwiftUI

/// Static 0.2.0 families. Live playground already shows line / area / candles / stream;
/// those still appear here as frozen samples so Gallery covers the full public set.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case simpleBar
    case groupedBar
    case stackedBar
    case histogram
    case waterfall
    case line
    case groupedLine
    case stackedLine
    case area
    case stepLine
    case pie
    case donut
    case scatter
    case bubble
    case candlestick
    case boxPlot
    case radar
    case gauge
    case bullet
    case funnel
    case treemap
    case polarArea
    case sunburst
    case sankey
    case stream
    case gantt
    case heatmap

    var id: String { rawValue }

    var title: String {
        switch self {
        case .simpleBar: "Bar"
        case .groupedBar: "Grouped bar"
        case .stackedBar: "Stacked bar"
        case .histogram: "Histogram"
        case .waterfall: "Waterfall"
        case .line: "Line"
        case .groupedLine: "Grouped line"
        case .stackedLine: "Stacked line"
        case .area: "Area"
        case .stepLine: "Step line"
        case .pie: "Pie"
        case .donut: "Donut"
        case .scatter: "Scatter"
        case .bubble: "Bubble"
        case .candlestick: "Candlestick"
        case .boxPlot: "Box plot"
        case .radar: "Radar"
        case .gauge: "Gauge"
        case .bullet: "Bullet"
        case .funnel: "Funnel"
        case .treemap: "Treemap"
        case .polarArea: "Polar area"
        case .sunburst: "Sunburst"
        case .sankey: "Sankey"
        case .stream: "Stream graph"
        case .gantt: "Gantt"
        case .heatmap: "Heatmap"
        }
    }

    var subtitle: String {
        switch self {
        case .simpleBar: "Four quarters"
        case .groupedBar: "2023 / 2024"
        case .stackedBar: "Three bands"
        case .histogram: "5 bins"
        case .waterfall: "Start … Net"
        case .line: "Catmull-Rom"
        case .groupedLine: "Two series"
        case .stackedLine: "Cumulative fill"
        case .area: "Gradient fill"
        case .stepLine: "Levels"
        case .pie: "Four slices"
        case .donut: "Same mix"
        case .scatter: "Seven marks"
        case .bubble: "Area scale"
        case .candlestick: "MA3 overlay"
        case .boxPlot: "Five-number"
        case .radar: "Two profiles"
        case .gauge: "Score 72"
        case .bullet: "Two KPIs"
        case .funnel: "Stages"
        case .treemap: "Five tiles"
        case .polarArea: "Weekdays"
        case .sunburst: "Two rings"
        case .sankey: "Flows"
        case .stream: "Three bands"
        case .gantt: "Four tasks"
        case .heatmap: "53 weeks"
        }
    }

    var cardHeight: CGFloat {
        switch self {
        case .heatmap: 120
        case .bullet: 140
        case .gantt: 180
        default: 168
        }
    }

    @ViewBuilder
    var chart: some View {
        switch self {
        case .simpleBar:
            SimpleBarChart(bars: Fixtures.quarterBars, animate: false)
        case .groupedBar:
            GroupedBarChart(
                series: Fixtures.yearSeries,
                categories: Fixtures.quarters,
                animate: false
            )
        case .stackedBar:
            StackedBarChart(
                series: Fixtures.stackSeries,
                categories: Fixtures.quarters,
                animate: false
            )
        case .histogram:
            Histogram(values: Fixtures.histogramValues, binCount: 5, animate: false)
        case .waterfall:
            WaterfallChart(
                steps: Fixtures.waterfallSteps,
                initialValue: 50,
                startLabel: "Start",
                totalLabel: "Net",
                animate: false
            )
        case .line:
            LineChart(points: Fixtures.monthPoints(Fixtures.lineValues), color: DrafterColors.teal, animate: false)
        case .groupedLine:
            GroupedLineChart(
                series: Fixtures.groupedLineSeries,
                categories: Fixtures.months,
                animate: false
            )
        case .stackedLine:
            StackedLineChart(
                series: Fixtures.stackedLineSeries,
                categories: Fixtures.months,
                animate: false
            )
        case .area:
            AreaChart(points: Fixtures.monthPoints(Fixtures.areaValues), color: DrafterColors.blue, animate: false)
        case .stepLine:
            StepLineChart(points: Fixtures.monthPoints(Fixtures.stepValues), animate: false)
        case .pie:
            PieChart(slices: Fixtures.pieSlices, animate: false)
        case .donut:
            DonutChart(slices: Fixtures.pieSlices, animate: false)
        case .scatter:
            ScatterPlot(points: Fixtures.scatterPoints, animate: false)
        case .bubble:
            BubbleChart(series: Fixtures.bubbleSeries, animate: false)
        case .candlestick:
            CandlestickChart(
                candles: Fixtures.candles,
                movingAverages: Fixtures.movingAverages,
                animate: false
            )
        case .boxPlot:
            BoxPlotChart(groups: Fixtures.boxGroups, animate: false)
        case .radar:
            RadarChart(series: Fixtures.radarSeries, animate: false)
        case .gauge:
            GaugeChart(value: 72, min: 0, max: 100, label: "Score", color: DrafterColors.teal, animate: false)
        case .bullet:
            BulletChart(metrics: Fixtures.bulletMetrics, animate: false)
        case .funnel:
            FunnelChart(stages: Fixtures.funnelStages, animate: false)
        case .treemap:
            TreemapChart(items: Fixtures.treemapItems, animate: false)
        case .polarArea:
            PolarAreaChart(slices: Fixtures.polarSlices, animate: false)
        case .sunburst:
            SunburstChart(roots: Fixtures.sunburstRoots, animate: false)
        case .sankey:
            SankeyChart(nodes: Fixtures.sankeyNodes, links: Fixtures.sankeyLinks, animate: false)
        case .stream:
            StreamGraphChart(
                series: Fixtures.streamSeries,
                categories: Fixtures.months,
                animate: false
            )
        case .gantt:
            GanttChart(tasks: Fixtures.ganttTasks, animate: false)
        case .heatmap:
            Heatmap(contributions: Fixtures.heatmapContributions, animate: false)
        }
    }
}

/// Sample data as computed helpers so Swift 6 does not treat Color-bearing
/// static lets as isolated globals (same lesson as Liveline GallerySamples).
private enum Fixtures {
    static var months: [String] { ["Jan", "Feb", "Mar", "Apr", "May", "Jun"] }
    static var quarters: [String] { ["Q1", "Q2", "Q3", "Q4"] }

    static var lineValues: [Float] { [40, 65, 50, 80, 70, 95] }
    static var areaValues: [Float] { [12, 18, 9, 24, 20, 30] }
    static var stepValues: [Float] { [10, 10, 25, 18, 32, 28] }

    static var histogramValues: [Float] {
        [2, 3, 3, 4, 5, 5, 5, 6, 6, 7, 7, 8, 9, 10, 11, 12, 12, 13, 15]
    }

    static func monthPoints(_ values: [Float]) -> [ChartPoint] {
        zip(months, values).map { ChartPoint($0, $1) }
    }

    static var quarterBars: [BarItem] {
        zip(quarters, [24, 38, 30, 46] as [Float]).map { BarItem($0, $1) }
    }

    static var yearSeries: [ChartSeries] {
        [
            ChartSeries(name: "2023", color: DrafterColors.blue, values: [20, 34, 26, 40]),
            ChartSeries(name: "2024", color: DrafterColors.teal, values: [28, 30, 38, 44]),
        ]
    }

    static var stackSeries: [ChartSeries] {
        [
            ChartSeries(color: DrafterColors.blue, values: [12, 16, 14, 20]),
            ChartSeries(color: DrafterColors.teal, values: [8, 10, 12, 14]),
            ChartSeries(color: DrafterColors.violet, values: [6, 8, 10, 9]),
        ]
    }

    static var groupedLineSeries: [ChartSeries] {
        [
            ChartSeries(name: "A", color: DrafterColors.blue, values: [30, 45, 40, 70, 60, 85]),
            ChartSeries(name: "B", color: DrafterColors.teal, values: [20, 35, 50, 45, 65, 55]),
        ]
    }

    static var stackedLineSeries: [ChartSeries] {
        [
            ChartSeries(color: DrafterColors.violet, values: [10, 14, 12, 20, 18, 24]),
            ChartSeries(color: DrafterColors.green, values: [8, 10, 14, 12, 16, 14]),
        ]
    }

    static var streamSeries: [ChartSeries] {
        [
            ChartSeries(name: "A", color: DrafterColors.blue, values: [4, 6, 8, 7, 9, 6]),
            ChartSeries(name: "B", color: DrafterColors.teal, values: [3, 4, 6, 8, 7, 9]),
            ChartSeries(name: "C", color: DrafterColors.green, values: [2, 3, 4, 5, 6, 7]),
        ]
    }

    static var waterfallSteps: [WaterfallStep] {
        [WaterfallStep("Sales", 60), WaterfallStep("Costs", -25), WaterfallStep("Tax", -10)]
    }

    static var pieSlices: [PieSlice] {
        [
            PieSlice(value: 40, color: DrafterColors.blue, label: "Tape"),
            PieSlice(value: 25, color: DrafterColors.teal, label: "Drift"),
            PieSlice(value: 20, color: DrafterColors.violet, label: "Echo"),
            PieSlice(value: 15, color: DrafterColors.amber, label: "Rest"),
        ]
    }

    static var scatterPoints: [ScatterPoint] {
        [(1, 2), (2, 5), (3, 3), (4, 8), (5, 6), (6, 9), (7, 7)].map { pair in
            ScatterPoint(x: Float(pair.0), y: Float(pair.1))
        }
    }

    static var bubbleSeries: [[BubbleData]] {
        [[
            BubbleData(x: 10, y: 20, size: 3, color: DrafterColors.blue),
            BubbleData(x: 30, y: 40, size: 6, color: DrafterColors.teal),
            BubbleData(x: 50, y: 25, size: 4, color: DrafterColors.violet),
            BubbleData(x: 70, y: 60, size: 8, color: DrafterColors.green),
        ]]
    }

    static var candles: [Candle] {
        [
            Candle(label: "1", open: 20, high: 26, low: 18, close: 24),
            Candle(label: "2", open: 24, high: 28, low: 22, close: 21),
            Candle(label: "3", open: 21, high: 25, low: 19, close: 23),
            Candle(label: "4", open: 23, high: 30, low: 22, close: 29),
            Candle(label: "5", open: 29, high: 32, low: 26, close: 27),
            Candle(label: "6", open: 27, high: 31, low: 25, close: 30),
        ]
    }

    static var movingAverages: [MovingAverage] {
        [MovingAverage(period: 3, color: DrafterColors.amber)]
    }

    static var boxGroups: [BoxGroup] {
        [
            BoxGroup(label: "A", min: 5, q1: 12, median: 18, q3: 24, max: 30, color: DrafterColors.violet),
            BoxGroup(label: "B", min: 8, q1: 15, median: 22, q3: 28, max: 38, color: DrafterColors.blue),
            BoxGroup(label: "C", min: 4, q1: 10, median: 14, q3: 20, max: 26, color: DrafterColors.teal),
        ]
    }

    static var radarSeries: [RadarSeries] {
        [
            RadarSeries(
                color: DrafterColors.blue,
                values: ["Speed": 0.8, "Power": 0.6, "Range": 0.9, "Agility": 0.5, "Armor": 0.7]
            ),
            RadarSeries(
                color: DrafterColors.teal,
                values: ["Speed": 0.5, "Power": 0.9, "Range": 0.6, "Agility": 0.8, "Armor": 0.4]
            ),
        ]
    }

    static var bulletMetrics: [BulletMetric] {
        [
            BulletMetric(label: "Revenue", value: 78, target: 85, ranges: [50, 75, 100], color: DrafterColors.blue),
            BulletMetric(label: "Profit", value: 62, target: 60, ranges: [40, 70, 100], color: DrafterColors.teal),
        ]
    }

    static var funnelStages: [FunnelStage] {
        [
            FunnelStage(label: "Visits", value: 1000, color: DrafterColors.blue),
            FunnelStage(label: "Signups", value: 620, color: DrafterColors.teal),
            FunnelStage(label: "Trials", value: 310, color: DrafterColors.violet),
            FunnelStage(label: "Paid", value: 120, color: DrafterColors.amber),
        ]
    }

    static var treemapItems: [TreemapItem] {
        [
            TreemapItem(label: "Alpha", value: 40, color: DrafterColors.blue),
            TreemapItem(label: "Beta", value: 25, color: DrafterColors.teal),
            TreemapItem(label: "Gamma", value: 18, color: DrafterColors.violet),
            TreemapItem(label: "Delta", value: 12, color: DrafterColors.green),
            TreemapItem(label: "Eps", value: 8, color: DrafterColors.amber),
        ]
    }

    static var polarSlices: [PolarSlice] {
        [
            PolarSlice(label: "Mon", value: 8, color: DrafterColors.blue),
            PolarSlice(label: "Tue", value: 12, color: DrafterColors.teal),
            PolarSlice(label: "Wed", value: 6, color: DrafterColors.violet),
            PolarSlice(label: "Thu", value: 15, color: DrafterColors.amber),
            PolarSlice(label: "Fri", value: 10, color: DrafterColors.green),
        ]
    }

    static var sunburstRoots: [SunburstNode] {
        [
            SunburstNode(label: "Web", value: 50, color: DrafterColors.blue, children: [
                SunburstNode(label: "iOS", value: 30, color: DrafterColors.blue),
                SunburstNode(label: "And", value: 20, color: DrafterColors.blue),
            ]),
            SunburstNode(label: "API", value: 30, color: DrafterColors.teal, children: [
                SunburstNode(label: "REST", value: 20, color: DrafterColors.teal),
                SunburstNode(label: "gRPC", value: 10, color: DrafterColors.teal),
            ]),
            SunburstNode(label: "DB", value: 20, color: DrafterColors.green, children: [
                SunburstNode(label: "SQL", value: 12, color: DrafterColors.green),
                SunburstNode(label: "KV", value: 8, color: DrafterColors.green),
            ]),
        ]
    }

    static var sankeyNodes: [SankeyNode] {
        [
            SankeyNode(id: "src", label: "Source", column: 0, color: DrafterColors.blue),
            SankeyNode(id: "a", label: "A", column: 1, color: DrafterColors.teal),
            SankeyNode(id: "b", label: "B", column: 1, color: DrafterColors.violet),
            SankeyNode(id: "out", label: "Out", column: 2, color: DrafterColors.green),
        ]
    }

    static var sankeyLinks: [SankeyLink] {
        [
            SankeyLink(from: "src", to: "a", value: 30),
            SankeyLink(from: "src", to: "b", value: 20),
            SankeyLink(from: "a", to: "out", value: 30),
            SankeyLink(from: "b", to: "out", value: 20),
        ]
    }

    static var ganttTasks: [GanttTask] {
        [
            GanttTask(name: "Design", startMonth: 0, duration: 2, color: DrafterColors.blue),
            GanttTask(name: "Build", startMonth: 2, duration: 3, color: DrafterColors.teal),
            GanttTask(name: "Test", startMonth: 4, duration: 2, color: DrafterColors.violet),
            GanttTask(name: "Ship", startMonth: 6, duration: 1, color: DrafterColors.green),
        ]
    }

    /// A full trailing year of deterministic counts. The package heatmap always
    /// paints a 53×7 grid, so fewer days would just leave empty leading weeks.
    static var heatmapContributions: [ContributionData] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        return (0..<371).compactMap { day -> ContributionData? in
            guard let date = calendar.date(byAdding: .day, value: day, to: start) else { return nil }
            let raw = (day * 13 + (day % 7) * 5 + (day % 11) * 2) % 16
            return ContributionData(date: date, count: max(0, raw - 4))
        }
    }
}
