import ExyteGrid
import SwiftUI

private func galleryTile(_ title: String, index: Int) -> some View {
    TileFace(title: title, fill: TilePalette.color(index: index))
}

struct FractionalTracksCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Fractional", subtitle: "Grid(tracks: 3)") {
            VStack(alignment: .leading, spacing: 8) {
                GridWell(isMounted: isMounted, height: 148) {
                    ExyteGrid.Grid(tracks: 3) {
                        galleryTile("1", index: 0)
                        galleryTile("2", index: 1)
                        galleryTile("3", index: 2)
                        galleryTile("4", index: 3)
                        galleryTile("5", index: 4)
                        galleryTile("6", index: 5)
                    }
                }
                caption("Integer tracks repeat .fr(1). Spacing is omitted, so the 5 pt default is used.")
                chipRow([".fr(1)", ".fr(1)", ".fr(1)", "spacing 5"])
            }
        }
    }
}

struct PointTracksCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(
            title: "Fixed points",
            subtitle: "tracks: [.pt(64), .pt(40), .pt(88)]"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                GridWell(isMounted: isMounted, height: 148) {
                    ExyteGrid.Grid(
                        0..<6,
                        tracks: [.pt(64), .pt(40), .pt(88)],
                        spacing: 8,
                        contentAlignment: GridAlignment.leading
                    ) { index in
                        galleryTile(String(index + 1), index: index)
                    }
                }
                caption("Range init. .pt stays fixed. contentAlignment: .leading pins the block to the leading edge.")
                chipRow([".pt(64)", ".pt(40)", ".pt(88)", ".leading"])
            }
        }
    }
}

struct FitTracksCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Fit", subtitle: "tracks: [.fit, .fr(1), .fit]") {
            VStack(alignment: .leading, spacing: 8) {
                GridWell(isMounted: isMounted, height: 148) {
                    ExyteGrid.Grid(tracks: [.fit, .fr(1), .fit], spacing: 6) {
                        galleryTile("A", index: 0)
                        galleryTile("flex", index: 1)
                        galleryTile("longer", index: 2)
                        galleryTile("B", index: 3)
                        galleryTile("mid", index: 4)
                        galleryTile("fit", index: 5)
                    }
                }
                caption(".fit columns size to the text. The middle .fr(1) track takes the width they leave.")
                chipRow([".fit", ".fr(1)", ".fit"])
            }
        }
    }
}

struct SpansCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Spans", subtitle: "gridSpan(column:row:) · gridSpan([column, row])") {
            VStack(alignment: .leading, spacing: 8) {
                GridWell(isMounted: isMounted, height: 200) {
                    ExyteGrid.Grid(tracks: 4, spacing: 6) {
                        galleryTile("2×1", index: 0)
                            .gridSpan(column: 2, row: 1)
                        galleryTile("2×1", index: 1)
                            .gridSpan(column: 2, row: 1)
                        galleryTile("1×2", index: 2)
                            .gridSpan(column: 1, row: 2)
                            .gridItemAlignment(GridAlignment.bottom)
                        galleryTile("3×1", index: 3)
                            .gridSpan([3, 1])
                        galleryTile("1×1", index: 4)
                    }
                }
                caption("The 1×2 cell uses gridItemAlignment(.bottom), which overrides the common center alignment.")
                chipRow(["column 2", "row 2", "[3, 1]", ".bottom"])
            }
        }
    }
}

struct StartsCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Starts", subtitle: "gridStart(column:row:) · gridStart([column, row])") {
            VStack(alignment: .leading, spacing: 8) {
                GridWell(isMounted: isMounted, height: 210) {
                    ExyteGrid.Grid(tracks: 3, spacing: 6) {
                        galleryTile("0,0", index: 0)
                            .gridStart(column: 0, row: 0)
                            .gridSpan(column: 2, row: 2)
                        galleryTile("2,0", index: 1)
                            .gridStart(column: 2, row: 0)
                        galleryTile("2,1", index: 2)
                            .gridStart([2, 1])
                        galleryTile("0,2", index: 3)
                            .gridStart(column: 0, row: 2)
                            .gridSpan(column: 3, row: 1)
                    }
                }
                caption("Placed cells name their column and row. The array form is [column, row].")
                chipRow(["start 0,0", "span 2×2", "[2, 1]", "span 3×1"])
            }
        }
    }
}

struct ContentModeCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Content mode", subtitle: ".scroll · .fill") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Scroll")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                GridWell(isMounted: isMounted, height: 160) {
                    ExyteGrid.Grid(0..<18, tracks: 3, contentMode: .scroll, flow: .rows, spacing: 5) { index in
                        galleryTile(String(index + 1), index: index)
                    }
                }
                Text("Fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                GridWell(isMounted: isMounted, height: 160) {
                    ExyteGrid.Grid(0..<18, tracks: 3, contentMode: .fill, flow: .rows, spacing: 5) { index in
                        galleryTile(String(index + 1), index: index)
                    }
                }
                caption("Same 18 cells and three tracks. Scroll keeps content size and moves. Fill shares the 160 pt stage.")
                chipRow([".scroll", ".fill", "flow .rows"])
            }
        }
    }
}

struct FlowCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Flow", subtitle: "flow: .rows · flow: .columns") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Rows")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                GridWell(isMounted: isMounted, height: 168) {
                    ExyteGrid.Grid(0..<9, tracks: 3, flow: .rows, spacing: 5) { index in
                        galleryTile(String(index + 1), index: index)
                    }
                }
                Text("Columns")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                GridWell(isMounted: isMounted, height: 168) {
                    ExyteGrid.Grid(0..<9, tracks: 3, flow: .columns, spacing: 5) { index in
                        galleryTile(String(index + 1), index: index)
                    }
                }
                caption("tracks: 3 is three columns in rows-flow, and three rows in columns-flow. Numbers follow the flow.")
                chipRow([".rows", ".columns", "9 cells"])
            }
        }
    }
}

struct PackingCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Packing", subtitle: "packing: .sparse · packing: .dense") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Sparse")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                packingGrid(isMounted: isMounted, packing: .sparse)
                Text("Dense")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                packingGrid(isMounted: isMounted, packing: .dense)
                caption("Cell 2 spans all four tracks, so it wraps and leaves a hole. Sparse keeps going. Dense fills the hole.")
                chipRow(["tracks 4", "gridSpan(column: 4)", ".sparse", ".dense"])
            }
        }
    }

    private func packingGrid(isMounted: Bool, packing: GridPacking) -> some View {
        GridWell(isMounted: isMounted, height: 148) {
            ExyteGrid.Grid(tracks: 4, packing: packing, spacing: 5) {
                galleryTile("1", index: 0)
                galleryTile("2", index: 1)
                    .gridSpan(column: 4)
                galleryTile("3", index: 2)
                galleryTile("4", index: 3)
                galleryTile("5", index: 4)
            }
        }
    }
}

struct SpacingCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Spacing", subtitle: "spacing: [18, 6]") {
            VStack(alignment: .leading, spacing: 8) {
                GridWell(isMounted: isMounted, height: 160) {
                    ExyteGrid.Grid(0..<6, tracks: 3, spacing: [18, 6]) { index in
                        galleryTile(String(index + 1), index: index)
                    }
                }
                caption("The array literal is [horizontal, vertical]. An Int literal would set both axes.")
                chipRow(["horizontal 18", "vertical 6"])
            }
        }
    }
}

struct GridGroupCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "GridGroup", subtitle: "GridGroup(0..<12)") {
            VStack(alignment: .leading, spacing: 8) {
                GridWell(isMounted: isMounted, height: 180) {
                    ExyteGrid.Grid(tracks: 4, spacing: 5) {
                        GridGroup(0..<12) { index in
                            galleryTile(String(index), index: index)
                        }
                    }
                }
                caption("GridBuilder holds 10 views. GridGroup turns the range into one cell per index, past that limit.")
                chipRow(["12 cells", "4 tracks"])
            }
        }
    }
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
