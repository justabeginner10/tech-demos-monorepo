import SwiftUI

/// `PrimitiveButtonStyle` — you own the gesture. There is **no** `isPressed`.
///
/// Call `configuration.trigger()` when the action should actually fire.
/// This demo arms on the first tap and confirms on the second (or auto-cancels).
struct ConfirmTapButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ConfirmTapBody(configuration: configuration)
    }
}

private struct ConfirmTapBody: View {
    let configuration: PrimitiveButtonStyleConfiguration

    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled

    @State private var isArmed = false

    var body: some View {
        let metrics = DemoControlMetrics.resolve(controlSize)
        VStack(spacing: 6) {
            configuration.label
                .font(metrics.font)
                .padding(.horizontal, metrics.horizontalPadding)
                .padding(.vertical, metrics.verticalPadding)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .background(fill, in: RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous))
                .opacity(isEnabled ? 1 : 0.42)

            Text(isArmed ? "Armed · tap again to confirm" : "PrimitiveButtonStyle · two-tap confirm")
                .font(.caption2)
                .foregroundStyle(isArmed ? Color.orange : Color.secondary)
        }
        .animation(.snappy(duration: 0.2), value: isArmed)
        .contentShape(Rectangle())
        .onTapGesture(perform: handleTap)
        .allowsHitTesting(isEnabled)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isArmed ? "Armed, tap again to confirm" : "Not armed")
        .task(id: isArmed) {
            guard isArmed else { return }
            try? await Task.sleep(for: .seconds(2.5))
            isArmed = false
        }
    }

    private var fill: Color {
        if isArmed { return .orange }
        return configuration.role == .destructive ? .red : .purple
    }

    private func handleTap() {
        if isArmed {
            isArmed = false
            // Fires the Button's action. Without this call, the tap is a no-op.
            configuration.trigger()
        } else {
            isArmed = true
        }
    }
}

extension PrimitiveButtonStyle where Self == ConfirmTapButtonStyle {
    static var confirmTap: ConfirmTapButtonStyle { ConfirmTapButtonStyle() }
}
