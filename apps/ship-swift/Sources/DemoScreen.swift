import Foundation
import SwiftUI

/// Dark playground for a slim, copy-paste slice of ShipSwift.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live)
                .tabItem { Label("Live", systemImage: "sparkles") }
                .tag(DemoTab.live)

            GalleryScreen()
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
    }
}

/// One live recipe at a time: shimmer, typewriter, line chart, or thinking dots.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @State private var family: LiveFamily = .shimmer

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    storyHeader
                    playgroundControls
                    if isSelected {
                        activeRecipe
                    } else {
                        parkedCard
                    }
                    howItWorks
                }
                .padding()
            }
            .background(DemoPalette.page)
            .navigationTitle("ShipSwift")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header

    private var storyHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI-native component recipes")
                .font(.title3.weight(.semibold))

            Text(
                "ShipSwift is a copy-paste catalog, not an SPM import. Recipes live "
                    + "under `SWPackage/` as self-contained `SW*` files. This playground "
                    + "vendors a slim slice — animation, chart, and component — and mounts "
                    + "only one live surface at a time."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Text("SWS")
                    .font(.caption.weight(.semibold).monospaced())
                Text("·")
                Text(family.title.lowercased())
                    .font(.caption)
                Text("·")
                Text("copy-paste")
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
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    // MARK: - Recipes

    @ViewBuilder
    private var activeRecipe: some View {
        DemoChrome.chartCard(title: family.title, subtitle: family.subtitle) {
            switch family {
            case .shimmer:
                liveShimmer
            case .typewriter:
                liveTypewriter
            case .line:
                liveLine
            case .thinking:
                liveThinking
            }
        }
    }

    private var liveShimmer: some View {
        SWShimmer(duration: 1.8, delay: 0.8) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 16)
                        .frame(maxWidth: 180)
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 12)
                        .frame(maxWidth: 220)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )

                Text("Upgrade Now")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(DemoPalette.accent, in: Capsule())
                    .foregroundStyle(.white)
            }
        }
        .padding(12)
    }

    private var liveTypewriter: some View {
        SWTypewriterText(
            texts: LiveFixtures.headlines,
            typingSpeed: 0.05,
            deletingSpeed: 0.03,
            pauseDuration: 2.2,
            animationStyle: .spring
        )
        .font(.title3.weight(.semibold))
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .center)
        .padding(16)
    }

    private var liveLine: some View {
        SWLineChart(
            dataPoints: LiveFixtures.weekLine,
            colorMapping: LiveFixtures.lineColors,
            referenceLines: [
                SWLineChart<String>.ReferenceLine(value: 60, label: "Target", color: .orange)
            ],
            interpolationMethod: .catmullRom,
            showPointMarkers: true,
            yDomain: 0...100,
            visibleDays: 7,
            chartHeight: 220,
            title: "Revenue vs cost"
        )
        .padding(8)
    }

    private var liveThinking: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(.purple)
            HStack(spacing: 6) {
                Text("Thinking")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                SWThinkingIndicator(dotSize: 7, dotColor: .secondary, spacing: 4)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .bottom)
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: family.title, subtitle: "Unmounted") {
            Text("Live recipe is unmounted while Gallery is open.")
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
                "The family picker keeps a single recipe in the view tree. "
                    + "**Shimmer** and **Writer** are SwiftUI loops; **Line** is a one-shot "
                    + "Swift Charts reveal; **Think** is a `TimelineView` bounce. Leaving "
                    + "this tab unmounts the active piece. Gallery is paused snapshots plus "
                    + "one-shot charts — no Metal, no CADisplayLink rows."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }
}

/// Live playground data as computed helpers so Swift 6 does not treat
/// Color-bearing static lets as isolated globals.
private enum LiveFixtures {
    static func pointID(_ series: Int, _ offset: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-4000-8000-%04d%08d", series, offset))!
    }

    static var headlines: [String] {
        [
            "Copy-paste from SWPackage",
            "AI-native SwiftUI recipes",
            "One live surface at a time",
        ]
    }

    static var lineColors: [String: Color] {
        [
            "Revenue": Color(red: 107 / 255, green: 153 / 255, blue: 214 / 255),
            "Cost": Color(red: 1, green: 152 / 255, blue: 0),
        ]
    }

    static var weekLine: [SWLineChart<String>.DataPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let revenue: [Double] = [42, 55, 48, 71, 63, 80, 74]
        let cost: [Double] = [28, 31, 35, 40, 38, 44, 41]
        return (0..<7).flatMap { offset -> [SWLineChart<String>.DataPoint] in
            let date = calendar.date(byAdding: .day, value: offset - 6, to: today)!
            return [
                .init(id: LiveFixtures.pointID(0, offset), date: date, value: revenue[offset], category: "Revenue"),
                .init(id: LiveFixtures.pointID(1, offset), date: date, value: cost[offset], category: "Cost"),
            ]
        }
    }
}

#Preview("ShipSwift Demo") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
