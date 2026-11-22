import Pow
import SwiftUI

// MARK: - Effects

/// One `changeEffect` at a time. The watched value is an `Int`, the same pattern as the package examples.
/// Pow fires when that value changes after the view has appeared. The first value does not fire.
struct EffectsSurface: View {
    @State private var effect: ChangeEffectKind = .shake

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Effect", selection: $effect) {
                ForEach(ChangeEffectKind.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            EffectStage(effect: effect)
                .id(effect)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct EffectStage: View {
    var effect: ChangeEffectKind

    @State private var plays: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(effect.title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(effect.api)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Button("Trigger") {
                plays += 1
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
            .foregroundStyle(Color.black)

            Text("changes \(plays)")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)

            Text(effect.summary)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            ZStack {
                triggered(card)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DemoPalette.canvas, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(DemoPalette.accent)
            .frame(width: 132, height: 132)
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: effect.symbol)
                        .font(.system(size: 34, weight: .semibold))
                    Text(effect.title)
                        .font(.headline)
                }
                .foregroundStyle(Color.black)
            }
    }

    /// The stage is not clipped, so jump, glow, and shake can travel outside the card.
    @ViewBuilder
    private func triggered(_ card: some View) -> some View {
        switch effect {
        case .shake:
            card.changeEffect(.shake(rate: .fast), value: plays)
        case .glow:
            card.changeEffect(.glow(color: DemoPalette.accent, radius: 20), value: plays)
        case .jump:
            card.changeEffect(.jump(height: 40), value: plays)
        case .spin:
            card.changeEffect(.spin(axis: (x: 0, y: 1, z: 0), rate: .fast), value: plays)
        case .shine:
            card.changeEffect(.shine, value: plays)
        }
    }
}

// MARK: - Transitions

/// One `AnyTransition.movingParts` transition at a time.
/// Switching the menu replaces the stage, so a half-played transition is removed with it.
struct TransitionsSurface: View {
    @State private var kind: TransitionKind = .boing

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Transition", selection: $kind) {
                ForEach(TransitionKind.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            TransitionStage(kind: kind)
                .id(kind)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct TransitionStage: View {
    var kind: TransitionKind

    @State private var isVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(kind.title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(kind.api)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Button(isVisible ? "Hide" : "Show") {
                withAnimation(kind.animation) {
                    isVisible.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
            .foregroundStyle(Color.black)

            Text(isVisible ? "inserted" : "removed")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)

            Text(kind.summary)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    .frame(width: 132, height: 132)

                if isVisible {
                    transitioned(card)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DemoPalette.canvas, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(DemoPalette.accent)
            .frame(width: 132, height: 132)
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: kind.symbol)
                        .font(.system(size: 34, weight: .semibold))
                    Text(kind.title)
                        .font(.headline)
                }
                .foregroundStyle(Color.black)
            }
    }

    /// Iris and wipe mask their content. `compositingGroup()` matches the package iris example
    /// so the mask applies to the filled card and its symbol together.
    @ViewBuilder
    private func transitioned(_ card: some View) -> some View {
        switch kind {
        case .boing:
            card.transition(boing)
        case .pop:
            card.transition(.movingParts.pop(DemoPalette.accent))
        case .flip:
            card.transition(.movingParts.flip)
        case .iris:
            card
                .compositingGroup()
                .transition(.movingParts.iris(origin: .center, blurRadius: 10))
        case .wipe:
            card
                .compositingGroup()
                .transition(wipe)
        }
    }

    /// Same shape as `BoingExample`: the spring is attached to the transition, and removal
    /// also fades so the squish does not linger.
    private var boing: AnyTransition {
        let spring = Animation.spring(duration: 0.55, bounce: 0.35)
        return .asymmetric(
            insertion: .movingParts.boing(edge: .top).animation(spring),
            removal: .movingParts.boing(edge: .top)
                .animation(spring)
                .combined(with: .opacity.animation(.easeInOut(duration: 0.2)))
        )
    }

    /// Angles are the ones in the `wipe(angle:blurRadius:)` doc comment.
    private var wipe: AnyTransition {
        .asymmetric(
            insertion: .movingParts.wipe(angle: .degrees(45), blurRadius: 10),
            removal: .movingParts.wipe(angle: .degrees(225), blurRadius: 10)
        )
    }
}

private extension TransitionKind {
    /// Drives the `withAnimation` transaction. Boing, pop, and the wipe angles also carry
    /// their own `AnyTransition.animation` from the calls above.
    var animation: Animation {
        switch self {
        case .boing:
            Animation.spring(duration: 0.55, bounce: 0.35)
        case .pop:
            Animation.spring(duration: 0.45, bounce: 0)
        case .flip:
            Animation.spring(duration: 0.6, bounce: 0.35)
        case .iris:
            Animation.spring(duration: 0.5, bounce: 0)
        case .wipe:
            Animation.easeInOut(duration: 0.6)
        }
    }
}
