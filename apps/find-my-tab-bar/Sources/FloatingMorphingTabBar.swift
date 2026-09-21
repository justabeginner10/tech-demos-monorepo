import SwiftUI

/// Floating tab row with a morphing selection pill.
///
/// Unselected tabs collapse to an icon. The selected tab expands to show
/// its title, and a capsule highlight slides with `matchedGeometryEffect`.
/// The parent supplies the material chrome so this row can sit in a capsule
/// or at the bottom of a peeking sheet.
struct FloatingMorphingTabBar: View {
    @Binding var selection: FindMyTab
    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 2) {
            ForEach(FindMyTab.allCases) { tab in
                tabButton(tab)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
        .padding(.bottom, 10)
    }

    private func tabButton(_ tab: FindMyTab) -> some View {
        let isSelected = selection == tab

        return Button {
            withAnimation(Self.morphSpring) {
                selection = tab
            }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 17, weight: .semibold))
                    .symbolEffect(.bounce, value: isSelected)

                if isSelected {
                    Text(tab.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .transition(
                            .asymmetric(
                                insertion: .opacity
                                    .combined(with: .scale(scale: 0.84, anchor: .leading)),
                                removal: .opacity
                                    .combined(with: .scale(scale: 0.84, anchor: .leading))
                            )
                        )
                }
            }
            .foregroundStyle(isSelected ? Color.white : Color.white.opacity(0.78))
            .padding(.horizontal, isSelected ? 14 : 10)
            .padding(.vertical, 12)
            .background {
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(FindMyTab.accent.gradient)
                        .matchedGeometryEffect(id: "findMySelectionPill", in: namespace)
                        .shadow(color: FindMyTab.accent.opacity(0.42), radius: 8, y: 3)
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(TabPressStyle())
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    static let morphSpring = Animation.spring(duration: 0.46, bounce: 0.26)
}

/// Light scale so the bar feels pressable without fighting the morph spring.
private struct TabPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}
