import SwiftUI
import AnimateText

/// One `AnimateText` run. The binding starts empty so `onAppear` is a real change.
/// The package animates inside `onChange` of the text, not on the first value.
struct TextStage<E: ATTextAnimateEffect>: View {
    var phrase: String
    var unit: ATUnitType
    var userInfo: Any?

    @State private var text = ""

    var body: some View {
        AnimateText<E>($text, type: unit, userInfo: userInfo)
            .font(.system(size: 32, weight: .semibold, design: .rounded))
            .foregroundStyle(DemoPalette.ink)
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(DemoPalette.canvas)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(phrase)
            .onAppear { text = phrase }
    }
}

/// Switches the generic effect. `AnimateText` is generic, so each case is its own view.
struct MountedEffect: View {
    var effect: BuiltInEffect
    var phrase: String
    var unit: ATUnitType
    var userInfo: Any?
    var identity: String

    var body: some View {
        stage
            .id(identity)
    }

    @ViewBuilder
    private var stage: some View {
        switch effect {
        case .opacity:
            TextStage<ATOpacityEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .scale:
            TextStage<ATScaleEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .blur:
            TextStage<ATBlurEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .slide:
            TextStage<ATSlideEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .offset:
            TextStage<ATOffsetEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .rotate:
            TextStage<ATRotateEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .topBottom:
            TextStage<ATTopBottomEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .bottomTop:
            TextStage<ATBottomTopEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .chain:
            TextStage<ATChainEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .chimeBell:
            TextStage<ATChimeBellEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .curtain:
            TextStage<ATCurtainEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .drop:
            TextStage<ATDropEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .hang:
            TextStage<ATHangEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .paper:
            TextStage<ATPaperEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .spring:
            TextStage<ATSpringEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .twist:
            TextStage<ATTwistEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .randomTypo:
            TextStage<ATRandomTypoEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        case .typo:
            TextStage<ATTypoEffect>(phrase: phrase, unit: unit, userInfo: userInfo)
        }
    }
}

struct EffectsSurface: View {
    @State private var effect: BuiltInEffect = .opacity
    @State private var unit: UnitChoice = .letters
    @State private var letterPhrase = PhraseBook.letters[0]
    @State private var wordPhrase = PhraseBook.words[0]
    @State private var replay = 0

    private var phrase: String {
        unit == .letters ? letterPhrase : wordPhrase
    }

    private var phraseBinding: Binding<String> {
        unit == .letters ? $letterPhrase : $wordPhrase
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MountedEffect(
                effect: effect,
                phrase: phrase,
                unit: unit.unit,
                userInfo: nil,
                identity: "\(effect.rawValue)|\(unit.rawValue)|\(phrase)|\(replay)"
            )

            CallCaption(text: "AnimateText<\(effect.typeName)>($text, type: .\(unit.rawValue))")

            Picker("Effect", selection: $effect) {
                ForEach(BuiltInEffect.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.accent)

            Text(effect.summary)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            unitAndPhrase
            ReplayButton { replay += 1 }
        }
    }

    private var unitAndPhrase: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Unit", selection: $unit) {
                ForEach(UnitChoice.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Picker("Phrase", selection: phraseBinding) {
                ForEach(unit.phrases, id: \.self) { line in
                    Text(line).tag(line)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.accent)
        }
    }
}

struct GlyphsSurface: View {
    @State private var mode: TypoMode = .random
    @State private var unit: UnitChoice = .letters
    @State private var letterPhrase = PhraseBook.letters[0]
    @State private var wordPhrase = PhraseBook.words[0]
    @State private var glyphSet = "ABCDEFG"
    @State private var replay = 0

    private var phrase: String {
        unit == .letters ? letterPhrase : wordPhrase
    }

    private var phraseBinding: Binding<String> {
        unit == .letters ? $letterPhrase : $wordPhrase
    }

    /// `ATTypoEffect` force-casts `userInfo["base"]` when `userInfo` is a dictionary.
    /// An empty set would also make `arc4random_uniform(0)` run inside the modifier.
    private var safeBase: String {
        glyphSet.isEmpty ? "-" : glyphSet
    }

    private var typoInfo: [String: Any] {
        ["base": safeBase]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            stage
            CallCaption(text: call)
            Picker("Glyphs", selection: $mode) {
                ForEach(TypoMode.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Text(modeNote)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            if mode == .fixed {
                TextField("Glyph set", text: $glyphSet)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.body.monospaced())
                    .foregroundStyle(DemoPalette.ink)
                    .padding(10)
                    .background(DemoPalette.canvas, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            Picker("Unit", selection: $unit) {
                ForEach(UnitChoice.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Picker("Phrase", selection: phraseBinding) {
                ForEach(unit.phrases, id: \.self) { line in
                    Text(line).tag(line)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.accent)

            ReplayButton { replay += 1 }
        }
    }

    @ViewBuilder
    private var stage: some View {
        switch mode {
        case .random:
            TextStage<ATRandomTypoEffect>(
                phrase: phrase,
                unit: unit.unit,
                userInfo: nil
            )
            .id("random|\(unit.rawValue)|\(phrase)|\(replay)")
        case .fixed:
            TextStage<ATTypoEffect>(
                phrase: phrase,
                unit: unit.unit,
                userInfo: typoInfo
            )
            .id("fixed|\(unit.rawValue)|\(phrase)|\(safeBase)|\(replay)")
        }
    }

    private var call: String {
        switch mode {
        case .random:
            "AnimateText<ATRandomTypoEffect>($text, type: .\(unit.rawValue))"
        case .fixed:
            "AnimateText<ATTypoEffect>($text, type: .\(unit.rawValue), userInfo: [\"base\": \"\(safeBase)\"])"
        }
    }

    private var modeNote: String {
        switch mode {
        case .random:
            "ATRandomTypoEffect ignores userInfo. The glyph set is the printable ASCII default inside ATRandomTypoAnimation, plus a pad of dashes."
        case .fixed:
            "ATTypoEffect reads userInfo as [String: Any] and uses the \"base\" string. This field is that string."
        }
    }
}

struct CustomSurface: View {
    @State private var unit: UnitChoice = .letters
    @State private var letterPhrase = PhraseBook.letters[0]
    @State private var wordPhrase = PhraseBook.words[0]
    @State private var delay = 0.06
    @State private var replay = 0

    private var phrase: String {
        unit == .letters ? letterPhrase : wordPhrase
    }

    private var phraseBinding: Binding<String> {
        unit == .letters ? $letterPhrase : $wordPhrase
    }

    private var delayText: String {
        String(format: "%.2f", delay)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextStage<StaggerRiseEffect>(
                phrase: phrase,
                unit: unit.unit,
                userInfo: delay
            )
            .id("custom|\(unit.rawValue)|\(phrase)|\(delayText)|\(replay)")

            CallCaption(
                text: "AnimateText<StaggerRiseEffect>($text, type: .\(unit.rawValue), userInfo: \(delayText))"
            )

            Text("StaggerRiseEffect fades and rises. A Double userInfo is the per-index delay. The README sample uses 0.06.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            DemoSlider(title: "Delay", value: $delay, range: 0.02...0.2, step: 0.01)

            Picker("Unit", selection: $unit) {
                ForEach(UnitChoice.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Picker("Phrase", selection: phraseBinding) {
                ForEach(unit.phrases, id: \.self) { line in
                    Text(line).tag(line)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.accent)

            ReplayButton { replay += 1 }
        }
    }
}

struct ReplayButton: View {
    var action: () -> Void

    var body: some View {
        Button("Replay", action: action)
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
    }
}
