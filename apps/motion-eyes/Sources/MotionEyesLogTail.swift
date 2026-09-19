import Foundation
import OSLog
import SwiftUI

/// Tails this process’s MotionEyes OSLog lines so the CADisplayLink trace
/// is visible without leaving the simulator.
@MainActor
final class MotionEyesLogTail: ObservableObject {
    struct Line: Identifiable, Equatable {
        let id: UUID
        let date: Date
        let text: String

        var isStart: Bool { text.contains("-- Start") }
        var isEnd: Bool { text.contains("-- End") }
    }

    enum BurstKind: Equatable {
        case idle
        case interpolating
        case snapped
    }

    @Published private(set) var lines: [Line] = []
    @Published private(set) var lastBurstKind: BurstKind = .idle
    @Published private(set) var lastBurstSamples = 0
    @Published private(set) var storeAvailable = true

    private var task: Task<Void, Never>?
    private var lastSeen: Date?
    private var samplesInCurrentBurst = 0

    func start() {
        stop()
        lastSeen = Date().addingTimeInterval(-2)
        storeAvailable = true
        task = Task { [weak self] in
            while let self, !Task.isCancelled {
                self.poll()
                try? await Task.sleep(for: .milliseconds(250))
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    func clear() {
        lines.removeAll()
        lastBurstKind = .idle
        lastBurstSamples = 0
        samplesInCurrentBurst = 0
    }

    private func poll() {
        do {
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let startDate = lastSeen ?? Date().addingTimeInterval(-5)
            let position = store.position(date: startDate)
            let predicate = NSPredicate(format: "subsystem == %@", "MotionEyes")
            let entries = try store.getEntries(at: position, matching: predicate)

            var newest = startDate
            var appended: [Line] = []

            for entry in entries {
                guard entry.date > startDate else { continue }
                guard let log = entry as? OSLogEntryLog, log.subsystem == "MotionEyes" else {
                    continue
                }

                let text = log.composedMessage
                appended.append(Line(id: UUID(), date: entry.date, text: text))
                classify(text)
                if entry.date > newest {
                    newest = entry.date
                }
            }

            if !appended.isEmpty {
                lines.append(contentsOf: appended)
                if lines.count > 200 {
                    lines.removeFirst(lines.count - 200)
                }
                lastSeen = newest
            }
        } catch {
            storeAvailable = false
        }
    }

    private func classify(_ text: String) {
        if text.contains("-- Start") {
            samplesInCurrentBurst = 0
        } else if text.contains("-- End") {
            lastBurstSamples = samplesInCurrentBurst
            lastBurstKind = samplesInCurrentBurst >= 4 ? .interpolating : .snapped
            samplesInCurrentBurst = 0
        } else if text.contains("[MotionEyes]") {
            samplesInCurrentBurst += 1
        }
    }
}

struct TraceLogPanel: View {
    @ObservedObject var logTail: MotionEyesLogTail

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("MotionEyes trace")
                    .font(.headline)
                Spacer()
                Button("Clear") {
                    logTail.clear()
                }
                .font(.caption)
            }

            verdict

            Text(
                "Filter Xcode’s console with `subsystem:MotionEyes`, or stream "
                    + "`xcrun simctl spawn booted log stream --predicate 'subsystem == \"MotionEyes\"'`."
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            if !logTail.storeAvailable {
                Text("OSLogStore could not read this process. Watch the Xcode console instead.")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        if logTail.lines.isEmpty {
                            Text("Waiting for MotionEyes samples… tap a control above.")
                                .font(.caption.monospaced())
                                .foregroundStyle(.tertiary)
                                .padding(.vertical, 8)
                        }

                        ForEach(logTail.lines) { line in
                            Text(line.text)
                                .font(.caption2.monospaced())
                                .foregroundStyle(color(for: line))
                                .textSelection(.enabled)
                                .id(line.id)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minHeight: 180, maxHeight: 260)
                .onChange(of: logTail.lines.last?.id) { _, newID in
                    guard let newID else { return }
                    withAnimation(.easeOut(duration: 0.15)) {
                        proxy.scrollTo(newID, anchor: .bottom)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var verdict: some View {
        switch logTail.lastBurstKind {
        case .idle:
            Label("No change burst yet. Animate for a long sample stream, or snap for a jump.", systemImage: "waveform.path")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        case .interpolating:
            Label(
                "Animation ran — \(logTail.lastBurstSamples) interpolating samples between Start and End.",
                systemImage: "checkmark.circle.fill"
            )
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.green)
        case .snapped:
            Label(
                "Animation did not run — \(logTail.lastBurstSamples) sample(s). That is a snap, not interpolated motion.",
                systemImage: "bolt.fill"
            )
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.orange)
        }
    }

    private func color(for line: MotionEyesLogTail.Line) -> Color {
        if line.isStart { return .green }
        if line.isEnd { return .blue }
        return .primary
    }
}
