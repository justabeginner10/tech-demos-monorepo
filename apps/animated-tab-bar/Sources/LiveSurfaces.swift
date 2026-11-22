import AnimatedTabBar
import SwiftUI

// MARK: - Shared chrome

/// Room above the bar for the parabolic arc. The ball is a geometry effect, so it
/// draws outside the circle's layout frame. The package's quad control sits 100 pt
/// up; the curve peaks about halfway to that control.
private struct BarStage<Content: View>: View {
    var title: String
    var detail: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Text(detail)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .padding(.top, 4)
                .fixedSize(horizontal: false, vertical: true)
            Color.clear
                .frame(height: 96)
                .accessibilityHidden(true)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DemoPalette.canvas, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }
}

private struct InkMenu: View {
    var title: String
    @Binding var ink: BarInk
    var choices: [BarInk]

    var body: some View {
        HStack {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
            Spacer()
            Circle()
                .fill(ink.color)
                .frame(width: 12, height: 12)
                .overlay(Circle().strokeBorder(DemoPalette.stroke, lineWidth: 1))
            Picker(title, selection: $ink) {
                ForEach(choices) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.ink)
        }
    }
}

/// Writes `selectedIndex` without going through the bar's tap gesture, so
/// `didSelectIndex` does not run. The bar still animates from its `onChange`.
private struct BindingIndexPicker: View {
    var titles: [String]
    @Binding var selectedIndex: Int
    var onSet: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Set index")
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
            Picker("Set index", selection: Binding(
                get: { selectedIndex },
                set: { onSet($0) }
            )) {
                ForEach(Array(titles.enumerated()), id: \.offset) { index, title in
                    Text(title).tag(index)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct EventReadout: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.caption.monospaced())
            .foregroundStyle(DemoPalette.inkMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private func symbolButton(_ tab: SymbolTab) -> some View {
    Image(systemName: tab.symbolName)
        .font(.system(size: 22, weight: .medium))
        .frame(width: 36, height: 28)
        .accessibilityLabel(tab.title)
}

// MARK: - Ball

/// Plain SF Symbols in the builder initializer, plus the ball / color / motion knobs.
/// Starts on the package defaults: white bar, red selection, black idle, red ball,
/// parabolic trajectory, 0 corner radius, 30 pt vertical padding, easeOut 0.6.
struct BallSurface: View {
    @State private var selectedIndex = 0
    @State private var prevSelectedIndex = 0
    @State private var path: BallPath = .parabolic
    @State private var ballMotion: BarMotion = .easeOutDefault
    @State private var indentMotion: BarMotion = .easeOutDefault
    @State private var bar: BarInk = .white
    @State private var selected: BarInk = .red
    @State private var unselected: BarInk = .black
    @State private var ball: BarInk = .red
    @State private var cornerRadius = 0.0
    @State private var verticalPadding = 30.0
    @State private var lastEvent = "none"

    private var tab: SymbolTab {
        SymbolTab.allCases[selectedIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            BarStage(title: tab.title, detail: path.detail) {
                barView
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Trajectory", selection: $path) {
                ForEach(BallPath.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            motionMenu("Ball motion", selection: $ballMotion)
            motionMenu("Indent motion", selection: $indentMotion)

            InkMenu(title: "Bar", ink: $bar, choices: BarInk.allCases)
            InkMenu(title: "Selected", ink: $selected, choices: BarInk.allCases)
            InkMenu(title: "Idle", ink: $unselected, choices: BarInk.allCases)
            InkMenu(title: "Ball", ink: $ball, choices: BarInk.allCases)

            DemoSlider(title: "Corner radius", value: $cornerRadius, range: 0 ... 28, step: 1, format: "%.0f")
            DemoSlider(title: "Vertical padding", value: $verticalPadding, range: 8 ... 40, step: 1, format: "%.0f")

            BindingIndexPicker(titles: SymbolTab.allCases.map(\.title), selectedIndex: $selectedIndex) { index in
                prevSelectedIndex = selectedIndex
                selectedIndex = index
                lastEvent = "binding \(index)"
            }

            EventReadout(text: "selected \(selectedIndex) · prev \(prevSelectedIndex) · \(lastEvent)")

            Text(
                "Tap the bar to run didSelectIndex. Set index writes selectedIndex and "
                    + "prevSelectedIndex only. buttonsAnimation is easeOut 0.6; on iOS 17+ "
                    + "the package tints with .animation(.linear) and does not read it."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .demoCard()
    }

    private func motionMenu(_ title: String, selection: Binding<BarMotion>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Picker(title, selection: selection) {
                    ForEach(BarMotion.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .tint(DemoPalette.ink)
            }
            Text(selection.wrappedValue.api)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }

    private var barView: some View {
        AnimatedTabBar(selectedIndex: $selectedIndex, prevSelectedIndex: $prevSelectedIndex) {
            symbolButton(.heart)
            symbolButton(.leaf)
            symbolButton(.drop)
            symbolButton(.circle)
            symbolButton(.book)
        }
        .barColor(bar.color)
        .selectedColor(selected.color)
        .unselectedColor(unselected.color)
        .ballColor(ball.color)
        .verticalPadding(CGFloat(verticalPadding))
        .cornerRadius(CGFloat(cornerRadius))
        .ballTrajectory(path.trajectory)
        .ballAnimation(ballMotion.animation)
        .indentAnimation(indentMotion.animation)
        .buttonsAnimation(.easeOut(duration: 0.6))
        .didSelectIndex { index in
            lastEvent = "tap \(index)"
        }
        .id(path)
    }
}

// MARK: - Droplet

/// `views:` array of `DropletButton`, matching the example's second bar.
/// Selected and idle both start at grey 30% so the purple droplet reads on its own.
/// Trajectory stays `.parabolic`, which is the default the example leaves unset.
struct DropletSurface: View {
    @State private var selectedIndex = 0
    @State private var droplet: BarInk = .samplePurple
    @State private var selected: BarInk = .sampleGreyFade
    @State private var unselected: BarInk = .sampleGreyFade
    @State private var ball: BarInk = .white
    @State private var cornerRadius = 16.0
    @State private var verticalPadding = 15.0
    @State private var lastEvent = "none"

    private var icon: DropletIcon {
        DropletIcon.allCases[selectedIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            BarStage(title: icon.title, detail: "DropletButton · \(icon.assetName)") {
                barView
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            InkMenu(
                title: "Droplet",
                ink: $droplet,
                choices: [.samplePurple, .red, .white, .sampleLightGrey] as [BarInk]
            )
            InkMenu(title: "Selected", ink: $selected, choices: BarInk.allCases)
            InkMenu(title: "Idle", ink: $unselected, choices: BarInk.allCases)
            InkMenu(title: "Ball", ink: $ball, choices: BarInk.allCases)
            DemoSlider(title: "Corner radius", value: $cornerRadius, range: 0 ... 28, step: 1, format: "%.0f")
            DemoSlider(title: "Vertical padding", value: $verticalPadding, range: 8 ... 40, step: 1, format: "%.0f")
            BindingIndexPicker(titles: DropletIcon.allCases.map(\.title), selectedIndex: $selectedIndex) { index in
                selectedIndex = index
                lastEvent = "binding \(index)"
            }
            EventReadout(text: "selected \(selectedIndex) · \(lastEvent)")
            Text(
                "imageName is an asset-catalog image, not an SF Symbol. "
                    + "prevSelectedIndex is omitted, as on the example droplet bar. "
                    + "The ball still moves: the package keeps its own previous index."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .demoCard()
    }

    private var barView: some View {
        AnimatedTabBar(
            selectedIndex: $selectedIndex,
            views: DropletIcon.allCases.enumerated().map { index, icon in
                DropletButton(
                    imageName: icon.assetName,
                    dropletColor: droplet.color,
                    isSelected: selectedIndex == index
                )
                .accessibilityLabel(icon.title)
            }
        )
        .barColor(.white)
        .selectedColor(selected.color)
        .unselectedColor(unselected.color)
        .ballColor(ball.color)
        .verticalPadding(CGFloat(verticalPadding))
        .cornerRadius(CGFloat(cornerRadius))
        .ballTrajectory(.parabolic)
        .didSelectIndex { index in
            lastEvent = "tap \(index)"
        }
    }
}

// MARK: - Wiggle

/// `views:` array of `WiggleButton`, matching the example's third bar:
/// teleport ball, purple selection, purple at 30% idle, white ball,
/// corner radius 16, vertical padding 28, and `.scaleEffect(1.2)` outside the button.
struct WiggleSurface: View {
    @State private var selectedIndex = 0
    @State private var imageSize = 20.0
    @State private var selected: BarInk = .samplePurple
    @State private var unselected: BarInk = .samplePurpleFade
    @State private var ball: BarInk = .white
    @State private var cornerRadius = 16.0
    @State private var verticalPadding = 28.0
    @State private var lastEvent = "none"

    private var tab: SymbolTab {
        SymbolTab.allCases[selectedIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            BarStage(title: tab.title, detail: "WiggleButton · imageSize \(Int(imageSize)) · teleport") {
                barView
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            DemoSlider(title: "Image size", value: $imageSize, range: 14 ... 36, step: 1, format: "%.0f")
            InkMenu(title: "Selected", ink: $selected, choices: BarInk.allCases)
            InkMenu(title: "Idle", ink: $unselected, choices: BarInk.allCases)
            InkMenu(title: "Ball", ink: $ball, choices: BarInk.allCases)
            DemoSlider(title: "Corner radius", value: $cornerRadius, range: 0 ... 28, step: 1, format: "%.0f")
            DemoSlider(title: "Vertical padding", value: $verticalPadding, range: 8 ... 40, step: 1, format: "%.0f")
            BindingIndexPicker(titles: SymbolTab.allCases.map(\.title), selectedIndex: $selectedIndex) { index in
                selectedIndex = index
                lastEvent = "binding \(index)"
            }
            EventReadout(text: "selected \(selectedIndex) · \(lastEvent)")
            Text(
                "image is the outline symbol. maskImage is the .fill variant. "
                    + "imageSize defaults to 20 when the example omits it. "
                    + "scaleEffect 1.2 is the example's wrapper, not a package parameter."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .demoCard()
    }

    private var barView: some View {
        AnimatedTabBar(
            selectedIndex: $selectedIndex,
            views: SymbolTab.allCases.enumerated().map { index, tab in
                WiggleButton(
                    image: Image(systemName: tab.symbolName),
                    maskImage: Image(systemName: tab.fillSymbolName),
                    imageSize: CGFloat(imageSize),
                    isSelected: selectedIndex == index
                )
                .scaleEffect(1.2)
                .accessibilityLabel(tab.title)
            }
        )
        .barColor(.white)
        .selectedColor(selected.color)
        .unselectedColor(unselected.color)
        .ballColor(ball.color)
        .verticalPadding(CGFloat(verticalPadding))
        .cornerRadius(CGFloat(cornerRadius))
        .ballTrajectory(.teleport)
        .didSelectIndex { index in
            lastEvent = "tap \(index)"
        }
    }
}
