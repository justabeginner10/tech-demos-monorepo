import SwiftUI

/// High-contrast cover / inner pair for the live `FoldTransition`.
/// Solid fields and explicit ink so the Metal frost never becomes the only contrast.
struct CoverPane: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.10, blue: 0.28),
                    Color(red: 0.07, green: 0.08, blue: 0.16),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 12) {
                Text("COVER")
                    .font(.caption.weight(.semibold).monospaced())
                    .tracking(2)
                    .foregroundStyle(DemoPalette.accent)

                Text("Night fold")
                    .font(.system(size: 36, weight: .semibold, design: .serif))
                    .foregroundStyle(DemoPalette.ink)

                Text("Swipe any direction. Release settles on the nearer endpoint.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(DemoPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    DemoChrome.chip("progress 0")
                    DemoChrome.chip("source")
                }
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}

struct InnerPane: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.86, blue: 0.52),
                    Color(red: 0.96, green: 0.62, blue: 0.28),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 12) {
                Text("INNER")
                    .font(.caption.weight(.semibold).monospaced())
                    .tracking(2)
                    .foregroundStyle(Color(red: 0.28, green: 0.12, blue: 0.04))

                Text("Destination")
                    .font(.system(size: 36, weight: .semibold, design: .serif))
                    .foregroundStyle(Color(red: 0.14, green: 0.08, blue: 0.04))

                Text("Both hierarchies stay mounted. Local state survives the fold.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color(red: 0.20, green: 0.10, blue: 0.05))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    inkChip("progress 1")
                    inkChip("destination")
                }
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }

    private func inkChip(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.medium).monospaced())
            .foregroundStyle(Color(red: 0.14, green: 0.08, blue: 0.04))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.12), in: Capsule())
    }
}

/// Single-view sample for `.foldEffect`. Return the angle to zero to recapture.
struct TiltPane: View {
    var degrees: Double

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.28, blue: 0.32),
                    Color(red: 0.42, green: 0.08, blue: 0.22),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 12) {
                Text("PANE")
                    .font(.caption.weight(.semibold).monospaced())
                    .tracking(2)
                    .foregroundStyle(Color.white.opacity(0.86))

                Text("Frosted glass")
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)

                Text("Positive angles hinge on the right. Zero is live content.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                DemoChrome.chip(String(format: "%0.0f°", degrees))
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}

struct PlaceCard: Identifiable {
    var id: String
    var title: String
    var caption: String
    var top: Color
    var bottom: Color

    static let catalog: [PlaceCard] = [
        PlaceCard(
            id: "harbor",
            title: "Harbor",
            caption: "Tide tables and a late ferry.",
            top: Color(red: 0.06, green: 0.28, blue: 0.34),
            bottom: Color(red: 0.03, green: 0.12, blue: 0.18)
        ),
        PlaceCard(
            id: "archive",
            title: "Archive",
            caption: "Reading room after hours.",
            top: Color(red: 0.32, green: 0.20, blue: 0.12),
            bottom: Color(red: 0.14, green: 0.08, blue: 0.05)
        ),
        PlaceCard(
            id: "atelier",
            title: "Atelier",
            caption: "Wet paint and north light.",
            top: Color(red: 0.42, green: 0.10, blue: 0.22),
            bottom: Color(red: 0.16, green: 0.04, blue: 0.10)
        ),
        PlaceCard(
            id: "signal",
            title: "Signal",
            caption: "A tower on the ridge.",
            top: Color(red: 0.10, green: 0.28, blue: 0.18),
            bottom: Color(red: 0.04, green: 0.12, blue: 0.08)
        ),
        PlaceCard(
            id: "vault",
            title: "Vault",
            caption: "Cool air, one lamp.",
            top: Color(red: 0.20, green: 0.16, blue: 0.42),
            bottom: Color(red: 0.08, green: 0.06, blue: 0.18)
        ),
    ]
}

struct PlacePane: View {
    var place: PlaceCard
    var index: Int
    var count: Int

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [place.top, place.bottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 12) {
                Text("ATLAS \(index + 1)/\(count)")
                    .font(.caption.weight(.semibold).monospaced())
                    .tracking(1.4)
                    .foregroundStyle(DemoPalette.accent)

                Text(place.title)
                    .font(.system(size: 36, weight: .semibold, design: .serif))
                    .foregroundStyle(DemoPalette.ink)

                Text(place.caption)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(DemoPalette.ink)

                DemoChrome.chip("FoldPager")
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}
