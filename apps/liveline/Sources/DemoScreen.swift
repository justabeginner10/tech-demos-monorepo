import Liveline
import SwiftUI

/// Dark one-screen playground for Liveline realtime charts.
struct DemoScreen: View {
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var tape = LiveTape()
    @State private var isLive = true
    @State private var userPaused = false
    @State private var useDither = false
    @State private var ditherVariant: DitherVariant = .gradient
    @State private var lineWindow: TimeInterval = 60
    @State private var candleLineMode = false
    @State private var lastScrub: LivelineHoverPoint?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    storyHeader
                    playgroundControls
                    liveLineCard
                    candleCard
                    seriesCard
                    howItWorks
                }
                .padding()
            }
            .background(DemoPalette.page)
            .navigationTitle("Liveline")
            .navigationBarTitleDisplayMode(.inline)
            .livelineChartStyle(ditherOverride)
        }
        .task(id: isLive) {
            guard isLive else { return }
            while !Task.isCancelled {
                tape.tick()
                try? await Task.sleep(for: .milliseconds(220))
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                isLive = !userPaused
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
                "Liveline draws on `Canvas` — no WebView. This playground feeds a "
                    + "`LivelineDataStream` with a fake tape and buckets the same ticks "
                    + "into live candles."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Text("LIV")
                    .font(.caption.weight(.semibold).monospaced())
                Text("·")
                Text(Self.money(tape.latest))
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

    private var liveLineCard: some View {
        chartCard(title: "Live tape", subtitle: "LivelineDataStream · line") {
            LivelineChart(
                data: tape.points,
                value: tape.latest,
                color: .cyan,
                configuration: LivelineChartConfiguration(
                    theme: .dark,
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
                    formatValue: Self.money,
                    onHover: { lastScrub = $0 },
                    onWindowChange: { lineWindow = $0 }
                )
            )
            .frame(height: 260)
        }
    }

    private var candleCard: some View {
        chartCard(
            title: "Session tape",
            subtitle: candleLineMode ? "Candles morphed to line" : "OHLC · 20s live candle"
        ) {
            LivelineChart(
                data: tape.points,
                value: tape.latest,
                candles: tape.candles,
                candleWidth: LiveTape.candleWidth,
                liveCandle: tape.liveCandle,
                lineData: tape.points,
                lineValue: tape.latest,
                color: Color(red: 247 / 255, green: 147 / 255, blue: 26 / 255),
                configuration: LivelineChartConfiguration(
                    theme: .dark,
                    window: 240,
                    windows: [
                        LivelineWindowOption(label: "2m", seconds: 120),
                        LivelineWindowOption(label: "4m", seconds: 240),
                        LivelineWindowOption(label: "8m", seconds: 480),
                    ],
                    badge: true,
                    showValue: true,
                    paused: !isLive,
                    formatValue: Self.money,
                    lineMode: candleLineMode,
                    onHover: { lastScrub = $0 },
                    onModeChange: { candleLineMode = $0 == .line }
                )
            )
            .frame(height: 280)
        }
    }

    private var seriesCard: some View {
        chartCard(title: "Compare", subtitle: "Multi-series · Tape / Drift / Echo") {
            LivelineChart(
                series: tape.series,
                configuration: LivelineChartConfiguration(
                    theme: .dark,
                    window: 180,
                    windows: [
                        LivelineWindowOption(label: "1m", seconds: 60),
                        LivelineWindowOption(label: "3m", seconds: 180),
                        LivelineWindowOption(label: "5m", seconds: 300),
                    ],
                    paused: !isLive,
                    formatValue: Self.money,
                    onHover: { lastScrub = $0 }
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
                "Drag a chart to scrub — the built-in tooltip and value badge follow "
                    + "the nearest sample. The **Scrub** row above mirrors `onHover`. "
                    + "Dither is a container override (`.livelineChartStyle`) so every "
                    + "family switches together. Pause stops the tick loop and sets "
                    + "`paused` on each configuration."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }

    private func chartCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            content()
                .padding(.horizontal, 4)
                .padding(.bottom, 6)
                .background(DemoPalette.canvas)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
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

    private var ditherOverride: LivelineChartStyle? {
        guard useDither else { return nil }
        return .dither(LivelineDitherStyle(variant: ditherVariant.liveline, bloom: .aura))
    }

    private var scrubCaption: String {
        guard let lastScrub else { return "Drag a chart" }
        return Self.money(lastScrub.value)
    }

    private static func money(_ value: Double) -> String {
        "$" + value.formatted(.number.precision(.fractionLength(2)))
    }
}

private enum DitherVariant: String, CaseIterable, Identifiable, Hashable {
    case gradient
    case dotted
    case hatched
    case solid

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gradient: "Gradient"
        case .dotted: "Dotted"
        case .hatched: "Hatched"
        case .solid: "Solid"
        }
    }

    var liveline: LivelineDitherVariant {
        switch self {
        case .gradient: .gradient
        case .dotted: .dotted
        case .hatched: .hatched
        case .solid: .solid
        }
    }
}

private enum DemoPalette {
    static let page = Color(red: 8 / 255, green: 8 / 255, blue: 10 / 255)
    static let card = Color(red: 16 / 255, green: 16 / 255, blue: 18 / 255)
    static let canvas = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)
    static let stroke = Color.white.opacity(0.08)
}
