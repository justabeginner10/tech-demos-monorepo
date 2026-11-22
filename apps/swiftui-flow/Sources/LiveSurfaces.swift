import Flow
import SwiftUI

/// One flow. Leaving the tab removes it. Chip identity stays stable so insertion and removal can animate.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var axis: FlowAxisChoice = .horizontal
    @State private var horizontal: HorizontalChoice = .leading
    @State private var vertical: VerticalChoice = .center
    @State private var itemSpacingExplicit = true
    @State private var itemSpacing = 8.0
    @State private var lineSpacingExplicit = true
    @State private var lineSpacing = 18.0
    @State private var justified = false
    @State private var distributed = false
    @State private var chips = FlowChip.seed
    @State private var nextID = FlowChip.seed.count
    @State private var nextWord = 0

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
            .navigationTitle("Flow")
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
        FlowWell(isMounted: isSelected, height: 260) {
            liveFlow
        }
    }

    private var liveFlow: some View {
        let layout = currentLayout
        return Group {
            switch layout.axis {
            case .horizontal:
                HFlow(
                    horizontalAlignment: layout.horizontal.alignment,
                    verticalAlignment: layout.vertical.alignment,
                    horizontalSpacing: layout.horizontalSpacing,
                    verticalSpacing: layout.verticalSpacing,
                    justified: layout.justified,
                    distributeItemsEvenly: layout.distributed
                ) {
                    chipRow(layout.chips)
                }
            case .vertical:
                VFlow(
                    horizontalAlignment: layout.horizontal.alignment,
                    verticalAlignment: layout.vertical.alignment,
                    horizontalSpacing: layout.horizontalSpacing,
                    verticalSpacing: layout.verticalSpacing,
                    justified: layout.justified,
                    distributeItemsEvenly: layout.distributed
                ) {
                    chipRow(layout.chips)
                }
            }
        }
        .animation(flowAnimation, value: layout.animationKey)
    }

    private func chipRow(_ chips: [FlowChip]) -> some View {
        ForEach(chips) { chip in
            Button {
                remove(chip.id)
            } label: {
                FlowChipFace(title: chip.title, fill: ChipPalette.color(index: chip.fillIndex))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(chip.title)")
            .transition(.opacity.combined(with: .scale(scale: 0.92)))
        }
    }

    private var callout: some View {
        Text(currentLayout.call())
            .font(.caption2.monospaced())
            .foregroundStyle(DemoPalette.ink)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            segmented("Axis", selection: $axis) { Text($0.title) }
            Text(axisCaption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            segmented("Horizontal alignment", selection: $horizontal) { Text($0.title) }
            segmented("Vertical alignment", selection: $vertical) { Text($0.title) }
            Text(alignmentCaption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            Toggle("Custom item spacing", isOn: $itemSpacingExplicit)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            DemoSlider(
                title: "Item spacing",
                value: $itemSpacing,
                range: 0...32,
                step: 1,
                caption: itemSpacingCaption
            )
            .disabled(!itemSpacingExplicit)

            Toggle("Custom line spacing", isOn: $lineSpacingExplicit)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            DemoSlider(
                title: "Line spacing",
                value: $lineSpacing,
                range: 0...40,
                step: 1,
                caption: lineSpacingCaption
            )
            .disabled(!lineSpacingExplicit)

            Toggle("Justified", isOn: $justified)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            Text("justified stretches the gaps on lines that have more than one item, including the last line. A single-item line stays put. The proposal on the flow axis has to be finite.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            Toggle("Distribute evenly", isOn: $distributed)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            Text("distributeItemsEvenly uses the Knuth–Plass breaker. Off keeps the greedy breaker, which fills earlier lines first.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Button("Add chip", action: addChip)
                    .disabled(chips.count >= 18)
                Button("Remove last", action: removeLast)
                    .disabled(chips.count <= 3)
            }
            .buttonStyle(.bordered)
            .tint(DemoPalette.accent)
            Text(chipCaption)
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

    private var axisCaption: String {
        switch axis {
        case .horizontal:
            "HFlow wraps rows. The stage width is the proposal those rows break on."
        case .vertical:
            "VFlow wraps columns. The 260 pt stage height is the proposal those columns break on."
        }
    }

    private var alignmentCaption: String {
        switch axis {
        case .horizontal:
            "verticalAlignment lines the chips up inside a row. horizontalAlignment shifts a short row against the widest row. Justified rows already fill the proposal, so that shift has nothing left to move."
        case .vertical:
            "horizontalAlignment lines the chips up inside a column. verticalAlignment shifts a short column against the tallest column. Justified columns already fill the 260 pt height."
        }
    }

    private var itemSpacingCaption: String {
        if itemSpacingExplicit {
            let name = axis == .horizontal ? "horizontalSpacing" : "verticalSpacing"
            return "\(name) is \(Int(itemSpacing.rounded())). That is the gap between chips on a line."
        }
        return "Passing nil. The layout uses ViewSpacing between neighbors."
    }

    private var lineSpacingCaption: String {
        if lineSpacingExplicit {
            let name = axis == .horizontal ? "verticalSpacing" : "horizontalSpacing"
            let line = axis == .horizontal ? "row" : "column"
            return "\(name) is \(Int(lineSpacing.rounded())). That is the gap before each \(line) after the first."
        }
        return "Passing nil. Line spacing is the ViewSpacing union of the items on adjacent lines."
    }

    private var chipCaption: String {
        if reduceMotion {
            return "Reduce Motion is on, so the flow is not animated. Tap a chip to remove it. The floor is 3 chips and the ceiling is 18."
        }
        return "Add and remove animate with .snappy. Tap a chip to remove it. The floor is 3 chips and the ceiling is 18."
    }

    private var flowAnimation: Animation? {
        reduceMotion ? nil : .snappy(duration: 0.32)
    }

    private var currentLayout: LiveFlowSettings {
        LiveFlowSettings(
            axis: axis,
            horizontal: horizontal,
            vertical: vertical,
            itemSpacingExplicit: itemSpacingExplicit,
            itemSpacing: itemSpacing,
            lineSpacingExplicit: lineSpacingExplicit,
            lineSpacing: lineSpacing,
            justified: justified,
            distributed: distributed,
            chips: chips
        )
    }

    private func addChip() {
        guard chips.count < 18 else { return }
        let title = FlowWordBank.additions[nextWord % FlowWordBank.additions.count]
        chips.append(FlowChip(id: nextID, title: title, fillIndex: nextID))
        nextID += 1
        nextWord += 1
    }

    private func removeLast() {
        guard chips.count > 3, let last = chips.last else { return }
        remove(last.id)
    }

    private func remove(_ id: Int) {
        guard chips.count > 3 else { return }
        chips.removeAll { $0.id == id }
    }

    private func applyDefaults() {
        axis = .horizontal
        horizontal = .leading
        vertical = .center
        itemSpacingExplicit = false
        lineSpacingExplicit = false
        itemSpacing = 8
        lineSpacing = 18
        justified = false
        distributed = false
        chips = FlowChip.seed
        nextID = FlowChip.seed.count
        nextWord = 0
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
