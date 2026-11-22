import AVKit
import ExyteMediaPicker
import SwiftUI

/// Default photos grid. Limit and media type are read once, in `onAppear`, so those knobs remount the picker.
struct PhotosSurface: View {
    var store: SelectionStore

    @State private var show = false
    @State private var kind: LibraryKind = .photoAndVideo
    @State private var mark: SelectionMark = .count
    @State private var limit = 5
    @State private var preview = true
    @State private var cell: CameraCell = .small
    @State private var fullscreen: Media?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Type", selection: $kind) {
                ForEach(LibraryKind.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Picker("Style", selection: $mark) {
                ForEach(SelectionMark.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Picker("Live cell", selection: $cell) {
                ForEach(CameraCell.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Stepper(value: $limit, in: 1...12) {
                Text("Limit \(limit)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DemoPalette.ink)
            }

            Toggle(isOn: $preview) {
                Text("Fullscreen preview")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DemoPalette.ink)
            }
            .tint(DemoPalette.accent)

            OpenPickerButton(title: "Open photos") {
                show = true
            }

            Text(readout)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .demoCard()
        .sheet(isPresented: $show) {
            photosPicker
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var photosPicker: some View {
        MediaPicker(
            isPresented: $show,
            onChange: PickerSink.changed { store.apply($0) }
        )
        .mediaSelectionType(kind.value)
        .mediaSelectionStyle(mark.value)
        .mediaSelectionLimit(limit)
        .showFullscreenPreview(preview)
        .liveCameraCell(cell.value)
        .selectedMedia(selection)
        .fullscreenMedia($fullscreen)
        .id("\(kind.rawValue)-\(limit)")
    }

    private var selection: Binding<[Media]> {
        Binding {
            store.medias
        } set: { medias in
            store.replace(medias)
        }
    }

    private var readout: String {
        let fullscreenLabel = fullscreen.map { MediaFormat.kind($0.type) } ?? "nil"
        return "\(kind.call)  ·  \(mark.call)  ·  limit \(limit)\n"
            + "liveCameraCell \(cell.call)  ·  fullscreen \(fullscreenLabel)\n"
            + "Limit and media type remount the picker. The Simulator forces the live cell to .none."
    }
}

/// Album list from the package, then one album via `pickerMode`.
struct AlbumsSurface: View {
    var store: SelectionStore

    @State private var show = false
    @State private var albums: [Album] = []
    @State private var mode: MediaPickerMode = .albums

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(MediaFormat.mode(mode))
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)

            if albums.isEmpty {
                Text("Album titles land here after the picker opens. The default header can also switch Photos and Albums.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(albums) { album in
                            Button {
                                mode = .album(album)
                                show = true
                            } label: {
                                HStack {
                                    Text(album.title ?? "Untitled")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(DemoPalette.ink)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(DemoPalette.inkMuted)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: 180)
            }

            OpenPickerButton(title: "Open albums") {
                mode = .albums
                show = true
            }
        }
        .demoCard()
        .sheet(isPresented: $show) {
            albumsPicker
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var albumsPicker: some View {
        MediaPicker(
            isPresented: $show,
            onChange: PickerSink.changed { store.apply($0) }
        )
        .mediaSelectionType(.photoAndVideo)
        .mediaSelectionStyle(.checkmark)
        .mediaSelectionLimit(8)
        .liveCameraCell(.none)
        .pickerMode($mode)
        .albums($albums)
        .selectedMedia(selection)
    }

    private var selection: Binding<[Media]> {
        Binding {
            store.medias
        } set: { medias in
            store.replace(medias)
        }
    }
}

/// Camera sheet. On the Simulator the package draws its own stub instead of a capture session.
struct CameraSurface: View {
    var store: SelectionStore

    @State private var show = false
    @State private var mode: MediaPickerMode = .camera
    @State private var orientation = "—"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(cameraNote)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            Text("mode \(MediaFormat.mode(mode))  ·  orientation \(orientation)")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)

            OpenPickerButton(title: "Open camera") {
                mode = .camera
                show = true
            }
        }
        .demoCard()
        .sheet(isPresented: $show) {
            cameraPicker
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var cameraPicker: some View {
        MediaPicker(
            isPresented: $show,
            onChange: PickerSink.changed { store.apply($0) }
        )
        .mediaSelectionType(.photoAndVideo)
        .mediaSelectionStyle(.checkmark)
        .mediaSelectionLimit(6)
        .liveCameraCell(.none)
        .pickerMode($mode)
        .orientationHandler(PickerSink.orientation { orientation = $0 })
        .selectedMedia(selection)
    }

    private var selection: Binding<[Media]> {
        Binding {
            store.medias
        } set: { medias in
            store.replace(medias)
        }
    }

    private var cameraNote: String {
        #if targetEnvironment(simulator)
        "This build is the Simulator. MediaPicker has no capture session here. Camera mode shows an in-picker message that the camera is unavailable, and Close returns to the photos grid. Nothing is recorded."
        #else
        "This build is a device. Camera mode asks for the camera and, when you record video, the microphone. Close on the live camera returns to the photos grid."
        #endif
    }
}

/// Selection color, cell metrics, and the default header colors.
struct ThemeSurface: View {
    var store: SelectionStore

    @State private var show = false
    @State private var accent: ThemeAccent = .gold
    @State private var mark: SelectionMark = .count
    @State private var spacing = 4.0
    @State private var radius = 12.0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Accent", selection: $accent) {
                ForEach(ThemeAccent.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Picker("Style", selection: $mark) {
                ForEach(SelectionMark.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            DemoSlider(title: "Spacing", value: $spacing, range: 1...8, step: 1)
            DemoSlider(title: "Corner", value: $radius, range: 0...20, step: 1)

            Text("selection accent \(accent.title)  ·  \(mark.call)\ncellStyle spacing \(Int(spacing))  ·  corner \(Int(radius))")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            OpenPickerButton(title: "Open themed picker") {
                show = true
            }
        }
        .demoCard()
        .sheet(isPresented: $show) {
            themedPicker
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var themedPicker: some View {
        MediaPicker(
            isPresented: $show,
            onChange: PickerSink.changed { store.apply($0) }
        )
        .mediaSelectionType(.photoAndVideo)
        .mediaSelectionStyle(mark.value)
        .mediaSelectionLimit(6)
        .liveCameraCell(.small)
        .selectedMedia(selection)
        .mediaPickerTheme(
            main: .init(
                pickerText: DemoPalette.ink,
                pickerBackground: DemoPalette.page,
                fullscreenPhotoBackground: DemoPalette.page
            ),
            selection: .init(
                accent: accent.color,
                tint: .white,
                background: Color.black.opacity(0.25)
            ),
            cellStyle: .init(
                columnsSpacing: CGFloat(spacing),
                rowSpacing: CGFloat(spacing),
                cornerRadius: CGFloat(radius)
            ),
            error: .init(
                background: accent.color.opacity(0.85),
                tint: .white
            ),
            defaultHeader: .init(
                background: DemoPalette.card,
                segmentTintColor: DemoPalette.canvas,
                selectedSegmentTintColor: accent.color,
                selectedText: DemoPalette.page,
                unselectedText: DemoPalette.ink
            )
        )
    }

    private var selection: Binding<[Media]> {
        Binding {
            store.medias
        } set: { medias in
            store.replace(medias)
        }
    }
}

struct SelectedMediaSection: View {
    var store: SelectionStore

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Selected")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                if store.isLoading {
                    ProgressView()
                        .tint(DemoPalette.accent)
                }
                Button("Clear") {
                    store.apply([])
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(DemoPalette.accent)
                .disabled(store.medias.isEmpty)
            }

            if store.medias.isEmpty {
                Text("Nothing selected. Open a picker, choose photos or videos, then tap Done.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
                    .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
            } else {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(store.items) { item in
                        NavigationLink {
                            MediaDetailScreen(item: item)
                        } label: {
                            MediaTile(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .demoCard()
    }
}

struct MediaTile: View {
    var item: LoadedMedia

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                tileImage
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(alignment: .bottomLeading) {
                if item.type == .video {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                        if let label = MediaFormat.duration(item.duration) {
                            Text(label)
                        }
                    }
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.black.opacity(0.55), in: Capsule())
                    .padding(6)
                }
            }
            .accessibilityLabel(MediaFormat.kind(item.type))
    }

    @ViewBuilder
    private var tileImage: some View {
        if let image = item.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                DemoPalette.canvas
                Image(systemName: item.type == .video ? "video" : "photo")
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
    }
}

struct MediaDetailScreen: View {
    let item: LoadedMedia

    @State private var player: AVPlayer?
    @State private var fullImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                stage
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 280)
                    .background(DemoPalette.canvas)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(caption)
                    Text(fileLine)
                }
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .background(DemoPalette.page)
        .navigationTitle(MediaFormat.kind(item.type))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DemoPalette.page, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear(perform: start)
        .onDisappear(perform: stop)
    }

    @ViewBuilder
    private var stage: some View {
        switch item.type {
        case .image:
            if let image = fullImage ?? item.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                missing("No image data")
            }
        case .video:
            if let player {
                VideoPlayer(player: player)
            } else if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                missing("No video URL")
            }
        }
    }

    private func missing(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
            .frame(maxWidth: .infinity, minHeight: 220)
    }

    private var caption: String {
        var parts = [MediaFormat.kind(item.type)]
        if let label = MediaFormat.duration(item.duration) {
            parts.append(label)
        }
        return parts.joined(separator: "  ·  ")
    }

    private var fileLine: String {
        if let url = item.url {
            return url.lastPathComponent
        }
        return "getURL() returned nil"
    }

    private func start() {
        switch item.type {
        case .image:
            guard let url = item.url else { return }
            Task {
                let data = await Task.detached(priority: .userInitiated) {
                    try? Data(contentsOf: url)
                }.value
                if let data, let image = UIImage(data: data) {
                    fullImage = image
                }
            }
        case .video:
            guard let url = item.url else { return }
            let player = AVPlayer(url: url)
            self.player = player
            player.play()
        }
    }

    private func stop() {
        player?.pause()
        player = nil
    }
}
