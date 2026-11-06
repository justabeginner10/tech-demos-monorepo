import SwiftUI
import AnimateText

/// One built-in effect, played once on the shared gallery word.
struct EffectCard: View {
    var effect: BuiltInEffect
    var replayToken: Int

    var body: some View {
        DemoChrome.chartCard(title: effect.title, subtitle: effect.group) {
            VStack(alignment: .leading, spacing: 8) {
                MountedEffect(
                    effect: effect,
                    phrase: PhraseBook.gallery,
                    unit: .letters,
                    userInfo: nil,
                    identity: "\(effect.rawValue)|\(replayToken)"
                )
                Text(effect.summary)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    DemoChrome.chip(effect.typeName)
                    DemoChrome.chip(".letters")
                }
            }
        }
    }
}
