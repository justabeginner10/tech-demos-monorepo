import ExyteChat
import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum AccentChoice: String, CaseIterable, Identifiable {
    case teal
    case amber
    case violet

    var id: String { rawValue }

    var title: String {
        switch self {
        case .teal: "Teal"
        case .amber: "Amber"
        case .violet: "Violet"
        }
    }

    var color: Color {
        switch self {
        case .teal: DemoPalette.accent
        case .amber: Color(red: 0.86, green: 0.55, blue: 0.18)
        case .violet: Color(red: 0.48, green: 0.36, blue: 0.86)
        }
    }
}

enum ReplyChoice: String, CaseIterable, Identifiable {
    case quote
    case answer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quote: "Quote"
        case .answer: "Answer"
        }
    }

    var mode: ReplyMode {
        switch self {
        case .quote: .quote
        case .answer: .answer
        }
    }

    var call: String {
        switch self {
        case .quote: ".quote"
        case .answer: ".answer"
        }
    }
}

enum ChatKind: String, CaseIterable, Identifiable {
    case conversation
    case comments

    var id: String { rawValue }

    var title: String {
        switch self {
        case .conversation: "Conversation"
        case .comments: "Comments"
        }
    }

    var chatType: ChatType {
        switch self {
        case .conversation: .conversation
        case .comments: .comments
        }
    }
}

enum DemoMenuAction: String, CaseIterable, MessageMenuAction {
    case reply
    case edit
    case delete

    func title() -> String {
        switch self {
        case .reply: "Reply"
        case .edit: "Edit"
        case .delete: "Delete"
        }
    }

    func icon() -> Image {
        // `MessageMenuAction.icon()` is nonisolated. The menu calls it on the main thread.
        MainActor.assumeIsolated {
            switch self {
            case .reply: Image(systemName: "arrowshape.turn.up.left")
            case .edit: Image(systemName: "square.and.pencil")
            case .delete: Image(systemName: "trash")
            }
        }
    }

    func isDestructive() -> Bool {
        self == .delete
    }

    static func menuItems(for message: Message) -> [DemoMenuAction] {
        message.user.isCurrentUser ? [.reply, .edit, .delete] : [.reply]
    }
}

enum StudioTheme {
    static func ink(accent: Color) -> ChatTheme {
        ChatTheme(
            colors: .init(
                mainBG: DemoPalette.page,
                mainTint: accent,
                mainText: DemoPalette.ink,
                mainCaptionText: DemoPalette.inkMuted,
                messageMyBG: accent,
                messageMyText: .white,
                messageMyTimeText: Color.white.opacity(0.72),
                messageReadStatus: Color.white.opacity(0.9),
                messageFriendBG: Color(red: 0.16, green: 0.16, blue: 0.18),
                messageFriendText: DemoPalette.ink,
                messageFriendTimeText: DemoPalette.inkMuted,
                messageSystemBG: Color(red: 0.24, green: 0.18, blue: 0.10),
                messageSystemText: DemoPalette.ink,
                messageSystemTimeText: DemoPalette.inkMuted,
                inputBG: DemoPalette.card,
                inputText: DemoPalette.ink,
                inputPlaceholderText: DemoPalette.inkMuted,
                menuBG: DemoPalette.card,
                menuText: DemoPalette.ink,
                menuTextDelete: Color(red: 0.93, green: 0.33, blue: 0.31),
                sendButtonBackground: accent
            )
        )
    }

    static func paper() -> ChatTheme {
        let ink = Color(red: 0.16, green: 0.12, blue: 0.09)
        let accent = Color(red: 0.45, green: 0.24, blue: 0.12)
        return ChatTheme(
            colors: .init(
                mainBG: Color(red: 0.96, green: 0.94, blue: 0.90),
                mainTint: accent,
                mainText: ink,
                mainCaptionText: Color(red: 0.42, green: 0.34, blue: 0.28),
                messageMyBG: accent,
                messageMyText: .white,
                messageMyTimeText: Color.white.opacity(0.72),
                messageFriendBG: .white,
                messageFriendText: ink,
                messageFriendTimeText: Color(red: 0.42, green: 0.34, blue: 0.28),
                inputBG: .white,
                inputText: ink,
                inputPlaceholderText: Color(red: 0.42, green: 0.34, blue: 0.28),
                sendButtonBackground: accent
            )
        )
    }
}

enum StudioPeople {
    static let you = User(id: "you", name: "You", avatarURL: nil, isCurrentUser: true)
    static let mina = User(id: "mina", name: "Mina", avatarURL: nil, isCurrentUser: false)
    static let desk = User(id: "desk", name: "Desk", avatarURL: nil, type: .system)
}

/// Files written once into Caches. Attachments point at these `file://` URLs, so Kingfisher never fetches them.
enum StudioFiles {
    private static let pngBase64 = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAIAAADYYG7QAAAA6UlEQVR42mMQEZMaVIhh1EGjDhp2DtKYtkVzxiatWRu152zQmbdOd8FavUVr9JesNli+0nDlCqPVy43XLjVZv8R042KzzYvMty6w3DHfatc86z1zbfbOtt09y27nTPvt0x22TnPcNNVpwxTndZNc1kx0XTXBbUWf+7JejyU9Xgu7ved3+szt8J3d7jezzX96S8DU5sDJTUETGoL76kN66kK7asM6qsPbqiJaKqOaKkYdNOqgUQeNOmjUQaMOGnXQqINGHTTqoFEHjTpo1EGjDhp10KiDRh006qBRBw0tB42Owo46aNRBNEYA/iqLCzEHvdUAAAAASUVORK5CYII="

    static let noteText = "Local note. This file never leaves the device."

    static func prepare() -> (image: URL, document: URL, documentBytes: Int)? {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("chat-demo", isDirectory: true)
        let imageURL = directory.appendingPathComponent("swatch.png")
        let documentURL = directory.appendingPathComponent("notes.txt")
        let documentData = Data(noteText.utf8)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            if !FileManager.default.fileExists(atPath: imageURL.path) {
                guard let png = Data(base64Encoded: pngBase64) else { return nil }
                try png.write(to: imageURL, options: .atomic)
            }
            if !FileManager.default.fileExists(atPath: documentURL.path) {
                try documentData.write(to: documentURL, options: .atomic)
            }
            return (imageURL, documentURL, documentData.count)
        } catch {
            return nil
        }
    }
}

enum StudioSeed {
    case studio
    case short
    case comments

    func messages() -> [Message] {
        let now = Date()
        let yesterday = now.addingTimeInterval(-86_400)
        switch self {
        case .studio:
            return studioMessages(now: now, yesterday: yesterday)
        case .short:
            return [
                Message(
                    id: "short-mina",
                    user: StudioPeople.mina,
                    createdAt: now.addingTimeInterval(-240),
                    text: "Short thread. The built-in bubbles stay."
                ),
                Message(
                    id: "short-you",
                    user: StudioPeople.you,
                    status: .readBy([StudioPeople.mina.id]),
                    createdAt: now.addingTimeInterval(-120),
                    text: "Send something from the input bar."
                ),
            ]
        case .comments:
            return [
                Message(
                    id: "comment-root",
                    user: StudioPeople.mina,
                    createdAt: yesterday.addingTimeInterval(10 * 3600),
                    text: "Comments put the newest row at the top."
                ),
                Message(
                    id: "comment-you",
                    user: StudioPeople.you,
                    status: .sent,
                    createdAt: now.addingTimeInterval(-600),
                    text: "This one is `chatType: .comments`."
                ),
            ]
        }
    }

    private func studioMessages(now: Date, yesterday: Date) -> [Message] {
        let files = StudioFiles.prepare()
        let hello = Message(
            id: "studio-hello",
            user: StudioPeople.mina,
            createdAt: yesterday.addingTimeInterval(15 * 3600),
            text: "The swatch and the note are files in Caches.",
            reactions: [
                Reaction(user: StudioPeople.you, type: .emoji("👋"), status: .sent),
            ]
        )
        var messages: [Message] = [
            Message(
                id: "studio-pin",
                user: StudioPeople.desk,
                createdAt: yesterday.addingTimeInterval(9 * 3600),
                text: "Pinned locally. Long-press still opens the menu.",
                customData: ["kind": "pin"] as [String: any Sendable]
            ),
            hello,
            Message(
                id: "studio-you-read",
                user: StudioPeople.you,
                status: .readBy([StudioPeople.mina.id]),
                createdAt: yesterday.addingTimeInterval(15 * 3600 + 90),
                text: "Reply quotes that message.",
                replyMessage: hello.toReplyMessage()
            ),
        ]
        if let files {
            messages.append(
                Message(
                    id: "studio-image",
                    user: StudioPeople.mina,
                    createdAt: now.addingTimeInterval(-3600),
                    text: "48×48 swatch, `file://`.",
                    attachments: [
                        Attachment(
                            id: "studio-swatch",
                            url: files.image,
                            type: .image,
                            cacheKey: "chat-demo-swatch"
                        ),
                    ]
                )
            )
            messages.append(
                Message(
                    id: "studio-doc",
                    user: StudioPeople.you,
                    status: .sent,
                    createdAt: now.addingTimeInterval(-1800),
                    text: "And a text file.",
                    attachments: [
                        Attachment(
                            id: "studio-notes",
                            url: files.document,
                            type: .document,
                            fileName: "notes.txt",
                            fileSize: files.documentBytes
                        ),
                    ]
                )
            )
        }
        messages.append(
            Message(
                id: "studio-markdown",
                user: StudioPeople.mina,
                createdAt: now.addingTimeInterval(-600),
                text: "Markdown stays **local**. Link previews are off, so this [example](https://example.com) is not fetched."
            )
        )
        return messages
    }
}

@MainActor
final class ChatStore: ObservableObject {
    @Published var messages: [Message]

    init(seed: StudioSeed) {
        messages = seed.messages()
    }

    func send(draft: DraftMessage) {
        let identifier = draft.id ?? UUID().uuidString
        Task {
            let outgoing = await Message.makeMessage(
                id: identifier,
                user: StudioPeople.you,
                status: .sending,
                draft: draft
            )
            messages.append(outgoing)
            try? await Task.sleep(nanoseconds: 450_000_000)
            updateStatus(id: identifier, status: .sent)
            try? await Task.sleep(nanoseconds: 700_000_000)
            updateStatus(id: identifier, status: .readBy([StudioPeople.mina.id]))
            messages.append(reply(to: draft))
        }
    }

    func applyEdit(id: String, text: String) {
        guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
        let current = messages[index]
        messages[index] = Message(
            id: current.id,
            user: current.user,
            status: current.status,
            createdAt: current.createdAt,
            text: text,
            attachments: current.attachments,
            reactions: current.reactions,
            recording: current.recording,
            replyMessage: current.replyMessage,
            customData: current.customData
        )
    }

    func delete(id: String) {
        messages.removeAll { $0.id == id }
    }

    func toggle(reaction draft: DraftReaction) {
        guard let index = messages.firstIndex(where: { $0.id == draft.messageID }) else { return }
        if let existing = messages[index].reactions.firstIndex(where: { $0.user.id == StudioPeople.you.id && $0.type == draft.type }) {
            messages[index].reactions.remove(at: existing)
            return
        }
        messages[index].reactions.append(
            Reaction(user: StudioPeople.you, type: draft.type, status: .sent)
        )
    }

    /// Called from the menu closure. Reply and edit hand off to ExyteChat; delete and the saved text stay in this store.
    nonisolated func handleMenu(
        action: DemoMenuAction,
        message: Message,
        defaultAction: @escaping (Message, DefaultMessageMenuAction) -> Void
    ) {
        switch action {
        case .reply:
            defaultAction(message, .reply)
        case .edit:
            let id = message.id
            defaultAction(message, .edit { edited in
                Task { @MainActor in
                    self.applyEdit(id: id, text: edited)
                }
            })
        case .delete:
            let id = message.id
            Task { @MainActor in
                self.delete(id: id)
            }
        }
    }

    private func updateStatus(id: String, status: Message.Status) {
        guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[index].status = status
    }

    private func reply(to draft: DraftMessage) -> Message {
        let trimmed = draft.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let text: String
        if trimmed.isEmpty {
            text = "Received the attachment. It stays on this device."
        } else {
            text = "Copying you locally: \(trimmed)"
        }
        return Message(
            id: UUID().uuidString,
            user: StudioPeople.mina,
            createdAt: Date(),
            text: text
        )
    }
}

struct InitialsAvatar: View {
    var user: User

    var body: some View {
        Text(String(user.name.prefix(1)))
            .font(.caption.weight(.semibold))
            .foregroundStyle(DemoPalette.ink)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DemoPalette.card, in: Circle())
            .overlay {
                Circle().strokeBorder(DemoPalette.stroke, lineWidth: 1)
            }
    }
}

struct PinBubble: View {
    var message: Message
    var position: PositionInUserGroup

    var body: some View {
        HStack {
            if message.user.isCurrentUser { Spacer(minLength: 40) }
            VStack(alignment: .leading, spacing: 4) {
                Text(message.user.name.uppercased())
                    .font(.caption2.weight(.semibold).monospaced())
                    .foregroundStyle(DemoPalette.accent)
                Text(message.attributedText)
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.ink)
                Text(positionLabel)
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            .padding(12)
            .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(DemoPalette.accent.opacity(0.45), lineWidth: 1)
            }
            if !message.user.isCurrentUser { Spacer(minLength: 40) }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    private var positionLabel: String {
        switch position {
        case .first: "positionInGroup .first"
        case .middle: "positionInGroup .middle"
        case .last: "positionInGroup .last"
        case .single: "positionInGroup .single"
        }
    }
}

/// `defaultMessageView()` runs in `body`, which is the main actor. The builder closure itself stays nonisolated.
struct MessageSlot: View {
    var params: MessageBuilderParameters
    var forceCustom: Bool

    var body: some View {
        if forceCustom || (params.message.customData["kind"] as? String) == "pin" {
            PinBubble(message: params.message, position: params.positionInGroup)
        } else {
            params.defaultMessageView()
        }
    }
}

struct CustomComposer: View {
    var params: InputViewBuilderParameters

    var body: some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: params.text)
                .textFieldStyle(.roundedBorder)
            Button("Send") {
                params.inputViewActionClosure(.send)
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(DemoPalette.card)
    }

    private var placeholder: String {
        switch params.inputViewStyle {
        case .message: "Message"
        case .signature: "Signature"
        }
    }
}
