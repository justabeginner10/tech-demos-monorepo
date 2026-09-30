import BottomSheet
import SwiftUI

struct AbsoluteSheetView: View {
    private static let headerHeight = BottomSheetPosition.absoluteBottom(150)
    private static let short = BottomSheetPosition.absolute(280)
    private static let medium = BottomSheetPosition.absolute(440)
    private static let tall = BottomSheetPosition.absoluteTop(620)

    private static let marks: [HeightMark] = [
        HeightMark(value: 150, title: "150 pt"),
        HeightMark(value: 280, title: "280 pt"),
        HeightMark(value: 440, title: "440 pt"),
        HeightMark(value: 620, title: "620 pt")
    ]

    @State private var position: BottomSheetPosition = short

    var body: some View {
        stage
            .bottomSheet(
                bottomSheetPosition: $position,
                switchablePositions: [Self.headerHeight, Self.short, Self.medium, Self.tall],
                headerContent: { header }
            ) {
                explanation
            }
            .showDragIndicator(true)
            .dragIndicatorColor(DemoPalette.ink.opacity(0.35))
            .enableAppleScrollBehavior(true)
            .demoChrome()
    }

    private var stage: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [DemoPalette.forestTop, DemoPalette.forestBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                ForEach(Self.marks) { mark in
                    HStack(spacing: 8) {
                        Capsule()
                            .fill(.white.opacity(0.92))
                            .frame(width: 18, height: 3)
                        Text(mark.title)
                            .font(.caption.monospaced().weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .position(x: 70, y: geo.size.height - mark.value)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Fixed points")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text("Lines sit that many points above the bottom of this screen.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 68)
            .padding(.top, 16)
            .padding(.trailing, 24)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Absolute snaps")
                    .font(.title3.bold())
                    .foregroundStyle(DemoPalette.ink)
                Text(positionName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                SnapButton(title: "150", isSelected: position == Self.headerHeight) {
                    position = Self.headerHeight
                }
                SnapButton(title: "280", isSelected: position == Self.short) {
                    position = Self.short
                }
                SnapButton(title: "440", isSelected: position == Self.medium) {
                    position = Self.medium
                }
                SnapButton(title: "620", isSelected: position == Self.tall) {
                    position = Self.tall
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var explanation: some View {
        VStack(alignment: .leading, spacing: 14) {
            note(
                symbol: "eye.slash",
                title: "absoluteBottom(150)",
                detail: "150 points tall. Main content is hidden and the header remains, the same idea as a collapsed Apple sheet."
            )
            note(
                symbol: "ruler",
                title: "absolute(280) and absolute(440)",
                detail: "Fixed pixel heights. The list is clipped until you drag or jump higher."
            )
            note(
                symbol: "arrow.up.to.line",
                title: "absoluteTop(620)",
                detail: "The top snap. On iPhone, .enableAppleScrollBehavior() only lets this list scroll here."
            )

            ForEach(sampleRows, id: \.self) { row in
                HStack(spacing: 10) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundStyle(DemoPalette.accent)
                    Text(row)
                        .font(.body)
                        .foregroundStyle(DemoPalette.ink)
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 32)
    }

    private func note(symbol: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.body)
                .foregroundStyle(DemoPalette.accent)
                .frame(width: 28, alignment: .center)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var sampleRows: [String] {
        [
            "Heights are points, not a fraction of the screen.",
            "Mix them with relative or dynamic snaps in one array.",
            "Values of 0 are not a height. Use .hidden.",
            "The top case is what unlocks Apple scrolling.",
            "Drag the handle, or tap a point value in the header."
        ]
    }

    private var positionName: String {
        switch position {
        case .absoluteBottom(let value):
            return "\(Int(value)) pt · header only"
        case .absoluteTop(let value):
            return "\(Int(value)) pt · scroll unlocked"
        case .absolute(let value):
            return "\(Int(value)) pt"
        default:
            return "Custom"
        }
    }
}

private struct HeightMark: Identifiable {
    let value: CGFloat
    let title: String
    var id: CGFloat { value }
}

#Preview {
    NavigationStack {
        AbsoluteSheetView()
    }
}
