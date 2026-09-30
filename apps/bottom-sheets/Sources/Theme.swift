import SwiftUI

enum Theme {
    static let canvas = Color(red: 0.96, green: 0.94, blue: 0.90)
    static let ink = Color(red: 0.13, green: 0.15, blue: 0.17)
    static let secondary = Color(red: 0.36, green: 0.37, blue: 0.34)
    static let accent = Color(red: 0.76, green: 0.36, blue: 0.22)
    static let card = Color(red: 0.99, green: 0.98, blue: 0.96)
    static let pine = Color(red: 0.11, green: 0.20, blue: 0.18)
    static let cream = Color(red: 0.96, green: 0.93, blue: 0.86)
    static let sand = Color(red: 0.84, green: 0.75, blue: 0.60)
    static let line = Color(red: 0.86, green: 0.83, blue: 0.77)
}

struct DemoButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.accent)
    }
}

struct DemoRow: View {
    let title: String
    let subtitle: String
    let symbol: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 40, height: 40)
                .background(Theme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.secondary)
                .padding(.top, 4)
        }
        .padding(14)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct SheetDismissButton: View {
    let action: () -> Void
    var foreground: Color = Theme.secondary

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(foreground)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close sheet")
    }
}

struct PageScroll<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                content()
            }
            .padding(20)
            .frame(maxWidth: 560, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.canvas)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
