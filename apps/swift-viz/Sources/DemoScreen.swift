import SwiftViz
import SwiftUI

/// Dark playground for SwiftViz, plus a static sample gallery.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live)
                .tabItem { Label("Live", systemImage: "chart.bar.fill") }
                .tag(DemoTab.live)

            GalleryScreen()
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
    }
}

/// One interactive `SVBarChart` at a time: stacked or simple.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @State private var family: LiveFamily = .stacked
    @State private var showAverage = true
    @State private var format: ValueFormat = .currency

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    storyHeader
                    playgroundControls
                    if isSelected {
                        activeChart
                    } else {
                        parkedCard
                    }
                    howItWorks
                }
                .padding()
            }
            .background(DemoPalette.page)
            .navigationTitle("SwiftViz")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header

    private var storyHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Opinionated SwiftUI bars")
                .font(.title3.weight(.semibold))

            Text(
                "SwiftViz is a stacked or simple bar chart with tap-to-detail spring "
                    + "animations, an average line, and a legend. Swift Charts covers more "
                    + "families and is more flexible; SwiftViz is the look-and-feel when you "
                    + "want that detail overlay without writing the gestures."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Text("SVZ")
                    .font(.caption.weight(.semibold).monospaced())
                Text("·")
                Text(family.title.lowercased())
                    .font(.caption)
                Text("·")
                Text(format.title.lowercased())
                    .font(.caption)
            }
            .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Controls

    private var playgroundControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Playground")
                .font(.headline)

            Picker("Family", selection: $family) {
                ForEach(LiveFamily.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Picker("Formatter", selection: $format) {
                ForEach(ValueFormat.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Toggle("Average line", isOn: $showAverage)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    // MARK: - Charts

    @ViewBuilder
    private var activeChart: some View {
        DemoChrome.chartCard(title: family.title, subtitle: family.subtitle) {
            switch family {
            case .stacked:
                SVBarChart(
                    data: LiveFixtures.weekStacked,
                    categories: LiveFixtures.spendCategories,
                    labels: LiveFixtures.weekShort,
                    expandedLabels: LiveFixtures.weekLong,
                    valueFormatter: format.formatter,
                    title: "Weekly spend",
                    style: liveStyle
                )
            case .simple:
                SVBarChart(
                    values: LiveFixtures.weekTotals,
                    labels: LiveFixtures.weekShort,
                    expandedLabels: LiveFixtures.weekLong,
                    color: Color(red: 107 / 255, green: 153 / 255, blue: 214 / 255),
                    valueFormatter: format.formatter,
                    title: "Weekly total",
                    style: liveStyle
                )
            }
        }
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: family.title, subtitle: "Unmounted") {
            Text("Interactive chart is unmounted while Gallery is open.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
        }
    }

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How it works")
                .font(.headline)

            Text(
                "Stacked and Simple swap a single interactive `SVBarChart`. Tap a bar "
                    + "for the package spring detail. **Currency** / **Percent** feed "
                    + "`valueFormatter`. The chart unmounts when this tab is not selected. "
                    + "Gallery is static — `isInteractive: false`, no timer."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }

    private var liveStyle: SVBarChartStyle {
        SVBarChartStyle(
            chartHeight: 220,
            barSpacing: 10,
            barCornerRadius: 8,
            backgroundBarColor: Color.white.opacity(0.08),
            showAverageLine: showAverage,
            averageLineColor: Color.white.opacity(0.45),
            showLegend: true,
            yAxisFont: .caption.bold(),
            xAxisFont: .caption.bold(),
            legendFont: .footnote.weight(.semibold),
            titleFont: .headline,
            selectionAnimation: .spring(duration: 0.25),
            isInteractive: true
        )
    }
}

/// Live playground data as computed helpers so Swift 6 does not treat
/// Color-bearing static lets as isolated globals.
private enum LiveFixtures {
    static var weekShort: [String] { ["M", "T", "W", "T", "F", "S", "S"] }

    static var weekLong: [String] {
        ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
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

    static var weekTotals: [Double] {
        weekStacked.map { $0.reduce(0, +) }
    }

    static var spendCategories: [SVCategory] {
        [
            SVCategory(name: "Food", colorHex: "#6B99D6"),
            SVCategory(name: "Transport", colorHex: "#4CAF50"),
            SVCategory(name: "Shopping", colorHex: "#FF9800"),
        ]
    }
}

#Preview("SwiftViz Demo") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
