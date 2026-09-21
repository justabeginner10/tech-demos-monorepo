import SwiftUI

/// One-screen playground: parent-passed region vs three ways to create child state.
struct DemoScreen: View {
    @ObservedObject private var initLog = ModelInitLog.shared

    @State private var region: Region = .bayArea
    @State private var technique: InitTechnique = .lazyState
    @State private var parentTick = 0
    @State private var childGeneration = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    storyHeader
                    techniquePicker
                    regionPicker
                    parentControls
                    initCounter
                    childHost
                    identityNote
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("LazyState")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var storyHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Why @State still fails with parent data")
                .font(.title3.weight(.semibold))

            Text(
                "Xcode’s @State macro is lazy only for inline defaults. "
                    + "State(wrappedValue:) in init is still eager: the child model is "
                    + "allocated on every parent re-render and then thrown away. "
                    + "@LazyState (Point-Free) wraps SwiftUI.LazyState so the thunk "
                    + "runs once per view identity, with no optionals and normal $bindings."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private var techniquePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Compare a pattern")
                .font(.headline)

            Picker("Pattern", selection: $technique) {
                ForEach(InitTechnique.allCases) { item in
                    Text(item.shortTitle).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Label(technique.headline, systemImage: technique.badgeSymbol)
                .font(.subheadline)
                .foregroundStyle(technique.tint)

            Text(technique.snippet)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var regionPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Parent region")
                .font(.headline)

            Text("Seed `\(region.seed)` is passed into the child initializer. Changing it does not rewrite existing state unless you remount the child.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("Region", selection: $region) {
                ForEach(Region.allCases) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var parentControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Parent lifetime")
                .font(.headline)

            LabeledContent("Parent re-renders") {
                Text("\(parentTick)")
                    .font(.body.monospacedDigit().weight(.semibold))
            }
            LabeledContent("Child identity") {
                Text("#\(childGeneration)")
                    .font(.body.monospacedDigit().weight(.semibold))
            }

            Button("Re-render parent") {
                parentTick += 1
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)

            Button("Remount child") {
                childGeneration += 1
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)

            Button("Reset counts + remount") {
                initLog.reset()
                childGeneration += 1
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)

            Text("Re-render parent reconstructs the child view value without changing identity. Remount assigns a new .id so LazyState runs the thunk again.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var initCounter: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SearchSession.init count")
                .font(.headline)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(initLog.count(for: technique))")
                    .font(.system(size: 44, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(technique.tint)
                Text("for \(technique.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                countChip(.lazyState)
                countChip(.eagerState)
                countChip(.onAppear)
            }

            Text(counterCaption)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var childHost: some View {
        // Bumping parentTick re-evaluates this body, so the child view *value*
        // is constructed again. Identity stays `technique + generation`, not region.
        Group {
            switch technique {
            case .lazyState:
                LazySessionView(region: region)
            case .eagerState:
                EagerSessionView(region: region)
            case .onAppear:
                OnAppearSessionView(region: region)
            }
        }
        .id("\(technique.rawValue)-\(childGeneration)")
    }

    private var identityNote: some View {
        Text(
            "Point-Free: https://www.pointfree.co/blog/posts/223-beta-preview-lazystate\n"
                + "This demo does not use the private Max package. It wraps SwiftUI.LazyState."
        )
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }

    private func countChip(_ item: InitTechnique) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.shortTitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text("\(initLog.count(for: item))")
                .font(.body.monospacedDigit().weight(.medium))
                .foregroundStyle(item.tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var counterCaption: String {
        switch technique {
        case .lazyState:
            return "Stay on LazyState and tap Re-render parent. This number should remain 1 until you remount."
        case .eagerState:
            return "Stay on Eager @State and tap Re-render parent. This number climbs even though SwiftUI discards the extra models."
        case .onAppear:
            return "onAppear also inits once per identity, but the model is optional until then and bindings get awkward."
        }
    }
}
