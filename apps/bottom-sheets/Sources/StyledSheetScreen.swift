import BottomSheets
import SwiftUI

struct StyledSheetScreen: View {
    private static let sheetColor = Color(red: 0.11, green: 0.20, blue: 0.18)
    private static let cornerRadius: CGFloat = 28

    @State private var isPresented = false

    var body: some View {
        PageScroll(title: "Styled sheet") {
            Text("Background color and corner radius are mapped onto the system sheet on iOS 16.4+. Shadow, dim overlay, and overdrag exist only on the custom sheet, so this screen forces that path.")
                .foregroundStyle(Theme.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 12) {
                StyleFact(symbol: "paintbrush.fill", title: "Background", detail: "Pine, via bPresentationBackground")
                StyleFact(symbol: "capsule.portrait", title: "Corner radius", detail: "28 pt, via bPresentationCornerRadius")
                StyleFact(symbol: "shadow", title: "Shadow", detail: "Custom sheet only")
                StyleFact(symbol: "circle.lefthalf.filled", title: "Dimming", detail: "presentationContentOverlay")
                StyleFact(symbol: "arrow.up.and.down", title: "Overdrag", detail: "20 pt pull-back limit")
            }
            .padding(16)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text("bPresentationBackground takes a Color. The package has no Material overload for the sheet chrome.")
                .font(.footnote)
                .foregroundStyle(Theme.secondary)
                .fixedSize(horizontal: false, vertical: true)

            DemoButton(title: "Show styled sheet", systemImage: "paintpalette.fill") {
                isPresented = true
            }
        }
        .bottomSheet(
            isPresented: $isPresented,
            [.height(280), .medium, .fraction(0.85)]
        ) {
            styledContent
        }
        .nativeBottomSheetDisabled(true)
    }

    private var styledContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Studio card")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.cream)
                Spacer()
                SheetDismissButton(action: { isPresented = false }, foreground: Theme.sand)
            }

            Text("The grabber is hidden. Radius, fill, shadow, and the dim color behind the sheet come from the backport modifiers.")
                .font(.subheadline)
                .foregroundStyle(Theme.sand)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                styledRow("Fill", "bPresentationBackground")
                styledRow("Radius", "\(Int(Self.cornerRadius)) pt")
                styledRow("Shadow", "radius 18, y −6")
                styledRow("Overlay", "black 40%")
                styledRow("Overdrag", "20 pt")
            }
            .padding(14)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .bPresentationDragIndicator(.hidden)
        .bPresentationBackground(Self.sheetColor)
        .bPresentationCornerRadius(Self.cornerRadius)
        .presentationShadow(color: .black.opacity(0.45), radius: 18, x: 0, y: -6)
        .presentationContentOverlay(Color.black.opacity(0.40))
        .presentationOverDragLimit(20)
    }

    private func styledRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Theme.cream)
            Spacer()
            Text(value)
                .font(.subheadline.monospaced())
                .foregroundStyle(Theme.sand)
        }
    }
}

private struct StyleFact: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(Theme.accent)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Theme.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        StyledSheetScreen()
    }
    .tint(Theme.accent)
}
