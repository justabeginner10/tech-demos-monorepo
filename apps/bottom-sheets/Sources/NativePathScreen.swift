import BottomSheets
import SwiftUI

struct NativePathScreen: View {
    private static let half = BPresentationDetent.medium
    private static let tall = BPresentationDetent.fraction(0.7)

    @State private var isPresented = false
    @State private var forceCustom = false
    @State private var showGrabber = true
    @State private var lockDismiss = false
    @State private var detent: BPresentationDetent = NativePathScreen.half

    var body: some View {
        PageScroll(title: "Native or custom") {
            Text(forceCustom
                 ? "Custom sheet is forced with nativeBottomSheetDisabled(true). Shadow, dim overlay, and overdrag apply on this path."
                 : "iOS 16.4+ uses the system sheet. The same BottomSheets modifiers still set detents, background, radius, grabber, and dismiss lock.")
                .foregroundStyle(Theme.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 4) {
                Toggle("Force custom sheet", isOn: $forceCustom)
                Toggle("Drag indicator", isOn: $showGrabber)
                Toggle("Lock dismiss", isOn: $lockDismiss)
            }
            .tint(Theme.accent)
            .padding(16)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            Label(forceCustom ? "BottomSheetViewModifier" : "System sheet via NativeBottomSheetViewModifier", systemImage: forceCustom ? "wrench.and.screwdriver.fill" : "apple.logo")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.sand.opacity(0.45), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            DemoButton(title: "Show comparison sheet", systemImage: "rectangle.bottomhalf.filled") {
                isPresented = true
            }
        }
        .bottomSheet(
            isPresented: $isPresented,
            [Self.half, Self.tall],
            selection: $detent,
            interaction: .enabled(upThrough: Self.half)
        ) {
            comparisonCard
        }
        .nativeBottomSheetDisabled(forceCustom)
        .onChange(of: forceCustom) { _, _ in
            isPresented = false
        }
    }

    private var comparisonCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(forceCustom ? "Custom implementation" : "Native implementation")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                    Text(detent.description)
                        .font(.caption.monospaced())
                        .foregroundStyle(Theme.secondary)
                }
                Spacer()
                SheetDismissButton { isPresented = false }
            }

            Text(forceCustom
                 ? "Drag past the top detent to feel the 16 pt overdrag. The page behind uses the custom dim color."
                 : "This is the system sheet. Background interaction is enabled through medium. Shadow and overdrag are ignored here.")
                .font(.subheadline)
                .foregroundStyle(Theme.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(detent == Self.half ? "Expand to fraction 0.70" : "Return to medium") {
                detent = detent == Self.half ? Self.tall : Self.half
            }
            .font(.body.weight(.semibold))
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
        }
        .bPresentationDragIndicator(showGrabber ? .visible : .hidden)
        .bPresentationBackground(Theme.cream)
        .bPresentationCornerRadius(24)
        .bInteractiveDismissDisabled(lockDismiss)
        .presentationShadow(color: Theme.ink.opacity(0.25), radius: 14, x: 0, y: -4)
        .presentationContentOverlay(Theme.accent.opacity(0.28))
        .presentationOverDragLimit(16)
    }
}

#Preview {
    NavigationStack {
        NativePathScreen()
    }
    .tint(Theme.accent)
}
