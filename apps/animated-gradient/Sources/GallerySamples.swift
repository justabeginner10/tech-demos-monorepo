import AnimatedGradient
import SwiftUI

private let galleryHeight: CGFloat = 148

struct MinimalCard: View {
    var isMounted: Bool
    var reducesMotion: Bool

    var body: some View {
        DemoChrome.chartCard(
            title: "Minimal",
            subtitle: "AnimatedLinearGradient(colors: [.red, .green, .blue])"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                GradientWell(
                    isMounted: isMounted,
                    reducesMotion: reducesMotion,
                    fallbackColors: [.red, .green, .blue],
                    fallbackStart: .topTrailing,
                    fallbackEnd: .bottomLeading,
                    height: galleryHeight
                ) {
                    AnimatedLinearGradient(colors: [.red, .green, .blue])
                }
                caption("No modifiers. Simultaneous colors 2, linear 3 seconds, start .topTrailing, end .bottomLeading.")
                chipRow(["colors 3", "simultaneous 2", ".linear(duration: 3)", ".topTrailing", ".bottomLeading"])
            }
        }
    }
}

struct ModifiersCard: View {
    var isMounted: Bool
    var reducesMotion: Bool

    var body: some View {
        DemoChrome.chartCard(
            title: "Modifiers",
            subtitle: ".numberOfSimultaneousColors(2) .setAnimation(.linear(duration: 5))"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                GradientWell(
                    isMounted: isMounted,
                    reducesMotion: reducesMotion,
                    fallbackColors: [.red, .green, .blue],
                    fallbackStart: .bottomLeading,
                    fallbackEnd: .topTrailing,
                    height: galleryHeight
                ) {
                    AnimatedLinearGradient(colors: [.red, .green, .blue])
                        .numberOfSimultaneousColors(2)
                        .setAnimation(.linear(duration: 5))
                        .gradientPoints(start: .bottomLeading, end: .topTrailing)
                }
                caption("The README sample. Points run from bottom leading to top trailing. The transition lasts 5 seconds.")
                chipRow(["simultaneous 2", "duration 5", ".bottomLeading", ".topTrailing"])
            }
        }
    }
}

struct PastelCard: View {
    var isMounted: Bool
    var reducesMotion: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Pastel", subtitle: "GradientPreset.pastel") {
            VStack(alignment: .leading, spacing: 8) {
                GradientWell(
                    isMounted: isMounted,
                    reducesMotion: reducesMotion,
                    fallbackColors: GradientPreset.pastel,
                    fallbackStart: .topTrailing,
                    fallbackEnd: .bottomLeading,
                    height: galleryHeight
                ) {
                    AnimatedLinearGradient(colors: GradientPreset.pastel)
                }
                caption("The public pastel array. Six colors. Modifiers stay at the stored defaults.")
                chipRow(["D2C7F6", "EFC6B7", "F4F2C1", "A2EFE9", "DCF4C4", "F5B8CE"])
            }
        }
    }
}

struct BrightCard: View {
    var isMounted: Bool
    var reducesMotion: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Bright", subtitle: "GradientPreset.bright") {
            VStack(alignment: .leading, spacing: 8) {
                GradientWell(
                    isMounted: isMounted,
                    reducesMotion: reducesMotion,
                    fallbackColors: GradientPreset.bright,
                    fallbackStart: .topTrailing,
                    fallbackEnd: .bottomLeading,
                    height: galleryHeight
                ) {
                    AnimatedLinearGradient(colors: GradientPreset.bright)
                }
                caption("The public bright array. Six colors. Modifiers stay at the stored defaults.")
                chipRow(["FFE53B", "00FFA9", "6094EA", "0D4DFF", "F02FC2", "FF2525"])
            }
        }
    }
}

struct ExampleCard: View {
    var isMounted: Bool
    var reducesMotion: Bool

    private var colors: [Color] {
        Array(GradientPreset.pastel.prefix(upTo: 2))
    }

    var body: some View {
        DemoChrome.chartCard(
            title: "Example",
            subtitle: "prefix(upTo: 2), duration 3, bottomLeading to topTrailing"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                GradientWell(
                    isMounted: isMounted,
                    reducesMotion: reducesMotion,
                    fallbackColors: colors,
                    fallbackStart: .bottomLeading,
                    fallbackEnd: .topTrailing,
                    height: galleryHeight
                ) {
                    AnimatedLinearGradient(colors: colors)
                        .numberOfSimultaneousColors(2)
                        .setAnimation(.linear(duration: 3))
                        .gradientPoints(start: .bottomLeading, end: .topTrailing)
                }
                caption("The example screen's initial state. It keeps the first two pastel colors and passes the modifiers explicitly.")
                chipRow(["prefix(upTo: 2)", "simultaneous 2", "duration 3", ".bottomLeading", ".topTrailing"])
            }
        }
    }
}

struct OneStopCard: View {
    var isMounted: Bool
    var reducesMotion: Bool

    var body: some View {
        DemoChrome.chartCard(
            title: "One stop",
            subtitle: ".numberOfSimultaneousColors(1)"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                GradientWell(
                    isMounted: isMounted,
                    reducesMotion: reducesMotion,
                    fallbackColors: [.red, .green, .blue],
                    fallbackStart: .topTrailing,
                    fallbackEnd: .bottomLeading,
                    height: galleryHeight
                ) {
                    AnimatedLinearGradient(colors: [.red, .green, .blue])
                        .numberOfSimultaneousColors(1)
                }
                caption("One stop crossfades the current palette color into the next. Points and animation stay at the stored defaults.")
                chipRow(["simultaneous 1", ".red", ".green", ".blue"])
            }
        }
    }
}

struct CycledStopsCard: View {
    var isMounted: Bool
    var reducesMotion: Bool

    var body: some View {
        DemoChrome.chartCard(
            title: "Cycled stops",
            subtitle: ".numberOfSimultaneousColors(5)"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                GradientWell(
                    isMounted: isMounted,
                    reducesMotion: reducesMotion,
                    fallbackColors: [.red, .green, .blue],
                    fallbackStart: .topTrailing,
                    fallbackEnd: .bottomLeading,
                    height: galleryHeight
                ) {
                    AnimatedLinearGradient(colors: [.red, .green, .blue])
                        .numberOfSimultaneousColors(5)
                }
                caption("Five stops on a three-color palette. The package walks off the end and wraps.")
                chipRow(["colors 3", "simultaneous 5", "cycle"])
            }
        }
    }
}

struct StartPointCard: View {
    var isMounted: Bool
    var reducesMotion: Bool

    var body: some View {
        DemoChrome.chartCard(
            title: "Start only",
            subtitle: ".gradientPoints(start: .topLeading)"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                GradientWell(
                    isMounted: isMounted,
                    reducesMotion: reducesMotion,
                    fallbackColors: GradientPreset.pastel,
                    fallbackStart: .topLeading,
                    fallbackEnd: .bottomLeading,
                    height: galleryHeight
                ) {
                    AnimatedLinearGradient(colors: GradientPreset.pastel)
                        .gradientPoints(start: .topLeading)
                }
                caption("The one-argument start overload sets the end to .bottomLeading. It does not keep a previous end.")
                chipRow([".topLeading", "end .bottomLeading", "GradientPreset.pastel"])
            }
        }
    }
}

struct EndPointCard: View {
    var isMounted: Bool
    var reducesMotion: Bool

    var body: some View {
        DemoChrome.chartCard(
            title: "End only",
            subtitle: ".gradientPoints(end: .bottom)"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                GradientWell(
                    isMounted: isMounted,
                    reducesMotion: reducesMotion,
                    fallbackColors: GradientPreset.bright,
                    fallbackStart: .topTrailing,
                    fallbackEnd: .bottom,
                    height: galleryHeight
                ) {
                    AnimatedLinearGradient(colors: GradientPreset.bright)
                        .gradientPoints(end: .bottom)
                }
                caption("The one-argument end overload sets the start to .topTrailing. It does not keep a previous start.")
                chipRow(["start .topTrailing", ".bottom", "GradientPreset.bright"])
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
