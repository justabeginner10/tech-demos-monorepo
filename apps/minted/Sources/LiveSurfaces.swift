import Minted
import SwiftUI

/// Live `SpinningCoinView` from `CoinDesign`. Silhouette and engraving restyle
/// this one coin — they do not add another SceneKit view.
struct AwardCoinSurface: View {
    @State private var art: AwardArt = .heart
    @State private var silhouette: DemoSilhouette = AwardArt.heart.defaultSilhouette
    @State private var engraving: CoinEngraving = AwardArt.heart.defaultEngraving

    private var design: CoinDesign {
        art.design(silhouette: silhouette, engraving: engraving)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls

            DemoChrome.coinStage {
                SpinningCoinView(design: design)
                    .frame(width: 280, height: 280)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("SpinningCoinView")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text("\(art.title) · \(silhouette.title)")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Picker("Art", selection: $art) {
                ForEach(AwardArt.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: art) { _, newArt in
                silhouette = newArt.defaultSilhouette
                engraving = newArt.defaultEngraving
            }

            LabeledContent("Silhouette") {
                Picker("Silhouette", selection: $silhouette) {
                    ForEach(DemoSilhouette.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(DemoPalette.ink)
            }
            .foregroundStyle(DemoPalette.ink)

            LabeledContent("Engraving") {
                Picker("Engraving", selection: $engraving) {
                    ForEach(CoinEngraving.allCases, id: \.self) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(DemoPalette.ink)
            }
            .foregroundStyle(DemoPalette.ink)

            Text(
                "Cloisonné enamel and arc lettering from CoinDesign. "
                    + "Drag the medallion to flick it. Idle spin resumes after momentum."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }
}

/// Live `SpinningArtworkCoinView` from a bundled `ArtworkCoin.Sample`.
/// Changing the pin remounts this one view (the representable does not remint).
struct PinArtworkSurface: View {
    @State private var sample: ArtworkCoin.Sample = .alhambra

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls

            DemoChrome.coinStage {
                if let coin = try? ArtworkCoin(sample: sample) {
                    SpinningArtworkCoinView(coin: coin)
                        .id(sample)
                        .frame(width: 280, height: 280)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("Could not mint \(sample.title).")
                        .font(.subheadline)
                        .foregroundStyle(DemoPalette.inkMuted)
                }
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("SpinningArtworkCoinView")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(sample.rawValue)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            LabeledContent("Sample pin") {
                Picker("Sample", selection: $sample) {
                    ForEach(ArtworkCoin.Sample.allCases, id: \.self) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(DemoPalette.ink)
            }
            .foregroundStyle(DemoPalette.ink)

            Text(
                "ArtworkCoin(sample:) traces the bundled pin, keys gold as metal, "
                    + "and extrudes a SceneKit medallion. One pin at a time."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }
}

/// Same `SpinningCoinView` contract, started on the die-struck reverse.
struct ReverseCoinSurface: View {
    @State private var showBack = true

    private var design: CoinDesign { CatalogCoins.awardHeart }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls

            DemoChrome.coinStage {
                SpinningCoinView(
                    design: design,
                    initialRotation: showBack ? .pi : 0
                )
                .id(showBack)
                .frame(width: 280, height: 280)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Orange-peel reverse")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(showBack ? "back · π" : "face · 0")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            HStack(spacing: 10) {
                Button("Back") {
                    showBack = true
                }
                .buttonStyle(.borderedProminent)
                .tint(DemoPalette.accent)
                .foregroundStyle(Color.black)
                .disabled(showBack)

                Button("Face") {
                    showBack = false
                }
                .buttonStyle(.bordered)
                .foregroundStyle(DemoPalette.ink)
                .disabled(!showBack)
            }

            Text(
                "SpinningCoinView(design:initialRotation: .pi) presents the "
                    + "die-struck back. Face / Back remounts this one coin."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }
}

#Preview("Award coin") {
    AwardCoinSurface()
        .padding()
        .background(DemoPalette.page)
        .preferredColorScheme(.dark)
}

#Preview("Pin artwork") {
    PinArtworkSurface()
        .padding()
        .background(DemoPalette.page)
        .preferredColorScheme(.dark)
}

#Preview("Reverse coin") {
    ReverseCoinSurface()
        .padding()
        .background(DemoPalette.page)
        .preferredColorScheme(.dark)
}
