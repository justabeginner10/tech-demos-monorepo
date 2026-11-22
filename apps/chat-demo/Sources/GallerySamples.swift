import ExyteChat
import SwiftUI

private struct GalleryChatCard: View {
    var title: String
    var subtitle: String
    var isMounted: Bool
    var chatType: ChatType = .conversation
    var theme: ChatTheme = StudioTheme.ink(accent: DemoPalette.accent)
    var inputs: [AvailableInputType] = [.text]
    var forceCustomBubbles = false
    var customInput = false

    @StateObject private var store: ChatStore

    init(
        title: String,
        subtitle: String,
        isMounted: Bool,
        seed: StudioSeed,
        chatType: ChatType = .conversation,
        theme: ChatTheme = StudioTheme.ink(accent: DemoPalette.accent),
        inputs: [AvailableInputType] = [.text],
        forceCustomBubbles: Bool = false,
        customInput: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isMounted = isMounted
        self.chatType = chatType
        self.theme = theme
        self.inputs = inputs
        self.forceCustomBubbles = forceCustomBubbles
        self.customInput = customInput
        _store = StateObject(wrappedValue: ChatStore(seed: seed))
    }

    var body: some View {
        DemoChrome.chartCard(title: title, subtitle: subtitle) {
            ChatWell(isMounted: isMounted, height: 320) {
                StudioChat(
                    store: store,
                    chatType: chatType,
                    theme: theme,
                    inputs: inputs,
                    forceCustomBubbles: forceCustomBubbles,
                    customInput: customInput,
                    showNames: true,
                    showAvatars: true
                )
            }
        }
    }
}

struct ConversationCard: View {
    var isMounted: Bool

    var body: some View {
        GalleryChatCard(
            title: "Conversation",
            subtitle: "ChatView(messages:chatType: .conversation)",
            isMounted: isMounted,
            seed: .short
        )
    }
}

struct CommentsCard: View {
    var isMounted: Bool

    var body: some View {
        GalleryChatCard(
            title: "Comments",
            subtitle: "chatType: .comments",
            isMounted: isMounted,
            seed: .comments,
            chatType: .comments
        )
    }
}

struct CustomBubblesCard: View {
    var isMounted: Bool

    var body: some View {
        GalleryChatCard(
            title: "Custom bubbles",
            subtitle: "messageBuilder: { PinBubble }",
            isMounted: isMounted,
            seed: .short,
            forceCustomBubbles: true
        )
    }
}

struct CustomInputCard: View {
    var isMounted: Bool

    var body: some View {
        GalleryChatCard(
            title: "Custom input",
            subtitle: "inputViewBuilder → inputViewActionClosure(.send)",
            isMounted: isMounted,
            seed: .short,
            customInput: true
        )
    }
}

struct PaperThemeCard: View {
    var isMounted: Bool

    var body: some View {
        GalleryChatCard(
            title: "Paper theme",
            subtitle: "chatTheme(ChatTheme(colors:))",
            isMounted: isMounted,
            seed: .short,
            theme: StudioTheme.paper()
        )
    }
}
