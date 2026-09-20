import SwiftUI

/// Child that owns a **non-optional** model created lazily from parent data.
struct LazySessionView: View {
    @LazyState private var session: SearchSession

    init(region: Region) {
        _session = LazyState { SearchSession(region: region, technique: .lazyState) }
    }

    var body: some View {
        SessionCard(
            technique: .lazyState,
            sessionRegion: session.region,
            createdAt: session.createdAt,
            query: $session.query,
            matches: session.matches
        )
    }
}

/// Broken pattern: `State(wrappedValue:)` in `init` is eager. SwiftUI keeps the first
/// value and discards every later `SearchSession` that `init` allocates.
struct EagerSessionView: View {
    @State private var session: SearchSession

    init(region: Region) {
        _session = State(wrappedValue: SearchSession(region: region, technique: .eagerState))
    }

    var body: some View {
        SessionCard(
            technique: .eagerState,
            sessionRegion: session.region,
            createdAt: session.createdAt,
            query: $session.query,
            matches: session.matches
        )
    }
}

/// Apple’s sanctioned workaround: optional state + `onAppear`. Init count stays at 1,
/// but optionality leaks into bindings and `ForEach`.
struct OnAppearSessionView: View {
    var region: Region
    @State private var session: SearchSession?

    var body: some View {
        SessionCard(
            technique: .onAppear,
            sessionRegion: session?.region,
            createdAt: session?.createdAt,
            query: Binding(
                get: { session?.query ?? "" },
                set: { session?.query = $0 }
            ),
            matches: session?.matches ?? []
        )
        .onAppear {
            if session == nil {
                session = SearchSession(region: region, technique: .onAppear)
            }
        }
    }
}

struct SessionCard: View {
    let technique: InitTechnique
    let sessionRegion: Region?
    let createdAt: Date?
    @Binding var query: String
    let matches: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Label("Child model", systemImage: "cube.fill")
                    .font(.headline)
                Spacer()
                Text(technique == .onAppear ? "optional + Binding(get:set:)" : "$session bindings")
                    .font(.caption2)
                    .foregroundStyle(technique == .onAppear ? Color.secondary : Color.green)
            }

            if technique == .onAppear, sessionRegion == nil {
                Text("session == nil until onAppear")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                LabeledContent("Model region") {
                    Label(sessionRegion?.rawValue ?? "—", systemImage: sessionRegion?.symbol ?? "mappin")
                        .fontWeight(.semibold)
                        .labelStyle(.titleAndIcon)
                }
                LabeledContent("Seed") {
                    Text(sessionRegion?.seed ?? "—")
                        .font(.body.monospaced())
                }
                LabeledContent("Created") {
                    Text(createdAt ?? .now, style: .time)
                        .font(.body.monospacedDigit())
                }
            }

            TextField("Filter places", text: $query)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)

            if matches.isEmpty {
                Text("No matches")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(matches, id: \.self) { place in
                    Label(place, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                }
            }

            if technique == .onAppear {
                Text("This panel uses Binding(get:set:) and session?.matches ?? []. LazyState lets you write $session.query and session.matches instead.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("TextField is bound with $session.query — a normal Binding, no optionals.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
