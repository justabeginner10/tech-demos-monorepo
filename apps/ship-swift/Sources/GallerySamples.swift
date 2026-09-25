import Foundation
import SwiftUI

/// Frozen / one-shot samples. Live playground already owns the looping recipes.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case shimmerStill
    case typewriterStill
    case glowStill
    case thinkingStill
    case line
    case donut
    case bars
    case rings
    case badges
    case kpis

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shimmerStill: "Shimmer still"
        case .typewriterStill: "Typewriter still"
        case .glowStill: "Glow still"
        case .thinkingStill: "Thinking still"
        case .line: "Line"
        case .donut: "Donut"
        case .bars: "Bars"
        case .rings: "Rings"
        case .badges: "Status badges"
        case .kpis: "KPI cards"
        }
    }

    var subtitle: String {
        switch self {
        case .shimmerStill: "No SWShimmer wrapper"
        case .typewriterStill: "Static gradient text"
        case .glowStill: "No sweep timer"
        case .thinkingStill: "No TimelineView"
        case .line: "One-shot reveal"
        case .donut: "Binding.constant"
        case .bars: "Grouped · one-shot"
        case .rings: "One-shot fill"
        case .badges: "SWStatusBadge"
        case .kpis: "SWKPICard"
        }
    }

    @ViewBuilder
    var preview: some View {
        switch self {
        case .shimmerStill:
            FrozenShimmer()
        case .typewriterStill:
            FrozenTypewriter()
        case .glowStill:
            FrozenGlow()
        case .thinkingStill:
            FrozenThinking()
        case .line:
            SWLineChart(
                dataPoints: Fixtures.weekLine,
                colorMapping: Fixtures.lineColors,
                interpolationMethod: .catmullRom,
                yDomain: 0...100,
                visibleDays: 7,
                chartHeight: 170,
                title: nil
            )
            .padding(8)
        case .donut:
            SWDonutChart(
                subjects: Fixtures.donutSubjects,
                selectedCategory: .constant(nil)
            )
            .padding(.vertical, 8)
        case .bars:
            SWBarChart(
                dataPoints: Fixtures.weekBars,
                colorMapping: Fixtures.barColors,
                stackMode: .grouped,
                yDomain: 0...90,
                visibleDays: 7,
                chartHeight: 170
            )
            .padding(8)
        case .rings:
            SWRingChart(
                data: [
                    .init(id: Fixtures.id(1, 0), label: "Move", value: 75, color: .red),
                    .init(id: Fixtures.id(1, 1), label: "Exercise", value: 50, color: .green),
                    .init(id: Fixtures.id(1, 2), label: "Stand", value: 90, color: .cyan),
                ],
                size: 160,
                ringWidth: 16,
                spacing: 7
            ) {
                Image(systemName: "flame.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
            }
            .padding(12)
        case .badges:
            FrozenBadges()
        case .kpis:
            FrozenKPIs()
        }
    }
}

// MARK: - Frozen snapshots (no continuous animation)

private struct FrozenShimmer: View {
    var body: some View {
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
            Text("Upgrade Now")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(DemoPalette.accent.opacity(0.85), in: Capsule())
                .foregroundStyle(.white)
                .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct FrozenTypewriter: View {
    var body: some View {
        Text("Copy-paste from SWPackage")
            .font(.title3.weight(.semibold))
            .foregroundStyle(
                LinearGradient(
                    colors: [.cyan, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
            .padding(16)
    }
}

private struct FrozenGlow: View {
    var body: some View {
        Text("Start Scan Today")
            .font(.title2.bold())
            .foregroundStyle(Color.gray)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
            .padding(16)
    }
}

private struct FrozenThinking: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(.purple)
            HStack(spacing: 6) {
                Text("Thinking")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Circle().fill(Color.secondary).frame(width: 7, height: 7)
                    Circle().fill(Color.secondary).frame(width: 7, height: 7)
                        .offset(y: -4)
                    Circle().fill(Color.secondary).frame(width: 7, height: 7)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            Spacer(minLength: 0)
        }
        .padding(16)
    }
}

private struct FrozenBadges: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                SWStatusBadge(text: "Ready", style: .success)
                SWStatusBadge(text: "Pending", style: .warning)
                SWStatusBadge(text: "Blocked", style: .error)
            }
            SWGradientDivider(color: .cyan, opacity: 0.45)
            VStack(alignment: .leading, spacing: 8) {
                SWBulletPointText(bulletColor: .cyan) {
                    Text("Copy from SWAnimation / SWChart / SWComponent")
                        .foregroundStyle(.primary)
                }
                SWBulletPointText(bulletColor: .purple) {
                    Text("SW prefix types · .sw modifiers")
                        .foregroundStyle(.primary)
                }
                SWBulletPointText(bulletColor: .orange) {
                    Text("SWModule frameworks left out")
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct FrozenKPIs: View {
    var body: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
            spacing: 10
        ) {
            SWKPICard(
                title: "Recipes vendored",
                value: "12",
                icon: "shippingbox.fill",
                tint: DemoPalette.accent
            ) {
                Text("SWPackage files")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            SWKPICard(
                title: "Live surfaces",
                value: "1",
                icon: "sparkles",
                tint: .purple
            ) {
                Text("Picker mounts one")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
    }
}

/// Sample data as computed helpers so Swift 6 does not treat Color-bearing
/// static lets as isolated globals (same lesson as SwiftViz / DrafterCharts).
private enum Fixtures {
    static func id(_ series: Int, _ offset: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-4000-8000-%04d%08d", series, offset))!
    }

    static var lineColors: [String: Color] {
        [
            "Revenue": Color(red: 107 / 255, green: 153 / 255, blue: 214 / 255),
            "Cost": Color(red: 1, green: 152 / 255, blue: 0),
        ]
    }

    static var barColors: [String: Color] {
        [
            "Online": Color(red: 107 / 255, green: 153 / 255, blue: 214 / 255),
            "Offline": .orange,
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
                .init(id: id(2, offset), date: date, value: revenue[offset], category: "Revenue"),
                .init(id: id(3, offset), date: date, value: cost[offset], category: "Cost"),
            ]
        }
    }

    static var weekBars: [SWBarChart<String>.DataPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let online: [Double] = [48, 62, 55, 70, 64, 81, 73]
        let offline: [Double] = [22, 18, 25, 20, 27, 19, 24]
        return (0..<7).flatMap { offset -> [SWBarChart<String>.DataPoint] in
            let date = calendar.date(byAdding: .day, value: offset - 6, to: today)!
            return [
                .init(id: id(4, offset), date: date, value: online[offset], category: "Online"),
                .init(id: id(5, offset), date: date, value: offline[offset], category: "Offline"),
            ]
        }
    }

    static var donutSubjects: [SWDonutChart.Subject] {
        let work = SWDonutChart.Category(name: "Work")
        let personal = SWDonutChart.Category(name: "Personal")
        let health = SWDonutChart.Category(name: "Health")
        return [
            .init(name: "Meeting", category: work),
            .init(name: "Report", category: work),
            .init(name: "Email", category: work),
            .init(name: "Shopping", category: personal),
            .init(name: "Reading", category: personal),
            .init(name: "Exercise", category: health),
            .init(name: "Meditation", category: health),
            .init(name: "Running", category: health),
            .init(name: "Uncategorized", category: nil),
        ]
    }
}
