import SwiftUI

enum DemoPalette {
    static let paper = Color(red: 0.945, green: 0.929, blue: 0.890)
    static let ink = Color(red: 0.122, green: 0.165, blue: 0.145)
    static let accent = Color(red: 0.176, green: 0.416, blue: 0.314)
    static let sheet = Color(red: 0.984, green: 0.973, blue: 0.949)
    static let mapLand = Color(red: 0.769, green: 0.816, blue: 0.690)
    static let mapPark = Color(red: 0.545, green: 0.682, blue: 0.475)
    static let mapWater = Color(red: 0.576, green: 0.745, blue: 0.769)
    static let mapRoad = Color(red: 0.965, green: 0.949, blue: 0.910)
    static let forestTop = Color(red: 0.173, green: 0.286, blue: 0.239)
    static let forestBottom = Color(red: 0.455, green: 0.565, blue: 0.396)
}

struct DemoBackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.backward")
                .font(.body.weight(.bold))
                .foregroundStyle(DemoPalette.ink)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.94), in: Circle())
                .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

extension View {
    /// Keeps a back button above a bottom sheet, which otherwise covers the screen.
    func demoChrome() -> some View {
        ZStack(alignment: .topLeading) {
            self
            DemoBackButton()
                .padding(.leading, 16)
                .padding(.top, 8)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct SnapButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .foregroundStyle(isSelected ? Color.white : DemoPalette.ink)
                .background(isSelected ? DemoPalette.accent : DemoPalette.ink.opacity(0.08), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
