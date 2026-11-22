import SwiftUI

enum GalleryCard: String, CaseIterable, Identifiable {
    case states
    case progress
    case failure
    case grid
    case prefetch
    case resize
    case rounded
    case blur
    case circle
    case memory
    case disk
    case pipeline

    var id: String { rawValue }

    var title: String {
        switch self {
        case .states: "LazyImage"
        case .progress: "Progress"
        case .failure: "Failure"
        case .grid: "Grid"
        case .prefetch: "Prefetch"
        case .resize: "Resize"
        case .rounded: "Corners"
        case .blur: "Blur"
        case .circle: "Circle"
        case .memory: "Memory"
        case .disk: "Disk"
        case .pipeline: "Pipeline"
        }
    }

    var subtitle: String {
        switch self {
        case .states: "placeholder"
        case .progress: "FetchImage.Progress"
        case .failure: "ImagePipeline.Error"
        case .grid: "LazyImage"
        case .prefetch: "ImagePrefetcher"
        case .resize: "ImageProcessors.Resize"
        case .rounded: "RoundedCorners"
        case .blur: "GaussianBlur"
        case .circle: "Circle"
        case .memory: "ImageCache"
        case .disk: "DataCache"
        case .pipeline: "Configuration"
        }
    }

    var chips: [String] {
        switch self {
        case .states: ["LazyImage", "image", "placeholder"]
        case .progress: ["completed", "total", "fraction"]
        case .failure: ["error", "status code"]
        case .grid: ["request", "processors"]
        case .prefetch: ["memoryCache", "priority .low"]
        case .resize: ["aspectFill", "crop"]
        case .rounded: ["radius", "points"]
        case .blur: ["radius 12"]
        case .circle: ["square crop"]
        case .memory: ["totalCount", "totalCost"]
        case .disk: ["totalSize", "flush"]
        case .pipeline: ["URLCache", "DataCache", "automatic"]
        }
    }

    @ViewBuilder
    var preview: some View {
        VStack(alignment: .leading, spacing: 8) {
            snapshot
            HStack(spacing: 6) {
                ForEach(chips, id: \.self) { label in
                    DemoChrome.chip(label)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private var snapshot: some View {
        switch self {
        case .states:
            PaintedWell {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(DemoPalette.ink.opacity(0.08))
                    .frame(width: 72, height: 48)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(DemoPalette.inkMuted)
                    }
            }
        case .progress:
            PaintedWell {
                VStack(alignment: .leading, spacing: 6) {
                    Capsule().fill(DemoPalette.accent).frame(width: 120, height: 6)
                    Text("completed / total")
                        .font(.caption2.monospaced())
                        .foregroundStyle(DemoPalette.inkMuted)
                }
            }
        case .failure:
            PaintedWell {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title2)
                    .foregroundStyle(DemoPalette.accent)
            }
        case .grid:
            PaintedWell {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(28), spacing: 6), count: 4), spacing: 6) {
                    ForEach(0..<8, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(DemoPalette.ink.opacity(0.16))
                            .frame(height: 28)
                    }
                }
            }
        case .prefetch:
            PaintedWell {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(DemoPalette.accent, lineWidth: 2)
                        .frame(width: 36, height: 36)
                    Image(systemName: "arrow.right")
                        .foregroundStyle(DemoPalette.inkMuted)
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(DemoPalette.ink.opacity(0.16))
                        .frame(width: 36, height: 36)
                }
            }
        case .resize:
            PaintedWell {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(DemoPalette.accent.opacity(0.85))
                    .frame(width: 96, height: 64)
            }
        case .rounded:
            PaintedWell {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(DemoPalette.accent.opacity(0.85))
                    .frame(width: 96, height: 64)
            }
        case .blur:
            PaintedWell {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(DemoPalette.accent.opacity(0.45))
                    .frame(width: 96, height: 64)
                    .blur(radius: 1.5)
            }
        case .circle:
            PaintedWell {
                Circle()
                    .fill(DemoPalette.accent.opacity(0.85))
                    .frame(width: 64, height: 64)
            }
        case .memory:
            PaintedWell {
                Image(systemName: "memorychip")
                    .font(.title2)
                    .foregroundStyle(DemoPalette.ink)
            }
        case .disk:
            PaintedWell {
                Image(systemName: "internaldrive")
                    .font(.title2)
                    .foregroundStyle(DemoPalette.ink)
            }
        case .pipeline:
            PaintedWell {
                HStack(spacing: 10) {
                    Text("URL")
                    Text("Data")
                }
                .font(.caption.weight(.semibold).monospaced())
                .foregroundStyle(DemoPalette.ink)
            }
        }
    }
}

private struct PaintedWell<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, minHeight: 96)
    }
}
