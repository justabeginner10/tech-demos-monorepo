import Flow
import SwiftUI

private enum GalleryData {
    static let columnTitles = ["alpha", "beta", "longer", "gamma", "delta", "fit", "epsilon", "zeta"]

    static let lineTitles = [
        "mercury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune",
        "pluto", "ceres", "io", "europa",
    ]

    static let lazyChips: [FlowChip] = (0..<28).map { index in
        let title = FlowWordBank.additions[index % FlowWordBank.additions.count]
        return FlowChip(id: index, title: "\(title) \(index + 1)", fillIndex: index)
    }

    static let blocks: [(String, CGFloat)] = [
        ("A", 88),
        ("B", 46),
        ("C", 72),
        ("D", 104),
        ("E", 54),
        ("F", 80),
        ("G", 42),
        ("H", 96),
    ]
}

struct TagCloudCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(
            title: "Tag cloud",
            subtitle: "HFlow(horizontalAlignment: .center, verticalAlignment: .top)"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                FlowWell(isMounted: isMounted, height: 168) {
                    HFlow(horizontalAlignment: .center, verticalAlignment: .top) {
                        chip("SwiftUI", index: 0, verticalPadding: 6)
                        chip("Flow", index: 1, verticalPadding: 14)
                        chip("wrap", index: 2, verticalPadding: 4)
                        chip("tags", index: 3, verticalPadding: 12)
                        chip("rows", index: 4, verticalPadding: 6)
                        chip("HFlow", index: 5, verticalPadding: 16)
                        chip("center", index: 6, verticalPadding: 5)
                        chip("top", index: 7, verticalPadding: 10)
                    }
                }
                caption("Spacing is omitted, so both axes use ViewSpacing. Short rows sit in the center. Chips in a row share the top guide.")
                chipRow([".center", ".top", "spacing nil"])
            }
        }
    }
}

struct VerticalFlowCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(
            title: "Columns",
            subtitle: "VFlow(alignment: .leading, itemSpacing: 8, columnSpacing: 16)"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                FlowWell(isMounted: isMounted, height: 200) {
                    VFlow(alignment: .leading, itemSpacing: 8, columnSpacing: 16) {
                        ForEach(Array(GalleryData.columnTitles.enumerated()), id: \.offset) { index, title in
                            chip(title, index: index, verticalPadding: index.isMultiple(of: 2) ? 6 : 14)
                        }
                    }
                }
                caption("The single-alignment initializer is horizontal. itemSpacing runs down a column. columnSpacing is the gap between columns. The 200 pt height is what makes it wrap.")
                chipRow([".leading", "item 8", "column 16"])
            }
        }
    }
}

struct RowAlignmentCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Row alignment", subtitle: "HFlow(alignment:)") {
            VStack(alignment: .leading, spacing: 8) {
                alignmentRow(isMounted: isMounted, title: "Top", alignment: .top)
                alignmentRow(isMounted: isMounted, title: "Center", alignment: .center)
                alignmentRow(isMounted: isMounted, title: "Bottom", alignment: .bottom)
                alignmentRow(isMounted: isMounted, title: "First text baseline", alignment: .firstTextBaseline)
                caption("alignment: on HFlow is the vertical guide. HFlowLayout stores that guide and uses horizontalAlignment .leading.")
                chipRow([".top", ".center", ".bottom", ".firstTextBaseline"])
            }
        }
    }

    private func alignmentRow(isMounted: Bool, title: String, alignment: VerticalAlignment) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            FlowWell(isMounted: isMounted, height: 78) {
                HFlow(alignment: alignment, spacing: 8) {
                    chip("Aa", index: 0, verticalPadding: 4)
                    chip("tall", index: 1, verticalPadding: 16)
                    chip("row", index: 2, verticalPadding: 8)
                }
            }
        }
    }
}

struct SpacingCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Spacing", subtitle: "HFlow(itemSpacing: 4, rowSpacing: 20)") {
            VStack(alignment: .leading, spacing: 8) {
                FlowWell(isMounted: isMounted, height: 168) {
                    HFlow(itemSpacing: 4, rowSpacing: 20) {
                        ForEach(0..<8, id: \.self) { index in
                            FlowBlock(title: String(index + 1), width: 56, fill: ChipPalette.color(index: index))
                        }
                    }
                }
                caption("itemSpacing is the gap inside a row. rowSpacing is the gap before every row after the first. spacing: would set both.")
                chipRow(["item 4", "row 20"])
            }
        }
    }
}

struct JustifiedCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Justified", subtitle: "HFlow(spacing: 8, justified: true)") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Off")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                justifiedFlow(isMounted: isMounted, justified: false)
                Text("On")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                justifiedFlow(isMounted: isMounted, justified: true)
                caption("Leftover width is split across the gaps between visible items. Lines with one item are skipped. The last line is included.")
                chipRow(["justified: false", "justified: true", "spacing 8"])
            }
        }
    }

    private func justifiedFlow(isMounted: Bool, justified: Bool) -> some View {
        FlowWell(isMounted: isMounted, height: 120) {
            HFlow(spacing: 8, justified: justified) {
                ForEach(0..<6, id: \.self) { index in
                    FlowBlock(title: String(index + 1), width: 58, fill: ChipPalette.color(index: index))
                }
            }
        }
    }
}

struct DistributedCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Distribute", subtitle: "HFlow(distributeItemsEvenly: true)") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Greedy")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                distributedFlow(isMounted: isMounted, evenly: false)
                Text("Even")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                distributedFlow(isMounted: isMounted, evenly: true)
                caption("The same eight widths. Greedy fills the first rows. Even minimizes the empty space left in each row and keeps order.")
                chipRow(["distributeItemsEvenly: false", "true"])
            }
        }
    }

    private func distributedFlow(isMounted: Bool, evenly: Bool) -> some View {
        FlowWell(isMounted: isMounted, height: 150) {
            HFlow(spacing: 8, distributeItemsEvenly: evenly) {
                ForEach(Array(GalleryData.blocks.enumerated()), id: \.offset) { index, block in
                    FlowBlock(title: block.0, width: block.1, fill: ChipPalette.color(index: index))
                }
            }
        }
    }
}

struct FlexibilityCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Flexibility", subtitle: ".flexibility(.minimum) · .natural · .maximum") {
            VStack(alignment: .leading, spacing: 8) {
                FlowWell(isMounted: isMounted, height: 132) {
                    HFlow(spacing: 8) {
                        flexible("Min", index: 1, behavior: .minimum)
                        flexible("Nat", index: 2, behavior: .natural)
                        flexible("Nat", index: 4, behavior: .natural)
                        flexible("Max", index: 3, behavior: .maximum)
                    }
                }
                caption("Each block is minWidth 44 and maxWidth .infinity. Minimum stays rigid. Natural shares leftover space. Maximum can take a row of its own.")
                chipRow([".minimum", ".natural", ".maximum"])
            }
        }
    }

    private func flexible(_ title: String, index: Int, behavior: FlexibilityBehavior) -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(ChipPalette.color(index: index))
            .frame(minWidth: 44, maxWidth: .infinity)
            .frame(height: 40)
            .overlay {
                Text(title)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.white)
            }
            .flexibility(behavior)
    }
}

struct MaxLinesCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Line limit", subtitle: ".maxLines(2) { hidden in }") {
            VStack(alignment: .leading, spacing: 8) {
                FlowWell(isMounted: isMounted, height: 120) {
                    HFlow(spacing: 6) {
                        ForEach(Array(GalleryData.lineTitles.enumerated()), id: \.offset) { index, title in
                            chip(title, index: index, verticalPadding: 6)
                        }
                    }
                    .maxLines(2) { hidden in
                        Text("+\(hidden)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(DemoPalette.ink)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.12), in: Capsule())
                    }
                    .frame(maxWidth: 280, alignment: .leading)
                }
                caption("Items past the second row stay in the line break, then drop out of view. The overflow builder is hidden when nothing is hidden. The count is the hidden items.")
                chipRow(["maxLines 2", "overflow"])
            }
        }
    }
}

struct SeparatorsCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(
            title: "Separators",
            subtitle: ".itemSeparator · .lineSeparator · ItemSeparator"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                FlowWell(isMounted: isMounted, height: 150) {
                    HFlow(spacing: 8) {
                        ForEach(0..<6, id: \.self) { index in
                            chip("\(index + 1)", index: index, verticalPadding: 6)
                        }
                    }
                    .itemSeparator {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(DemoPalette.inkMuted)
                    }
                    .lineSeparator {
                        Divider()
                    }
                }
                FlowWell(isMounted: isMounted, height: 64) {
                    HFlow(itemSpacing: 4, rowSpacing: 8) {
                        chip("Ink", index: 0, verticalPadding: 6)
                        ItemSeparator {
                            Text("·")
                                .foregroundStyle(DemoPalette.inkMuted)
                        }
                        chip("Paper", index: 1, verticalPadding: 6)
                        chip("Type", index: 2, verticalPadding: 6)
                    }
                }
                caption("The modifiers draw between items and between lines, never on the outer edge. ItemSeparator replaces the automatic item separator at that one boundary.")
                chipRow(["itemSeparator", "lineSeparator", "ItemSeparator"])
            }
        }
    }
}

struct BreaksCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Breaks", subtitle: "LineBreak() · .startInNewLine()") {
            VStack(alignment: .leading, spacing: 8) {
                Text("LineBreak")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                FlowWell(isMounted: isMounted, height: 96) {
                    HFlow(spacing: 8) {
                        chip("red", index: 1, verticalPadding: 6)
                        chip("green", index: 2, verticalPadding: 6)
                        chip("blue", index: 0, verticalPadding: 6)
                        LineBreak()
                        chip("yellow", index: 3, verticalPadding: 6)
                    }
                }
                Text("startInNewLine")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                FlowWell(isMounted: isMounted, height: 96) {
                    HFlow(spacing: 8) {
                        chip("red", index: 1, verticalPadding: 6)
                        chip("green", index: 2, verticalPadding: 6)
                            .startInNewLine()
                        chip("blue", index: 0, verticalPadding: 6)
                        chip("yellow", index: 3, verticalPadding: 6)
                    }
                }
                caption("LineBreak is an empty child that ends the line. startInNewLine forces that child onto a new line. Both win over fitting.")
                chipRow(["LineBreak()", ".startInNewLine()"])
            }
        }
    }
}

struct LayoutTypeCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(
            title: "Layout",
            subtitle: "HFlowLayout(alignment:itemSpacing:rowSpacing:) · VFlowLayout(alignment:itemSpacing:columnSpacing:)"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Text("HFlowLayout")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                FlowWell(isMounted: isMounted, height: 140) {
                    HFlowLayout(alignment: .top, itemSpacing: 8, rowSpacing: 12) {
                        chip("layout", index: 0, verticalPadding: 6)
                        chip("cache", index: 4, verticalPadding: 14)
                        chip("rows", index: 5, verticalPadding: 6)
                        chip("place", index: 2, verticalPadding: 10)
                        chip("size", index: 3, verticalPadding: 6)
                    }
                }
                Text("VFlowLayout")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                FlowWell(isMounted: isMounted, height: 160) {
                    VFlowLayout(alignment: .leading, itemSpacing: 8, columnSpacing: 12) {
                        chip("layout", index: 0, verticalPadding: 6)
                        chip("cache", index: 4, verticalPadding: 14)
                        chip("columns", index: 5, verticalPadding: 6)
                        chip("place", index: 2, verticalPadding: 10)
                        chip("size", index: 3, verticalPadding: 6)
                    }
                }
                caption("HFlowLayout and VFlowLayout are the Layout types. HFlow and VFlow are the views that own one. FlowLayoutCache is the public cache type the protocol requires.")
                chipRow(["HFlowLayout", "VFlowLayout", "FlowLayoutCache"])
            }
        }
    }
}

struct DirectionCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Direction", subtitle: ".environment(\\.layoutDirection, .rightToLeft)") {
            VStack(alignment: .leading, spacing: 8) {
                FlowWell(isMounted: isMounted, height: 120) {
                    HFlow(spacing: 8) {
                        ForEach(1..<7, id: \.self) { index in
                            chip(String(index), index: index, verticalPadding: 6)
                        }
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                }
                caption("The same HFlow. The leading edge is on the right, and the first chip starts there.")
                chipRow([".rightToLeft"])
            }
        }
    }
}

struct LazyFlowCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Lazy", subtitle: "LazyHFlow(data:spacing:) · LazyVFlow(data:spacing:)") {
            VStack(alignment: .leading, spacing: 8) {
                Text("LazyHFlow")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                FlowWell(isMounted: isMounted, height: 180) {
                    ScrollView {
                        LazyHFlow(data: GalleryData.lazyChips, spacing: 8) { chip in
                            FlowChipFace(title: chip.title, fill: ChipPalette.color(index: chip.fillIndex))
                        }
                    }
                }
                Text("LazyVFlow")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                FlowWell(isMounted: isMounted, height: 180) {
                    ScrollView(.horizontal) {
                        LazyVFlow(data: GalleryData.lazyChips, alignment: .leading, spacing: 8) { chip in
                            FlowChipFace(
                                title: chip.title,
                                fill: ChipPalette.color(index: chip.fillIndex),
                                verticalPadding: chip.id.isMultiple(of: 2) ? 6 : 14
                            )
                        }
                        .frame(height: 160)
                    }
                }
                caption("Both types are iOS 17. Inside a scroll view they reveal items as that axis moves. Without one, they render eagerly, like HFlow and VFlow.")
                chipRow(["LazyHFlow", "LazyVFlow", "spacing 8"])
            }
        }
    }
}

private func chip(_ title: String, index: Int, verticalPadding: CGFloat) -> some View {
    FlowChipFace(title: title, fill: ChipPalette.color(index: index), verticalPadding: verticalPadding)
}

private func caption(_ text: String) -> some View {
    Text(text)
        .font(.caption)
        .foregroundStyle(DemoPalette.inkMuted)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 8)
}

private func chipRow(_ labels: [String]) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        ForEach(labels, id: \.self) { label in
            DemoChrome.chip(label)
        }
    }
    .padding(.horizontal, 8)
    .padding(.bottom, 8)
}
