import Foldy
import SwiftUI

/// Live `FoldTransition` driven by `.foldSwipe` plus a slider / Play control.
/// Glass appearance and choreography restyle this one fold — they do not add another.
struct SwipeFoldSurface: View {
    @State private var progress = 0.0
    @State private var appearance: FoldAppearance = .frosted
    @State private var choreography: FoldChoreography = .reveal

    private var style: FoldStyle {
        FoldStyle(appearance: appearance, choreography: choreography)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls

            FoldTransition(progress: progress, style: style) {
                CoverPane()
            } destination: {
                InnerPane()
            }
            .foldSwipe(progress: $progress)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .background(.black, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("FoldTransition")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(familyCaption)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            LabeledContent("Glass") {
                Picker("Appearance", selection: $appearance) {
                    ForEach(FoldAppearance.allCases, id: \.self) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(DemoPalette.ink)
            }
            .foregroundStyle(DemoPalette.ink)

            Picker("Choreography", selection: $choreography) {
                ForEach(FoldChoreography.allCases, id: \.self) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Slider(value: $progress, in: 0 ... 1)
                .tint(DemoPalette.accent)

            HStack(spacing: 10) {
                Button("Play") {
                    withAnimation(.easeInOut(duration: 0.75)) {
                        progress = progress < 0.5 ? 1 : 0
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(DemoPalette.accent)
                .foregroundStyle(Color.black)

                Button("Mid") {
                    withAnimation(.easeInOut(duration: 0.45)) { progress = 0.5 }
                }
                .buttonStyle(.bordered)
                .foregroundStyle(DemoPalette.ink)

                Button("Reset") {
                    withAnimation(.easeOut(duration: 0.35)) { progress = 0 }
                }
                .buttonStyle(.bordered)
                .foregroundStyle(DemoPalette.ink)
            }

            Text(
                "Materials are invisible at rest. Fold to the midpoint to see "
                    + "\(appearance.title.lowercased()) glass. Swipe still works on the pane."
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

    private var familyCaption: String {
        String(format: "p %.2f · %@", progress, choreography.title)
    }
}

/// Live single-view tilt. One `foldEffect` — return to 0° to refresh the snapshot.
struct TiltFoldSurface: View {
    @State private var degrees = 28.0
    @State private var appearance: FoldAppearance = .frosted

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls

            TiltPane(degrees: degrees)
                .foldEffect(angle: .degrees(degrees), style: FoldStyle(appearance: appearance))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                        .allowsHitTesting(false)
                }
                .background(.black, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("foldEffect")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(String(format: "%0.0f°", degrees))
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            LabeledContent("Glass") {
                Picker("Appearance", selection: $appearance) {
                    ForEach(FoldAppearance.allCases, id: \.self) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(DemoPalette.ink)
            }
            .foregroundStyle(DemoPalette.ink)

            Slider(value: $degrees, in: -70 ... 70)
                .tint(DemoPalette.accent)

            HStack(spacing: 10) {
                Button("Rest") {
                    withAnimation(.easeOut(duration: 0.4)) { degrees = 0 }
                }
                .buttonStyle(.borderedProminent)
                .tint(DemoPalette.accent)
                .foregroundStyle(Color.black)

                Button("30°") {
                    withAnimation(.easeInOut(duration: 0.45)) { degrees = 30 }
                }
                .buttonStyle(.bordered)
                .foregroundStyle(DemoPalette.ink)
            }

            Text("Zero shows live content and recaptures. Positive hinges right; negative hinges left.")
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

/// Live `FoldPager`. One internal FoldTransition; swipe left / right to turn.
struct PagerFoldSurface: View {
    @State private var index = 0
    @State private var appearance: FoldAppearance = .midnight

    private let places = PlaceCard.catalog

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls

            FoldPager(
                items: places,
                columns: 1,
                selection: $index,
                style: FoldStyle(appearance: appearance, choreography: .pageTurn)
            ) { place in
                let pageIndex = places.firstIndex(where: { $0.id == place.id }) ?? 0
                PlacePane(place: place, index: pageIndex, count: places.count)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .background(.black, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("FoldPager")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(places[index].title)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            LabeledContent("Glass") {
                Picker("Appearance", selection: $appearance) {
                    ForEach(FoldAppearance.allCases, id: \.self) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(DemoPalette.ink)
            }
            .foregroundStyle(DemoPalette.ink)

            HStack(spacing: 10) {
                Button("Previous") {
                    index = max(index - 1, 0)
                }
                .buttonStyle(.bordered)
                .foregroundStyle(DemoPalette.ink)
                .disabled(index == 0)

                Button("Next") {
                    index = min(index + 1, places.count - 1)
                }
                .buttonStyle(.borderedProminent)
                .tint(DemoPalette.accent)
                .foregroundStyle(Color.black)
                .disabled(index == places.count - 1)
            }

            Text("Swipe left for the next place, right for the previous. One page-turn fold at a time.")
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

#Preview("Swipe fold") {
    SwipeFoldSurface()
        .padding()
        .background(DemoPalette.page)
        .preferredColorScheme(.dark)
}

#Preview("Tilt fold") {
    TiltFoldSurface()
        .padding()
        .background(DemoPalette.page)
        .preferredColorScheme(.dark)
}

#Preview("Pager fold") {
    PagerFoldSurface()
        .padding()
        .background(DemoPalette.page)
        .preferredColorScheme(.dark)
}
