import SwiftUI
import UIKit

// MARK: - Shared stage

private struct PayloadEditor: View {
    @Binding var text: String

    var body: some View {
        TextField("Text to encode", text: $text, axis: .vertical)
            .lineLimit(2...4)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .font(.body.monospaced())
            .foregroundStyle(DemoPalette.ink)
            .padding(10)
            .background(DemoPalette.canvas, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct CodeStage: View {
    var image: UIImage?
    var caption: String
    var detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)

                if let image {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                } else {
                    Text("Generate to draw a code.")
                        .font(.subheadline)
                        .foregroundStyle(Color.black.opacity(0.55))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }

            if !caption.isEmpty {
                Text(caption)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            if !detail.isEmpty {
                Text(detail)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.ink)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private struct GenerateButton: View {
    var title: String
    var disabled: Bool
    var action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
            .foregroundStyle(Color.black)
            .disabled(disabled)
    }
}

private struct InkMenu: View {
    var title: String
    @Binding var ink: InkChoice

    var body: some View {
        Picker(title, selection: $ink) {
            ForEach(InkChoice.allCases) { item in
                Text(item.title).tag(item)
            }
        }
        .pickerStyle(.menu)
        .tint(DemoPalette.ink)
    }
}

// MARK: - Content

/// Text, correction level, package-default basic style, then `Recognizer`.
struct ContentSurface: View {
    @State private var text = QRRendering.sampleText
    @State private var correction: CorrectionChoice = .h
    @State private var image: UIImage?
    @State private var caption = ""
    @State private var detail = ""
    @State private var encoded = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Default basic")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)

                PayloadEditor(text: $text)

                Picker("Correction", selection: $correction) {
                    ForEach(CorrectionChoice.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                Text("EFStyleBasicParams() · errorCorrectLevel \(correction.api). The Generator default is .h.")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)

                HStack(spacing: 10) {
                    GenerateButton(title: "Generate", disabled: trimmed.isEmpty, action: generate)
                    Button("Recognize") { recognize() }
                        .buttonStyle(.bordered)
                        .tint(DemoPalette.ink)
                        .disabled(image == nil)
                }
            }
            .demoCard()

            CodeStage(image: image, caption: caption, detail: detail)
        }
    }

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func generate() {
        detail = ""
        do {
            let code = try QRRendering.generateDefaultBasic(text: trimmed, correction: correction)
            image = code.image
            caption = code.caption
            encoded = trimmed
        } catch {
            image = nil
            caption = ""
            encoded = ""
            detail = QRRendering.message(for: error)
        }
    }

    private func recognize() {
        guard let image else {
            detail = "Generate a code first."
            return
        }
        let contents = QRRendering.recognize(image)
        if contents == encoded {
            detail = "Matched.\n\(contents)"
        } else {
            detail = contents
        }
    }
}

// MARK: - Styles

/// One `EFQRCodeStyle` case at a time, built from that case's params type.
struct StylesSurface: View {
    @State private var text = QRRendering.sampleText
    @State private var knobs = StyleKnobs(dataShape: .round)
    @State private var correction: CorrectionChoice = .h
    @State private var image: UIImage?
    @State private var caption = ""
    @State private var detail = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                Text(knobs.kind.api)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)

                PayloadEditor(text: $text)

                Picker("Style", selection: $knobs.kind) {
                    ForEach(QRStyleKind.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .tint(DemoPalette.ink)
                .onChange(of: knobs.kind) { _, kind in
                    applySuggestions(for: kind)
                }

                Text(knobs.kind.blurb)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)

                styleControls

                GenerateButton(title: "Generate", disabled: trimmed.isEmpty, action: generate)
            }
            .demoCard()

            CodeStage(image: image, caption: caption, detail: detail)
        }
    }

    @ViewBuilder
    private var styleControls: some View {
        switch knobs.kind {
        case .basic:
            InkMenu(title: "Modules", ink: $knobs.foreground)
            InkMenu(title: "Backdrop", ink: $knobs.background)
            shapeMenu
            positionMenu
            DemoSlider(
                title: "Data scale",
                value: scaleBinding,
                range: 0.5 ... 1,
                step: 0.05,
                format: "%.2f"
            )
        case .image:
            InkMenu(title: "Backdrop", ink: $knobs.background)
            fillToggle
            modeMenu
        case .bubble:
            InkMenu(title: "Bubble", ink: $knobs.foreground)
            InkMenu(title: "Center", ink: $knobs.background)
            positionMenu
        case .line:
            InkMenu(title: "Line", ink: $knobs.foreground)
            InkMenu(title: "Backdrop", ink: $knobs.background)
            lineMenu
            positionMenu
            DemoSlider(
                title: "Thickness",
                value: thicknessBinding,
                range: 0.15 ... 1,
                step: 0.05,
                format: "%.2f"
            )
        case .d25:
            InkMenu(title: "Faces", ink: $knobs.foreground)
            InkMenu(title: "Backdrop", ink: $knobs.background)
            DemoSlider(
                title: "Data height",
                value: dataHeightBinding,
                range: 0.4 ... 1.4,
                step: 0.1,
                format: "%.1f"
            )
            DemoSlider(
                title: "Position height",
                value: positionHeightBinding,
                range: 0.4 ... 1.4,
                step: 0.1,
                format: "%.1f"
            )
        case .dsj:
            InkMenu(title: "Backdrop", ink: $knobs.background)
            positionMenu
            Text("Data colors stay on EFStyleDSJParamsData defaults. Position color stays on defaultColor.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        case .function:
            Picker("Function", selection: $knobs.function) {
                ForEach(FunctionRecipe.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
            InkMenu(title: "Data", ink: $knobs.foreground)
            InkMenu(title: "Backdrop", ink: $knobs.background)
            positionMenu
            Text("Circle's second color is Tide. Fade uses the data color only.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        case .imageFill:
            InkMenu(title: "Background", ink: $knobs.background)
            fillToggle
            modeMenu
            Text("maskColor stays on EFStyleImageFillParams.defaultMaskColor.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        case .randomRectangle:
            InkMenu(title: "Color", ink: $knobs.foreground)
            InkMenu(title: "Backdrop", ink: $knobs.background)
        case .resampleImage:
            InkMenu(title: "Fallback", ink: $knobs.foreground)
            InkMenu(title: "Backdrop", ink: $knobs.background)
            fillToggle
            modeMenu
            DemoSlider(
                title: "Contrast",
                value: contrastBinding,
                range: -1 ... 1,
                step: 0.1,
                format: "%.1f"
            )
            DemoSlider(
                title: "Exposure",
                value: exposureBinding,
                range: -1 ... 1,
                step: 0.1,
                format: "%.1f"
            )
        }

        Text("errorCorrectLevel \(correction.api). Styles keeps the package default.")
            .font(.caption.monospaced())
            .foregroundStyle(DemoPalette.inkMuted)
    }

    private var shapeMenu: some View {
        Picker("Data", selection: $knobs.dataShape) {
            ForEach(BasicDataShape.allCases) { item in
                Text(item.title).tag(item)
            }
        }
        .pickerStyle(.menu)
        .tint(DemoPalette.ink)
    }

    private var positionMenu: some View {
        Picker("Position", selection: $knobs.position) {
            ForEach(PositionShape.allCases) { item in
                Text(item.title).tag(item)
            }
        }
        .pickerStyle(.menu)
        .tint(DemoPalette.ink)
    }

    private var lineMenu: some View {
        Picker("Direction", selection: $knobs.lineDirection) {
            ForEach(LineDirectionChoice.allCases) { item in
                Text(item.title).tag(item)
            }
        }
        .pickerStyle(.menu)
        .tint(DemoPalette.ink)
    }

    private var modeMenu: some View {
        Picker("Image mode", selection: $knobs.imageMode) {
            ForEach(ImageModeChoice.allCases) { item in
                Text(item.title).tag(item)
            }
        }
        .pickerStyle(.menu)
        .tint(DemoPalette.ink)
    }

    private var fillToggle: some View {
        Toggle("Fill image", isOn: $knobs.useFillImage)
            .font(.subheadline)
            .foregroundStyle(DemoPalette.ink)
            .tint(DemoPalette.accent)
    }

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var scaleBinding: Binding<Double> {
        Binding(
            get: { Double(knobs.dataScale) },
            set: { knobs.dataScale = CGFloat($0) }
        )
    }

    private var thicknessBinding: Binding<Double> {
        Binding(
            get: { Double(knobs.lineThickness) },
            set: { knobs.lineThickness = CGFloat($0) }
        )
    }

    private var dataHeightBinding: Binding<Double> {
        Binding(
            get: { Double(knobs.dataHeight) },
            set: { knobs.dataHeight = CGFloat($0) }
        )
    }

    private var positionHeightBinding: Binding<Double> {
        Binding(
            get: { Double(knobs.positionHeight) },
            set: { knobs.positionHeight = CGFloat($0) }
        )
    }

    private var contrastBinding: Binding<Double> {
        Binding(
            get: { Double(knobs.contrast) },
            set: { knobs.contrast = CGFloat($0) }
        )
    }

    private var exposureBinding: Binding<Double> {
        Binding(
            get: { Double(knobs.exposure) },
            set: { knobs.exposure = CGFloat($0) }
        )
    }

    private func applySuggestions(for kind: QRStyleKind) {
        switch kind {
        case .basic:
            knobs.foreground = .black
            knobs.background = .white
            knobs.dataShape = .round
            knobs.position = .rectangle
        case .image, .imageFill, .resampleImage:
            knobs.foreground = .black
            knobs.background = .white
            knobs.useFillImage = true
            knobs.imageMode = .scaleAspectFill
        case .bubble:
            knobs.foreground = .tide
            knobs.background = .white
            knobs.position = .round
        case .line:
            knobs.foreground = .black
            knobs.background = .white
            knobs.lineDirection = .x
            knobs.lineThickness = 0.5
            knobs.position = .rectangle
        case .d25:
            knobs.foreground = .black
            knobs.background = .white
            knobs.dataHeight = 1
            knobs.positionHeight = 1
        case .dsj:
            knobs.background = .white
            knobs.position = .dsj
        case .function:
            knobs.foreground = .ember
            knobs.background = .paper
            knobs.position = .round
            knobs.function = .fade
        case .randomRectangle:
            knobs.foreground = .moss
            knobs.background = .white
        }
    }

    private func generate() {
        detail = ""
        do {
            let code = try QRRendering.generate(
                text: trimmed,
                correction: correction,
                knobs: knobs
            )
            image = code.image
            caption = "\(knobs.kind.api) · \(code.caption)"
        } catch {
            image = nil
            caption = ""
            detail = QRRendering.message(for: error)
        }
    }
}

// MARK: - Marks

/// Icon and backdrop image on the basic style. High correction is the default.
struct MarksSurface: View {
    @State private var text = QRRendering.sampleText
    @State private var correction: CorrectionChoice = .h
    @State private var knobs = StyleKnobs(
        foreground: .black,
        background: .paper,
        includeIcon: true,
        includeBackdropImage: false
    )
    @State private var image: UIImage?
    @State private var caption = ""
    @State private var detail = ""
    @State private var encoded = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Icon and backdrop")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)

                PayloadEditor(text: $text)

                Picker("Correction", selection: $correction) {
                    ForEach(CorrectionChoice.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                InkMenu(title: "Modules", ink: $knobs.foreground)
                InkMenu(title: "Backdrop", ink: $knobs.background)

                Toggle("Center icon", isOn: $knobs.includeIcon)
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.ink)
                    .tint(DemoPalette.accent)

                if knobs.includeIcon {
                    DemoSlider(
                        title: "Icon %",
                        value: iconBinding,
                        range: 0.12 ... 0.33,
                        step: 0.01,
                        format: "%.2f"
                    )
                }

                Toggle("Backdrop image", isOn: $knobs.includeBackdropImage)
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.ink)
                    .tint(DemoPalette.accent)

                Picker("Image mode", selection: $knobs.imageMode) {
                    ForEach(ImageModeChoice.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .tint(DemoPalette.ink)

                Text(
                    "EFStyleParamIcon percentage is clamped at 0.33 inside the package. "
                        + "The backdrop image is EFStyleParamBackdropImage, alpha 0.45. "
                        + "Basic getParamImages returns that picture as nil watermark."
                )
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

                HStack(spacing: 10) {
                    GenerateButton(title: "Generate", disabled: trimmed.isEmpty, action: generate)
                    Button("Recognize") { recognize() }
                        .buttonStyle(.bordered)
                        .tint(DemoPalette.ink)
                        .disabled(image == nil)
                }
            }
            .demoCard()

            CodeStage(image: image, caption: caption, detail: detail)
        }
    }

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var iconBinding: Binding<Double> {
        Binding(
            get: { Double(knobs.iconPercentage) },
            set: { knobs.iconPercentage = CGFloat($0) }
        )
    }

    private func generate() {
        detail = ""
        var request = knobs
        request.kind = .basic
        do {
            let code = try QRRendering.generate(
                text: trimmed,
                correction: correction,
                knobs: request
            )
            image = code.image
            caption = code.caption
            encoded = trimmed
        } catch {
            image = nil
            caption = ""
            encoded = ""
            detail = QRRendering.message(for: error)
        }
    }

    private func recognize() {
        guard let image else {
            detail = "Generate a code first."
            return
        }
        let contents = QRRendering.recognize(image)
        if contents == encoded {
            detail = "Matched.\n\(contents)"
        } else {
            detail = contents
        }
    }
}
