import Liveline
import SwiftUI

/// Dark playground for Liveline realtime charts, plus a static family gallery.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live)
                .tabItem { Label("Live", systemImage: "waveform.path.ecg") }
                .tag(DemoTab.live)

            GalleryScreen()
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
    }
}

/// One live Canvas at a time: line, candles, or multi-series.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var tape = LiveTape()
    @State private var isLive = true
    @State private var userPaused = false
    @State private var useDither = false
    @State private var ditherVariant: DitherVariant = .gradient
    @State private var family: LiveFamily = .line
    @State private var lineWindow: TimeInterval = 60
    @State private var candleLineMode = false
    @State private var lastScrub: LivelineHoverPoint?

    private var shouldTick: Bool {
        isSelected && isLive && scenePhase == .active
    }

    private var tickToken: String {
        "\(shouldTick ? 1 : 0)-\(family.rawValue)"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    storyHeader
                    playgroundControls
                    activeChart
                    howItWorks
                }
                .padding()
            }
            .background(DemoPalette.page)
            .navigationTitle("Liveline")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task(id: tickToken) {
            guard shouldTick else { return }
            while !Task.isCancelled {
                tape.tick(family: family)
                try? await Task.sleep(for: .milliseconds(220))
            }
        }
        .onChange(of: family) { _, newFamily in
            tape.prepare(for: newFamily)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                isLive = !userPaused
            } else {
                isLive = false
            }
        }
        .onChange(of: isSelected) { _, selected in
            if selected {
                isLive = !userPaused
                tape.prepare(for: family)
            } else {
                isLive = false
            }
        }
    }

    // MARK: - Header

    private var storyHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Realtime SwiftUI charts")
                .font(.title3.weight(.semibold))

            Text(
                "Liveline draws on `Canvas` — no WebView. One live family ticks at a "
                    + "time from a `LivelineDataStream`. Open Gallery for the rest of the pack."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Text("LIV")
                    .font(.caption.weight(.semibold).monospaced())
                Text("·")
                Text(DemoPalette.money(tape.latest))
                    .font(.caption.monospacedDigit())
                Text("·")
                Text(isLive ? "live" : "paused")
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

            Toggle("Live ticks", isOn: pauseBinding)

            Toggle("Dither style", isOn: $useDither)

            if useDither {
                Picker("Dither variant", selection: $ditherVariant) {
                    ForEach(DitherVariant.allCases) { variant in
                        Text(variant.title).tag(variant)
                    }
                }
                .pickerStyle(.segmented)
            }

            LabeledContent("Scrub") {
                Text(scrubCaption)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
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
        switch family {
        case .line:
            liveLineCard
        case .candles:
            candleCard
        case .compare:
            seriesCard
        }
    }

    private var liveLineCard: some View {
        DemoChrome.chartCard(title: "Live tape", subtitle: "LivelineDataStream · line") {
            LivelineChart(
                data: tape.visiblePoints(covering: lineWindow + 15),
                value: tape.latest,
                color: .cyan,
                configuration: LivelineChartConfiguration(
                    theme: .dark,
                    style: liveChartStyle,
                    window: lineWindow,
                    windows: [
                        LivelineWindowOption(label: "30s", seconds: 30),
                        LivelineWindowOption(label: "1m", seconds: 60),
                        LivelineWindowOption(label: "3m", seconds: 180),
                    ],
                    badge: true,
                    pulse: true,
                    showValue: true,
                    valueMomentumColor: true,
                    paused: !isLive,
                    referenceLine: LivelineReferenceLine(value: 48, label: "Open"),
                    formatValue: DemoPalette.money,
                    onHover: { reportScrub($0) },
                    onWindowChange: { lineWindow = $0 }
                )
            )
            .frame(height: 260)
        }
    }

    private var candleCard: some View {
        DemoChrome.chartCard(
            title: "Session tape",
            subtitle: candleLineMode ? "Candles morphed to line" : "OHLC · 20s live candle"
        ) {
            LivelineChart(
                data: tape.visiblePoints(covering: 270),
                value: tape.latest,
                candles: tape.candles,
                candleWidth: LiveTape.candleWidth,
                liveCandle: tape.liveCandle,
                lineData: candleLineMode ? tape.visiblePoints(covering: 270) : [],
                lineValue: candleLineMode ? tape.latest : nil,
                color: Color(red: 247 / 255, green: 147 / 255, blue: 26 / 255),
                configuration: LivelineChartConfiguration(
                    theme: .dark,
                    style: liveChartStyle,
                    window: 240,
                    windows: [
                        LivelineWindowOption(label: "2m", seconds: 120),
                        LivelineWindowOption(label: "4m", seconds: 240),
                        LivelineWindowOption(label: "8m", seconds: 480),
                    ],
                    badge: true,
                    showValue: true,
                    paused: !isLive,
                    formatValue: DemoPalette.money,
                    lineMode: candleLineMode,
                    onHover: { reportScrub($0) },
                    onModeChange: { candleLineMode = $0 == .line }
                )
            )
            .frame(height: 280)
        }
    }

    private var seriesCard: some View {
        DemoChrome.chartCard(title: "Compare", subtitle: "Multi-series · Tape / Drift / Echo") {
            LivelineChart(
                series: tape.series,
                configuration: LivelineChartConfiguration(
                    theme: .dark,
                    style: liveChartStyle,
                    window: 180,
                    windows: [
                        LivelineWindowOption(label: "1m", seconds: 60),
                        LivelineWindowOption(label: "3m", seconds: 180),
                        LivelineWindowOption(label: "5m", seconds: 300),
                    ],
                    paused: !isLive,
                    formatValue: DemoPalette.money,
                    onHover: { reportScrub($0) }
                )
            )
            .frame(height: 240)
        }
    }

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How it works")
                .font(.headline)

            Text(
                "The family picker keeps a single Canvas live at ~220ms. Drag to scrub; "
                    + "the **Scrub** row updates only when the hovered value moves. Dither "
                    + "uses bloom `.low` at 24 FPS so one live chart stays cheap. Gallery "
                    + "is static — no timer."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }

    // MARK: - Bindings / helpers

    private var pauseBinding: Binding<Bool> {
        Binding(
            get: { isLive },
            set: { live in
                userPaused = !live
                isLive = live
            }
        )
    }

    private var liveChartStyle: LivelineChartStyle {
        guard useDither else { return .standard }
        return .dither(
            LivelineDitherStyle(
                variant: ditherVariant.liveline,
                bloom: .low,
                maximumFramesPerSecond: 24
            )
        )
    }

    private var scrubCaption: String {
        guard let lastScrub else { return "Drag a chart" }
        return DemoPalette.money(lastScrub.value)
    }

    private func reportScrub(_ point: LivelineHoverPoint?) {
        guard let point else {
            if lastScrub != nil { lastScrub = nil }
            return
        }
        if let lastScrub,
           abs(lastScrub.value - point.value) < 0.005,
           abs(lastScrub.time - point.time) < 0.05
        {
            return
        }
        lastScrub = point
    }
}

#Preview("Liveline Demo") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
