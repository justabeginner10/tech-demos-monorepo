import SwiftUI

/// Find My–style chrome demo: a map canvas, a morphing floating tab bar,
/// and a peeking material sheet. Visual recreation only — not a clone.
struct DemoScreen: View {
    @State private var selection: FindMyTab = .devices
    @State private var detent: ChromeDetent = .peek
    @Namespace private var tabMorph

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                MapCanvas(selection: selection)
                    .onTapGesture {
                        withAnimation(FloatingMorphingTabBar.morphSpring) {
                            detent = .bar
                        }
                    }

                VStack(spacing: 10) {
                    HStack {
                        Spacer()
                        RecenterButton {
                            withAnimation(FloatingMorphingTabBar.morphSpring) {
                                selection = .me
                                detent = .peek
                            }
                        }
                    }
                    .padding(.horizontal, 22)

                    FloatingFindMyChrome(
                        selection: $selection,
                        detent: $detent,
                        namespace: tabMorph,
                        maxHeight: proxy.size.height
                    )
                }
            }
        }
        .preferredColorScheme(.dark)
        .sensoryFeedback(.selection, trigger: selection)
        .sensoryFeedback(.impact(weight: .light), trigger: detent)
    }
}

private struct RecenterButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "location.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(Color(red: 0.22, green: 0.72, blue: 0.42).gradient)
                )
                .overlay {
                    Circle()
                        .strokeBorder(.white.opacity(0.28), lineWidth: 0.8)
                }
                .shadow(color: Color(red: 0.22, green: 0.72, blue: 0.42).opacity(0.45), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Recenter on Me")
    }
}

#Preview("Demo") {
    DemoScreen()
}
