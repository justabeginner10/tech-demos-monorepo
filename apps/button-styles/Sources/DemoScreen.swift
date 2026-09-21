import SwiftUI

/// One-screen gallery: live custom `ButtonStyle` / `PrimitiveButtonStyle` examples.
struct DemoScreen: View {
    @State private var isDisabled = false
    @State private var useDestructiveRole = false
    @State private var controlSize: ControlSize = .regular
    @State private var tapLog: [String] = []

    private var role: ButtonRole? { useDestructiveRole ? .destructive : nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    storyHeader
                    playgroundControls
                    ForEach(DemoStyle.allCases) { style in
                        styleCard(style)
                    }
                    howItWorks
                    systemReference
                    footer
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Button Styles")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header

    private var storyHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Custom ButtonStyle in SwiftUI")
                .font(.title3.weight(.semibold))

            Text(
                "A `ButtonStyle` restyles `configuration.label` and can react to "
                    + "`configuration.isPressed`. A `PrimitiveButtonStyle` skips press "
                    + "tracking — you call `configuration.trigger()` yourself."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Controls

    private var playgroundControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Playground")
                .font(.headline)

            Toggle("Disabled", isOn: $isDisabled)

            Toggle("Role: .destructive", isOn: $useDestructiveRole)

            VStack(alignment: .leading, spacing: 6) {
                Text("Control size")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Picker("Control size", selection: $controlSize) {
                    Text("Small").tag(ControlSize.small)
                    Text("Regular").tag(ControlSize.regular)
                    Text("Large").tag(ControlSize.large)
                }
                .pickerStyle(.segmented)
            }

            LabeledContent("Last taps") {
                Text(tapLog.isEmpty ? "—" : tapLog.prefix(3).joined(separator: " · "))
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Text("Toggles apply to every live button below. Size is read from the environment inside each style.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Style cards

    private func styleCard(_ style: DemoStyle) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(style.title)
                    .font(.headline)
                Spacer()
                Text(style.protocolName)
                    .font(.caption.monospaced())
                    .foregroundStyle(.tertiary)
            }

            Text(style.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            liveButton(for: style)
                .disabled(isDisabled)
                .controlSize(controlSize)
                .frame(maxWidth: .infinity)

            Text(style.snippet)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private func liveButton(for style: DemoStyle) -> some View {
        let title = style.sampleTitle
        let symbol = style.symbol
        switch style {
        case .capsuleFill:
            Button(role: role) { ping(style) } label: {
                Label(title, systemImage: symbol)
            }
            .buttonStyle(.capsuleFill)
        case .prominentFill:
            Button(role: role) { ping(style) } label: {
                Label(title, systemImage: symbol)
            }
            .buttonStyle(.prominentFill)
        case .scaleOnPress:
            Button(role: role) { ping(style) } label: {
                Label(title, systemImage: symbol)
            }
            .buttonStyle(.scaleOnPress)
        case .gradientPill:
            Button(role: role) { ping(style) } label: {
                Label(title, systemImage: symbol)
            }
            .buttonStyle(.gradientPill)
        case .destructiveOutline:
            Button(role: role) { ping(style) } label: {
                Label(title, systemImage: symbol)
            }
            .buttonStyle(.destructiveOutline)
        case .confirmTap:
            Button(role: role) { ping(style) } label: {
                Label(title, systemImage: symbol)
            }
            .buttonStyle(.confirmTap)
        }
    }

    // MARK: - How it works

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How it works")
                .font(.headline)

            Text(
                "`ButtonStyleConfiguration` hands you the label and a live press flag. "
                    + "Hold the lamp below — the green state is `configuration.isPressed`."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Button {
                pingLog("Press lamp")
            } label: {
                Text("Press and hold")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.pressLamp)
            .disabled(isDisabled)

            Text(
                """
                configuration.label        // wrap the caller’s label
                configuration.isPressed    // true while the finger is down
                configuration.role         // .destructive when that role is set

                // PrimitiveButtonStyle only — no isPressed:
                configuration.trigger()    // you must call this to fire the action
                """
            )
            .font(.caption.monospaced())
            .foregroundStyle(.secondary)
            .textSelection(.enabled)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var systemReference: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("System styles (for comparison)")
                .font(.headline)

            Text("Same role / disabled / size as the custom gallery.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button("Bordered", role: role) { pingLog("system.bordered") }
                        .buttonStyle(.bordered)
                    Button("Prominent", role: role) { pingLog("system.prominent") }
                        .buttonStyle(.borderedProminent)
                    Button("Plain", role: role) { pingLog("system.plain") }
                        .buttonStyle(.plain)
                }
            }
            .disabled(isDisabled)
            .controlSize(controlSize)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var footer: some View {
        Text(
            "Inspiration: Mohammad Azam (@azamsharp) — Custom ButtonStyles in SwiftUI\n"
                + "https://x.com/azamsharp/status/1864738722647822541\n"
                + "https://youtu.be/R5I7DCNDrD0"
        )
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }

    private func ping(_ style: DemoStyle) {
        pingLog(style.title)
    }

    private func pingLog(_ name: String) {
        tapLog.insert(name, at: 0)
        if tapLog.count > 8 {
            tapLog.removeLast()
        }
    }
}

private enum DemoStyle: String, CaseIterable, Identifiable {
    case capsuleFill
    case prominentFill
    case scaleOnPress
    case gradientPill
    case destructiveOutline
    case confirmTap

    var id: String { rawValue }

    var title: String {
        switch self {
        case .capsuleFill: "CapsuleFill"
        case .prominentFill: "ProminentFill"
        case .scaleOnPress: "ScaleOnPress"
        case .gradientPill: "GradientPill"
        case .destructiveOutline: "DestructiveOutline"
        case .confirmTap: "ConfirmTap"
        }
    }

    var protocolName: String {
        self == .confirmTap ? "PrimitiveButtonStyle" : "ButtonStyle"
    }

    var summary: String {
        switch self {
        case .capsuleFill:
            "Solid capsule. Dims and scales while `isPressed` is true."
        case .prominentFill:
            "Custom stand-in for `.borderedProminent`: filled rounded rect, hairline highlight."
        case .scaleOnPress:
            "Elevated card. Press shrinks scale and collapses the drop shadow."
        case .gradientPill:
            "Indigo→teal capsule. Press darkens via `brightness` keyed off `isPressed`."
        case .destructiveOutline:
            "Red outline that tints on press. Reads as destructive even without a role."
        case .confirmTap:
            "First tap arms, second tap calls `configuration.trigger()`. Auto-cancels after 2.5s."
        }
    }

    var snippet: String {
        switch self {
        case .capsuleFill:
            ".background(fill.opacity(isPressed ? 0.72 : 1), in: Capsule())"
        case .prominentFill:
            ".scaleEffect(configuration.isPressed ? 0.98 : 1)"
        case .scaleOnPress:
            ".scaleEffect(isPressed ? 0.95 : 1) + shadow radius 10 → 3"
        case .gradientPill:
            ".brightness(configuration.isPressed ? -0.1 : 0)"
        case .destructiveOutline:
            ".background(stroke.opacity(isPressed ? 0.16 : 0))"
        case .confirmTap:
            "if armed { configuration.trigger() } else { armed = true }"
        }
    }

    var sampleTitle: String {
        switch self {
        case .capsuleFill: "Continue"
        case .prominentFill: "Save Draft"
        case .scaleOnPress: "Press Me"
        case .gradientPill: "Subscribe"
        case .destructiveOutline: "Delete"
        case .confirmTap: "Erase All"
        }
    }

    var symbol: String {
        switch self {
        case .capsuleFill: "arrow.right"
        case .prominentFill: "square.and.arrow.down"
        case .scaleOnPress: "hand.tap"
        case .gradientPill: "star.fill"
        case .destructiveOutline: "trash"
        case .confirmTap: "exclamationmark.triangle"
        }
    }
}

#Preview("Demo") {
    DemoScreen()
}
