# Chat

Dark SwiftUI playground for **[Chat](https://github.com/exyte/Chat)** (`import ExyteChat`, from **3.3.7**, annotated tag **3.3.7**, commit **49bf1f37**).

Product **`ExyteChat` only**. `Package.swift` at that tag (`swift-tools-version: 6.1`) declares iOS 17 and no other platform. This app's deployment target is iOS 17.0. The home-screen name is **Chat**. The app module is `ChatDemo`.

Tag `3.3.7` is an annotated tag. The tag object is `44b5b03ac3b379333dfa706e73fde580d0232745`. It points at commit `49bf1f37606e60a44972fa72f2693b62236b7c57` (2026-10-01, "Merge pull request #305 from lissine0/small-fix"). That tag is the newest tag on the repository. The newest published GitHub Release is 2.1.4 (2025-01-23), which is older. Swift Package Manager requirement `from: 3.3.7` resolves the tag. The license is MIT.

The type this demo shows is `ChatView`. A seeded `Message` list, `didSendMessage`, `messageBuilder`, `inputViewBuilder`, `chatTheme`, and `setAvailableInputs` are the calls. Attachments are local `file://` URLs written into Caches. Nothing is uploaded.

Two tabs:

- **Live** — one `ChatView` for You, Mina, and a system Desk pin. The input bar sends, then a local reply from Mina arrives. Accent, reply mode, photos, files, names, and avatars are editable. Opens on this tab.
- **Gallery** — conversation, comments, custom bubbles, a custom input bar, and a paper `chatTheme`. Leaving the tab removes every chat.

Chrome is a near-black page with light ink. Avatars are initials, not remote images. Link previews are off so a markdown link is not fetched.

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this change. Capture both on Aditya's Mac as a follow-up. A Linux VM cannot run the Simulator. This app was not compiled here. `swiftc -parse` accepted the sources. `swift package resolve` for `from: 3.3.7` selected tag 3.3.7 at `49bf1f37606e60a44972fa72f2693b62236b7c57`.

1. Open `apps/chat-demo/Chat.xcodeproj` in Xcode 16+ (iOS 17 SDK).
2. Pick an iPhone simulator.
3. Run the **Chat** scheme. Xcode resolves the remote Swift package `https://github.com/exyte/Chat.git` (from 3.3.7 / tag `3.3.7`).

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/chat-demo
xcodegen generate
```

`PRODUCT_MODULE_NAME = ChatDemo`. Bundle id is `com.techdemos.chat`.

Do not copy the package's `ChatExample` target.

## What Chat does

`ChatView` lists `Message` values and calls `didSendMessage` with a `DraftMessage` when the input bar sends. This app turns that draft into a `Message` with `Message.makeMessage` and appends a Mina reply on device. Defaults below are the initializer and `InputViewCustomizationParameters` at tag 3.3.7.

| API | Default | What the demo does |
| --- | --- | --- |
| `chatType` | `.conversation` | Live stays on conversation. Gallery has a `.comments` card |
| `replyMode` | `.quote` | Live can switch to `.answer` |
| `messageBuilder` | `DummyView()`, which keeps the built-in bubble | Pins, and the custom-bubbles card, draw `PinBubble`. Everything else calls `params.defaultMessageView()` |
| `inputViewBuilder` | `DummyView()`, which keeps the built-in bar | The custom-input card returns a field and calls `inputViewActionClosure(.send)` |
| `setAvailableInputs` | `[.text, .audio, .media]` | Live passes `.text`, plus `.media` and `.document` when those toggles are on. Audio, Giphy, and location are not passed |
| `photoPickerBackend` | `.custom` | `.system`, so the library picker is Apple's `PhotosPicker`. Camera still uses ExyteMediaPicker |
| `chatTheme` | asset colors in the package | `ChatTheme(colors:)` for the ink accents and the paper card |
| `linkPreviewsEnabled` | on | Off |
| `showAvatar` / `avatarBuilder` | on, remote `avatarURL` | On, with an initials view. Every `User` has `avatarURL: nil` |
| `onMessageReaction` | none | Heart, thumbs up, laugh, party. Search is off. Tapping toggles a local `Reaction` |

`AvailableInputType` at this tag is `.text`, `.media`, `.giphy`, `.document`, `.staticLocation`, `.liveLocation`, and `.audio`. There is no `.location` case.

## What to tap

### Live

| Control | What to look for |
| --- | --- |
| **Thread** | Desk pin (custom bubble), Mina, a quote reply, a Caches PNG, `notes.txt`, and markdown. The PNG and the note are `file://` |
| **Input bar** | Send text. The row goes `.sending`, then `.sent`, then `.readBy`. Mina replies with the same words |
| **Photos / Files** | `.media` and `.document` on `setAvailableInputs`. Photos opens the system picker. A picked file stays local |
| **Accent** | `chatTheme` `messageMyBG` and `sendButtonBackground` |
| **Reply** | `.quote` or `.answer` |
| **Names / Avatars** | `showUsername` and `showAvatar` |
| **Long press** | Reply, and on your own rows Edit and Delete. Edit writes the new text into the store |
| **Reaction row** | The four emojis. A second tap on the same one removes it |
| **Leave the tab** | The stage says "Unmounted" |

### Gallery

| Card | Call | What to look for |
| --- | --- | --- |
| **Conversation** | `chatType: .conversation` | Newest row at the bottom |
| **Comments** | `chatType: .comments` | Newest row at the top |
| **Custom bubbles** | `messageBuilder` | Every row is `PinBubble`, including a send |
| **Custom input** | `inputViewBuilder` | The field and Send call `.send`. The built-in bar is not in this card |
| **Paper theme** | `chatTheme(ChatTheme(colors:))` | Light page, brown outgoing bubbles |

**Skipped:** Giphy (needs a client id), audio recording (microphone), static and live location (location permission, and live updates want a map), and link previews (they fetch the URL). The package `ChatExample` screens are not copied.

## Dependencies

- Network on first resolve for Swift Package `ExyteChat` **3.3.7** (tag `3.3.7`, pin `49bf1f37606e60a44972fa72f2693b62236b7c57`)
- Transitive pins from that resolve: ExyteMediaPicker 3.4.7, AnchoredPopup 1.3.1, Kingfisher 8.16.0, GiphyUISDK 2.2.16, ActivityIndicatorView 2.0.2, libwebp-Xcode 1.6.0. The demo does not pass a Giphy key and does not call `giphyConfig`
