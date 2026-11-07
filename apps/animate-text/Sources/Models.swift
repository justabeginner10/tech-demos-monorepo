import SwiftUI
import AnimateText

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case effects
    case glyphs
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .effects: "Effects"
        case .glyphs: "Glyphs"
        case .custom: "Custom"
        }
    }

    var subtitle: String {
        switch self {
        case .effects: "AnimateText<Effect> · ATUnitType"
        case .glyphs: "ATRandomTypoEffect · ATTypoEffect"
        case .custom: "ATTextAnimateEffect · userInfo"
        }
    }
}

enum UnitChoice: String, CaseIterable, Identifiable, Hashable {
    case letters
    case words

    var id: String { rawValue }

    var title: String { rawValue.capitalized }

    var unit: ATUnitType {
        switch self {
        case .letters: .letters
        case .words: .words
        }
    }

    var phrases: [String] {
        switch self {
        case .letters: PhraseBook.letters
        case .words: PhraseBook.words
        }
    }
}

enum PhraseBook {
    static let letters = ["AnimateText", "Typewriter", "SwiftUI", "Ephemeral"]
    static let words = ["Seize the day.", "Be brave.", "Live positive."]
    /// One short word on every gallery card so the effects can be compared.
    static let gallery = "Animate"
}

enum TypoMode: String, CaseIterable, Identifiable, Hashable {
    case random
    case fixed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .random: "Random"
        case .fixed: "Fixed"
        }
    }
}

enum BuiltInEffect: String, CaseIterable, Identifiable, Hashable {
    case opacity
    case scale
    case blur
    case slide
    case offset
    case rotate
    case topBottom
    case bottomTop
    case chain
    case chimeBell
    case curtain
    case drop
    case hang
    case paper
    case spring
    case twist
    case randomTypo
    case typo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .opacity: "Opacity"
        case .scale: "Scale"
        case .blur: "Blur"
        case .slide: "Slide"
        case .offset: "Offset"
        case .rotate: "Rotate"
        case .topBottom: "Top to bottom"
        case .bottomTop: "Bottom to top"
        case .chain: "Chain"
        case .chimeBell: "Chime bell"
        case .curtain: "Curtain"
        case .drop: "Drop"
        case .hang: "Hang"
        case .paper: "Paper"
        case .spring: "Spring"
        case .twist: "Twist"
        case .randomTypo: "Random typo"
        case .typo: "Typo"
        }
    }

    var typeName: String {
        switch self {
        case .opacity: "ATOpacityEffect"
        case .scale: "ATScaleEffect"
        case .blur: "ATBlurEffect"
        case .slide: "ATSlideEffect"
        case .offset: "ATOffsetEffect"
        case .rotate: "ATRotateEffect"
        case .topBottom: "ATTopBottomEffect"
        case .bottomTop: "ATBottomTopEffect"
        case .chain: "ATChainEffect"
        case .chimeBell: "ATChimeBellEffect"
        case .curtain: "ATCurtainEffect"
        case .drop: "ATDropEffect"
        case .hang: "ATHangEffect"
        case .paper: "ATPaperEffect"
        case .spring: "ATSpringEffect"
        case .twist: "ATTwistEffect"
        case .randomTypo: "ATRandomTypoEffect"
        case .typo: "ATTypoEffect"
        }
    }

    var group: String {
        switch self {
        case .opacity, .scale, .blur, .slide, .offset, .rotate, .topBottom, .bottomTop:
            "Basic"
        case .chain, .chimeBell, .curtain, .drop, .hang, .paper, .spring, .twist, .randomTypo, .typo:
            "Advanced"
        }
    }

    /// What the effect's `body` does at tag 0.5.0. Delays are `data.index` times the constant in that file.
    var summary: String {
        switch self {
        case .opacity:
            "Opacity follows data.value. easeInOut, delay index × 0.06."
        case .scale:
            "Opacity and scaleEffect(data.scale). Duration 0.4, delay index × 0.06."
        case .blur:
            "Opacity and blur from 20 down to 0. Duration 0.6, delay index × 0.06."
        case .slide:
            "Opacity and a horizontal offset of the measured width. Spring, delay index × 0.05."
        case .offset:
            "Opacity and a random vertical offset. Duration 0.4, delay index × 0.06."
        case .rotate:
            "Opacity and a 460° spin. easeInOut, delay index × 0.06."
        case .topBottom:
            "Opacity and an upward offset of 3.6 × the measured height. Spring, delay index × 0.09."
        case .bottomTop:
            "Opacity and a downward offset of 3.6 × the measured height. Spring, delay index × 0.09."
        case .chain:
            "Opacity and a −270° turn from the top leading corner. Spring, delay index × 0.08."
        case .chimeBell:
            "Opacity, then a 180° flip on the x axis from the top. Spring response 0.6."
        case .curtain:
            "Opacity and an 80° turn from the top leading corner. Spring, delay index × 0.08."
        case .drop:
            "Scale from 7 to 1, a random spin, blur from 26 to 0, and opacity."
        case .hang:
            "Opacity, then a 180° turn on axis (0, 1, 1) anchored at the top."
        case .paper:
            "Slides by the measured height and flips −180° on the y axis from the leading edge."
        case .spring:
            "Opacity, then a 180° turn on the z axis from the bottom. Spring damping 0.4."
        case .twist:
            "Scale, blur, opacity, a (30, −50) offset, and a full turn. Duration 1 second."
        case .randomTypo:
            "ATRandomTypoAnimation scrambles glyphs, then settles on the real element."
        case .typo:
            "Same scramble. A [String: Any] userInfo must include \"base\". nil keeps \"-\"."
        }
    }
}

/// README-shaped effect. `userInfo` as a `Double` is the per-element delay. Any other value uses 0.06.
///
/// `ATTextAnimateEffect` does not name an actor, but it refines `ViewModifier`, so a Swift 6
/// conformance on the type declaration is inferred onto the main actor. `data`, `userInfo`, and
/// `init` would then be main-actor witnesses for nonisolated requirements. Isolating this
/// conformance keeps those witnesses on the main actor, which is where `AnimateText` creates
/// each effect (`View.body`) and where SwiftUI applies it. Off-main use of the conformance is
/// still rejected.
@MainActor
public struct StaggerRiseEffect: @MainActor ATTextAnimateEffect {
    public var data: ATElementData
    public var userInfo: Any?

    public init(_ data: ATElementData, _ userInfo: Any?) {
        self.data = data
        self.userInfo = userInfo
    }

    public func body(content: Content) -> some View {
        let step = userInfo as? Double ?? 0.06
        content
            .opacity(data.value)
            .offset(y: 18 * data.invValue)
            .animation(.easeInOut.delay(Double(data.index) * step), value: data.value)
    }
}
