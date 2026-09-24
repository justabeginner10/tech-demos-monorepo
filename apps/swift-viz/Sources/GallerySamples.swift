import SwiftViz
import SwiftUI

/// Static README-shaped samples. Live playground already shows stacked / simple
/// tap-detail; those still appear here frozen so Gallery covers the public set.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case simpleBars
    case expandedLabels
    case stackedCategories
    case weeklyHex
    case averageOn
    case averageOff
    case customStyle
    case titledAxesHidden

    var id: String { rawValue }

    var title: String {
        switch self {
        case .simpleBars: "Simple bars"
        case .expandedLabels: "Expanded labels"
        case .stackedCategories: "Stacked"
        case .weeklyHex: "Hex colors"
        case .averageOn: "Average on"
        case .averageOff: "Average off"
        case .customStyle: "Custom style"
        case .titledAxesHidden: "Title · no axes"
        }
    }

    var subtitle: String {
        switch self {
        case .simpleBars: "values: + labels"
        case .expandedLabels: "Q1…Q4 → Quarter"
        case .stackedCategories: "Revenue / Expenses"
        case .weeklyHex: "colorHex + weekdays"
        case .averageOn: "Dashed overlay"
        case .averageOff: "showAverageLine false"
        case .customStyle: "SVBarChartStyle"
        case .titledAxesHidden: "title + hide axes"
        }
    }

    @ViewBuilder
    var chart: some View {
        switch self {
        case .simpleBars:
            SVBarChart(
                values: Fixtures.monthValues,
                labels: Fixtures.months,
                color: .purple,
                style: Fixtures.frozen(chartHeight: 150)
            )
        case .expandedLabels:
            SVBarChart(
                values: [120, 95, 140, 85],
                labels: Fixtures.quarters,
                expandedLabels: Fixtures.quarterLong,
                color: .teal,
                style: Fixtures.frozen(chartHeight: 150)
            )
        case .stackedCategories:
            SVBarChart(
                data: Fixtures.revenueExpenses,
                categories: Fixtures.revenueCategories,
                labels: Fixtures.quarters,
                style: Fixtures.frozen(chartHeight: 160)
            )
        case .weeklyHex:
            SVBarChart(
                data: Fixtures.weekStacked,
                categories: Fixtures.hexCategories,
                labels: Fixtures.weekShort,
                expandedLabels: Fixtures.weekLong,
                style: Fixtures.frozen(chartHeight: 160, showAverageLine: true, barSpacing: 10)
            )
        case .averageOn:
            SVBarChart(
                values: Fixtures.monthValues,
                labels: Fixtures.months,
                color: .cyan,
                style: Fixtures.frozen(chartHeight: 150, showAverageLine: true)
            )
        case .averageOff:
            SVBarChart(
                data: Fixtures.revenueExpenses,
                categories: Fixtures.revenueCategories,
                labels: Fixtures.quarters,
                style: Fixtures.frozen(chartHeight: 160, showAverageLine: false)
            )
        case .customStyle:
            SVBarChart(
                data: Fixtures.weekStacked,
                categories: Fixtures.hexCategories,
                labels: Fixtures.weekShort,
                style: SVBarChartStyle(
                    chartHeight: 170,
                    barSpacing: 14,
                    barCornerRadius: 12,
                    backgroundBarColor: Color.blue.opacity(0.12),
                    showAverageLine: false,
                    showLegend: true,
                    yAxisFont: .caption.bold(),
                    xAxisFont: .caption2,
                    legendFont: .footnote,
                    selectionAnimation: .spring(duration: 0.3, bounce: 0.2),
                    isInteractive: false
                )
            )
        case .titledAxesHidden:
            SVBarChart(
                values: Fixtures.monthValues,
                labels: Fixtures.months,
                color: .orange,
                title: "H1 sessions",
                style: SVBarChartStyle(
                    chartHeight: 140,
                    showAverageLine: false,
                    showYAxis: false,
                    showXAxis: false,
                    isInteractive: false
                )
            )
        }
    }
}

/// Sample data as computed helpers so Swift 6 does not treat Color-bearing
/// static lets as isolated globals (same lesson as DrafterCharts / Liveline).
private enum Fixtures {
    static var months: [String] { ["Jan", "Feb", "Mar", "Apr", "May", "Jun"] }
    static var quarters: [String] { ["Q1", "Q2", "Q3", "Q4"] }
    static var quarterLong: [String] { ["Quarter 1", "Quarter 2", "Quarter 3", "Quarter 4"] }
    static var weekShort: [String] { ["M", "T", "W", "T", "F", "S", "S"] }
    static var weekLong: [String] {
        ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    }

    static var monthValues: [Double] { [45, 62, 38, 71, 55, 48] }

    static var revenueExpenses: [[Double]] {
        [
            [1200, 800],
            [1500, 900],
            [1100, 750],
            [1800, 1200],
        ]
    }

    static var weekStacked: [[Double]] {
        [
            [50, 20, 30],
            [45, 25, 15],
            [60, 30, 40],
            [55, 20, 25],
            [70, 35, 50],
            [40, 10, 80],
            [30, 5, 20],
        ]
    }

    static var revenueCategories: [SVCategory] {
        [
            SVCategory(name: "Revenue", color: .green),
            SVCategory(name: "Expenses", color: .red),
        ]
    }

    static var hexCategories: [SVCategory] {
        [
            SVCategory(name: "Food", colorHex: "#6B99D6"),
            SVCategory(name: "Transport", colorHex: "#4CAF50"),
            SVCategory(name: "Shopping", colorHex: "#FF9800"),
        ]
    }

    static func frozen(
        chartHeight: CGFloat,
        showAverageLine: Bool = false,
        barSpacing: CGFloat = 8
    ) -> SVBarChartStyle {
        SVBarChartStyle(
            chartHeight: chartHeight,
            barSpacing: barSpacing,
            backgroundBarColor: Color.white.opacity(0.08),
            showAverageLine: showAverageLine,
            averageLineColor: Color.white.opacity(0.4),
            yAxisFont: .caption.bold(),
            xAxisFont: .caption2.bold(),
            legendFont: .caption.weight(.semibold),
            isInteractive: false
        )
    }
}
