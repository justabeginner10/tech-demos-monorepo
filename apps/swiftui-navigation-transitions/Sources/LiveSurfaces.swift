import SwiftUI
import SwiftUINavigationTransitions

// MARK: - Stage

private struct TransitionStage: View {
    var transition: CustomNavigationTransition
    var interactivity: CustomNavigationTransition.Interactivity
    var token: String
    var showsField: Bool
    var hint: String

    @State private var path: [Int] = []

    var body: some View {
        NavigationStack(path: $path) {
            TrailPage(depth: 0, path: $path, showsField: showsField, hint: hint)
                .navigationDestination(for: Int.self) { depth in
                    TrailPage(depth: depth, path: $path, showsField: showsField, hint: hint)
                }
        }
        .customNavigationTransition(transition, interactivity: interactivity)
        .id(token)
        .onChange(of: token) {
            path.removeAll()
        }
    }
}

private struct TrailPage: View {
    var depth: Int
    @Binding var path: [Int]
    var showsField: Bool
    var hint: String

    @State private var note = ""

    private var color: Color { trailColor(depth) }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(trailTitle(depth))
                    .font(.system(size: 42, weight: .regular, design: .serif))
                    .foregroundStyle(DemoPalette.ink)
                Text("Depth \(depth)")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Text(depth == 0 ? hint : popHint)
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            if showsField, depth == 2 {
                TextField("Note", text: $note)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .foregroundStyle(DemoPalette.ink)
                    .padding(12)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text("This field is a first responder for the interactive pop. Tag 0.19.1 skips the iOS 16 reparent workaround on iOS 17+, because reparenting resigns first responder.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            HStack(spacing: 8) {
                if depth > 0 {
                    Button("Pop") { path.removeLast() }
                        .buttonStyle(.bordered)
                        .tint(DemoPalette.ink)
                }
                Button("Push") { path.append(depth + 1) }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .disabled(depth >= 3)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(color.ignoresSafeArea())
        .navigationTitle(trailTitle(depth))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(color, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var popHint: String {
        "Back, Pop, or a rightward drag. The package recognizer stays idle when this stack has one view controller."
    }
}

// MARK: - Presets

struct PresetSurface: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var preset: PresetChoice = .slide
    @State private var gesture: PopGesture = .edge
    @State private var motion: MotionChoice = .ease
    @State private var duration = 0.45
    @State private var stiffness = 140.0
    @State private var damping = 16.0
    @State private var faster = false
    @State private var forceFade = false

    private var fadeInstead: Bool { forceFade || reduceMotion }

    private var built: (CustomNavigationTransition, TransitionBuild) {
        TransitionFactory.preset(
            choice: preset,
            fadeInstead: fadeInstead,
            motion: motion,
            duration: duration,
            stiffness: stiffness,
            damping: damping,
            faster: faster,
            gesture: gesture
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                controls
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
            .frame(height: 292)

            TransitionStage(
                transition: built.0,
                interactivity: gesture.interactivity,
                token: built.1.token,
                showsField: true,
                hint: "Push through three pages. Changing a control rebuilds the stack and returns to Root."
            )
        }
        .background(DemoPalette.page)
    }

    private var controls: some View {
        InspectorCard {
            Text(built.1.expression)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
            Text("interactivity: \(gesture.call)")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)

            Picker("Preset", selection: $preset) {
                ForEach(PresetChoice.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.accent)
            .disabled(fadeInstead)

            Text("Pop gesture")
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
            Picker("Pop gesture", selection: $gesture) {
                ForEach(PopGesture.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Text("Motion")
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
            Picker("Motion", selection: $motion) {
                ForEach(MotionChoice.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .disabled(built.1.locksMotion || fadeInstead)

            if fadeInstead {
                Text(fadeCaption)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
                DemoSlider(title: "Duration", value: $duration, range: 0.2...1.2, step: 0.05, format: "%.2f")
            } else if built.1.locksMotion {
                Text(".default ignores animation(_:). The initializer still stores an animation so push and pop stay animated. Pass nil only when you want the swizzle to call push and pop with animated: false.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            } else if motion == .spring {
                DemoSlider(title: "Stiffness", value: $stiffness, range: 40...320, step: 4, format: "%.0f")
                DemoSlider(title: "Damping", value: $damping, range: 4...40, step: 1, format: "%.0f")
                Text("interpolatingSpring(mass: 1, stiffness:damping:initialVelocity: 0) stores duration 0.35. The duration slider does not apply. Faster divides that stored duration by 1.6.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            } else if motion != .packageDefault {
                DemoSlider(title: "Duration", value: $duration, range: 0.2...1.2, step: 0.05, format: "%.2f")
            }

            Toggle("Faster (speed 1.6)", isOn: $faster)
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
                .disabled(built.1.locksMotion)
            Toggle("Force fade", isOn: $forceFade)
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            Text(reduceMotion ? "Reduce Motion is on, so the fade branch is already selected." : "Reduce Motion is off. Force fade selects the same branch.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }

    private var fadeCaption: String {
        if reduceMotion, forceFade {
            "Reduce Motion and Force fade both select .fade(.in).animation(.linear)."
        } else if reduceMotion {
            "Reduce Motion selects .fade(.in).animation(.linear), the README branch."
        } else {
            "Force fade selects .fade(.in).animation(.linear) in place of the preset."
        }
    }
}

// MARK: - Custom

struct CustomSurface: View {
    @State private var choice: CustomChoice = .swing
    @State private var gesture: PopGesture = .edge
    @State private var motion: MotionChoice = .packageDefault
    @State private var duration = 0.55
    @State private var stiffness = 140.0
    @State private var damping = 16.0
    @State private var faster = false

    private var built: (CustomNavigationTransition, TransitionBuild) {
        TransitionFactory.custom(
            choice: choice,
            motion: motion,
            duration: duration,
            stiffness: stiffness,
            damping: damping,
            faster: faster,
            gesture: gesture
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                controls
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
            .frame(height: 268)

            TransitionStage(
                transition: built.0,
                interactivity: gesture.interactivity,
                token: built.1.token,
                showsField: false,
                hint: choice.detail
            )
        }
        .background(DemoPalette.page)
    }

    private var controls: some View {
        InspectorCard {
            Text(built.1.expression)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("interactivity: \(gesture.call)")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)

            Picker("Custom", selection: $choice) {
                ForEach(CustomChoice.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.accent)

            Text(choice.detail)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            Picker("Pop gesture", selection: $gesture) {
                ForEach(PopGesture.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Picker("Motion", selection: $motion) {
                ForEach(MotionChoice.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            if motion == .spring {
                DemoSlider(title: "Stiffness", value: $stiffness, range: 40...320, step: 4, format: "%.0f")
                DemoSlider(title: "Damping", value: $damping, range: 4...40, step: 1, format: "%.0f")
            } else if motion != .packageDefault {
                DemoSlider(title: "Duration", value: $duration, range: 0.2...1.2, step: 0.05, format: "%.2f")
            }

            Toggle("Faster (speed 1.6)", isOn: $faster)
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)

            Text("Swing, Zoom, and Flip follow the package example at tag 0.19.1. Drift is the handler entry point. PrimitiveNavigationTransition is left unused.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

// MARK: - Gesture

struct GestureSurface: View {
    @State private var useSystem = false
    @State private var gesture: PopGesture = .content

    private var transition: CustomNavigationTransition {
        useSystem ? .default : .slide
    }

    private var token: String {
        "\(useSystem ? "system" : "slide")|\(gesture.rawValue)"
    }

    var body: some View {
        VStack(spacing: 0) {
            controls
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            TransitionStage(
                transition: transition,
                interactivity: gesture.interactivity,
                token: token,
                showsField: false,
                hint: gesture.detail
            )
        }
        .background(DemoPalette.page)
    }

    private var controls: some View {
        InspectorCard {
            Text(useSystem ? ".default" : ".slide")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
            Text("interactivity: \(gesture.call)")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)

            Picker("Transition", selection: $useSystem) {
                Text("Slide").tag(false)
                Text("System").tag(true)
            }
            .pickerStyle(.segmented)

            Picker("Pop gesture", selection: $gesture) {
                ForEach(PopGesture.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Text(gesture.detail)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
            Text("Push, then drag right. For a custom transition the package finishes the pop when velocity is above 675, or when progress is at least 0.2 and velocity is above -200. System gestures keep the system finish behavior.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}
