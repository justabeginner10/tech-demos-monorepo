import Shimmer
import SwiftUI

private enum ShimmerStyle: String, CaseIterable, Identifiable {
    case mask = "Mask"
    case overlay = "Overlay"
    case background = "Background"

    var id: String { rawValue }

    var mode: Shimmer.Mode {
        switch self {
        case .mask: .mask
        case .overlay: .overlay()
        case .background: .background
        }
    }
}

struct DemoScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var loading = true
    @State private var animate = true
    @State private var rightToLeft = false
    @State private var duration = 1.5
    @State private var bandSize = 0.3
    @State private var style = ShimmerStyle.mask

    private var shimmerActive: Bool { loading && animate && !reduceMotion }

    var body: some View {
        TabView {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("A little light while you wait.")
                            .font(.largeTitle.bold())
                        Text("Turn a loading skeleton into a moving highlight with SwiftUI-Shimmer.")
                            .foregroundStyle(.secondary)

                        RecipeCard(placeholder: loading)
                            .shimmering(
                                active: shimmerActive,
                                animation: .linear(duration: duration).repeatForever(autoreverses: false),
                                gradient: style == .mask
                                    ? Shimmer.defaultGradient
                                    : Gradient(colors: [.clear, .mint.opacity(0.55), .clear]),
                                bandSize: CGFloat(bandSize),
                                mode: style.mode
                            )
                            // The library starts its animation on appear. Recreate only the
                            // preview when animation parameters or direction change.
                            .id("\(style.rawValue)-\(duration)-\(bandSize)-\(rightToLeft)-\(shimmerActive)")
                            .environment(\.layoutDirection, rightToLeft ? .rightToLeft : .leftToRight)

                        controls

                        Button(loading ? "Show loaded recipe" : "Load again") {
                            loading.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.mint)
                        .foregroundStyle(.black)

                        if reduceMotion {
                            Label("Reduce Motion is on. The loading placeholder stays still.", systemImage: "accessibility")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(20)
                }
                .navigationTitle("Shimmer")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Live", systemImage: "sparkles") }

            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Loading → ready")
                            .font(.largeTitle.bold())
                        Text("Static samples for comparing the same content before and after loading.")
                            .foregroundStyle(.secondary)
                        Text("Loading skeleton · motion off").font(.headline)
                        RecipeCard(placeholder: true)
                        Text("Loaded content").font(.headline)
                        RecipeCard(placeholder: false)
                        Text("Use the Live tab to compare mask, overlay, and background modes. The gallery stays still.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                }
                .navigationTitle("Gallery")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
        }
        .tint(.mint)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 18) {
            Picker("Mode", selection: $style) {
                ForEach(ShimmerStyle.allCases) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .pickerStyle(.segmented)

            Toggle("Animate loading", isOn: $animate)
            Toggle("Right-to-left preview", isOn: $rightToLeft)

            VStack(alignment: .leading) {
                Text("Cycle: \(duration, specifier: "%.1f") seconds")
                Slider(value: $duration, in: 0.5...3, step: 0.1)
                    .accessibilityLabel("Shimmer cycle in seconds")
            }

            VStack(alignment: .leading) {
                Text("Band size: \(bandSize, specifier: "%.1f")")
                Slider(value: $bandSize, in: 0.1...0.7, step: 0.1)
                    .accessibilityLabel("Shimmer band size")
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 20))
    }
}
