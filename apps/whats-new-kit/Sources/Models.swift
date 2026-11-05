import SwiftUI
import UIKit
import WhatsNewKit

enum LiveFamily: String, CaseIterable, Identifiable {
    case automatic
    case manual
    case view

    var id: String { rawValue }

    var title: String {
        switch self {
        case .automatic: "Automatic"
        case .manual: "Manual"
        case .view: "View"
        }
    }

    var subtitle: String {
        switch self {
        case .automatic: ".whatsNewSheet() · WhatsNewEnvironment"
        case .manual: ".sheet(whatsNew:versionStore:layout:)"
        case .view: "WhatsNewView · WhatsNewViewController"
        }
    }
}

enum ManualStore: String, CaseIterable, Identifiable {
    case userDefaults
    case memory
    case off

    var id: String { rawValue }

    var title: String {
        switch self {
        case .userDefaults: "UserDefaults"
        case .memory: "Memory"
        case .off: "Off"
        }
    }

    var versionStore: (any WhatsNewVersionStore)? {
        switch self {
        case .userDefaults: DemoStores.userDefaults
        case .memory: DemoStores.memory
        case .off: nil
        }
    }
}

enum InstalledVersion: String, CaseIterable, Identifiable {
    case oneZero
    case twoTwo
    case twoTwoOne
    case threeZero

    var id: String { rawValue }

    var title: String {
        switch self {
        case .oneZero: "1.0.0"
        case .twoTwo: "2.2.0"
        case .twoTwoOne: "2.2.1"
        case .threeZero: "3.0.0"
        }
    }

    var detail: String {
        switch self {
        case .oneZero: "exact"
        case .twoTwo: "exact"
        case .twoTwoOne: "patch fallback"
        case .threeZero: "no entry"
        }
    }

    var version: WhatsNew.Version {
        switch self {
        case .oneZero: DemoVersion.oneZero
        case .twoTwo: DemoVersion.twoTwo
        case .twoTwoOne: DemoVersion.twoTwoOne
        case .threeZero: DemoVersion.threeZero
        }
    }
}

enum ManualPreset: String, CaseIterable, Identifiable {
    case harbor
    case atelier
    case signal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .harbor: "Harbor"
        case .atelier: "Atelier"
        case .signal: "Signal"
        }
    }

    var subtitle: String {
        switch self {
        case .harbor: "openURL · notification"
        case .atelier: "present · markdown"
        case .signal: "custom · impact"
        }
    }

    var tint: Color {
        switch self {
        case .harbor: DemoPalette.harbor
        case .atelier: DemoPalette.atelier
        case .signal: DemoPalette.signal
        }
    }

    var version: WhatsNew.Version {
        switch self {
        case .harbor: DemoVersion.oneOne
        case .atelier: DemoVersion.oneTwo
        case .signal: DemoVersion.twoZero
        }
    }

    var primaryTitle: String {
        switch self {
        case .harbor: "Get started"
        case .atelier: "Open the studio"
        case .signal: "See what's new"
        }
    }

    var secondaryTitle: String {
        switch self {
        case .harbor: "Learn more"
        case .atelier: "Release notes"
        case .signal: "Remind me"
        }
    }

    var rows: [FeaturePaint] {
        switch self {
        case .harbor:
            [
                FeaturePaint("water.waves", "Tide tables", "High and low water for this harbor only."),
                FeaturePaint("ferry.fill", "Late ferry", "A ping when the last boat is about to leave."),
                FeaturePaint("map.fill", "Offline charts", "The map stays with you when the signal drops."),
            ]
        case .atelier:
            [
                FeaturePaint("paintbrush.pointed.fill", "Wet paint", "Notes stay on this device until you pin them."),
                FeaturePaint("sun.horizon.fill", "North light", "A quiet palette that still reads at 6am."),
                FeaturePaint("lamp.desk.fill", "One lamp", "Focus mode hides everything but the page."),
            ]
        case .signal:
            [
                FeaturePaint("antenna.radiowaves.left.and.right", "Ridge tower", "Line-of-sight check before you hike."),
                FeaturePaint("battery.100.bolt", "Overnight watch", "Battery use dropped on the long sit."),
                FeaturePaint("mappin.and.ellipse", "Shared pin", "Drop a mark the rest of the watch can see."),
            ]
        }
    }
}

struct FeaturePaint: Identifiable, Hashable {
    var symbol: String
    var title: String
    var subtitle: String

    var id: String { title }

    init(_ symbol: String, _ title: String, _ subtitle: String) {
        self.symbol = symbol
        self.title = title
        self.subtitle = subtitle
    }
}

struct LayoutKnobs {
    var featureListSpacing: Double = 25
    var footerActionSpacing: Double = 15
    var featureImageWidth: Double = 40
    var cornerRadius: Double = 14
    var showIndicators = false

    var layout: WhatsNew.Layout {
        WhatsNew.Layout(
            showsScrollViewIndicators: showIndicators,
            featureListSpacing: featureListSpacing,
            featureImageWidth: featureImageWidth,
            footerActionSpacing: footerActionSpacing,
            footerPrimaryActionButtonCornerRadius: cornerRadius
        )
    }
}

enum DemoVersion {
    static let oneZero = WhatsNew.Version(major: 1, minor: 0, patch: 0)
    static let oneOne = WhatsNew.Version(major: 1, minor: 1, patch: 0)
    static let oneTwo = WhatsNew.Version(major: 1, minor: 2, patch: 0)
    static let twoZero = WhatsNew.Version(major: 2, minor: 0, patch: 0)
    static let twoTwo = WhatsNew.Version(major: 2, minor: 2, patch: 0)
    static let twoTwoOne = WhatsNew.Version(major: 2, minor: 2, patch: 1)
    static let threeZero = WhatsNew.Version(major: 3, minor: 0, patch: 0)
}

enum DemoStores {
    /// Isolated from `UserDefaults.standard` so reset does not touch other keys.
    static let suiteName = "com.techdemos.whatsnewkit"

    static let userDefaults: UserDefaultsWhatsNewVersionStore = {
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        return UserDefaultsWhatsNewVersionStore(userDefaults: defaults)
    }()

    static let memory = InMemoryWhatsNewVersionStore()

    static func descriptions(_ store: some ReadableWhatsNewVersionStore) -> String {
        let versions = store.presentedVersions.sorted().map(\.description)
        return versions.isEmpty ? "none" : versions.joined(separator: ", ")
    }
}

enum DemoCopy {
    static func text(_ markdown: String) -> WhatsNew.Text {
        guard let attributed = try? AttributedString(markdown: markdown) else {
            return WhatsNew.Text(markdown)
        }
        return WhatsNew.Text(attributed)
    }

    static var signalTitle: WhatsNew.Text {
        var nameAttributes = AttributeContainer()
        nameAttributes.foregroundColor = ManualPreset.signal.tint
        let name = AttributedString("Signal", attributes: nameAttributes)
        return WhatsNew.Text(AttributedString("What's New in ") + name)
    }
}

enum DemoCatalog {
    static let releaseNotes = "Field notes stay on this device. SecondaryAction.Action.present put this view on a sheet."

    static func fieldNotesOne(onPrimary: @escaping () -> Void) -> WhatsNew {
        WhatsNew(
            version: DemoVersion.oneZero,
            title: "What's New in Field Notes",
            features: [
                .init(
                    image: .init(systemName: "note.text", foregroundColor: DemoPalette.accent),
                    title: "First page",
                    subtitle: "A sheet for the features in this version."
                ),
                .init(
                    image: .init(systemName: "sparkles", foregroundColor: DemoPalette.accent),
                    title: "Automatic presentation",
                    subtitle: "The environment picks this sheet when the stored versions allow it."
                ),
                .init(
                    image: .init(systemName: "arrow.counterclockwise", foregroundColor: DemoPalette.accent),
                    title: "Stored versions",
                    subtitle: "Reset removes the UserDefaults keys so the sheet can return."
                ),
            ],
            primaryAction: .init(
                title: "Continue",
                backgroundColor: DemoPalette.accent,
                foregroundColor: .white,
                hapticFeedback: .notification(.success),
                onDismiss: onPrimary
            ),
            secondaryAction: .init(
                title: "Learn more",
                foregroundColor: DemoPalette.accent,
                hapticFeedback: .selection,
                action: .openURL(URL(string: "https://github.com/SvenTiigi/WhatsNewKit"))
            )
        )
    }

    static func fieldNotesTwoTwo(onPrimary: @escaping () -> Void) -> WhatsNew {
        WhatsNew(
            version: DemoVersion.twoTwo,
            title: WhatsNew.Title(text: DemoCopy.text("What's **New** in 2.2")),
            features: [
                .init(
                    image: .init(
                        systemName: "square.grid.2x2",
                        renderingMode: .template,
                        symbolRenderingMode: .hierarchical,
                        foregroundColor: DemoPalette.accent
                    ),
                    title: "Layout",
                    subtitle: "Spacing, image width, and the scroll indicator come from the layout value."
                ),
                .init(
                    image: .init(systemName: "hand.tap", foregroundColor: DemoPalette.accent),
                    title: "Two actions",
                    subtitle: "Primary dismisses. Secondary can open a URL, present a view, or run a closure."
                ),
                .init(
                    image: .init(systemName: "number", foregroundColor: DemoPalette.accent),
                    title: "Patch fallback",
                    subtitle: "Version 2.2.1 uses this 2.2.0 sheet when 2.2.0 has not been stored."
                ),
            ],
            primaryAction: .init(
                title: "Continue",
                backgroundColor: DemoPalette.accent,
                foregroundColor: .white,
                hapticFeedback: .notification(.success),
                onDismiss: onPrimary
            ),
            secondaryAction: .init(
                title: "Release notes",
                foregroundColor: DemoPalette.accent,
                hapticFeedback: .selection,
                action: .present {
                    ReleaseNotesSheet(message: "2.2.0 is the minor release the environment falls back to.")
                }
            )
        )
    }

    static func environment(current: WhatsNew.Version, layout: WhatsNew.Layout, onPrimary: @escaping () -> Void) -> WhatsNewEnvironment {
        WhatsNewEnvironment(
            currentVersion: current,
            versionStore: DemoStores.userDefaults,
            defaultLayout: layout,
            whatsNewCollection: {
                fieldNotesOne(onPrimary: onPrimary)
                fieldNotesTwoTwo(onPrimary: onPrimary)
            }
        )
    }

    static func probe(current: WhatsNew.Version) -> WhatsNew.Version? {
        environment(current: current, layout: .init(), onPrimary: {}).whatsNew()?.version
    }

    /// The stored version that is keeping `whatsNew()` from returning a sheet for `current`.
    static func versionToClear(current: WhatsNew.Version) -> WhatsNew.Version? {
        if DemoStores.userDefaults.hasPresented(current) {
            return current
        }
        let minor = WhatsNew.Version(major: current.major, minor: current.minor, patch: 0)
        if minor != current, DemoStores.userDefaults.hasPresented(minor) {
            return minor
        }
        return nil
    }

    static func manual(
        preset: ManualPreset,
        onPrimary: @escaping () -> Void,
        onCustom: @escaping () -> Void
    ) -> WhatsNew {
        WhatsNew(
            version: preset.version,
            title: title(for: preset),
            features: features(for: preset),
            primaryAction: primary(for: preset, onDismiss: onPrimary),
            secondaryAction: secondary(for: preset, onCustom: onCustom)
        )
    }

    static func title(for preset: ManualPreset) -> WhatsNew.Title {
        switch preset {
        case .harbor:
            "What's New in Harbor"
        case .atelier:
            WhatsNew.Title(text: DemoCopy.text("What's **New** in Atelier"))
        case .signal:
            WhatsNew.Title(
                text: DemoCopy.signalTitle,
                foregroundColor: preset.tint
            )
        }
    }

    static func features(for preset: ManualPreset) -> [WhatsNew.Feature] {
        switch preset {
        case .harbor:
            [
                .init(
                    image: .init(systemName: "water.waves", foregroundColor: preset.tint),
                    title: "Tide tables",
                    subtitle: "High and low water for this harbor only."
                ),
                .init(
                    image: .init(systemName: "ferry.fill", foregroundColor: preset.tint),
                    title: "Late ferry",
                    subtitle: "A ping when the last boat is about to leave."
                ),
                .init(
                    image: .init(image: Image(systemName: "map.fill")),
                    title: "Offline charts",
                    subtitle: "The map stays with you when the signal drops."
                ),
            ]
        case .atelier:
            [
                .init(
                    image: .init(
                        systemName: "paintbrush.pointed.fill",
                        renderingMode: nil,
                        symbolRenderingMode: .hierarchical,
                        foregroundColor: preset.tint
                    ),
                    title: "Wet paint",
                    subtitle: DemoCopy.text("Notes stay on this device until you _pin_ them.")
                ),
                .init(
                    image: .init(
                        systemName: "sun.horizon.fill",
                        symbolRenderingMode: .hierarchical,
                        foregroundColor: preset.tint
                    ),
                    title: "North light",
                    subtitle: "A quiet palette that still reads at 6am."
                ),
                .init(
                    image: .init(systemName: "lamp.desk.fill", foregroundColor: preset.tint),
                    title: "One lamp",
                    subtitle: "Focus mode hides everything but the page."
                ),
            ]
        case .signal:
            [
                .init(
                    image: .init {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(preset.tint, Color(red: 0.45, green: 0.78, blue: 0.96))
                            .font(.title)
                    },
                    title: "Ridge tower",
                    subtitle: "Line-of-sight check before you hike."
                ),
                .init(
                    image: .init(
                        systemName: "battery.100.bolt",
                        renderingMode: .original,
                        symbolRenderingMode: .multicolor,
                        foregroundColor: preset.tint
                    ),
                    title: "Overnight watch",
                    subtitle: "Battery use dropped on the long sit."
                ),
                .init(
                    image: .init(systemName: "mappin.and.ellipse", foregroundColor: preset.tint),
                    title: "Shared pin",
                    subtitle: "Drop a mark the rest of the watch can see."
                ),
            ]
        }
    }

    static func primary(for preset: ManualPreset, onDismiss: @escaping () -> Void) -> WhatsNew.PrimaryAction {
        let haptic: WhatsNew.HapticFeedback = switch preset {
        case .harbor: .notification(.success)
        case .atelier: .selection
        case .signal: .impact(style: .medium, intensity: 0.85)
        }
        return WhatsNew.PrimaryAction(
            title: WhatsNew.Text(preset.primaryTitle),
            backgroundColor: preset.tint,
            foregroundColor: .white,
            hapticFeedback: haptic,
            onDismiss: onDismiss
        )
    }

    static func secondary(for preset: ManualPreset, onCustom: @escaping () -> Void) -> WhatsNew.SecondaryAction {
        let action: WhatsNew.SecondaryAction.Action = switch preset {
        case .harbor:
            .openURL(URL(string: "https://github.com/SvenTiigi/WhatsNewKit"))
        case .atelier:
            .present { ReleaseNotesSheet(message: DemoCatalog.releaseNotes) }
        case .signal:
            .custom { _ in onCustom() }
        }
        let haptic: WhatsNew.HapticFeedback = switch preset {
        case .harbor, .atelier: .selection
        case .signal: .impact(style: .light, intensity: nil)
        }
        return WhatsNew.SecondaryAction(
            title: WhatsNew.Text(preset.secondaryTitle),
            foregroundColor: preset.tint,
            hapticFeedback: haptic,
            action: action
        )
    }
}

struct ReleaseNotesSheet: View {
    var message: String

    var body: some View {
        NavigationStack {
            Text(message)
                .font(.body)
                .foregroundStyle(DemoPalette.ink)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(DemoPalette.page)
                .navigationTitle("Release notes")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
