import SwiftUI

/// Custom `ButtonStyle` implementations for the gallery.
///
/// Inspired by Mohammad Azam (@azamsharp) — Custom ButtonStyles in SwiftUI
/// https://x.com/azamsharp/status/1864738722647822541
///
/// `ButtonStyle.makeBody` is where you restyle a `Button`. Two values matter:
/// - `configuration.label` — the view the caller put in the button (text, `Label`, etc.)
/// - `configuration.isPressed` — `true` while the finger is down; drive scale, fill, shadow from it
///
/// `configuration.role` is `.destructive` when the `Button` was created with that role.

// MARK: - CapsuleFill

struct CapsuleFillButtonStyle: ButtonStyle {
    var tint: Color = .indigo

    func makeBody(configuration: Configuration) -> some View {
        CapsuleFillBody(configuration: configuration, tint: tint)
    }
}

private struct CapsuleFillBody: View {
    let configuration: ButtonStyleConfiguration
    let tint: Color

    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let metrics = DemoControlMetrics.resolve(controlSize)
        // `configuration.label` is the original button content — wrap it, don't replace it.
        configuration.label
            .font(metrics.font)
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.vertical, metrics.verticalPadding)
            .foregroundStyle(.white)
            .background(fill.opacity(configuration.isPressed ? 0.72 : 1), in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(isEnabled ? 1 : 0.42)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }

    private var fill: Color {
        configuration.role == .destructive ? .red : tint
    }
}

extension ButtonStyle where Self == CapsuleFillButtonStyle {
    static var capsuleFill: CapsuleFillButtonStyle { CapsuleFillButtonStyle() }

    static func capsuleFill(tint: Color) -> CapsuleFillButtonStyle {
        CapsuleFillButtonStyle(tint: tint)
    }
}

// MARK: - ProminentFill (borderedProminent-ish)

struct ProminentFillButtonStyle: ButtonStyle {
    var tint: Color = .blue

    func makeBody(configuration: Configuration) -> some View {
        ProminentFillBody(configuration: configuration, tint: tint)
    }
}

private struct ProminentFillBody: View {
    let configuration: ButtonStyleConfiguration
    let tint: Color

    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let metrics = DemoControlMetrics.resolve(controlSize)
        configuration.label
            .font(metrics.font)
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.vertical, metrics.verticalPadding)
            .foregroundStyle(.white)
            .background(
                fill.opacity(configuration.isPressed ? 0.8 : 1),
                in: RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(configuration.isPressed ? 0.18 : 0.28), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(isEnabled ? 1 : 0.42)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }

    private var fill: Color {
        configuration.role == .destructive ? .red : tint
    }
}

extension ButtonStyle where Self == ProminentFillButtonStyle {
    static var prominentFill: ProminentFillButtonStyle { ProminentFillButtonStyle() }
}

// MARK: - ScaleOnPress

struct ScaleOnPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ScaleOnPressBody(configuration: configuration)
    }
}

private struct ScaleOnPressBody: View {
    let configuration: ButtonStyleConfiguration

    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let metrics = DemoControlMetrics.resolve(controlSize)
        // Several properties keyed off the same `isPressed` flag — scale, shadow, and fill.
        configuration.label
            .font(metrics.font)
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.vertical, metrics.verticalPadding)
            .foregroundStyle(foreground)
            .background(background, in: RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous))
            .shadow(
                color: .black.opacity(configuration.isPressed ? 0.08 : 0.18),
                radius: configuration.isPressed ? 3 : 10,
                y: configuration.isPressed ? 1 : 6
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(isEnabled ? 1 : 0.42)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }

    private var foreground: Color {
        if configuration.role == .destructive { return .red }
        return colorScheme == .dark ? .white : .primary
    }

    private var background: Color {
        colorScheme == .dark ? Color(.secondarySystemGroupedBackground) : .white
    }
}

extension ButtonStyle where Self == ScaleOnPressButtonStyle {
    static var scaleOnPress: ScaleOnPressButtonStyle { ScaleOnPressButtonStyle() }
}

// MARK: - GradientPill

struct GradientPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        GradientPillBody(configuration: configuration)
    }
}

private struct GradientPillBody: View {
    let configuration: ButtonStyleConfiguration

    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let metrics = DemoControlMetrics.resolve(controlSize)
        configuration.label
            .font(metrics.font)
            .padding(.horizontal, metrics.horizontalPadding + 4)
            .padding(.vertical, metrics.verticalPadding)
            .foregroundStyle(.white)
            .background(pillGradient, in: Capsule())
            .brightness(configuration.isPressed ? -0.1 : 0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(isEnabled ? 1 : 0.42)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }

    private var pillGradient: LinearGradient {
        let colors: [Color] = configuration.role == .destructive
            ? [.pink, .red]
            : [.indigo, .teal]
        return LinearGradient(
            colors: colors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

extension ButtonStyle where Self == GradientPillButtonStyle {
    static var gradientPill: GradientPillButtonStyle { GradientPillButtonStyle() }
}

// MARK: - DestructiveOutline

struct DestructiveOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        DestructiveOutlineBody(configuration: configuration)
    }
}

private struct DestructiveOutlineBody: View {
    let configuration: ButtonStyleConfiguration

    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let metrics = DemoControlMetrics.resolve(controlSize)
        let shape = RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
        configuration.label
            .font(metrics.font)
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.vertical, metrics.verticalPadding)
            .foregroundStyle(stroke)
            .background(stroke.opacity(configuration.isPressed ? 0.16 : 0), in: shape)
            .overlay(shape.strokeBorder(stroke, lineWidth: configuration.isPressed ? 2 : 1.5))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(isEnabled ? 1 : 0.42)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }

    private var stroke: Color { .red }
}

extension ButtonStyle where Self == DestructiveOutlineButtonStyle {
    static var destructiveOutline: DestructiveOutlineButtonStyle { DestructiveOutlineButtonStyle() }
}

// MARK: - Press lamp (teaching probe)

/// Tiny style whose only job is to *show* `configuration.isPressed` on screen.
struct PressLampButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(configuration.isPressed ? Color.green : Color.secondary.opacity(0.28))
                .frame(width: 12, height: 12)
            configuration.label
            Spacer(minLength: 8)
            Text(configuration.isPressed ? "isPressed" : "idle")
                .font(.caption.monospaced())
                .foregroundStyle(configuration.isPressed ? Color.green : Color.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        }
        .scaleEffect(configuration.isPressed ? 0.99 : 1)
        .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressLampButtonStyle {
    static var pressLamp: PressLampButtonStyle { PressLampButtonStyle() }
}
