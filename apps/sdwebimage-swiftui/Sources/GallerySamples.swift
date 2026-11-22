import SDWebImageSwiftUI
import SwiftUI
import UIKit

/// One remote still. The tile is the ForEach child so `WebImage` keeps its own state.
struct GalleryTile: View {
    var still: RemoteStill
    var isMounted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                if isMounted {
                    WebImage(url: still.url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        PhotoPlaceholder()
                    }
                    .indicator(.activity)
                    .transition(.fade(duration: 0.35))
                } else {
                    PhotoPlaceholder()
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(still.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .lineLimit(1)
            Text(isMounted ? still.host : "Unmounted")
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
    }
}

/// GIF or animated WebP. `placeholderImage` is the `PlatformImage` initializer.
struct AnimatedClipCard: View {
    var clip: AnimatedClip
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: clip.title, subtitle: clip.host) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    if isMounted {
                        AnimatedImage(
                            url: clip.url,
                            placeholderImage: UIImage(systemName: "photo")
                        )
                        .indicator(.activity)
                        .transition(SDWebImageTransition.fade(duration: 0.5))
                        .resizable()
                        .scaledToFit()
                    } else {
                        PhotoPlaceholder()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)

                Text("AnimatedImage(url: placeholderImage:) · .indicator(.activity)")
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
                DemoChrome.chipRow([clip.title, "fade(duration: 0.5)", ".resizable()"])
            }
        }
    }
}
