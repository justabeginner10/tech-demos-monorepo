import DrafterCharts
import SwiftUI

/// Dark playground for DrafterCharts, plus a static family gallery.
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
        .drafterTheme(.dark)
    }
}

/// One live Canvas at a time: line, area, candles, or stream graph.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var tape = LiveTape()
    @State private var isLive = true
    @State private var userPaused = false
    @State private var family: LiveFamily = .line
    @State private var replayKey = 0

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
            .navigationTitle("DrafterCharts")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task(id: tickToken) {
            guard shouldTick else { return }
            while !Task.isCancelled {
                tape.tick(family: family)
                try? await Task.sleep(for: .milliseconds(LiveTape.tickMilliseconds))
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
            Text("Native SwiftUI charts")
                .font(.title3.weight(.semibold))

            Text(
                "DrafterCharts draws on `Canvas` — Catmull-Rom curves, gradient fills, "
                    + "and a one-shot reveal. One live family ticks at a time. Open Gallery "
                    + "for the rest of the pack."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Text("DFT")
                    .font(.caption.weight(.semibold).monospaced())
                Text("·")
                Text(DemoPalette.compact(tape.latest))
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

            Button("Replay reveal") {
                replayKey += 1
            }
            .buttonStyle(.bordered)
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
            case .line:
                LineChart(
                    points: tape.linePoints,
                    color: DrafterColors.teal,
                    animate: true,
                    replay: replayKey
                )
                .frame(height: 260)
            case .area:
                AreaChart(
                    points: tape.linePoints,
                    color: DrafterColors.blue,
                    animate: true,
                    replay: replayKey
                )
                .frame(height: 260)
            case .candles:
                CandlestickChart(
                    candles: tape.candles,
                    movingAverages: [MovingAverage(period: 3, color: DrafterColors.amber)],
                    animate: true,
                    replay: replayKey
                )
                .frame(height: 280)
            case .stream:
                StreamGraphChart(
                    series: tape.stream.series,
                    categories: tape.stream.categories,
                    animate: true,
                    replay: replayKey
                )
                .frame(height: 260)
            }
        }
    }

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How it works")
                .font(.headline)

            Text(
                "The family picker keeps a single Canvas live at \(LiveTape.tickMilliseconds)ms. "
                    + "Ticks pause when this tab is backgrounded or the scene is inactive. "
                    + "**Replay reveal** re-runs the package entrance on the active chart only. "
                    + "Gallery is static — `animate: false`, no timer."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }

    // MARK: - Bindings

    private var pauseBinding: Binding<Bool> {
        Binding(
            get: { isLive },
            set: { live in
                userPaused = !live
                isLive = live
            }
        )
    }
}

#Preview("DrafterCharts Demo") {
    DemoScreen()
        .preferredColorScheme(.dark)
        .drafterTheme(.dark)
}
