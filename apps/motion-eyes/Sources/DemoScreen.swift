import MotionEyes
import SwiftUI

/// Playground that makes MotionEyes’ CADisplayLink traces readable in-app.
///
/// Tap a **Spring / Fade / Scale** control to change values inside `withAnimation`.
/// Tap the matching **Snap** control to assign the same values with no animation.
/// MotionEyes samples the driving values on a display link; interpolated motion
/// produces a Start → many FPS samples → End burst, while a snap is nearly a
/// single jump.
struct DemoScreen: View {
    private static let movedOffset = CGSize(width: 92, height: -54)
    private static let fadedOpacity = 0.22
    private static let enlargedScale = 1.45

    @StateObject private var logTail = MotionEyesLogTail()

    @State private var offset = CGSize.zero
    @State private var opacity = 1.0
    @State private var scale = 1.0
    @State private var fps = 12
    @State private var tracingEnabled = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        storyHeader
                        stage
                        liveReadout
                        controls
                    }
                    .padding()
                    .padding(.bottom, 8)
                }

                Divider()

                // Pinned so traces stay visible while the card animates above.
                TraceLogPanel(logTail: logTail)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("MotionEyes")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            logTail.start()
        }
        .onDisappear {
            logTail.stop()
        }
    }

    private var storyHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Did the animation actually run?")
                .font(.title3.weight(.semibold))

            Text(
                "MotionEyes traces SwiftUI value changes on a CADisplayLink. "
                    + "An animated change prints Start, samples at \(fps) fps, then End with deltas. "
                    + "A snap without withAnimation is a one-frame jump."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Label("engine: displayLink", systemImage: "metronome")
                Text("·")
                Text("\(fps) fps")
                Text("·")
                Text("subsystem MotionEyes")
            }
            .font(.caption.monospaced())
            .foregroundStyle(.tertiary)
        }
    }

    private var stage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(style: StrokeStyle(lineWidth: 1.2, dash: [7, 5]))
                .foregroundStyle(.tertiary)
                .frame(height: 200)

            card
                .offset(offset)
                .opacity(opacity)
                .scaleEffect(scale)
                .motionTrace(
                    "Demo Card",
                    fps: fps,
                    engine: .displayLink,
                    enabled: tracingEnabled
                ) {
                    Trace.value("opacity", opacity)
                    Trace.value("scale", scale)
                    Trace.value("offset", CGPoint(x: offset.width, y: offset.height))
                    Trace.geometry(
                        "cardFrame",
                        properties: [.minX, .minY, .width, .height],
                        space: .screen,
                        source: .presentation
                    )
                }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.orange.gradient)
            .frame(width: 168, height: 110)
            .overlay {
                VStack(spacing: 4) {
                    Image(systemName: "eye")
                        .font(.title2.weight(.semibold))
                    Text("traced view")
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(.white)
            }
            .shadow(color: .orange.opacity(0.35), radius: 12, y: 6)
    }

    private var liveReadout: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target @State")
                .font(.headline)

            Text("These chips jump as soon as you tap. MotionEyes samples the interpolated presentation values, which is why an animated tap still produces a long trace.")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                valueChip("opacity", format(opacity, digits: 2))
                valueChip("scale", format(scale, digits: 2))
                valueChip(
                    "offset",
                    "\(format(offset.width, digits: 0)), \(format(offset.height, digits: 0))"
                )
            }

            Toggle("Tracing enabled", isOn: $tracingEnabled)
            Stepper("Sample FPS: \(fps)", value: $fps, in: 8...60, step: 1)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trigger a change")
                .font(.headline)

            Text("Left column uses withAnimation. Right column assigns the same values instantly.")
                .font(.caption)
                .foregroundStyle(.secondary)

            pair(
                animateTitle: "Spring move",
                snapTitle: "Snap move",
                animate: {
                    run(animated: true) {
                        offset = offset == .zero ? Self.movedOffset : .zero
                    }
                },
                snap: {
                    run(animated: false) {
                        offset = offset == .zero ? Self.movedOffset : .zero
                    }
                }
            )

            pair(
                animateTitle: "Fade",
                snapTitle: "Snap fade",
                animate: {
                    run(animated: true) {
                        opacity = opacity == 1 ? Self.fadedOpacity : 1
                    }
                },
                snap: {
                    run(animated: false) {
                        opacity = opacity == 1 ? Self.fadedOpacity : 1
                    }
                }
            )

            pair(
                animateTitle: "Scale",
                snapTitle: "Snap scale",
                animate: {
                    run(animated: true) {
                        scale = scale == 1 ? Self.enlargedScale : 1
                    }
                },
                snap: {
                    run(animated: false) {
                        scale = scale == 1 ? Self.enlargedScale : 1
                    }
                }
            )

            Button("Reset all") {
                run(animated: true) {
                    offset = .zero
                    opacity = 1
                    scale = 1
                }
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func pair(
        animateTitle: String,
        snapTitle: String,
        animate: @escaping () -> Void,
        snap: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 10) {
            Button(animateTitle, action: animate)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

            Button(snapTitle, action: snap)
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
        }
    }

    private func run(animated: Bool, _ updates: () -> Void) {
        if animated {
            withAnimation(.spring(duration: 0.85, bounce: 0.28)) {
                updates()
            }
        } else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                updates()
            }
        }
    }

    private func valueChip(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body.monospacedDigit().weight(.medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func format(_ value: Double, digits: Int) -> String {
        String(format: "%.*f", digits, value)
    }
}
