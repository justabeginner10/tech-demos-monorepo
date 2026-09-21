import SwiftUI

/// Dummy rows shown in the peeking sheet above the tab bar.
struct Locatee: Identifiable {
    var id: String
    var title: String
    var subtitle: String
    var systemImage: String
    var tint: Color
    var status: String
}

enum DemoCatalog {
    static func rows(for tab: FindMyTab) -> [Locatee] {
        switch tab {
        case .people:
            [
                Locatee(
                    id: "maya",
                    title: "Maya Chen",
                    subtitle: "Civic Bowl",
                    systemImage: "person.fill",
                    tint: Color(red: 0.95, green: 0.55, blue: 0.35),
                    status: "Live"
                ),
                Locatee(
                    id: "jordan",
                    title: "Jordan Hale",
                    subtitle: "North Quay · 6 min ago",
                    systemImage: "person.fill",
                    tint: Color(red: 0.45, green: 0.72, blue: 0.95),
                    status: "Walk"
                ),
                Locatee(
                    id: "riley",
                    title: "Riley Okonkwo",
                    subtitle: "Ridgeway",
                    systemImage: "person.fill",
                    tint: Color(red: 0.62, green: 0.82, blue: 0.48),
                    status: "2 hr"
                ),
            ]
        case .devices:
            [
                Locatee(
                    id: "pocket",
                    title: "Pocket Phone",
                    subtitle: "Harbor Green · This device",
                    systemImage: "iphone",
                    tint: Color(red: 0.55, green: 0.80, blue: 0.55),
                    status: "Now"
                ),
                Locatee(
                    id: "travel",
                    title: "Travel Tablet",
                    subtitle: "Left at Civic Bowl",
                    systemImage: "ipad",
                    tint: Color(red: 0.40, green: 0.70, blue: 0.95),
                    status: "Play"
                ),
                Locatee(
                    id: "desk",
                    title: "Desk Computer",
                    subtitle: "Offline · Ridgeway",
                    systemImage: "desktopcomputer",
                    tint: Color(red: 0.70, green: 0.70, blue: 0.78),
                    status: "Off"
                ),
            ]
        case .items:
            [
                Locatee(
                    id: "keys",
                    title: "House Keys",
                    subtitle: "Updated 4 min ago",
                    systemImage: "key.fill",
                    tint: Color(red: 0.95, green: 0.78, blue: 0.30),
                    status: "Near"
                ),
                Locatee(
                    id: "bag",
                    title: "Day Bag",
                    subtitle: "North Quay",
                    systemImage: "backpack.fill",
                    tint: Color(red: 0.75, green: 0.55, blue: 0.95),
                    status: "Left"
                ),
                Locatee(
                    id: "bike",
                    title: "City Bike",
                    subtitle: "Ridgeway rack",
                    systemImage: "bicycle",
                    tint: Color(red: 0.40, green: 0.78, blue: 0.72),
                    status: "Parked"
                ),
            ]
        case .me:
            [
                Locatee(
                    id: "share",
                    title: "Location sharing",
                    subtitle: "On · Harbor Green",
                    systemImage: "location.fill",
                    tint: Color(red: 0.35, green: 0.78, blue: 0.48),
                    status: "On"
                ),
                Locatee(
                    id: "name",
                    title: "You",
                    subtitle: "Shown as Alex",
                    systemImage: "person.crop.circle.fill",
                    tint: Color(red: 0.39, green: 0.68, blue: 1.00),
                    status: "Edit"
                ),
                Locatee(
                    id: "alerts",
                    title: "Separation alerts",
                    subtitle: "Notify when items are left behind",
                    systemImage: "bell.fill",
                    tint: Color(red: 1.00, green: 0.62, blue: 0.32),
                    status: "On"
                ),
            ]
        }
    }
}

struct TabPeekList: View {
    var tab: FindMyTab

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(tab.title)
                        .font(.title3.weight(.bold))
                    Spacer()
                    Text("Demo data")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 4)

                ForEach(DemoCatalog.rows(for: tab)) { row in
                    LocateeRow(row: row)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 2)
            .padding(.bottom, 8)
        }
        .scrollIndicators(.hidden)
    }
}

private struct LocateeRow: View {
    var row: Locatee

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(row.tint.gradient)
                    .frame(width: 40, height: 40)
                Image(systemName: row.systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(row.title)
                    .font(.body.weight(.semibold))
                Text(row.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text(row.status)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.white.opacity(0.08), in: Capsule())
        }
        .padding(.vertical, 4)
    }
}
