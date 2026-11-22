import RichTextKit
import UIKit

enum LiveFamily: String, CaseIterable, Identifiable {
    case editor
    case format
    case preview

    var id: String { rawValue }

    var title: String {
        switch self {
        case .editor: "Editor"
        case .format: "Format"
        case .preview: "Preview"
        }
    }

    var subtitle: String {
        switch self {
        case .editor: "RichTextEditor · RichTextKeyboardToolbar · RichTextFormat.Toolbar"
        case .format: "RichTextFormat.Sidebar · RichTextFormat.Sheet"
        case .preview: "RichTextViewer"
        }
    }
}

enum GalleryFamily: String, CaseIterable, Identifiable {
    case harbor
    case fieldNote
    case margin

    var id: String { rawValue }

    var title: String {
        switch self {
        case .harbor: "Harbor"
        case .fieldNote: "Field note"
        case .margin: "Margin"
        }
    }

    var subtitle: String {
        switch self {
        case .harbor: "RichTextViewer"
        case .fieldNote: "RichTextViewer"
        case .margin: "RichTextViewer"
        }
    }

    var chips: [String] {
        switch self {
        case .harbor:
            ["bold", "italic", "underline", "strikethrough", "center", "right"]
        case .fieldNote:
            ["italic", "Georgia", "center", "foreground"]
        case .margin:
            ["justified", "background", "bold"]
        }
    }

    /// `NSAttributedString` is not `Sendable`. The samples live on the main actor.
    @MainActor
    var text: NSAttributedString {
        switch self {
        case .harbor: SampleRichText.harbor
        case .fieldNote: SampleRichText.fieldNote
        case .margin: SampleRichText.margin
        }
    }
}

/// Format controls shared by the toolbar, the sheet, and the sidebar.
@MainActor
enum DemoFormat {
    static var toolbar: RichTextFormat.ToolbarConfig {
        .init(
            alignments: .defaultPickerValues,
            colorPickers: [.foreground, .background],
            colorPickersDisclosed: [.underline, .strikethrough],
            fontPicker: true,
            fontSizePicker: true,
            indentButtons: true,
            lineSpacingPicker: false,
            styles: .all,
            superscriptButtons: false
        )
    }
}

/// Seed strings are `NSAttributedString` instances, which are not `Sendable`.
/// They stay on the main actor with the views that draw them.
@MainActor
enum SampleRichText {
    static let harbor = makeHarbor()
    static let fieldNote = makeFieldNote()
    static let margin = makeMargin()

    private static let ink = UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1)
    private static let teal = UIColor(red: 0.05, green: 0.42, blue: 0.48, alpha: 1)
    private static let clay = UIColor(red: 0.72, green: 0.28, blue: 0.12, alpha: 1)
    private static let wash = UIColor(red: 1, green: 0.88, blue: 0.55, alpha: 1)

    private static func makeHarbor() -> NSAttributedString {
        let text = NSMutableAttributedString()
        text.append(run(
            "Harbor notes\n",
            font: .systemFont(ofSize: 22, weight: .bold),
            color: ink,
            alignment: .left
        ))
        text.append(mixedBody())
        text.append(run(
            "Centered, set in Georgia.\n",
            font: named("Georgia", size: 18, fallback: .italicSystemFont(ofSize: 18)),
            color: teal,
            alignment: .center
        ))
        text.append(run(
            "Right aligned, with a background wash.",
            font: .systemFont(ofSize: 16, weight: .semibold),
            color: clay,
            alignment: .right,
            background: wash
        ))
        return text
    }

    private static func makeFieldNote() -> NSAttributedString {
        let text = NSMutableAttributedString()
        text.append(run(
            "Field note\n",
            font: .systemFont(ofSize: 20, weight: .bold),
            color: ink,
            alignment: .left
        ))
        text.append(run(
            "The tide line moved overnight.\n",
            font: named("Georgia", size: 17, fallback: .italicSystemFont(ofSize: 17)),
            color: teal,
            alignment: .center
        ))
        text.append(run(
            "— dock ledger",
            font: .systemFont(ofSize: 15, weight: .medium),
            color: clay,
            alignment: .right
        ))
        return text
    }

    private static func makeMargin() -> NSAttributedString {
        let text = NSMutableAttributedString()
        text.append(run(
            "Margin\n",
            font: .systemFont(ofSize: 20, weight: .bold),
            color: ink,
            alignment: .left
        ))
        text.append(run(
            "A justified paragraph keeps the same attributed string the editor is bound to. The highlight is a background color on this sentence.",
            font: .systemFont(ofSize: 16),
            color: ink,
            alignment: .justified,
            background: wash
        ))
        return text
    }

    private static func mixedBody() -> NSAttributedString {
        let paragraph = paragraphStyle(.left)
        let text = NSMutableAttributedString()

        func piece(
            _ string: String,
            _ font: UIFont,
            color: UIColor = ink,
            extra: [NSAttributedString.Key: Any] = [:]
        ) {
            var attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: paragraph
            ]
            for (key, value) in extra {
                attributes[key] = value
            }
            text.append(NSAttributedString(string: string, attributes: attributes))
        }

        piece("The ", .systemFont(ofSize: 17))
        piece("RichTextEditor", .italicSystemFont(ofSize: 17))
        piece(" edits an ", .systemFont(ofSize: 17))
        piece("NSAttributedString", .systemFont(ofSize: 17), extra: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        piece(" through a ", .systemFont(ofSize: 17))
        piece("plain", .systemFont(ofSize: 17), extra: [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue
        ])
        piece(" ", .systemFont(ofSize: 17))
        piece("RichTextContext", .systemFont(ofSize: 17, weight: .bold), color: teal)
        piece(".\n", .systemFont(ofSize: 17))
        return text
    }

    private static func run(
        _ string: String,
        font: UIFont,
        color: UIColor,
        alignment: NSTextAlignment,
        background: UIColor? = nil
    ) -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle(alignment)
        ]
        if let background {
            attributes[.backgroundColor] = background
        }
        return NSAttributedString(string: string, attributes: attributes)
    }

    private static func paragraphStyle(_ alignment: NSTextAlignment) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        style.paragraphSpacing = 10
        return style
    }

    private static func named(_ name: String, size: CGFloat, fallback: UIFont) -> UIFont {
        UIFont(name: name, size: size) ?? fallback
    }
}
