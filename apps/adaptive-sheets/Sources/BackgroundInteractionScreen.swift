import AdaptiveSheets
import SwiftUI

struct BackgroundInteractionScreen: View {
    @State private var isPresented = false
    @State private var tapCount = 0
    @State private var mode: BackgroundMode = .upThrough

    private let shortDetent = AdaptiveDetents.height(160)

    var body: some View {
        ZStack {
            CityBlockMap {
                tapCount += 1
            }
            VStack(spacing: 12) {
                statusCard
                modePicker
                PresentButton(title: isPresented ? "Sheet is up" : "Show sheet over the map") {
                    isPresented = true
                }
                .disabled(isPresented)
                Spacer()
            }
            .padding(16)
        }
        .background(DemoPalette.street)
        .navigationTitle("Background taps")
        .navigationBarTitleDisplayMode(.inline)
        .adaptiveSheets(
            isPresented: $isPresented,
            detents: [shortDetent, .medium, .large],
            startDetent: shortDetent,
            backgroundInteraction: mode.interaction(upThrough: shortDetent),
            grabberIndicator: .visible,
            disableDismissOnSwipe: false,
            cornerRardius: 22
        ) {
            SheetBody(
                title: "Sheet at 160 points",
                detail: mode.sheetDetail
            ) {
                Text("Drag higher to medium or large. With “Up through 160”, taps on the map work only while the sheet is at that short stop.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var statusCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "hand.tap.fill")
                .foregroundStyle(DemoPalette.brass)
            VStack(alignment: .leading, spacing: 2) {
                Text("Map taps")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(tapCount)")
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .foregroundStyle(DemoPalette.ink)
                    .contentTransition(.numericText())
            }
            Spacer()
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Background interaction")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Picker("Background interaction", selection: $mode) {
                ForEach(BackgroundMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.menu)
            .disabled(isPresented)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

enum BackgroundMode: String, CaseIterable, Identifiable {
    case automatic
    case enabled
    case upThrough
    case disabled

    var id: String { rawValue }

    var label: String {
        switch self {
        case .automatic: "Automatic"
        case .enabled: "Enabled"
        case .upThrough: "Up through 160"
        case .disabled: "Disabled"
        }
    }

    var sheetDetail: String {
        switch self {
        case .automatic:
            "Automatic leaves background taps to the system. On a phone the sheet usually blocks them."
        case .enabled:
            "Enabled passes taps through at every detent, including large."
        case .upThrough:
            "Enabled up through 160 points. At this height the blocks still receive taps. Above it, they do not."
        case .disabled:
            "Disabled blocks every tap on the map while the sheet is up."
        }
    }

    func interaction(upThrough detent: AdaptiveDetents) -> AdaptivePresetationBackgroundInteraction {
        switch self {
        case .automatic:
            .automatic
        case .enabled:
            .enabled
        case .upThrough:
            .enabledUpThrough(detent)
        case .disabled:
            .disabled
        }
    }
}

private struct CityBlockMap: View {
    let onTap: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    private let fills: [Color] = [
        Color(red: 0.78, green: 0.86, blue: 0.80),
        Color(red: 0.90, green: 0.87, blue: 0.80),
        Color(red: 0.76, green: 0.83, blue: 0.88),
        Color(red: 0.86, green: 0.84, blue: 0.78),
        Color(red: 0.72, green: 0.80, blue: 0.76)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<40, id: \.self) { index in
                    Button(action: onTap) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(fills[index % fills.count])
                            .aspectRatio(1.05, contentMode: .fit)
                            .overlay(alignment: .topLeading) {
                                if index == 1 || index == 9 || index == 18 || index == 27 {
                                    Text(label(for: index))
                                        .font(.caption2)
                                        .foregroundStyle(DemoPalette.ink.opacity(0.7))
                                        .padding(6)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("City block \(index + 1)")
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 168)
            .padding(.bottom, 24)
        }
        .background(DemoPalette.street)
    }

    private func label(for index: Int) -> String {
        switch index {
        case 1: "Harbor"
        case 9: "Market"
        case 18: "Yard"
        default: "Park"
        }
    }
}
