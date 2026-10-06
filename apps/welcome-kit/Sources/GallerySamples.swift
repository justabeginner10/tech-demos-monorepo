import SwiftUI

/// Frozen marketing stand-ins. Live playground owns every WelcomeKit presentation.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case harbor
    case atelier
    case signal
    case centered
    case pinkSlide

    var id: String { rawValue }

    var title: String {
        switch self {
        case .harbor: "Harbor"
        case .atelier: "Atelier"
        case .signal: "Signal"
        case .centered: "Centered"
        case .pinkSlide: "Pink slide"
        }
    }

    var subtitle: String {
        switch self {
        case .harbor: "plain title · monochrome"
        case .atelier: "welcome(to:) · hierarchical"
        case .signal: "whatsNew(in:) · palette"
        case .centered: "titleAlignment.center"
        case .pinkSlide: "accentColor · slide reveal"
        }
    }

    var chips: [String] {
        switch self {
        case .harbor:
            ["welcomeSheetOnFirstLaunch", "monochrome", "Continue"]
        case .atelier:
            [".welcome(to:)", "rounded", "hierarchical"]
        case .signal:
            [".whatsNew(in:)", "serif", "palette"]
        case .centered:
            ["titleAlignment", "footnote", "center"]
        case .pinkSlide:
            ["accentColor", ".slide", "WelcomeConfiguration"]
        }
    }

    @ViewBuilder
    var preview: some View {
        VStack(alignment: .leading, spacing: 8) {
            snapshot
            chipRow
        }
    }

    @ViewBuilder
    private var snapshot: some View {
        switch self {
        case .harbor:
            FrozenWelcomeCard(
                lead: nil,
                name: "Welcome to Harbor",
                tint: Color(red: 0.04, green: 0.52, blue: 0.56),
                rows: LivePreset.harbor.previewRows,
                continueTitle: "Get started",
                footnote: "You can change alerts later in Settings.",
                alignment: .leading
            )
        case .atelier:
            FrozenWelcomeCard(
                lead: "Welcome to",
                name: "Atelier",
                tint: Color(red: 0.82, green: 0.34, blue: 0.10),
                rows: LivePreset.atelier.previewRows,
                continueTitle: "Open the studio",
                footnote: nil,
                alignment: .leading,
                fontDesign: .rounded
            )
        case .signal:
            FrozenWelcomeCard(
                lead: "What’s new in",
                name: "Signal",
                tint: Color(red: 0.33, green: 0.34, blue: 0.82),
                rows: LivePreset.signal.previewRows,
                continueTitle: "See what’s new",
                footnote: "Watch faces update on the next sync.",
                alignment: .leading,
                fontDesign: .serif
            )
        case .centered:
            FrozenWelcomeCard(
                lead: "Welcome to",
                name: "Ova",
                tint: Color(red: 0.10, green: 0.46, blue: 0.82),
                rows: [
                    WelcomePreviewRow("lock.fill", "Private by design", "Everything runs on your device."),
                    WelcomePreviewRow("square.stack.3d.up.fill", "Every model", "Local and cloud, in one place."),
                    WelcomePreviewRow("wrench.and.screwdriver.fill", "Yours to shape", "Agents, prompts, shortcuts."),
                ],
                continueTitle: "Continue",
                footnote: "You can change this later in Settings.",
                alignment: .center
            )
        case .pinkSlide:
            FrozenWelcomeCard(
                lead: nil,
                name: "Welcome to Lark",
                tint: Color(red: 0.86, green: 0.24, blue: 0.48),
                rows: [
                    WelcomePreviewRow("bird.fill", "Short hops", "A route that fits between meetings."),
                    WelcomePreviewRow("bell.fill", "Quiet hours", "Pings wait until you are home."),
                    WelcomePreviewRow("slider.horizontal.3", "Your accent", "Pink symbols, slide reveal."),
                ],
                continueTitle: "Let’s go",
                footnote: nil,
                alignment: .leading
            )
        }
    }

    private var chipRow: some View {
        HStack(spacing: 6) {
            ForEach(chips, id: \.self) { label in
                DemoChrome.chip(label)
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
    }
}

/// Painted welcome sheet. Not `WelcomeView`.
struct FrozenWelcomeCard: View {
    var lead: String?
    var name: String
    var tint: Color
    var rows: [WelcomePreviewRow]
    var continueTitle: String
    var footnote: String?
    var alignment: TextAlignment
    var fontDesign: Font.Design = .default

    var body: some View {
        VStack(alignment: horizontalAlignment, spacing: 16) {
            headline
            VStack(alignment: .leading, spacing: 12) {
                ForEach(rows) { row in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: row.symbol)
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(tint)
                            .frame(width: 28, height: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(DemoPalette.ink)
                            Text(row.subtitle)
                                .font(.caption)
                                .foregroundStyle(DemoPalette.inkMuted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            VStack(spacing: 8) {
                Text(continueTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(tint, in: Capsule())

                if let footnote {
                    Text(footnote)
                        .font(.caption2)
                        .foregroundStyle(DemoPalette.inkMuted)
                        .multilineTextAlignment(alignment)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: frameAlignment)
        .background(DemoPalette.welcomePage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var headline: some View {
        if let lead {
            (Text(lead).foregroundStyle(tint) + Text("\n") + Text(name).foregroundStyle(DemoPalette.ink))
                .font(.system(.title2, design: fontDesign).weight(.bold))
                .multilineTextAlignment(alignment)
        } else {
            Text(name)
                .font(.system(.title2, design: fontDesign).weight(.bold))
                .foregroundStyle(DemoPalette.ink)
                .multilineTextAlignment(alignment)
        }
    }

    private var horizontalAlignment: HorizontalAlignment {
        alignment == .center ? .center : .leading
    }

    private var frameAlignment: Alignment {
        alignment == .center ? .center : .leading
    }
}
