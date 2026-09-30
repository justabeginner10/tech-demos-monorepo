# Lucas BottomSheet

SwiftUI playground for **[lucaszischka/BottomSheet](https://github.com/lucaszischka/BottomSheet)** (`from: 3.1.0`, resolves to **3.1.1**). Custom snap states, header, search, and Apple-like scroll behavior.

Requires **iOS 18.0**. The package itself still supports iOS 13.

## Open and run

1. Open `apps/lucas-bottom-sheet/LucasBottomSheet.xcodeproj` in Xcode 16+ (iOS 18 SDK).
2. Pick an iPhone simulator.
3. Run the **LucasBottomSheet** scheme.

```bash
cd apps/lucas-bottom-sheet
xcodegen generate
```

Bundle id is `com.techdemos.lucasbottomsheet`.

## Screens

1. **Nearby places** — A map placeholder with a sheet at three relative snaps: `.relativeBottom(0.125)`, `.relative(0.4)`, and `.relativeTop(0.975)`. The header has a title and a search field. Focusing search jumps to the top snap. `.enableAppleScrollBehavior()` lets the place list scroll only at that top snap on iPhone. Background blur and keyboard padding are on.

2. **Hug content** — `.dynamic` sizes the sheet to the header plus the rows. Add and remove stops and the height animates. `.dynamicBottom` keeps the header and hides the list. Fit and Header jump there in code; tapping the drag indicator cycles the same two positions.

3. **Modifier playground** — Toggles for the drag indicator, swipe to dismiss, a custom background, corner radius, shadow, hiding content when collapsed, the iPad floating sheet, and a slow `.customAnimation`. Peek, Half, Full, and Hide jump the position. On iPhone the toggle list scrolls only when the sheet is at `.relativeTop`.

4. **Point heights** — `.absoluteBottom(150)`, `.absolute(280)`, `.absolute(440)`, and `.absoluteTop(620)`. Header buttons set each height. The 620-point snap is the one that unlocks Apple scrolling.

## API notes

- Hiding the main content is not its own modifier. `.dynamicBottom`, `.relativeBottom`, and `.absoluteBottom` keep the header and hide the content. The other cases show it.
- Version 3 has no corner-radius modifier. Radius and shadow are part of the view passed to `.customBackground`. The library notes that a shadow there can disturb the hide transition.
- `.enableAppleScrollBehavior()` wraps the main content in a scroll view. On iPhone that scroll view only scrolls in a `...Top` position; a downward pull at the top of the list drags the sheet instead. iPad uses an ordinary scroll view. Do not combine it with `.enableContentDrag()` — the library says that glitches inside a scroll view.
- `.dynamic` measures its content. Scroll views, colors, and vertical spacers that expand to fill space fight that measurement. Drag-to-nearest-height also skips dynamic positions; tap the drag indicator to cycle them.
- `.enableFloatingIPadSheet` defaults to `true`. In the 3.1.1 source, `true` is an inset card aligned to the top on iPad, and `false` pins the sheet to the bottom. The README’s one-line description (“appear like on iPhone”) does not match that alignment.
- Setting `bottomSheetPosition` to `.hidden` yourself does not call `.onDismiss`. Swipe-to-dismiss does.
- Flick-through stays at the library default (on) unless a screen turns it off. It shares the 30% threshold with swipe-to-dismiss.
