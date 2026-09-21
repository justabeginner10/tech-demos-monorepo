import SwiftUI

struct FloatingMorphingTabBar: View {
    @Binding var selection: FindMyTab
    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 4) {
            ForEach(FindMyTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
    }

    private func tabButton(_ tab: FindMyTab) -> some View {
        let isSelected = selection == tab

        return Button {
            withAnimation(.snappy(duration: 0.28)) {
                selection = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 16, weight: .semibold))

                if isSelected {
                    Text(tab.title)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .foregroundStyle(isSelected ? Color.white : Color.white.opacity(0.72))
            .padding(.horizontal, isSelected ? 12 : 10)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background {
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(FindMyTab.accent)
                        .matchedGeometryEffect(id: "findMySelectionPill", in: namespace)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
