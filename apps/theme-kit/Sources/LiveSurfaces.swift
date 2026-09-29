import SwiftUI
import ThemeKit

/// ThemePicker plus a token-bound preview that re-skins with `Theme.shared`.
struct ThemesLiveSurface: View {
    @ObservedObject private var shared = Theme.shared
    @State private var active: String?
    @State private var name = "Ada"
    @State private var poolOn = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                DemoChrome.chartCard(title: LiveFamily.themes.title, subtitle: LiveFamily.themes.subtitle) {
                    VStack(alignment: .leading, spacing: 12) {
                        colorSchemeRow
                        ThemePicker(selection: $active, themes: LiveCatalog.pickerPresets)
                            .columns(2)
                            .spacing(8)
                    }
                    .padding(8)
                }

                DemoChrome.chartCard(title: "Live preview", subtitle: active ?? "custom") {
                    ThemedPreviewStrip(name: $name, chipOn: $poolOn, showsField: true)
                        .id(shared.revision)
                }
            }
            .padding(.bottom, 8)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var colorSchemeRow: some View {
        HStack {
            Text("Dark variant")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            ThemeToggle(
                isOn: Binding(
                    get: { shared.isDark },
                    set: { shared.setColorScheme(dark: $0) }
                )
            )
        }
        .padding(.horizontal, 4)
    }
}

/// Short curated strip of token-bound atoms / molecules. Not the 175-count catalog.
struct ComponentsLiveSurface: View {
    @ObservedObject private var shared = Theme.shared
    @State private var name = "Ada"
    @State private var poolOn = true

    var body: some View {
        ScrollView {
            DemoChrome.chartCard(title: LiveFamily.components.title, subtitle: LiveFamily.components.subtitle) {
                ThemedPreviewStrip(name: $name, chipOn: $poolOn, showsField: true)
                    .id(shared.revision)
            }
            .padding(.bottom, 8)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

/// Dial an accent and regenerate the palette on-device. No Figma / MCP / CSS import.
struct GeneratorLiveSurface: View {
    @ObservedObject private var shared = Theme.shared
    @State private var accent = DemoHex.color(DemoHex.violet)
    @State private var hex = DemoHex.violet
    @State private var name = "Ada"
    @State private var poolOn = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                DemoChrome.chartCard(title: LiveFamily.generator.title, subtitle: LiveFamily.generator.subtitle) {
                    VStack(alignment: .leading, spacing: 12) {
                        ColorPicker("Accent", selection: $accent, supportsOpacity: false)
                            .onChange(of: accent) { _, newColor in
                                hex = DemoHex.string(from: newColor)
                                applyGenerated()
                            }

                        HStack(spacing: 8) {
                            Text("#")
                                .font(.body.monospaced())
                                .foregroundStyle(.secondary)
                            TextField("RRGGBB", text: $hex)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                                .font(.body.monospaced())
                                .onSubmit(applyHexField)
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                        HStack(spacing: 8) {
                            ForEach(DemoHex.swatches, id: \.hex) { swatch in
                                Button(swatch.label) {
                                    hex = swatch.hex
                                    accent = DemoHex.color(swatch.hex)
                                    applyGenerated()
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        }

                        Text("Theme.shared.applyGenerated(primaryHex: \"\(DemoHex.normalize(hex))\")")
                            .font(.caption2.monospaced())
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                    .padding(8)
                }

                DemoChrome.chartCard(title: "Live preview", subtitle: "#\(DemoHex.normalize(hex))") {
                    ThemedPreviewStrip(name: $name, chipOn: $poolOn, showsField: true)
                        .id(shared.revision)
                }
            }
            .padding(.bottom, 8)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func applyHexField() {
        let cleaned = DemoHex.normalize(hex)
        guard DemoHex.isRGB(cleaned) else { return }
        hex = cleaned
        accent = DemoHex.color(cleaned)
        applyGenerated()
    }

    private func applyGenerated() {
        let cleaned = DemoHex.normalize(hex)
        guard DemoHex.isRGB(cleaned) else { return }
        shared.applyGenerated(primaryHex: cleaned, dark: shared.isDark)
        shared.persistConfig()
    }
}

/// Shared token-bound sample. Reads `@ThemeContext` so an injected `.theme(_:)` re-skins it.
struct ThemedPreviewStrip: View {
    @ThemeContext private var theme
    @Binding var name: String
    @Binding var chipOn: Bool
    var showsField: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing(.md)) {
            tokenRow

            HStack(spacing: theme.spacing(.sm)) {
                Avatar(.initials("TK"))
                    .size(.md)
                Badge("New")
                    .badgeStyle(.info)
                Badge("Sale")
                    .badgeStyle(.error)
                    .variant(.solid)
                Chip("Pool", isSelected: $chipOn)
                    .icon("drop.fill")
                    .size(.small)
            }

            HStack(spacing: theme.spacing(.sm)) {
                PrimaryButton("Primary") {}
                    .controlSize(.small)
                ThemeButton("Accent") {}
                    .color(.accent)
                    .variant(.solid)
                    .controlSize(.small)
            }

            if showsField {
                TextInput("Name", text: $name)
                    .icon(leading: "person")
                    .placeholder("Ada")
            }

            ProgressBar(value: 0.62)
                .showsPercentage()

            Card("Booking") {
                Text("Hero, surfaces, and type all resolve from the active Theme.")
                    .textStyle(.bodyBase400)
                    .foregroundStyle(theme.text(.textSecondary))
            }
            .subtitle("Token-bound organism")
            .elevation(.soft)
        }
        .padding(theme.spacing(.md))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.background(.bgWhite))
    }

    private var tokenRow: some View {
        HStack(spacing: theme.spacing(.sm)) {
            TokenSwatch(name: "hero", color: theme.foreground(.fgHero))
            TokenSwatch(name: "bg", color: theme.background(.bgWhite))
            TokenSwatch(name: "elev", color: theme.background(.bgElevatorPrimary))
            TokenSwatch(name: "text", color: theme.text(.textPrimary))
        }
    }
}

private struct TokenSwatch: View {
    @ThemeContext private var theme
    let name: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: theme.radius(.sm), style: .continuous)
                .fill(color)
                .frame(height: 28)
                .overlay {
                    RoundedRectangle(cornerRadius: theme.radius(.sm), style: .continuous)
                        .strokeBorder(theme.border(.borderPrimary), lineWidth: 1)
                }
            Text(name)
                .textStyle(.labelSm600)
                .foregroundStyle(theme.text(.textSecondary))
        }
        .frame(maxWidth: .infinity)
    }
}
