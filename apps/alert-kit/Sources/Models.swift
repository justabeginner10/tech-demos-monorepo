import AlertKit
import UIKit

/// `present(view:)` completion and the SwiftUI modifier completion are plain `() -> Void`.
/// `UIView.animate` runs its completion on the main thread, so `MainActor.assumeIsolated`
/// is the synchronous hop back to SwiftUI state.
enum AlertEventSink {
    nonisolated static func finished(
        _ body: @escaping @MainActor () -> Void
    ) -> () -> Void {
        {
            MainActor.assumeIsolated {
                body()
            }
        }
    }
}

enum IconChoice: String, CaseIterable, Identifiable, Hashable {
    case done
    case error
    case heart
    case spinnerSmall
    case spinnerLarge
    case symbol
    case message

    var id: String { rawValue }

    var name: String {
        switch self {
        case .done: "Done"
        case .error: "Error"
        case .heart: "Heart"
        case .spinnerSmall: "Spinner small"
        case .spinnerLarge: "Spinner large"
        case .symbol: "Star"
        case .message: "Message"
        }
    }

    var alertTitle: String {
        switch self {
        case .done: "Added to Library"
        case .error: "Couldn't Add"
        case .heart: "Loved"
        case .spinnerSmall, .spinnerLarge: "Syncing"
        case .symbol: "Starred"
        case .message: "Saved"
        }
    }

    /// Argument passed as `icon:`. Message-only is `nil`.
    var call: String {
        switch self {
        case .done: ".done"
        case .error: ".error"
        case .heart: ".heart"
        case .spinnerSmall: ".spinnerSmall"
        case .spinnerLarge: ".spinnerLarge"
        case .symbol: ".custom(UIImage(systemName: \"star.fill\"))"
        case .message: "nil"
        }
    }

    var isSpinner: Bool {
        self == .spinnerSmall || self == .spinnerLarge
    }

    var sketch: SketchIcon {
        switch self {
        case .done: .done
        case .error: .error
        case .heart: .heart
        case .spinnerSmall, .spinnerLarge: .spinner
        case .symbol: .symbol
        case .message: .message
        }
    }
}

enum IconValue {
    case ready(AlertIcon?)
    case missingSymbol
}

enum StyleChoice: String, CaseIterable, Identifiable, Hashable {
    case banner
    case center

    var id: String { rawValue }

    var name: String {
        switch self {
        case .banner: "iOS 17"
        case .center: "iOS 16"
        }
    }

    var value: AlertViewStyle {
        switch self {
        case .banner: .iOS17AppleMusic
        case .center: .iOS16AppleMusic
        }
    }

    var call: String {
        switch self {
        case .banner: ".iOS17AppleMusic"
        case .center: ".iOS16AppleMusic"
        }
    }

    var typeName: String {
        switch self {
        case .banner: "AlertAppleMusic17View"
        case .center: "AlertAppleMusic16View"
        }
    }

    var sketch: SketchStyle {
        switch self {
        case .banner: .banner
        case .center: .center
        }
    }
}

enum HapticChoice: String, CaseIterable, Identifiable, Hashable {
    case unset
    case success
    case warning
    case error
    case none

    var id: String { rawValue }

    var name: String {
        switch self {
        case .unset: "Unset"
        case .success: "Success"
        case .warning: "Warning"
        case .error: "Error"
        case .none: "None"
        }
    }

    /// `nil` skips `impact()`. `AlertHaptic.none` calls `impact()` and then returns.
    /// A bare `.none` in an `AlertHaptic?` position is `nil`.
    var value: AlertHaptic? {
        switch self {
        case .unset: nil
        case .success: .success
        case .warning: .warning
        case .error: .error
        case .none: AlertHaptic.none
        }
    }

    var call: String {
        switch self {
        case .unset: "nil"
        case .success: ".success"
        case .warning: ".warning"
        case .error: ".error"
        // `AlertHaptic?` makes a bare `.none` Optional.none, which is nil.
        case .none: "AlertHaptic.none"
        }
    }
}

struct AlertDraft: Equatable {
    var icon: IconChoice = .done
    var style: StyleChoice = .banner
    var haptic: HapticChoice = .success
    var showsSubtitle = false
    var duration = 1.5
    var dismissByTap = true
    var dismissInTime = true
    var whiteInk = false
    var largeTitle = false

    var subtitle: String? {
        showsSubtitle ? "Favorites" : nil
    }

    var subtitleCall: String {
        showsSubtitle ? "\"Favorites\"" : "nil"
    }

    /// `present(title:style:)` does not return the view. An iOS 16 spinner from that call
    /// cannot be dismissed: `dismissAllAlerts` only sees `AlertAppleMusic17View`.
    var blocksCenterSpinner: Bool {
        style == .center && icon.isSpinner
    }

    func iconValue() -> IconValue {
        switch icon {
        case .done:
            return .ready(.done)
        case .error:
            return .ready(.error)
        case .heart:
            return .ready(.heart)
        case .spinnerSmall:
            return .ready(.spinnerSmall)
        case .spinnerLarge:
            return .ready(.spinnerLarge)
        case .message:
            return .ready(nil)
        case .symbol:
            guard let image = UIImage(systemName: "star.fill") else {
                return .missingSymbol
            }
            return .ready(.custom(image))
        }
    }

    var apiCall: String {
        "AlertKitAPI.present(title: \"\(icon.alertTitle)\", subtitle: \(subtitleCall), icon: \(icon.call), style: \(style.call), haptic: \(haptic.call))"
    }

    var viewCall: String {
        "\(style.typeName)(title: \"\(icon.alertTitle)\", subtitle: \(subtitleCall), icon: \(icon.call))"
    }

    func makeBanner() -> AlertAppleMusic17View? {
        guard case .ready(let icon) = iconValue() else { return nil }
        let view = AlertAppleMusic17View(
            title: self.icon.alertTitle,
            subtitle: subtitle,
            icon: icon
        )
        applyBanner(view)
        return view
    }

    func makeCenter() -> AlertAppleMusic16View? {
        guard case .ready(let icon) = iconValue() else { return nil }
        let view = AlertAppleMusic16View(
            title: self.icon.alertTitle,
            subtitle: subtitle,
            icon: icon
        )
        applyCenter(view)
        return view
    }

    private func applyBanner(_ view: AlertAppleMusic17View) {
        view.duration = duration
        view.dismissByTap = dismissByTap
        view.dismissInTime = dismissInTime
        view.haptic = haptic.value
        paint(view.titleLabel, view.subtitleLabel, view.iconView)
    }

    private func applyCenter(_ view: AlertAppleMusic16View) {
        view.duration = duration
        view.dismissByTap = dismissByTap
        view.dismissInTime = dismissInTime
        view.haptic = haptic.value
        paint(view.titleLabel, view.subtitleLabel, view.iconView)
    }

    private func paint(_ titleLabel: UILabel?, _ subtitleLabel: UILabel?, _ iconView: UIView?) {
        if whiteInk {
            titleLabel?.textColor = .white
            subtitleLabel?.textColor = .white
            iconView?.tintColor = .white
        }
        if largeTitle {
            titleLabel?.font = UIFont.systemFont(ofSize: 21)
        }
    }
}

enum MountedAlert {
    case banner(AlertAppleMusic17View)
    case center(AlertAppleMusic16View)

    var token: ObjectIdentifier {
        switch self {
        case .banner(let view):
            ObjectIdentifier(view)
        case .center(let view):
            ObjectIdentifier(view)
        }
    }

    func dismiss() {
        switch self {
        case .banner(let view):
            view.dismiss()
        case .center(let view):
            view.dismiss()
        }
    }
}
