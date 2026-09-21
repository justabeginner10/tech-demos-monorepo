import SwiftUI

struct DemoScreen: View {
    @State private var selection: FindMyTab = .devices
    @State private var detent: ChromeDetent = .peek
    @Namespace private var tabMorph

    var body: some View {
        GeometryReader { proxy in
            let bottomInset = proxy.safeAreaInsets.bottom

            ZStack(alignment: .bottom) {
                MapCanvas(selection: selection)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.32)) {
                            detent = .bar
                        }
                    }

                VStack(spacing: 12) {
                    HStack {
                        Spacer()
                        RecenterButton {
                            withAnimation(.snappy(duration: 0.32)) {
                                selection = .me
                                detent = .peek
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    FloatingFindMyChrome(
                        selection: $selection,
                        detent: $detent,
                        namespace: tabMorph,
                        maxHeight: proxy.size.height
                    )
                }
                .padding(.bottom, max(bottomInset, 8))
            }
        }
        .preferredColorScheme(.dark)
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
                .background(Circle().fill(Color(red: 0.22, green: 0.72, blue: 0.42)))
                .shadow(color: .black.opacity(0.35), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Recenter on Me")
    }
}

#Preview("Demo") {
    DemoScreen()
}
