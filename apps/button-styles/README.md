# Button Styles

SwiftUI playground for **custom `ButtonStyle` and `PrimitiveButtonStyle`**.

A `ButtonStyle` restyles `configuration.label` and can react to `configuration.isPressed` (scale, fill, shadow). A `PrimitiveButtonStyle` does not get a press flag — you own the gesture and call `configuration.trigger()` when the action should fire.

This is an original gallery inspired by [Mohammad Azam (@azamsharp) — Custom ButtonStyles in SwiftUI](https://x.com/azamsharp/status/1864738722647822541) ([YouTube](https://youtu.be/R5I7DCNDrD0)).

## Open and run

This worker did not have Xcode or an iOS Simulator, so there is no screenshot or video in this PR. Capture both on a Mac as a follow-up.

1. Open `apps/button-styles/ButtonStyles.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **ButtonStyles** scheme.

Regenerate the project after editing `project.yml` (optional):

```bash
cd apps/button-styles
xcodegen generate
```

`PRODUCT_MODULE_NAME = ButtonStylesDemo` so the module is not a generic `ButtonStyles` clash with the protocol.

## What to tap

| Control | What to look for |
| --- | --- |
| **CapsuleFill / ProminentFill / ScaleOnPress / GradientPill / DestructiveOutline** | Press and hold — fill, scale, or shadow tracks `configuration.isPressed`. Release fires the action; **Last taps** updates. |
| **ConfirmTap** | First tap **arms** (orange, caption changes). Second tap calls `configuration.trigger()` and logs. Wait 2.5s to auto-cancel. |
| **Press and hold** lamp in **How it works** | Circle goes green and the caption reads `isPressed` only while the finger is down. |
| **Disabled** | Every live button (including ConfirmTap) dims and ignores taps. |
| **Role: .destructive** | Capsule / Prominent / Gradient pick up `configuration.role == .destructive` (red / pink). Outline stays red. System **Prominent** turns red. |
| **Control size** | Custom styles read `@Environment(\.controlSize)` for padding and type. |

## Requirements

- Xcode 16 or newer / Swift 6
- iOS 18 simulator (same floor as the MotionEyes / Find My Tab Bar demos)
