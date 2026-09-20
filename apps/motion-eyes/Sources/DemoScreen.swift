import MotionEyes
import SwiftUI

/// Playground that makes MotionEyes’ CADisplayLink traces readable in-app.
///
/// Layout keeps the traced card, trigger buttons, and console visible together
/// so you can watch motion and the Start → samples → End burst at the same time.
struct DemoScreen: View {
    private static let movedOffset = CGSize(width: 72, height: -40)
    private static let fadedOpacity = 0.22
    private static let enlargedScale = 1.35

    @StateObject private var logTail = MotionEyesLogTail()

    @State private var offset = CGSize.zero
    @State private var opacity = 1.0
    @State private var scale = 1.0
    @State private var fps = 12
    @State private var tracingEnabled = true
    @State private var showMore = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stage
                    .padding(.horizontal)
                    .padding(.top, 8)

                controls
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                Divider()

                TraceLogPanel(logTail: logTail)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("MotionEyes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("More") { showMore = true }
                }
            }
            .sheet(isPresented: $showMore) {
                NavigationStack {
                    Form {
                        Section("Tracing") {
                            Toggle("Tracing enabled", isOn: $tracingEnabled)
                            Stepper("Sample FPS: \(fps)", value: $fps, in: 8...60, step: 1)
                        }
                        Section("Target @State") {
                            LabeledContent("opacity", value: format(opacity, digits: 2))
                            LabeledContent("scale", value: format(scale, digits: 2))
                            LabeledContent(
                                "offset",
                                value: "\(format(offset.width, digits: 0)), \(format(offset.height, digits: 0))"
                            )
                        }
                        Section("How to read it") {
                            Text("Left buttons use withAnimation (many samples). Right buttons snap with animations disabled (almost no samples).")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .navigationTitle("More")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showMore = false }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
        .onAppear { logTail.start() }
        .onDisappear { logTail.stop() }
    }

    private var stage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(style: StrokeStyle(lineWidth: 1.2, dash: [7, 5]))
                .foregroundStyle(.tertiary)
                .frame(height: 168)

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
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.orange.gradient)
            .frame(width: 140, height: 92)
            .overlay {
                VStack(spacing: 2) {
                    Image(systemName: "eye")
                        .font(.title3.weight(.semibold))
                    Text("traced view")
                        .font(.caption2.weight(.medium))
                }
                .foregroundStyle(.white)
            }
            .shadow(color: .orange.opacity(0.35), radius: 10, y: 5)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trigger — watch card + console together")
                .font(.caption.weight(.semibold))
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

            HStack(spacing: 10) {
                Button("Reset") {
                    run(animated: true) {
                        offset = .zero
                        opacity = 1
                        scale = 1
                    }
                }
                .buttonStyle(.bordered)

                Button("Clear logs") {
                    logTail.clear()
                }
                .buttonStyle(.bordered)

                Spacer()
            }
        }
    }

    private func pair(
        animateTitle: String,
        snapTitle: String,
        animate: @escaping () -> Void,
        snap: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 8) {
            Button(animateTitle, action: animate)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .frame(maxWidth: .infinity)

            Button(snapTitle, action: snap)
                .buttonStyle(.bordered)
                .controlSize(.small)
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

    private func format(_ value: Double, digits: Int) -> String {
        String(format: "%.*f", digits, value)
    }
}
