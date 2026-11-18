import RichTextKit
import SwiftUI

struct GalleryCard: View {
    var family: GalleryFamily
    var isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isSelected {
                RichTextViewer(family.text)
                    .frame(minHeight: 150)
                    .paperSurface()
            } else {
                Text("Viewer unmounted.")
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.inkMuted)
                    .frame(maxWidth: .infinity, minHeight: 150, alignment: .center)
                    .paperSurface()
            }

            chipRow
        }
    }

    private var chipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(family.chips, id: \.self) { chip in
                    DemoChrome.chip(chip)
                }
            }
        }
    }
}
