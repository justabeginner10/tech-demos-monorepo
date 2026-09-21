import SwiftUI

struct FloatingFindMyChrome: View {
    @Binding var selection: FindMyTab
    @Binding var detent: ChromeDetent
    var namespace: Namespace.ID
    var maxHeight: CGFloat

    @State private var dragOffset: CGFloat = 0

    private var restingHeight: CGFloat { detent.height(in: maxHeight) }
    private var height: CGFloat {
        let minH = ChromeDetent.bar.height(in: maxHeight)
        let maxH = ChromeDetent.half.height(in: maxHeight)
        return min(max(restingHeight - dragOffset, minH), maxH)
    }

    private var expandProgress: CGFloat {
        let minH = ChromeDetent.bar.height(in: maxHeight)
        let peekH = ChromeDetent.peek.height(in: maxHeight)
        return min(max((height - minH) / max(peekH - minH, 1), 0), 1)
    }

    private var cornerRadius: CGFloat {
        let bar = ChromeDetent.bar.cornerRadius
        let sheet = ChromeDetent.peek.cornerRadius
        return bar + (sheet - bar) * expandProgress
    }

    var body: some View {
        VStack(spacing: 0) {
            if expandProgress > 0.08 {
                Capsule()
                    .fill(.white.opacity(0.35))
                    .frame(width: 36, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 6)

                TabPeekList(tab: selection)
                    .frame(maxHeight: .infinity, alignment: .top)
            }

            FloatingMorphingTabBar(selection: $selection, namespace: namespace)
        }
        .frame(height: height, alignment: .bottom)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.black.opacity(0.22))
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.14), lineWidth: 0.8)
        }
        .shadow(color: .black.opacity(0.28), radius: 18, y: 8)
        .padding(.horizontal, 14)
        .gesture(drag)
        .onChange(of: selection) { _, _ in
            guard detent == .bar else { return }
            withAnimation(.snappy(duration: 0.32)) {
                detent = .peek
            }
        }
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                dragOffset = value.translation.height
            }
            .onEnded { value in
                let predicted = restingHeight - value.predictedEndTranslation.height
                let next = ChromeDetent.allCases.min {
                    abs($0.height(in: maxHeight) - predicted) < abs($1.height(in: maxHeight) - predicted)
                } ?? .peek
                withAnimation(.snappy(duration: 0.32)) {
                    dragOffset = 0
                    detent = next
                }
            }
    }
}
