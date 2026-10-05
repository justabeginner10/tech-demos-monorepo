import SwiftUI
import WelcomeKit

struct LiveStatusCard: View {
    var preset: LivePreset
    var hasSeenFirstLaunch: Bool

    var body: some View {
        DemoChrome.chartCard(title: "First launch", subtitle: hasSeenFirstLaunch ? "Seen" : "Armed") {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    DemoChrome.chip(hasSeenFirstLaunch ? "hasSeenWelcome yes" : "hasSeenWelcome no")
                    DemoChrome.chip(WelcomeStore.key(for: LivePreset.firstLaunchID))
                }

                Text(statusCopy)
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var statusCopy: String {
        if hasSeenFirstLaunch {
            return "\(preset.title) already ran. Show welcome again presents the same sheet without touching the flag. Reset arms first launch."
        }
        return "\(preset.title) will present on first appear. Continue writes \(WelcomeStore.key(for: LivePreset.firstLaunchID))."
    }
}

/// Compact painted stand-in of the selected preset. The live sheet is WelcomeKit itself.
struct LivePreviewCard: View {
    var preset: LivePreset

    var body: some View {
        DemoChrome.chartCard(title: preset.title, subtitle: preset.subtitle) {
            FrozenWelcomeCard(
                lead: preset.leadLabel,
                name: preset.nameLabel,
                tint: preset.tint,
                rows: preset.previewRows,
                continueTitle: preset.continueLabel,
                footnote: preset.footnoteLabel,
                alignment: .leading
            )
        }
    }
}
