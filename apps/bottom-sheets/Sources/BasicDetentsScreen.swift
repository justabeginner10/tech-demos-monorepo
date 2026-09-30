import BottomSheets
import SwiftUI

struct BasicDetentsScreen: View {
    private static let compact = BPresentationDetent.height(180)
    private static let half = BPresentationDetent.medium
    private static let tall = BPresentationDetent.fraction(0.72)
    private static let full = BPresentationDetent.large

    private static let choices: [(title: String, symbol: String, detent: BPresentationDetent)] = [
        ("Height 180", "arrow.down.to.line", compact),
        ("Medium", "rectangle.split.2x1", half),
        ("Fraction 0.72", "percent", tall),
        ("Large", "arrow.up.to.line", full)
    ]

    @State private var isPresented = false
    @State private var detent: BPresentationDetent = BasicDetentsScreen.half

    private var detents: Set<BPresentationDetent> {
        Set(Self.choices.map(\.detent))
    }

    var body: some View {
        PageScroll(title: "Basic detents") {
            Text("Four detents share one selection binding. Jump from the page before the sheet opens, or from the chips inside it.")
                .foregroundStyle(Theme.secondary)
                .fixedSize(horizontal: false, vertical: true)

            DetentReadout(detent: detent)

            VStack(spacing: 10) {
                ForEach(Self.choices, id: \.title) { choice in
                    DetentJumpButton(title: choice.title, symbol: choice.symbol, isSelected: detent == choice.detent) {
                        detent = choice.detent
                    }
                }
            }

            DemoButton(title: isPresented ? "Sheet is open" : "Show sheet", systemImage: "rectangle.bottomhalf.filled") {
                isPresented = true
            }
            .disabled(isPresented)
        }
        .bottomSheet(
            isPresented: $isPresented,
            detents,
            selection: $detent
        ) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Selected detent")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Text(detent.description)
                            .font(.body.monospaced())
                            .foregroundStyle(Theme.accent)
                    }
                    Spacer()
                    SheetDismissButton { isPresented = false }
                }

                Text("These buttons write the same binding the sheet uses for its current detent.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 10) {
                    ForEach(Self.choices, id: \.title) { choice in
                        DetentJumpButton(title: choice.title, symbol: choice.symbol, isSelected: detent == choice.detent) {
                            detent = choice.detent
                        }
                    }
                }
            }
            .bPresentationDragIndicator(.visible)
        }
    }
}

private struct DetentReadout: View {
    let detent: BPresentationDetent

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Binding")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.secondary)
                Text(detent.description)
                    .font(.title3.monospaced().weight(.semibold))
                    .foregroundStyle(Theme.ink)
            }
            Spacer()
            Image(systemName: "link")
                .foregroundStyle(Theme.accent)
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct DetentJumpButton: View {
    let title: String
    let symbol: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: symbol)
                Text(title)
                    .font(.body.weight(.medium))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .foregroundStyle(isSelected ? Color.white : Theme.ink)
            .background(
                isSelected ? Theme.accent : Theme.card,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        BasicDetentsScreen()
    }
    .tint(Theme.accent)
}
