# Build an indistinguishable Notes on iOS 26

A replica of Apple Notes that a spectator can open, browse and type into without noticing anything is buildable almost entirely with **stock iOS 26 components**: Notes' iOS 26 chrome is plain Liquid Glass (system bars, inset-grouped lists, bottom search), and its visual tokens are a handful of system colors plus one custom gold. The hard numbers here are unusually solid: colors, fonts and paragraph metrics were read **directly from the Notes frameworks** in Xcode's iOS 26.5 Simulator runtime (`NotesUI`, `NotesEditor`, `NotesShared`), not color-picked from screenshots; layout comes from Apple's own iOS 26 Support screenshots; behavior from the iOS 26 Notes User Guide. What's left unverified is listed at the end and needs ten minutes with the real app on the test iPhone 12 (iOS 26.6.2). iOS 27 shipped on 2026-09-14 and supports the iPhone 12; **keep the test phone on 26.6.2** (differences in the last section). Not legal advice.

Topic notes: [layout & screens](../research_notes/Apple%20Notes%20replica%20guide/layout_screens_ui.md) · [colors & typography](../research_notes/Apple%20Notes%20replica%20guide/colors_typography_tokens.md) · [features & behavior](../research_notes/Apple%20Notes%20replica%20guide/features_behavior.md) · [icons, assets & platform](../research_notes/Apple%20Notes%20replica%20guide/icons_assets_platform.md).

## Three screens on one push stack

**Folders → Notes list → Note editor**, with search, menus, sheets and selection mode layered on top. iOS 26 kept the iOS 18 structure and replaced all the chrome:

| Area | iOS 26 (target) | iOS 18 (don't copy) |
|---|---|---|
| Bar items | Monochrome glyphs on floating glass circles/capsules | Yellow text and glyphs |
| Back | Chevron-only glass circle | "‹ Folders" in yellow |
| Search | Bottom capsule (magnifier, "Search", mic) beside a 48 pt compose circle | Under the large title |
| Note count | Subtitle under the large title ("45 Notes") | Bottom toolbar label |
| New Folder | Top-right circle beside **Edit** | Bottom-left toolbar |
| Editor bottom | Tool capsule (checklist, paperclip, markup) + separate compose circle | Four spaced yellow glyphs |
| Done | Gold prominent circle with a white `checkmark` | "Done" text |
| Keyboard bar | Floating, horizontally scrolling glass capsule, adaptive (18 tools) | Fixed row of 6 |
| Lists | Inset-grouped, ~24–26 pt corners, 52 pt folder rows | ~10 pt corners, 44 pt rows |
| Swipe actions | Circular buttons with labels | Full-height rectangles |

**Folders**: large title "Folders"; an "iCloud" section (All iCloud, Notes, user folders, gold `folder` glyphs, trailing counts); Recently Deleted only when non-empty; Tags at the bottom. **Notes list**: folder name large title + "N Notes" subtitle; `ellipsis` menu top-right; sections **Pinned → Today → Yesterday → Previous 7 Days → Previous 30 Days → months → years**; rows = semibold title, then date + two spaces + preview ("No additional text" when empty), a folder line only in aggregate views. Trailing swipe **Share (`#3293FC`) · Move (`#787AFF`) · Delete (red)**, leading swipe **Pin (`#FF9400`)**. **Editor**: back circle; top-right Share + `ellipsis` capsule, plus an Undo circle after the first edit and the gold Done while editing; no title in the bar.

## Tokens: system colors plus one gold

- **Accent `#E4AF0A`** in light *and* dark (Increase Contrast `#B68C08`). Not `systemYellow`, which is visibly lemon. Selection fill `#E4AF0A`@20% light / `#FFD966`@50% dark. System switches inside Notes stay blue.
- **Backgrounds**: lists `systemGroupedBackground` with cells on `secondarySystemGroupedBackground`; editor `systemBackground`, text `label`. Table borders `systemGray4`.

| Editor style | Font (default size) | lineSpacing / paragraphSpacing |
|---|---|---|
| Title (new notes' first line) | SF Pro Bold 28 | 1 / 3 |
| Heading | SF Pro Bold 22 | 0 / 4 |
| Subheading | SF Pro Bold 17 | 4 / 0 |
| Body | SF Pro Regular 17 | 4 / 0 |
| Monostyled | SF Mono Regular 15 | 2 / 0 |
| Lists / checklist | inherit Body | 2 / 0; checklist 0 / 3.5 (+3.5 before) |

All scale with Dynamic Type through the Body metrics. Chrome: list title Semibold 17, detail Regular 15, section headers Semibold 20, large titles Bold 34. Checklist: `circle` 17 Regular in `tertiaryLabel` → `checkmark.circle.fill` 17 Medium in gold. Highlights: system purple / pink / orange / mint / blue via UIKit's `textHighlightColorScheme`.

## Behavior a spectator will notice

1. **First line is the title** (Title style); Return after it switches to Body. Untitled = "New Note".
2. **Continuous autosave**; Done only ends editing; an empty new note is discarded silently on back.
3. **Row dates**: time today, "Yesterday", weekday within the week, short date otherwise; always the *edited* date.
4. **Undo** appears in the top bar only after an edit; shake / three-finger gestures come with `UITextView`.
5. **Checklists**: tap the circle; Return continues; Return on an empty item exits.
6. **Inline math**: `12+30=` shows a gray suggested result that Return inserts. A spectator doing sums will expect it.
7. **No Apple Intelligence on the iPhone 12**: no Writing Tools button anywhere. Audio transcription does exist.

## How to build it

- **SwiftUI `NavigationStack` + `List(.insetGrouped)`** for folders and notes: glass bars, large titles with subtitle, bottom search (`DefaultToolbarItem(kind: .search, placement: .bottomBar)` + `ToolbarSpacer` + compose), swipe actions and context menus come for free. Deployment target iOS 26.0; never set `UIDesignRequiresCompatibility`.
- **`UITextView` (TextKit 2) for the editor**, not SwiftUI `TextEditor`: it gives the native caret, loupe, edit menu, undo and data detectors, and supports attachments for checklist circles and tables. Store notes as paragraphs (style, inline runs, checked) and render to `NSAttributedString`. Never touch `layoutManager` (falls back to TextKit 1).
- **Keyboard bar** = `inputAccessoryView` holding a `UIGlassEffect` capsule with a horizontal scroll of buttons (iOS 26's inset keyboard makes the floating gap look native).
- **Icon**: Icon Composer `.icon` (yellow band ~`#FFDA3B`, perforation, near-white body, two gray rules), Default/Dark/Mono; display name "Notes"; XcodeGen ≥ 2.45.1 reads `.icon` folders. Draw it, don't extract Apple's.
- **Fake, don't implement**: iCloud (static section names), sharing (system share sheet), Markup (PencilKit), attachments (system pickers), search over typed text only.

## Build order

1. Lists chrome and rows with real date grouping; native push/pop.
2. Editor: Title first line, Return → Body, autosave, empty discard, top bar (undo/share/more/Done), bottom tool capsule.
3. Keyboard bar visuals (Aa, checklist, table, paperclip, markup, B I U S), checklists.
4. Inline math suggestion; swipe/context menus; Aa format card; highlights; tags, links, lists, sections.

## Check on the device (iPhone 12, iOS 26.6.2)

Editor bottom capsule and keyboard-bar order without Apple Intelligence · whether the gray date stamp above a note still exists · row date color (label vs secondary) · glass bar glyphs gold or monochrome · editor text inset (~26 pt?) · ruled-paper pitch · swipe sets and haptics · checked-item styling · folder glyphs for Smart Folder / Shared / Quick Notes.

## iOS 27 (shipped 2026-09-14)

Refreshed icon (more saturated band), colored square Quick Notes / Shared icons, Select All + icon-only select-mode bar, reordered attachments menu, Insert Divider Line, Link to Section, Markdown paste / Copy as Markdown, Siri AI notes. No color or font changes. Only matters if the test phone updates.
