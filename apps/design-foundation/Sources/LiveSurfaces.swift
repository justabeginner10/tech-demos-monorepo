import DesignFoundation
import SwiftUI

/// Preset tiles plus a token-bound preview that re-skins from `.dfThemePreset`.
struct ThemesLiveSurface: View {
    @State private var preset: DemoPreset = .slate
    @State private var isDark = true
    @State private var name = "Ada"
    @State private var poolOn = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                DemoChrome.chartCard(title: LiveFamily.themes.title, subtitle: LiveFamily.themes.subtitle) {
                    VStack(alignment: .leading, spacing: 12) {
                        colorSchemeRow
                        presetGrid
                    }
                    .padding(8)
                }

                DemoChrome.chartCard(title: "Live preview", subtitle: "\(preset.title) · \(isDark ? "dark" : "light")") {
                    IsolatedPresetHost(preset: preset.preset, colorScheme: isDark ? .dark : .light) {
                        ThemedPreviewStrip(name: $name, chipOn: $poolOn, showsField: true)
                    }
                    .id("\(preset.rawValue)-\(isDark)")
                }
            }
            .padding(.bottom, 8)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var colorSchemeRow: some View {
        Toggle(isOn: $isDark) {
            Text("Dark variant")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .tint(Color.white.opacity(0.55))
        .padding(.horizontal, 4)
    }

    private var presetGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(DemoPreset.allCases) { item in
                Button {
                    preset = item
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.swatch(isDark: isDark))
                                .frame(width: 16, height: 16)
                            Text(item.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(DemoPalette.ink)
                            Spacer(minLength: 0)
                        }
                        Text(item.blurb)
                            .font(.caption2)
                            .foregroundStyle(DemoPalette.inkMuted)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        Color.white.opacity(preset == item ? 0.12 : 0.05),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(
                                preset == item ? Color.white.opacity(0.28) : DemoPalette.stroke,
                                lineWidth: 1
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// Curated strip of primitives + inputs. Not the 44-component catalog.
struct ComponentsLiveSurface: View {
    @State private var preset: DemoPreset = .aurora
    @State private var isDark = true
    @State private var name = "Ada"
    @State private var notificationsOn = true
    @State private var poolOn = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                DemoChrome.chartCard(title: LiveFamily.components.title, subtitle: LiveFamily.components.subtitle) {
                    VStack(alignment: .leading, spacing: 8) {
                        Picker("Preset", selection: $preset) {
                            ForEach(DemoPreset.allCases) { item in
                                Text(item.title).tag(item)
                            }
                        }
                        .pickerStyle(.segmented)

                        Toggle("Dark variant", isOn: $isDark)
                            .font(.subheadline)
                            .foregroundStyle(DemoPalette.inkMuted)
                            .tint(Color.white.opacity(0.55))
                    }
                    .padding(8)
                }

                DemoChrome.chartCard(title: "Primitives + inputs", subtitle: preset.title) {
                    IsolatedPresetHost(preset: preset.preset, colorScheme: isDark ? .dark : .light) {
                        ComponentsPreviewStrip(
                            name: $name,
                            notificationsOn: $notificationsOn,
                            poolOn: $poolOn
                        )
                    }
                    .id("\(preset.rawValue)-\(isDark)")
                }
            }
            .padding(.bottom, 8)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

/// Queue toasts on the scene-root `.dfToast()`; present one sheet and one floater.
struct ToastLiveSurface: View {
    @State private var showSheet = false
    @State private var showFloater = false
    @State private var lastUndo = "Idle"

    var body: some View {
        ScrollView {
            DemoChrome.chartCard(title: LiveFamily.toast.title, subtitle: LiveFamily.toast.subtitle) {
                IsolatedThemeHost(theme: .slateDark, colorScheme: .dark) {
                    toastIsland
                }
                .padding(8)
            }
            .padding(.bottom, 8)
        }
        .dfPopup(isPresented: $showSheet, configuration: .sheet(backdrop: .dim)) {
            DFPopupCard(
                icon: "square.and.arrow.up",
                title: "Share project",
                message: "Orbit — 14 tasks. This sheet is `.dfPopup` with `.sheet`.",
                primaryAction: DFPopupAction("Share") { showSheet = false },
                secondaryAction: DFPopupAction("Cancel") { showSheet = false },
                onClose: { showSheet = false }
            )
        }
        .dfPopup(
            isPresented: $showFloater,
            configuration: .floater(position: .bottom, autoDismissAfter: 3.5, dismissOnDrag: true)
        ) {
            DFPopupCard(
                icon: "link",
                iconTint: .soft,
                title: "Link copied",
                message: "Floater at `.bottom`. Drag down or wait to dismiss.",
                primaryAction: DFPopupAction("OK") { showFloater = false }
            )
        }
        .dfPopupStyle(.frosted)
        .dfTheme(.slateDark)
    }

    private var toastIsland: some View {
        ToastIsland(
            lastUndo: lastUndo,
            onSuccess: showSuccessToast,
            onError: showErrorToast,
            onSheet: { showSheet = true },
            onFloater: { showFloater = true }
        )
    }

    private func showSuccessToast() {
        DFToastQueue.shared.show(
            text: "Project saved.",
            icon: "checkmark.circle.fill",
            severity: .success,
            title: "Saved"
        )
    }

    private func showErrorToast() {
        DFToastQueue.shared.show(
            text: "Could not reach the workspace.",
            icon: "exclamationmark.triangle.fill",
            severity: .error,
            title: "Sync failed",
            actionTitle: "Retry",
            action: { lastUndo = "Retried" }
        )
    }
}

private struct ToastIsland: View {
    @Environment(\.dfTheme) private var theme
    let lastUndo: String
    let onSuccess: () -> Void
    let onError: () -> Void
    let onSheet: () -> Void
    let onFloater: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            DFText("Toasts ride the scene-root `.dfToast(style: .filled)`.", scale: .bodySmall)
            DFText("Last retry: \(lastUndo)", scale: .caption)

            HStack(spacing: theme.spacing.sm) {
                DFButton("Success", action: onSuccess)
                DFButton("Error", role: .destructive, action: onError)
            }

            HStack(spacing: theme.spacing.sm) {
                DFButton("Sheet", action: onSheet)
                    .dfButtonStyle(.outlined)
                DFButton("Floater", action: onFloater)
                    .dfButtonStyle(.tinted)
            }

            DFText("Popup modifiers sit outside the presenting view so style and theme apply.", scale: .caption)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.background)
    }
}

/// Shared token-bound sample. Reads `\.dfTheme` so an injected preset re-skins it.
struct ThemedPreviewStrip: View {
    @Environment(\.dfTheme) private var theme
    @Binding var name: String
    @Binding var chipOn: Bool
    var showsField: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            tokenRow

            HStack(spacing: theme.spacing.sm) {
                DFAvatar("DF", presence: .online, accessibilityName: "DesignFoundation")
                DFBadge(text: "New")
                DFBadge(count: 3)
                    .dfBadgeStyle(.tinted)
                Button {
                    chipOn.toggle()
                } label: {
                    DFChip(.selectable("Pool"), isSelected: chipOn)
                        .dfChipStyle(.tinted)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: theme.spacing.sm) {
                DFButton("Primary") {}
                DFButton("Ghost") {}
                    .dfButtonStyle(.ghost)
            }

            DFText("Hero, surfaces, and type all resolve from the nearest DFTheme.", scale: .bodySmall)

            if showsField {
                DFTextField("Name", text: $name, placeholder: "Ada", leading: {
                    Image(systemName: "person")
                })
            }

            DFProgressBar(value: 0.62, label: "Capacity")

            DFCard {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    DFText("Booking", scale: .headline)
                    DFText("Token-bound organism. Isolated from chrome.", scale: .bodySmall)
                }
            }
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.background)
    }

    private var tokenRow: some View {
        HStack(spacing: theme.spacing.sm) {
            TokenSwatch(name: "prim", color: theme.colors.primary)
            TokenSwatch(name: "bg", color: theme.colors.background)
            TokenSwatch(name: "surf", color: theme.colors.surface)
            TokenSwatch(name: "text", color: theme.colors.textPrimary)
        }
    }
}

struct ComponentsPreviewStrip: View {
    @Environment(\.dfTheme) private var theme
    @Binding var name: String
    @Binding var notificationsOn: Bool
    @Binding var poolOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            DFText("Button styles", scale: .label)
            HStack(spacing: theme.spacing.sm) {
                DFButton("Filled") {}
                DFButton("Out") {}
                    .dfButtonStyle(.outlined)
                DFButton("Tint") {}
                    .dfButtonStyle(.tinted)
            }
            DFButton("Ghost") {}
                .dfButtonStyle(.ghost)

            DFTextField("Name", text: $name, placeholder: "Ada", leading: {
                Image(systemName: "person")
            })

            HStack(spacing: theme.spacing.sm) {
                DFChip("Label")
                DFChip(.labelWithIcon("Filter", systemImage: "line.3.horizontal.decrease"))
                    .dfChipStyle(.outlined)
                Button {
                    poolOn.toggle()
                } label: {
                    DFChip(.selectable("Pool"), isSelected: poolOn)
                }
                .buttonStyle(.plain)
            }

            DFToggle("Notifications", isOn: $notificationsOn)

            HStack(spacing: theme.spacing.md) {
                DFProgressBar(value: 0.45, label: "Upload")
                DFProgressBar(variant: .circular, value: 0.7, label: "Sync")
                    .frame(width: 44, height: 44)
            }

            DFCard {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    HStack {
                        DFAvatar("NS", size: 36, presence: .away)
                        DFBadge(text: "Live")
                            .dfBadgeStyle(.outlined)
                    }
                    DFText("Inputs and primitives share the same tokens.", scale: .bodySmall)
                }
            }
            .dfCardStyle(.outlined)

            DFEmptyState(
                icon: "tray",
                title: "No results",
                message: "Try a different filter.",
                actionTitle: "Clear",
                onAction: {}
            )
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.background)
    }
}

private struct TokenSwatch: View {
    @Environment(\.dfTheme) private var theme
    let name: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .fill(color)
                .frame(height: 28)
                .overlay {
                    RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                        .strokeBorder(theme.colors.border, lineWidth: 1)
                }
            Text(name)
                .font(theme.typography.caption.font)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
