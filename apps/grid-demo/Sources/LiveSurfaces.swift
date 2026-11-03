import ExyteGrid
import SwiftUI

/// One grid. Leaving the tab removes it. Identifiable tiles keep their identity while the layout animates.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var recipe: TrackRecipe = .fractions
    @State private var contentMode: ContentModeChoice = .fill
    @State private var flow: FlowChoice = .rows
    @State private var packing: PackingChoice = .sparse
    @State private var horizontalSpacing = 5.0
    @State private var verticalSpacing = 5.0
    @State private var count = 12.0
    @State private var focusColumnSpan = 1.0
    @State private var focusRowSpan = 1.0
    @State private var itemAlignment: GridAlignment = .center
    @State private var animates = true

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                stage
                callout
                ScrollView {
                    controls
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DemoPalette.page)
            .navigationTitle("Grid")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
        }
    }

    private var stage: some View {
        GridWell(isMounted: isSelected, height: 240) {
            liveGrid
        }
    }

    private var liveGrid: some View {
        let layout = currentLayout
        let animationEnabled = animates && !reduceMotion
        return ExyteGrid.Grid(
            layout.tiles,
            tracks: layout.recipe.tracks,
            contentMode: layout.contentMode.mode,
            flow: layout.flow.flow,
            packing: layout.packing.packing,
            spacing: layout.spacing,
            commonItemsAlignment: layout.itemAlignment
        ) { tile in
            let span = layout.placement(for: tile.index)
            TileFace(title: tile.title, fill: TilePalette.color(index: tile.index))
                .gridSpan(column: span.column, row: span.row)
        }
        .gridAnimation(animationEnabled ? Animation.default : nil)
    }

    private var callout: some View {
        Text(currentLayout.call(animationEnabled: animates && !reduceMotion))
            .font(.caption2.monospaced())
            .foregroundStyle(DemoPalette.ink)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            segmented("Tracks", selection: $recipe) { Text($0.title) }
            Text(recipeCaption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            segmented("Content mode", selection: $contentMode) { Text($0.title) }
            Text("Init contentMode wins over .gridContentMode. Scroll grows along the flow. Fill shares the stage.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            segmented("Flow", selection: $flow) { Text($0.title) }
            Text("Rows fix the column count. Columns fix the row count. tracks: is that fixed axis.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            segmented("Packing", selection: $packing) { Text($0.title) }
            Text("Wide spans the fixed axis, so a hole sits beside A. Dense can place a later cell back into that hole.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            alignmentPicker

            DemoSlider(
                title: "Cells",
                value: $count,
                range: 4...16,
                step: 1,
                caption: "Grid(tiles) uses Identifiable ids, so added cells keep a stable identity."
            )
            DemoSlider(
                title: "F column span",
                value: $focusColumnSpan,
                range: 1...Double(LiveGridMetrics.trackCount),
                step: 1,
                caption: "gridSpan(column:row:) on F. Column is the horizontal axis."
            )
            DemoSlider(
                title: "F row span",
                value: $focusRowSpan,
                range: 1...2,
                step: 1,
                caption: "Row span taller than the hole stays on the forward path."
            )
            DemoSlider(
                title: "Horizontal spacing",
                value: $horizontalSpacing,
                range: 0...28,
                step: 1,
                caption: "GridSpacing(horizontal:vertical:). The default literal is 5."
            )
            DemoSlider(
                title: "Vertical spacing",
                value: $verticalSpacing,
                range: 0...28,
                step: 1,
                caption: "An Int spacing literal sets both axes. [horizontal, vertical] is the array form."
            )

            Toggle("Animate layout", isOn: $animates)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            Text(animationCaption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            Button("Package defaults") {
                applyDefaults()
            }
            .buttonStyle(.bordered)
            .tint(DemoPalette.accent)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
        .padding(.bottom, 8)
    }

    private var alignmentPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Item alignment")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Picker("Item alignment", selection: $itemAlignment) {
                Text("Center").tag(GridAlignment.center)
                Text("Leading").tag(GridAlignment.leading)
                Text("Top").tag(GridAlignment.top)
                Text("Bottom trailing").tag(GridAlignment.bottomTrailing)
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.ink)
            Text("commonItemsAlignment. Default is .center. A per-cell .gridItemAlignment wins over this.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var recipeCaption: String {
        switch recipe {
        case .fractions:
            "tracks: 3 builds three .fr(1) tracks. Constants.defaultFractionSize is 1."
        case .points:
            ".pt tracks stay that many points on the fixed axis."
        case .fit:
            ".fit uses the cell text. .fr(1) takes the space the fit tracks leave."
        }
    }

    private var animationCaption: String {
        if reduceMotion {
            return "Reduce Motion is on, so .gridAnimation(nil) is passed."
        }
        if animates {
            return ".gridAnimation(Animation.default) runs on the grid's inner stack."
        }
        return ".gridAnimation(nil) leaves placement changes unanimated."
    }

    private var currentLayout: LiveLayout {
        LiveLayout(
            recipe: recipe,
            contentMode: contentMode,
            flow: flow,
            packing: packing,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            count: Int(count.rounded()),
            focusColumnSpan: Int(focusColumnSpan.rounded()),
            focusRowSpan: Int(focusRowSpan.rounded()),
            itemAlignment: itemAlignment
        )
    }

    private func applyDefaults() {
        recipe = .fractions
        contentMode = .fill
        flow = .rows
        packing = .sparse
        horizontalSpacing = 5
        verticalSpacing = 5
        count = 12
        focusColumnSpan = 1
        focusRowSpan = 1
        itemAlignment = .center
        animates = true
    }

    private func segmented<Choice: Hashable, Label: View>(
        _ title: String,
        selection: Binding<Choice>,
        @ViewBuilder label: @escaping (Choice) -> Label
    ) -> some View where Choice: CaseIterable & Identifiable, Choice.AllCases: RandomAccessCollection {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Picker(title, selection: selection) {
                ForEach(Array(Choice.allCases)) { choice in
                    label(choice).tag(choice)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
