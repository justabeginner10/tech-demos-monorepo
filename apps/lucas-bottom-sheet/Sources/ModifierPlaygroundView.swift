import BottomSheet
import SwiftUI

struct ModifierPlaygroundView: View {
    private static let hiddenPeek = BottomSheetPosition.relativeBottom(0.28)
    private static let visiblePeek = BottomSheetPosition.relative(0.28)
    private static let half = BottomSheetPosition.relative(0.58)
    private static let expanded = BottomSheetPosition.relativeTop(0.96)

    @State private var position: BottomSheetPosition = half
    @State private var showDragIndicator = true
    @State private var swipeToDismiss = false
    @State private var customBackground = true
    @State private var largeCorners = true
    @State private var shadow = false
    @State private var hideContentWhenCollapsed = true
    @State private var floatingIPad = true
    @State private var slowAnimation = false
    @State private var dismissCount = 0

    private var peek: BottomSheetPosition {
        hideContentWhenCollapsed ? Self.hiddenPeek : Self.visiblePeek
    }

    private var switchablePositions: [BottomSheetPosition] {
        [peek, Self.half, Self.expanded]
    }

    var body: some View {
        makeSheet()
            .demoChrome()
            .onChange(of: hideContentWhenCollapsed) { _, hide in
                guard position == Self.hiddenPeek || position == Self.visiblePeek else { return }
                position = hide ? Self.hiddenPeek : Self.visiblePeek
            }
    }

    private func makeSheet() -> some View {
        let sheet = stage
            .bottomSheet(
                bottomSheetPosition: $position,
                switchablePositions: switchablePositions,
                headerContent: { header }
            ) {
                controls
            }
            .showDragIndicator(showDragIndicator)
            .enableSwipeToDismiss(swipeToDismiss)
            .enableFloatingIPadSheet(floatingIPad)
            .enableAppleScrollBehavior(true)
            .customAnimation(
                slowAnimation
                    ? .easeInOut(duration: 0.9)
                    : .spring(response: 0.5, dampingFraction: 0.75, blendDuration: 1)
            )
            .dragIndicatorColor(DemoPalette.ink.opacity(0.45))
            .onDismiss {
                dismissCount += 1
            }

        return withBackground(sheet)
    }

    private func withBackground<Header: View, Content: View, Underlying: View>(
        _ sheet: BottomSheet<Header, Content, Underlying>
    ) -> BottomSheet<Header, Content, Underlying> {
        if customBackground {
            sheet.customBackground(
                RoundedRectangle(cornerRadius: largeCorners ? 30 : 12, style: .continuous)
                    .fill(DemoPalette.sheet)
                    .shadow(
                        color: shadow ? Color.black.opacity(0.22) : .clear,
                        radius: shadow ? 18 : 0,
                        y: shadow ? -6 : 0
                    )
            )
        } else {
            sheet
        }
    }

    private var stage: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [DemoPalette.forestTop, DemoPalette.forestBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 8) {
                Text(positionName)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text(stageDetail)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                if position == .hidden {
                    Button("Show sheet") {
                        position = Self.half
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundStyle(DemoPalette.ink)
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 64)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Playground")
                .font(.title3.bold())
                .foregroundStyle(DemoPalette.ink)

            HStack(spacing: 8) {
                SnapButton(title: "Peek", isSelected: position == peek) {
                    position = peek
                }
                SnapButton(title: "Half", isSelected: position == Self.half) {
                    position = Self.half
                }
                SnapButton(title: "Full", isSelected: position == Self.expanded) {
                    position = Self.expanded
                }
                SnapButton(title: "Hide", isSelected: position == .hidden) {
                    position = .hidden
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(positionName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.accent)
                .padding(.bottom, 4)

            Text("On iPhone the list scrolls only at the full snap. Anywhere lower, a drag moves the sheet.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 8)

            option(
                "Drag indicator",
                "Shows the capsule. The header stays draggable either way.",
                isOn: $showDragIndicator
            )
            option(
                "Swipe to dismiss",
                "A long swipe past the default 30% threshold hides the sheet and runs onDismiss.",
                isOn: $swipeToDismiss
            )
            option(
                "Custom background",
                "Replaces the default system material with a warm fill.",
                isOn: $customBackground
            )
            option(
                "Large corner radius",
                "Drawn on the custom background. v3 has no separate corner-radius modifier.",
                isOn: $largeCorners
            )
            option(
                "Shadow",
                "Also on the custom background. The library warns this can disturb the hide transition.",
                isOn: $shadow
            )
            option(
                "Hide content when collapsed",
                "Peek uses relativeBottom, which keeps the header and hides this list. Off, the same height uses relative and the list stays visible.",
                isOn: $hideContentWhenCollapsed
            )
            option(
                "iPad floating sheet",
                "On by default. On iPad it is an inset card from the top; off pins the sheet to the bottom.",
                isOn: $floatingIPad
            )
            option(
                "Slow custom animation",
                "Switches .customAnimation from the library spring to a 0.9s ease.",
                isOn: $slowAnimation
            )

            Text(dismissFootnote)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 28)
    }

    private func option(_ title: String, _ detail: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .tint(DemoPalette.accent)
        .padding(.vertical, 8)
    }

    private var positionName: String {
        switch position {
        case .hidden:
            return "Hidden"
        case .relativeBottom:
            return "Peek · header only"
        case .relative(0.58):
            return "Half"
        case .relativeTop:
            return "Full"
        case .relative:
            return "Peek · content visible"
        default:
            return "Custom"
        }
    }

    private var stageDetail: String {
        if position == .hidden {
            return dismissCount > 0
                ? "Dismissed by swipe. onDismiss ran."
                : "Hidden from the Hide button. onDismiss does not run for that."
        }
        return "Header snaps jump the position in code."
    }

    private var dismissFootnote: String {
        if dismissCount == 0 {
            return "Hide sets .hidden directly, so onDismiss stays quiet. Swipe-to-dismiss calls it."
        }
        let noun = dismissCount == 1 ? "time" : "times"
        return "onDismiss has run \(dismissCount) \(noun)."
    }
}

#Preview {
    NavigationStack {
        ModifierPlaygroundView()
    }
}
