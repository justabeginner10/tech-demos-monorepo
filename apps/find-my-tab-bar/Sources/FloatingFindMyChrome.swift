import SwiftUI

/// Shared floating chrome: a material card that morphs from a wide capsule
/// into a peeking sheet, with the morphing tab bar pinned to the bottom.
struct FloatingFindMyChrome: View {
    @Binding var selection: FindMyTab
    @Binding var detent: ChromeDetent
    var namespace: Namespace.ID
    var maxHeight: CGFloat

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        let resting = detent.height(in: maxHeight)
        let height = clampHeight(resting - dragOffset)
        let progress = expandProgress(height: height)

        VStack(spacing: 0) {
            grabber
                .padding(.top, 8)
                .opacity(progress)
                .frame(height: progress > 0.02 ? 18 : 0)

            TabPeekList(tab: selection)
                .opacity(progress)
                .frame(maxHeight: .infinity, alignment: .top)
                .clipped()

            FloatingMorphingTabBar(selection: $selection, namespace: namespace)
                .layoutPriority(1)
        }
        .frame(height: height, alignment: .bottom)
        .frame(maxWidth: .infinity)
        .background {
            chromeBackground(cornerRadius: interpolatedCornerRadius(progress: progress))
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: interpolatedCornerRadius(progress: progress),
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: interpolatedCornerRadius(progress: progress),
                style: .continuous
            )
            .strokeBorder(.white.opacity(0.16), lineWidth: 0.8)
        }
        .shadow(color: .black.opacity(0.32), radius: 28, y: 12)
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
        .simultaneousGesture(drag)
        .onChange(of: selection) { _, _ in
            if detent == .bar {
                withAnimation(FloatingMorphingTabBar.morphSpring) {
                    detent = .peek
                }
            }
        }
    }

    private var grabber: some View {
        Capsule()
            .fill(.white.opacity(0.38))
            .frame(width: 36, height: 5)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .accessibilityLabel("Resize sheet")
    }

    private func chromeBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.regularMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.black.opacity(0.18))
            }
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 16)
            .onChanged { value in
                dragOffset = value.translation.height
            }
            .onEnded { value in
                let predicted = detent.height(in: maxHeight) - value.predictedEndTranslation.height
                let next = nearestDetent(to: predicted)
                withAnimation(FloatingMorphingTabBar.morphSpring) {
                    dragOffset = 0
                    detent = next
                }
            }
    }

    private func nearestDetent(to height: CGFloat) -> ChromeDetent {
        ChromeDetent.allCases.min { lhs, rhs in
            abs(lhs.height(in: maxHeight) - height) < abs(rhs.height(in: maxHeight) - height)
        } ?? .peek
    }

    private func clampHeight(_ height: CGFloat) -> CGFloat {
        let minH = ChromeDetent.bar.height(in: maxHeight)
        let maxH = ChromeDetent.half.height(in: maxHeight)
        min(max(height, minH), maxH)
    }

    private func expandProgress(height: CGFloat) -> CGFloat {
        let minH = ChromeDetent.bar.height(in: maxHeight)
        let peekH = ChromeDetent.peek.height(in: maxHeight)
        let span = max(peekH - minH, 1)
        return min(max((height - minH) / span, 0), 1)
    }

    private func interpolatedCornerRadius(progress: CGFloat) -> CGFloat {
        let bar = ChromeDetent.bar.cornerRadius
        let sheet = ChromeDetent.peek.cornerRadius
        return bar + (sheet - bar) * progress
    }
}
