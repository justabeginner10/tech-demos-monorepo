import ConcentricOnboarding
import SwiftUI

/// The package stores plain `() -> Void` and `(Int) -> Void` closures.
/// Button taps and `withAnimation` completion run on the main thread, so
/// `MainActor.assumeIsolated` is the synchronous hop back to SwiftUI state.
enum OnboardingSink {
    nonisolated static func event(
        _ body: @escaping @MainActor () -> Void
    ) -> () -> Void {
        {
            MainActor.assumeIsolated {
                body()
            }
        }
    }

    nonisolated static func page(
        _ body: @escaping @MainActor (Int) -> Void
    ) -> (Int) -> Void {
        { index in
            MainActor.assumeIsolated {
                body(index)
            }
        }
    }
}

/// `duration`, `nextIcon`, and the page callbacks. The drawn button calls `goToNextPage`.
struct PagesSurface: View {
    @State private var duration = 1.0
    @State private var icon: NextIcon = .chevron
    @State private var page = 0
    @State private var lines: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            controls
            EventLine(page: page, lines: lines)
            flow
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 8) {
            DemoSlider(title: "Duration", value: $duration, range: 0.4...2.0, step: 0.1)
            Picker("Icon", selection: $icon) {
                ForEach(NextIcon.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
            Text("The circle button calls goToNextPage(animated:). There is no back button.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var flow: some View {
        ConcentricOnboardingView(pageContents: makePages(PageLibrary.walk))
            .duration(duration)
            .nextIcon(icon.symbol)
            .animationWillBegin(perform: OnboardingSink.event {
                note("animationWillBegin")
            })
            .animationDidEnd(perform: OnboardingSink.event {
                note("animationDidEnd")
            })
            .didChangeCurrentPage(perform: OnboardingSink.page { index in
                page = index
                note("didChangeCurrentPage \(index)")
            })
            .didGoToLastPage(perform: OnboardingSink.event {
                note("didGoToLastPage")
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func note(_ line: String) {
        lines = Array((lines + [line]).suffix(4))
    }
}

/// Last page calls `insteadOfCyclingToFirstPage` instead of wrapping to page 0.
struct FinishSurface: View {
    @State private var generation = 0
    @State private var page = 0
    @State private var stayed = false
    @State private var lines: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            controls
            EventLine(page: page, lines: lines)
            flow
                .id(generation)
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(stayed ? "Stayed on the last page" : "Next on the last page stays")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
                Spacer()
                Button("Start over") {
                    stayed = false
                    page = 0
                    lines = []
                    generation += 1
                }
                .buttonStyle(.bordered)
                .tint(DemoPalette.ink)
            }
            Text("duration(1.5) · insteadOfCyclingToFirstPage. goToPreviousPage is not called.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var flow: some View {
        ConcentricOnboardingView(pageContents: makePages(PageLibrary.finish))
            .duration(1.5)
            .nextIcon("chevron.forward")
            .animationWillBegin(perform: OnboardingSink.event {
                note("animationWillBegin")
            })
            .animationDidEnd(perform: OnboardingSink.event {
                note("animationDidEnd")
            })
            .didChangeCurrentPage(perform: OnboardingSink.page { index in
                page = index
                note("didChangeCurrentPage \(index)")
            })
            .didGoToLastPage(perform: OnboardingSink.event {
                note("didGoToLastPage")
            })
            .insteadOfCyclingToFirstPage(perform: OnboardingSink.event {
                stayed = true
                note("insteadOfCyclingToFirstPage")
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func note(_ line: String) {
        lines = Array((lines + [line]).suffix(4))
    }
}

/// `didPressNextButton` replaces the drawn button. The page does not advance.
struct ButtonSurface: View {
    @State private var presses = 0

    var body: some View {
        VStack(spacing: 0) {
            controls
            flow
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Presses \(presses)")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
            Text(
                "didPressNextButton replaces goToNextPage. The closure does not receive the view, "
                    + "so this screen cannot advance or go back."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var flow: some View {
        ConcentricOnboardingView(pageContents: makePages(PageLibrary.held))
            .duration(1.0)
            .nextIcon("arrow.right")
            .didPressNextButton(perform: OnboardingSink.event {
                presses += 1
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct EventLine: View {
    var page: Int
    var lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Page \(page)")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
            Text(lines.last ?? "Waiting for the button")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}

@MainActor
private func makePages(_ specs: [PageSpec]) -> [ConcentricOnboardingView<OnboardingPage>.PageContent] {
    var pages: [ConcentricOnboardingView<OnboardingPage>.PageContent] = []
    for spec in specs {
        pages.append((view: OnboardingPage(page: spec), background: spec.background))
    }
    return pages
}
