import ExyteChat
import SwiftUI
import UIKit

/// One `ChatView`. Leaving the tab removes it. The store keeps the thread.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @StateObject private var store = ChatStore(seed: .studio)
    @State private var accent: AccentChoice = .teal
    @State private var reply: ReplyChoice = .quote
    @State private var includePhotos = true
    @State private var includeFiles = true
    @State private var showNames = true
    @State private var showAvatars = true

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                controls
                ChatWell(isMounted: isSelected) {
                    StudioChat(
                        store: store,
                        replyMode: reply.mode,
                        theme: StudioTheme.ink(accent: accent.color),
                        inputs: inputs,
                        showNames: showNames,
                        showAvatars: showAvatars,
                        banner: "Local mock. A send gets a reply from Mina on this device.",
                        showLastRead: true
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DemoPalette.page)
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
        }
    }

    private var inputs: [AvailableInputType] {
        var values: [AvailableInputType] = [.text]
        if includePhotos { values.append(.media) }
        if includeFiles { values.append(.document) }
        return values
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ChatView(messages:didSendMessage:)  replyMode: \(reply.call)")
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.ink)
                .fixedSize(horizontal: false, vertical: true)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Picker("Accent", selection: $accent) {
                        ForEach(AccentChoice.allCases) { choice in
                            Text(choice.title).tag(choice)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 210)

                    Picker("Reply", selection: $reply) {
                        ForEach(ReplyChoice.allCases) { choice in
                            Text(choice.title).tag(choice)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)

                    Toggle("Photos", isOn: $includePhotos)
                        .toggleStyle(.button)
                    Toggle("Files", isOn: $includeFiles)
                        .toggleStyle(.button)
                    Toggle("Names", isOn: $showNames)
                        .toggleStyle(.button)
                    Toggle("Avatars", isOn: $showAvatars)
                        .toggleStyle(.button)
                }
            }
        }
    }
}

struct StudioChat: View {
    @ObservedObject var store: ChatStore
    var chatType: ChatType = .conversation
    var replyMode: ReplyMode = .quote
    var theme: ChatTheme
    var inputs: [AvailableInputType]
    var forceCustomBubbles: Bool = false
    var customInput: Bool = false
    var showNames: Bool = true
    var showAvatars: Bool = true
    var banner: String? = nil
    var showLastRead: Bool = false

    var body: some View {
        Group {
            if customInput {
                configured(customInputChat)
            } else {
                configured(defaultInputChat)
            }
        }
        .chatTheme(theme)
    }

    private var defaultInputChat: ChatView<MessageSlot, DummyView, DemoMenuAction> {
        ChatView(
            messages: store.messages,
            chatType: chatType,
            replyMode: replyMode,
            didSendMessage: { draft in
                Task { @MainActor in
                    store.send(draft: draft)
                }
            },
            messageBuilder: { params in
                MessageSlot(params: params, forceCustom: forceCustomBubbles)
            },
            messageMenuAction: { (action: DemoMenuAction, defaultAction, message) in
                store.handleMenu(action: action, message: message, defaultAction: defaultAction)
            }
        )
    }

    private var customInputChat: ChatView<MessageSlot, CustomComposer, DemoMenuAction> {
        ChatView(
            messages: store.messages,
            chatType: chatType,
            replyMode: replyMode,
            didSendMessage: { draft in
                Task { @MainActor in
                    store.send(draft: draft)
                }
            },
            messageBuilder: { params in
                MessageSlot(params: params, forceCustom: forceCustomBubbles)
            },
            inputViewBuilder: { params in
                CustomComposer(params: params)
            },
            messageMenuAction: { (action: DemoMenuAction, defaultAction, message) in
                store.handleMenu(action: action, message: message, defaultAction: defaultAction)
            }
        )
    }

    private func configured<MessageContent: View, InputContent: View>(
        _ chat: ChatView<MessageContent, InputContent, DemoMenuAction>
    ) -> AnyView {
        let themed = chat
            .setAvailableInputs(inputs)
            .showUsername(showNames)
            .showMessageTimeView(true)
            .showAvatar(showAvatars)
            .avatarSize(avatarSize: 32)
            .avatarBuilder { user in
                InitialsAvatar(user: user)
            }
            .linkPreviewsEnabled(false)
            .showNetworkConnectionProblem(false)
            .showScrollToBottomButton(true)
            .showDateHeaders(true)
            .showMessageMenuOnLongPress(true)
            .showLastReadIndicator(showLastRead)
            .keyboardDismissMode(.interactive)
            .photoPickerBackend(.system)
            .assetsPickerLimit(assetsPickerLimit: 4)
            .onMessageReaction(
                didReactTo: { _, draft in
                    Task { @MainActor in
                        store.toggle(reaction: draft)
                    }
                },
                availableReactionsFor: { _ in
                    [.emoji("❤️"), .emoji("👍"), .emoji("😂"), .emoji("🎉")]
                },
                allowEmojiSearchFor: { _ in false }
            )
        guard let banner else { return AnyView(themed) }
        return AnyView(
            themed.betweenListAndInputViewBuilder {
                Text(banner)
                    .font(.caption2)
                    .foregroundStyle(DemoPalette.inkMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(DemoPalette.card)
            }
        )
    }
}
