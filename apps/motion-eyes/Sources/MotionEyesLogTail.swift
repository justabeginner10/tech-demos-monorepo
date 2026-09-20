import Foundation
import OSLog
import SwiftUI

/// Tails MotionEyes trace lines for the in-app panel.
///
/// Primary source: `Notification.Name("MotionEyes.TraceLine")` posted by the
/// DEBUG sink (reliable on device). Fallback: OSLogStore for the same subsystem.
@MainActor
final class MotionEyesLogTail: ObservableObject {
    struct Line: Identifiable, Equatable, Sendable {
        let id: UUID
        let date: Date
        let text: String

        var isStart: Bool { text.contains("-- Start") }
        var isEnd: Bool { text.contains("-- End") }
    }

    enum BurstKind: Equatable, Sendable {
        case idle
        case interpolating
        case snapped
    }

    @Published private(set) var lines: [Line] = []
    @Published private(set) var lastBurstKind: BurstKind = .idle
    @Published private(set) var lastBurstSamples = 0
    @Published private(set) var storeAvailable = true

    private var task: Task<Void, Never>?
    private var observer: NSObjectProtocol?
    private var lastSeen: Date?
    private var samplesInCurrentBurst = 0

    private static let traceNotification = Notification.Name("MotionEyes.TraceLine")

    func start() {
        stop()
        lastSeen = Date().addingTimeInterval(-2)
        storeAvailable = true

        observer = NotificationCenter.default.addObserver(
            forName: Self.traceNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let message = note.userInfo?["message"] as? String else { return }
            Task { @MainActor in
                self?.appendLive(message)
            }
        }

        task = Task { [weak self] in
            while let self, !Task.isCancelled {
                let since = await self.snapshotLastSeen()
                let result = await Self.fetchEntries(since: since)
                guard !Task.isCancelled else { return }
                await self.applyStore(result)
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        if let observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }

    func clear() {
        lines.removeAll()
        lastBurstKind = .idle
        lastBurstSamples = 0
        samplesInCurrentBurst = 0
    }

    private func snapshotLastSeen() -> Date {
        lastSeen ?? Date().addingTimeInterval(-5)
    }

    private func appendLive(_ text: String) {
        let line = Line(id: UUID(), date: Date(), text: text)
        classify(text)
        lines.append(line)
        if lines.count > 80 {
            lines.removeFirst(lines.count - 80)
        }
        lastSeen = line.date
        storeAvailable = true
    }

    private struct FetchResult: Sendable {
        var ok: Bool
        var newest: Date
        var lines: [Line]
    }

    nonisolated private static func fetchEntries(since startDate: Date) async -> FetchResult {
        await Task.detached(priority: .utility) {
            do {
                let store = try OSLogStore(scope: .currentProcessIdentifier)
                let position = store.position(date: startDate)
                let predicate = NSPredicate(format: "subsystem == %@", "MotionEyes")
                let entries = try store.getEntries(at: position, matching: predicate)

                var newest = startDate
                var appended: [Line] = []
                appended.reserveCapacity(32)

                for entry in entries {
                    guard entry.date > startDate else { continue }
                    guard let log = entry as? OSLogEntryLog, log.subsystem == "MotionEyes" else {
                        continue
                    }
                    appended.append(Line(id: UUID(), date: entry.date, text: log.composedMessage))
                    if entry.date > newest {
                        newest = entry.date
                    }
                }

                return FetchResult(ok: true, newest: newest, lines: appended)
            } catch {
                return FetchResult(ok: false, newest: startDate, lines: [])
            }
        }.value
    }

    private func applyStore(_ result: FetchResult) {
        // Live notification feed is preferred; OSLog is backup only.
        if !result.ok {
            // Don't flip storeAvailable false if live feed already works.
            return
        }
        guard !result.lines.isEmpty else { return }

        // Deduplicate against lines we already got via notification (same text + close time).
        let existing = Set(lines.suffix(40).map(\.text))
        let fresh = result.lines.filter { !existing.contains($0.text) }
        guard !fresh.isEmpty else {
            lastSeen = max(lastSeen ?? result.newest, result.newest)
            return
        }

        for line in fresh {
            classify(line.text)
        }
        lines.append(contentsOf: fresh)
        if lines.count > 80 {
            lines.removeFirst(lines.count - 80)
        }
        lastSeen = result.newest
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

            Text("Pinned live feed — tap Spring/Snap above and watch Start → samples → End here.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        if logTail.lines.isEmpty {
                            Text("Waiting for MotionEyes samples… tap Spring move.")
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
                .frame(minHeight: 120, maxHeight: 180)
                .onChange(of: logTail.lines.last?.id) { _, newID in
                    guard let newID else { return }
                    proxy.scrollTo(newID, anchor: .bottom)
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
