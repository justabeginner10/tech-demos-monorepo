import SwiftUI

/// Frozen stand-ins for the Live families. The playground owns every picker.
enum GalleryCard: String, CaseIterable, Identifiable {
    case modes
    case selection
    case theme
    case camera
    case results

    var id: String { rawValue }

    var title: String {
        switch self {
        case .modes: "Modes"
        case .selection: "Selection"
        case .theme: "Theme"
        case .camera: "Camera"
        case .results: "Results"
        }
    }

    var subtitle: String {
        switch self {
        case .modes: "MediaPickerMode"
        case .selection: "limit · style"
        case .theme: "selection · cellStyle"
        case .camera: "simulator stub"
        case .results: "getThumbnailURL · getURL"
        }
    }

    var chips: [String] {
        switch self {
        case .modes:
            [".photos", ".albums", ".album", ".camera"]
        case .selection:
            [".count", ".checkmark", "limit 5"]
        case .theme:
            ["accent", "cornerRadius", "spacing"]
        case .camera:
            [".camera", "no capture"]
        case .results:
            ["image", "video", "detail"]
        }
    }

    @ViewBuilder
    var preview: some View {
        VStack(alignment: .leading, spacing: 8) {
            snapshot
            chipRow
        }
    }

    @ViewBuilder
    private var snapshot: some View {
        switch self {
        case .modes:
            ModesMark()
        case .selection:
            SelectionMarkView()
        case .theme:
            ThemeMark()
        case .camera:
            CameraMark()
        case .results:
            ResultsMark()
        }
    }

    private var chipRow: some View {
        HStack(spacing: 6) {
            ForEach(chips, id: \.self) { chip in
                DemoChrome.chip(chip)
            }
        }
    }
}

private struct ModesMark: View {
    var body: some View {
        HStack(spacing: 8) {
            modeTile(title: "Photos", symbol: "square.grid.3x3")
            modeTile(title: "Albums", symbol: "rectangle.stack")
            modeTile(title: "Camera", symbol: "camera")
        }
        .padding(.vertical, 8)
    }

    private func modeTile(title: String, symbol: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(DemoPalette.accent)
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct SelectionMarkView: View {
    var body: some View {
        HStack(spacing: 10) {
            cell(selected: true, label: "1")
            cell(selected: true, label: "2")
            cell(selected: false, label: nil)
            cell(selected: false, label: nil)
        }
        .padding(.vertical, 8)
    }

    private func cell(selected: Bool, label: String?) -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(DemoPalette.card)
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .topTrailing) {
                ZStack {
                    Circle()
                        .fill(selected ? DemoPalette.accent : Color.black.opacity(0.25))
                    Circle()
                        .strokeBorder(.white, lineWidth: 1.5)
                    if let label {
                        Text(label)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(DemoPalette.page)
                    }
                }
                .frame(width: 18, height: 18)
                .padding(6)
            }
    }
}

private struct ThemeMark: View {
    var body: some View {
        HStack(spacing: 12) {
            swatch(DemoPalette.accent)
            swatch(Color(red: 0.32, green: 0.76, blue: 0.70))
            swatch(Color(red: 0.58, green: 0.48, blue: 0.95))
        }
        .padding(.vertical, 10)
    }

    private func swatch(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(DemoPalette.card)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Circle()
                    .strokeBorder(color, lineWidth: 3)
                    .padding(16)
                    .overlay {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(color)
                    }
            }
    }
}

private struct CameraMark: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("Camera")
                .font(.title3.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Text("Unavailable on simulator")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .multilineTextAlignment(.center)
            Text("Close")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DemoPalette.page)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(DemoPalette.accent, in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.vertical, 4)
    }
}

private struct ResultsMark: View {
    var body: some View {
        HStack(spacing: 8) {
            result(symbol: "photo", badge: nil)
            result(symbol: "photo", badge: nil)
            result(symbol: "video", badge: "0:12")
        }
        .padding(.vertical, 8)
    }

    private func result(symbol: String, badge: String?) -> some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(DemoPalette.card)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Image(systemName: symbol)
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            .overlay(alignment: .bottomLeading) {
                if let badge {
                    Text(badge)
                        .font(.caption2.weight(.semibold).monospaced())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.black.opacity(0.55), in: Capsule())
                        .padding(6)
                }
            }
    }
}
