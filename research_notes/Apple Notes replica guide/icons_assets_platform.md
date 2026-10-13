# Apple Notes (iPhone, iOS 26) — Icons, Assets, Platform & Implementation Approach

Research target: everything needed to make a sideloaded SwiftUI/UIKit app look and behave like Notes on **iOS 26.x** (test device: iPhone 12, iOS 26.6.2; Xcode 26.6 / iOS 26.5 SDK; XcodeGen 2.46.0). It covers: SF Symbol names for every Notes control, how they are weighted and rendered, the app icon (layers, colours, the iOS 26 Default/Dark/Clear/Tinted styles, Icon Composer, XcodeGen wiring), display name, the framework choice that gets native Liquid Glass bars, search, swipe actions and large titles "for free", the editor engine (UITextView + TextKit 2 vs SwiftUI `TextEditor(AttributedString)`), the keyboard formatting bar, and platform details (Dynamic Type, dark mode, VoiceOver, haptics, persistence, launch, status bar, Lock, Home Screen tells). It also covers what cannot be replicated and how to fake it, and an IP note. **iOS 27 shipped on 14 Sep 2026**, and its differences are listed separately. Labels used throughout: **[Apple]** = Apple-documented, **[Community]** = third-party reporting, **[Local]** = checked on this Mac (macOS 26.3 CoreGlyphs bundle / Apple Support asset images), **[Estimate]** = my inference. Not legal advice.

---

## Which SF Symbol does each Notes control use?

### Takeaway
Nearly every Notes control is a public SF Symbol. Apple's iOS 26 Support pages include the actual glyph images inline. I downloaded them and compared each one against symbols rendered on this Mac. **Matched exactly [Local]:** compose `square.and.pencil`, checklist `checklist`, table `tablecells`, attachments `paperclip`, markup/handwriting `pencil.tip.crop.circle`, format `textformat` ("Aa"), share `square.and.arrow.up`, more `ellipsis`, new folder `folder.badge.plus`, move `folder`, delete `trash`, lock/unlock `lock`/`lock.open`, search `magnifyingglass`, back `chevron.left`, collapse `chevron.down`, expand `chevron.right`, collaborate `person.crop.circle.badge.checkmark`, Done `checkmark` on a yellow prominent button. The Quick Note glyph (a rounded window with a scribble) has **no public symbol**; `quicknote` does not exist in the symbol list.

### Cited Findings
- **[Apple]** In the iOS 26 Notes guide, the inline icons carry these alt texts: "the New Note button", "the Done button", "the Format button", "the Checklist button", "the Add Table button", "the Attachments button", "the Handwriting Tools button", "the Note Actions / Folder Actions / More button" (the same ellipsis image for all three), "the Share button", "the Lock/Unlock button", "the New Folder button", "the Delete Folder button", "the Move Folder button", "the Search button", "the Collaborate button", "the Back button", "the Collapse/Expand button", and "the Quick Note button". — [Create and format notes (iOS 26)](https://support.apple.com/guide/iphone/create-and-format-notes-iph1ac0b3a2/26/ios/26); [Organize in folders](https://support.apple.com/guide/iphone/organize-in-folders-ipha61270292/26/ios/26); [Lock notes](https://support.apple.com/guide/iphone/lock-notes-iphf177bb154/26/ios/26); [Share and collaborate](https://support.apple.com/guide/iphone/share-and-collaborate-iphe4d04f674/26/ios/26); [Use Quick Notes](https://support.apple.com/guide/iphone/use-quick-notes-iph5084c0387/26/ios/26)
- **[Local]** I compared those images side by side with `NSImage(systemSymbolName:)` renders. The Checklist image (a filled check-circle row above an empty-circle row) is `checklist`, not `checklist.checked` or `checklist.unchecked`. The More image is a bare `ellipsis`. A yellow `ellipsis.circle` image also appears on the Share page, but it looks like a stale iOS 18 asset. The swipe-action images are `trash` (red, about #FF736D) and `folder` (indigo, about #8895F8). — Apple Support asset images (ipcdn/help.apple.com) on the pages above
- **[Local]** All of these names exist in the macOS 26.3 `CoreGlyphs.bundle/name_availability.plist` (9,184 symbols): `checklist` (2021), `tablecells` (2020), `textformat` (2019), `folder.badge.gearshape` (2021), `folder.badge.person.crop`, `pin`/`pin.fill`/`pin.slash`, `scribble.variable`, `note.text`, `apple.writing.tools`, `checklist.checked`/`.unchecked` (2022). `quicknote` is **absent**.
- **[Local]** `symbol_restrictions.strings` says `pencil.tip.crop.circle*` "may only be used to refer to Apple's Markup feature", `apple.writing.tools` only to Writing Tools, `apple.intelligence` only to Apple Intelligence, and `faceid` only to Face ID. Using them for the same meaning, as the replica does, is in spirit.
- **[Community]** TechWiser's walkthrough of the editor names the same set: share (up-arrow square), checklist (circle with lines), paperclip, pencil/markup, Writing Tools (the "DNA in circle" glyph), undo/redo (curved arrows in circles), table, and "Aa". The Aa panel holds B/I/U/S, colour, bullet/dash/numbered lists, outdent/indent and block quote. — [TechWiser](https://techwiser.com/what-do-icons-and-symbols-mean-on-apple-reminders-and-notes-app/)
- **[Apple]** Notes' ellipsis menu items are View as Gallery/List, Sort By (Date Edited/Date Created/Title), Group By Date, View Attachments, Select Notes, Create/Convert to Smart Folder. The note-level menu has Find in Note, Lines & Grids, Lock/Remove, Pin, Attachment View and Delete. Swiping right pins a note; swiping left offers Delete and Move. — [Change the Notes view](https://support.apple.com/guide/iphone/change-the-notes-view-iph65637affe/26/ios/26); [Organize in folders](https://support.apple.com/guide/iphone/organize-in-folders-ipha61270292/26/ios/26); [Use Notes (118442)](https://support.apple.com/en-al/118442)
- **[Apple]** Folder order: Quick Notes → Math Notes → Shared → account ("All iCloud", then "Notes", then user folders) → Recently Deleted (last; shown only if there are deletions in the last 30 days) → Tags section at the bottom. — [About accounts and folders (Mac Notes guide)](https://support.apple.com/guide/notes/notc3b2d538b/mac); [Organize with tags](https://support.apple.com/guide/iphone/organize-with-tags-iphedddbfdf9/26/ios/26); [Delete and recover](https://support.apple.com/guide/iphone/delete-and-recover-notes-iph904eee369/26/ios/26)

### Inferences — symbol map to build with
| Control (iOS 26) | SF Symbol | Status |
| --- | --- | --- |
| Compose / New Note | `square.and.pencil` | [Local] exact |
| New Folder (folders list bottom bar) | `folder.badge.plus` | [Local] exact |
| Folder row icon / Move swipe | `folder` | [Local] exact |
| Smart Folder row | `folder.badge.gearshape` | [Estimate] — verify |
| Shared row | `person.2` or `folder.badge.person.crop` (iOS 27 makes it blue) | [Estimate] — verify |
| Quick Notes row | private glyph; closest public options are `note.text` or a custom symbol from `note` + `scribble.variable` | [Local] no public match |
| Math Notes row | `x.squareroot` | [Estimate] — verify |
| Recently Deleted row / Delete swipe | `trash` | [Local] exact |
| Tags | `#name` capsule chips, "All Tags" chip; `number` if a glyph is needed | [Apple] text chips |
| Ellipsis (list and note) | `ellipsis` inside a glass circle (not `ellipsis.circle`) | [Local] |
| Back | `chevron.left` (system back button) | [Local] |
| Search | `magnifyingglass` (bottom search field) | [Local] |
| Checklist (toolbar) | `checklist` | [Local] exact |
| Table | `tablecells` | [Local] exact |
| Attachments | `paperclip`; menu items `camera`, `photo.on.rectangle`, `doc.viewfinder`, `text.viewfinder`, `waveform` | toolbar exact; menu items [Estimate] |
| Markup | `pencil.tip.crop.circle` | [Local] exact |
| Format | `textformat` ("Aa") | [Local] exact |
| Writing Tools | `apple.writing.tools` | [Local] exists — verify it shows on a non-AI iPhone 12 (probably hidden) |
| Share / Collaborate | `square.and.arrow.up` / `person.crop.circle.badge.checkmark` | [Local] exact |
| Pin / Unpin swipe | `pin.fill` / `pin.slash.fill` (orange-yellow) | [Estimate] |
| Lock / Unlock | `lock` / `lock.open`; locked row badge `lock.fill` | [Local] for the first two |
| Gallery / List / Select / Sort / Group by date | `square.grid.2x2` / `list.bullet` / `checkmark.circle` / `arrow.up.arrow.down` / `calendar` | [Estimate] |
| Done | `checkmark` on a prominent yellow glass circle | [Local] image ≈ #E8B906 |
| Checklist bullets in text | `circle` (unchecked, grey) / `checkmark.circle.fill` (yellow) | [Estimate] |
| Format panel | `bold` `italic` `underline` `strikethrough` `list.bullet` `list.dash` `list.number` `decrease.indent` `increase.indent` `text.quote` | [Estimate] |
| Undo / Redo | `arrow.uturn.backward(.circle)` / `arrow.uturn.forward(.circle)` | [Community] |

- **Weight, scale and rendering.** Let the system pick: `UIBarButtonItem(image: UIImage(systemName:))` or SwiftUI `Button(_, systemImage:)` inside `.toolbar`. Don't set your own `SymbolConfiguration` on bar items. iOS 26 bars render icons monochrome in `labelColor` and reserve tint for the prominent action. For in-content glyphs (folder rows, checklist circles), use `.font(.body)` / `UIImage.SymbolConfiguration(textStyle: .body)`, `.regular` weight, `.hierarchical` or monochrome with the Notes yellow tint. [Apple, WWDC25-323/284] + [Estimate]

---

## What does the app icon look like, and how do I build the replica's icon?

### Takeaway
On iOS 26 the Notes icon is a light, nearly white "paper" body with a **yellow header band** across roughly the top quarter, a fine **perforated tear line** under the band, and **two grey ruled lines**. Liquid Glass adds the specular rim. Build it as a 2–3 group Icon Composer `.icon` file: a background gradient plus band and line layers. Supply Dark and Mono (Clear/Tinted) annotations. Set the display name to `Notes`. XcodeGen ≥ 2.45.1 understands `.icon` folders natively.

### Cited Findings
- **[Local]** Sampling Apple's iOS 26 Support thumbnail (60×60) gives: band ≈ `#FFDA3B`, brightening to `#FFE250` at its lower edge; body gradient ≈ `#FAFAFA` at the top to `#EFEFEF` at the bottom; ruled lines ≈ `#D7D7D7`; perforation dots just under the band. The iOS 27 thumbnail has a more saturated band (`#FFD616`–`#FFDB3D`) and a whiter body (`#FFFEFF`–`#FAFAFA`). These are **[Estimate]** values, because the thumbnails are downscaled. — icons on [Create and format notes (iOS 26)](https://support.apple.com/guide/iphone/create-and-format-notes-iph1ac0b3a2/26/ios/26) and [current (iOS 27) page](https://support.apple.com/guide/iphone/create-and-format-notes-iph1ac0b3a2/ios)
- **[Community]** iOS 26 shipped "a revised app icon" for Notes, and iOS 27 a "newly refreshed app icon". — [9to5Mac iOS 26 Notes](https://9to5mac.com/2025/07/17/heres-everything-new-for-apple-notes-in-ios-26/); [9to5Mac iOS 27 Notes](https://9to5mac.com/2026/09/28/heres-everything-new-for-apple-notes-in-ios-27/)
- **[Apple]** iOS icons are 1024×1024, with appearances Default, Dark, Clear light, Clear dark, Tinted light and Tinted dark. "The system automatically generates variants you don't provide." Provide square, **unmasked** layers; the system applies the mask, specular highlights and shadows. — [HIG: App icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- **[Apple]** Icon Composer workflow: import SVG/PNG layers, use at most **four groups**, keep the canvas at 1024², set a solid or gradient background inside Icon Composer, and preview Clear/Tinted through Mono → Options. Add the `.icon` file to the project and make the target's App Icon name match the filename (`ASSETCATALOG_COMPILER_APPICON_NAME`). It replaces the AppIcon asset set, and Xcode generates fallbacks for older OSes. — [Creating your app icon using Icon Composer](https://developer.apple.com/documentation/xcode/creating-your-app-icon-using-icon-composer); [WWDC25-361 Create icons with Icon Composer](https://developer.apple.com/videos/play/wwdc2025/361/)
- **[Community]** Pitfalls: remove or rename the old `AppIcon.appiconset`, or the icon may not show. Alternate icons still need asset-catalog PNGs. — [Use Your Loaf](https://useyourloaf.com/blog/adding-icon-composer-icons-to-xcode/); [Apple forums 813010](https://developer.apple.com/forums/thread/813010)
- **[Apple/Community]** XcodeGen 2.45.1 changelog: "Added built in `.icon` folder support for IconComposer (#1600)". — [XcodeGen CHANGELOG](https://github.com/yonaskolb/XcodeGen/blob/master/CHANGELOG.md)

### Inferences
- **Layers [Estimate]:** (1) a background gradient `#FAFAFA→#EEEEEE` set in Icon Composer; (2) a yellow band rectangle (top ~27%) with a subtle `#FFD93A→#FFE14E` vertical gradient; (3) a perforation row of tiny dots plus two rounded grey rules at about 45% and 70% height, inset ~14% from each side. In Dark mode use a dark-grey body (~`#2C2C2E`) with the same yellow band. Mono: band at full opacity, lines at ~50%. Compare at 100% zoom on the Home Screen against the real icon, using the same wallpaper.
- XcodeGen: put `AppIcon.icon` under the target's sources, keep `ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon`, delete the `.appiconset`, and set `INFOPLIST_KEY_CFBundleDisplayName: Notes`. Use a different bundle ID (e.g. `com.rahulbhatt.MagicNotes`); the system Notes app is `com.apple.mobilenotes`. Sketch:

  ```yaml
  options: { deploymentTarget: { iOS: "26.0" } }
  settings: { base: {
    INFOPLIST_KEY_CFBundleDisplayName: Notes,
    ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon,          # = AppIcon.icon (Icon Composer)
    ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME: AccentColor,  # Notes yellow, light/dark
    INFOPLIST_KEY_NSFaceIDUsageDescription: "Unlock locked notes." } }
  ```

---

## SwiftUI or UIKit for the shell (folders → notes list → note)?

### Takeaway
Both produce native iOS 26 Liquid Glass bars, inset-grouped lists, large titles, swipe actions, a bottom search field and the zoom/morph transitions without custom drawing. **Recommendation:** use a **SwiftUI `NavigationStack` + `List`** for the folders and notes lists. It is fastest, matches the existing SwiftUI codebase, and Apple's own samples show the Mail-style "search + compose" bottom bar. Use **UIKit for the editor** (next section). Drop to a `UICollectionView` list only if a pixel test shows a row or spacing you can't reach in SwiftUI.

### Cited Findings
- **[Apple]** "Toolbar items are placed on a Liquid Glass surface… automatically grouped." `ToolbarSpacer(.fixed/.flexible)` splits groups. Apple's Mail example is `ToolbarItem(.bottomBar){filter}`, `ToolbarSpacer(.flexible)`, `DefaultToolbarItem(kind: .search, placement: .bottomBar)`, `ToolbarSpacer(.fixed)`, `ToolbarItem{compose}`. Also documented: `searchToolbarBehavior(.minimize)`, `.badge`, and `sharedBackgroundVisibility(.hidden)`. Icons are monochrome by default, and tint is reserved for meaning. — [WWDC25-323 Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
- **[Apple]** UIKit equivalents: `toolbarItems = [navigationItem.searchBarPlacementBarButtonItem, .flexibleSpace(), addButton]`; `.fixedSpace(0)` to split groups; `flexibleSpace.hidesSharedBackground = false`; `style = .prominent` + `tintColor` for the Done button; `navigationItem.subtitle`/`largeSubtitleView`; `scrollView.topEdgeEffect.style`; `UIGlassEffect` for custom views; content-area back-swipe (swipe actions take priority over it). — [WWDC25-284 Build a UIKit app with the new design](https://developer.apple.com/videos/play/wwdc2025/284/)
- **[Apple]** Liquid Glass belongs only on the navigation layer: "avoid glass on glass", tint only primary actions, prefer the Regular variant over Clear. — [WWDC25-219 Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
- **[Community]** In iOS 26 Notes, search is "prominently available at the bottom of the screen" and is "always docked at the bottom". Top buttons became glass circles and pills. — [9to5Mac](https://9to5mac.com/2025/10/16/heres-everything-new-for-apple-notes-in-ios-26/); [MacStories iOS 26 review p.3](https://www.macstories.net/stories/ios-and-ipados-26-the-macstories-review/3)

### Inferences
- Folders screen: `List { Section { rows } }.listStyle(.insetGrouped)`, large title "Folders", "Edit" at top right, bottom bar `folder.badge.plus` … `square.and.pencil`. Notes list: `.navigationTitle(folder.name)`, large title; `.searchable` with `DefaultToolbarItem(kind: .search, placement: .bottomBar)` + `ToolbarSpacer(.fixed)` + compose; `ellipsis` `Menu` at top right; `.swipeActions(edge: .leading){pin}` and `.swipeActions(edge: .trailing){delete, move}`; a "Pinned" section. Show the note count as `.navigationSubtitle` (iOS 26), or wherever the device shows it.
- Set the deployment target to **iOS 26.0** so glass APIs need no `#available` checks. Never set `UIDesignRequiresCompatibility` (it switches off Liquid Glass).

---

## Which editor engine: UITextView (TextKit 2) or SwiftUI `TextEditor(AttributedString)`?

### Takeaway
**Use `UITextView` with TextKit 2, wrapped in `UIViewRepresentable`.** iOS 26's `TextEditor` + `AttributedString` is good for basic rich text. It cannot do inline attachments (checklist circles, tables, images), has no list paragraph model, and gives no access to the caret, `inputAccessoryView` or attachment hit-testing. Notes needs all of those. `UITextView` provides native caret/selection/loupe, the edit menu, `undoManager` (shake and three-finger gestures), data detectors, `NSTextList` bullets/numbering and view-based attachments.

### Cited Findings
- **[Apple]** iOS 26 `TextEditor(text: $attributedString, selection:)` supports bold, italic, underline, strikethrough, font/size, colours, kerning, tracking, baseline, Genmoji, line height, alignment and writing direction. Selection is a `RangeSet`, mutations go through `transform(updating:)`, and `AttributedTextFormattingDefinition` plus value constraints restrict what users can apply. The session does not cover lists or attachments. — [WWDC25-280 Rich text in SwiftUI](https://developer.apple.com/videos/play/wwdc2025/280/); [Building rich SwiftUI text experiences](https://developer.apple.com/documentation/swiftui/building-rich-swiftui-text-experiences)
- **[Apple forum]** An Apple engineer said TextEditor + AttributedString "doesn't appear to support inline attachments" and suggested filing feedback. Other threads report odd format-panel scoping and no API to open the Format sheet programmatically. — [Forum 787898](https://developer.apple.com/forums/thread/787898); [795644](https://developer.apple.com/forums/thread/795644); [798354](https://developer.apple.com/forums/thread/798354)
- **[Apple]** UITextView has used TextKit 2 by default since iOS 16. Touching `layoutManager` silently falls back to TextKit 1 ("no automatic way of going back"). `NSTextList` + `NSMutableParagraphStyle` gives lists in UIKit. View-provider attachments let "events be handled directly by the attachment view… only possible with TextKit 2". — [WWDC22-10090 What's new in TextKit and text views](https://developer.apple.com/videos/play/wwdc2022/10090/); [WWDC21 Meet TextKit 2](https://developer.apple.com/videos/play/wwdc2021/10061/)
- **[Apple]** `UITextFormattingViewController` (iOS 18+) is the system "Aa"-style formatting sheet, configured with component groups (styles, font, size, alignment, lists, highlight) and connected through `UITextView.textFormattingConfiguration`. — [UITextFormattingViewController](https://developer.apple.com/documentation/uikit/uitextformattingviewcontroller)

### Inferences
- Model: store notes as **blocks** (paragraph style: title/heading/subheading/body/mono/bullet/dash/number/checklist(done)/quote, indent level, inline runs). Render the blocks to `NSAttributedString` and parse back on edit. The first line gets the Title style automatically. Checklist rows: an `NSTextAttachment` with an `NSTextAttachmentViewProvider` showing a tappable `circle`/`checkmark.circle.fill` image view, plus a paragraph head indent so wrapped lines align. Toggle the done state with `textStorage` edits inside `undoManager` grouping so undo restores it.
- The Aa panel: building your own sheet that looks like Notes (Title/Heading/Subheading/Body/Monostyled chips, B I U S, lists, indents) gives better fidelity than `UITextFormattingViewController`, whose layout differs from Notes. Verify on device.

---

## How do I build the keyboard formatting bar and bottom toolbar on iOS 26?

### Takeaway
iOS 26 Notes shows a **floating, horizontally scrollable glass capsule above the keyboard**. It adapts to context: B/I/U while typing; list, indent and quote tools when several lines are selected. When the keyboard is down it switches to a bottom glass toolbar (checklist, paperclip, markup, compose). Build the keyboard bar as the `UITextView.inputAccessoryView`: a transparent container holding a `UIVisualEffectView(effect: UIGlassEffect())` capsule with a `UIScrollView` of buttons. Build the resting toolbar with SwiftUI `.toolbar(.bottomBar)`.

### Cited Findings
- **[Community]** The toolbar "sits above the software keyboard", can be swiped horizontally (18 buttons, the first six as in iOS 18), and adapts to the selection (multi-line → list tools, indent/outdent, block quote). — [9to5Mac iOS 26 Notes](https://9to5mac.com/2025/10/16/heres-everything-new-for-apple-notes-in-ios-26/); [9to5Mac adaptive toolbar](https://9to5mac.com/2026/03/12/ios-26-added-four-new-features-ive-been-using-almost-every-day/); [PhoneArena](https://www.phonearena.com/news/adaptive-toolbar-added-to-native-ios-app_id173060)
- **[Apple forum]** On iOS 26 the system keyboard has its own inset, rounded top, so an `inputAccessoryView` no longer sits flush (FB17978212). A `UIToolbar` accessory with menus can misbehave, and the workaround is a custom view. A SwiftUI `.keyboard` toolbar can block taps on content beneath it. — [Forum 787687](https://developer.apple.com/forums/thread/787687); [804465](https://developer.apple.com/forums/thread/804465); [846059](https://developer.apple.com/forums/thread/846059)
- **[Apple]** Glass for custom UIKit views: `UIVisualEffectView` + `UIGlassEffect` (`isInteractive = true`), animated in and out by setting `effect`. — [WWDC25-284](https://developer.apple.com/videos/play/wwdc2025/284/)

### Inferences
- Avoid `ToolbarItemGroup(placement: .keyboard)`: it only appears for SwiftUI-focused fields, not for a representable UITextView. Use `inputAccessoryView`, and call `reloadInputViews()` when the context changes. Pair it with `keyboardDismissMode = .interactive` so the bar follows the keyboard down. If the gap or sizing misbehaves, fall back to a view pinned to `view.keyboardLayoutGuide.topAnchor`.
- The floating gap that frustrates other developers is exactly Notes' look, so use a transparent accessory background, ~8 pt side insets, a capsule height of ~44 pt, and `ellipsis`/`xmark` affordances as the device shows. Measure them.

---

## Platform behaviour: Dynamic Type, dark mode, VoiceOver, haptics, persistence, launch, status bar, Lock

### Takeaway
Use system semantics everywhere (text styles, `systemGroupedBackground`/`secondarySystemGroupedBackground`, `label`/`secondaryLabel`, an accent asset for the Notes yellow). Dark mode and Dynamic Type then match automatically. Persist with **Codable JSON** in Application Support; SwiftData is optional. Fake Lock with LocalAuthentication. Siri, Spotlight, widgets and App Intents are **not needed**: skip them.

### Cited Findings
- **[Apple]** Notes searches typed and handwritten text, image objects and scans. Locked notes show only their title. Lock uses the device passcode/Face ID or a custom password, with a "Lock Now" control at the top of the list. Recently Deleted keeps notes for 30 days. An orange dot marks changed shared notes. Tags turn yellow when activated. — [Search notes](https://support.apple.com/guide/iphone/search-notes-iphb8628c6b8/26/ios/26); [Lock notes](https://support.apple.com/guide/iphone/lock-notes-iphf177bb154/26/ios/26); [Delete and recover](https://support.apple.com/guide/iphone/delete-and-recover-notes-iph904eee369/26/ios/26); [Share and collaborate](https://support.apple.com/guide/iphone/share-and-collaborate-iphe4d04f674/26/ios/26); [Organize with tags](https://support.apple.com/guide/iphone/organize-with-tags-iphedddbfdf9/26/ios/26)
- **[Apple]** Settings → Apps → Notes includes Viewing (sort, Lines & Grids, group by date), Auto Convert to Tag, Lock Screen access, and Search ("allow content to appear in Search"). — [Change Notes settings](https://support.apple.com/guide/iphone/change-notes-settings-iph92579feda/26/ios/26)
- **[Local]** The Notes accent in Apple's iOS 26 glyph images is ≈ `#E8B906`–`#F0B500` (Done, Collaborate, Folder Actions), [Estimate] for light mode.
- **[Community]** Older Home Screen quick actions were New Note, New Checklist, New Photo and New Sketch; newer reports list Scan Document. — [iPhoneLife](https://iphonelife.com/content/how-to-quickly-create-new-checklist-notes-3d-touch); [leapp.nl](https://leapp.nl/en/blogs/ipad/ontdek-deze-10-verborgen-apple-notes-functies-die-je-productiviteit-verdubbelen)

### Inferences
- **Dynamic Type:** `UIFont.preferredFont(forTextStyle:)` + `adjustsFontForContentSizeCategory = true` in the editor; SwiftUI text styles in the lists. **Dark mode:** paper `systemBackground` (black in dark), lists `systemGroupedBackground`; keep the yellow accent in both, with a slightly darker yellow in light mode. **Status bar:** default (automatic); do not force a style.
- **VoiceOver:** use Apple's alt-text names as labels ("New Note", "Format", "Checklist", "Add Table", "Attachments", "Handwriting Tools", "More", "Share", "Done", "New Folder", "Search"). Checklist rows get `.isButton` plus a "completed" value.
- **Haptics:** none is documented for Notes. Swipe-action full-swipe and context-menu haptics come free from the system. Add nothing custom unless the device shows it (verify checklist taps and pinning).
- **Persistence:** one JSON file (folders, notes as blocks, pinned, locked, tags, deletedAt), written atomically on a debounce and on `scenePhase == .background`. Also persist the last-open folder and note and restore the `NavigationStack` path, since Notes resumes the last note. SwiftData works but adds migration risk for no visible gain.
- **Lock:** `LAContext().evaluatePolicy(.deviceOwnerAuthentication)`. Add `NSFaceIDUsageDescription` (iPhone 12 has Face ID). Show "This note is locked." with a `lock` glyph and a View Note button.
- **Launch:** `UILaunchScreen` with `UIColorName` set to the grouped-background colour. Notes usually restores from the snapshot anyway.
- **Home Screen fidelity:** add `UIApplicationShortcutItems` with `UIApplicationShortcutItemIconSymbolName` (`square.and.pencil`, `checklist`, `camera`, `doc.viewfinder`). Move the real Notes to the App Library and turn off its Search toggle so it doesn't show up next to the replica.

---

## What can't be replicated, and how do I fake it convincingly?

### Takeaway
iCloud sync and collaboration, Apple Intelligence (Writing Tools, Image Wand, Siri AI), real handwriting recognition, Math Notes evaluation, audio transcription, Quick Note from Control Center, and the Lock Screen Notes entry all belong to Apple and are off limits to a sideloaded app. Show the chrome and make the actions harmless.

### Cited Findings
- **[Apple]** Quick Notes come from a Control Center button or the share sheet, and handwriting uses Markup tools with Smart Selection. Writing Tools and Image Wand require Apple Intelligence hardware, which the iPhone 12 lacks. — [Use Quick Notes](https://support.apple.com/guide/iphone/use-quick-notes-iph5084c0387/26/ios/26); [Add drawings and handwriting](https://support.apple.com/guide/iphone/add-drawings-and-handwriting-iphd939f0a1c/26/ios/26); [Create and format notes](https://support.apple.com/guide/iphone/create-and-format-notes-iph1ac0b3a2/26/ios/26)

### Inferences
| Feature | Fake |
| --- | --- |
| iCloud account header ("iCloud", "All iCloud") | Static section titles; seed realistic folders and notes |
| Shared / collaboration | Static "Shared" folder and person badges; Share opens `UIActivityViewController` with plain text |
| Markup / handwriting | PencilKit `PKCanvasView` + `PKToolPicker` (public API; looks close to native); no transcription |
| Attachments | `PHPickerViewController`, camera, `VNDocumentCameraViewController` (scan): all public APIs |
| Writing Tools / Apple Intelligence | Hide them, since a genuine iPhone 12 doesn't show them |
| Audio recording / transcription | Omit unless the routine needs it (AVAudioRecorder for audio only) |
| Search of handwriting and images | Search typed text only |

---

## IP note (personal use; not legal advice)

- **[Apple]** Apple prohibits using its icons, logos and trade dress on third-party products without a licence. App Review 4.1 rejects copycats. — [Apple trademark guidelines](https://www.apple.com/legal/intellectual-property/guidelinesfor3rdparties.html); [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- **[Estimate]** A personally sideloaded, development-signed build that is never distributed carries little practical risk. Still, draw the icon yourself rather than extracting Apple's artwork. Never submit it to the App Store or TestFlight. Using restricted symbols (`pencil.tip.crop.circle`, `apple.writing.tools`) for their real meaning is acceptable inside the app.

---

## iOS 27 differences (shipped 14 Sep 2026; secondary target)

- **[Community]** iOS 27 Notes: refreshed app icon; a new **blue Shared folder icon** at the top of the folders list; updated icons for shared folders and notes; Liquid Glass refinements to buttons and menus; **Insert Divider Line** (edit menu / Expand button); **Link to Section**; Markdown paste → rich text and **Copy as Markdown**; Siri AI note creation. — [9to5Mac iOS 27 Notes](https://9to5mac.com/2026/09/28/heres-everything-new-for-apple-notes-in-ios-27/); [AllThings.how](https://allthings.how/apple-notes-in-ios-27-divider-lines-siri-ai-and-markdown-upgrades/); [Business Today: release date](https://www.businesstoday.in/technology/news/story/apple-announces-ios-27-release-date-check-when-your-iphone-gets-the-update-554454-2026-09-10)
- **[Apple]** The current (iOS 27) Support page adds "Add a divider line: … tap the Expand button, then choose Insert Divider Line". — [Create and format notes (current)](https://support.apple.com/guide/iphone/create-and-format-notes-iph1ac0b3a2/ios)
- **[Estimate]** Keep the iPhone 12 on iOS 26.6.2 and turn off automatic updates. If it updates, swap the icon (more saturated band, whiter body) and the Shared glyph, and add the divider item.

---

## Verification gaps (check on device)

1. Folder row glyphs for **Smart Folder, Shared, Quick Notes, Math Notes, Tags**, and their tint (yellow?). Screenshot the folders list in light and dark mode.
2. Are iOS 26 toolbar glyphs monochrome (`label`) or yellow? Is Done a yellow prominent circle in both modes? Measure the accent hex in light and dark.
3. Exact contents and order of the keyboard bar (all ~18 items), when it adapts, and whether a dismiss-keyboard button exists. Exact resting bottom-bar items in the editor and their grouping.
4. Notes list chrome: where the note count appears (subtitle or bar), the bottom search + compose grouping, and whether the ellipsis menu items show the symbols guessed above.
5. Swipe actions: leading pin colour; whether trailing includes Share in addition to Delete and Move; colours.
6. Checklist circle size, weight and colour, and whether ticking a checklist item, pinning or deleting plays any haptic.
7. Attachments menu items and symbols (camera / photo / scan / audio / file).
8. Real icon pixels: Home Screen screenshot of Notes in Default, Dark, Clear and Tinted modes for side-by-side matching with the replica's `.icon`.
9. The real app's Home Screen long-press menu on iOS 26 (quick actions; is "Share App" present?), so the replica's menu matches.
10. Whether `inputAccessoryView` glass shows the iOS 26 gap/inset correctly on 26.6.2; if not, switch to a `keyboardLayoutGuide`-pinned bar.
11. That `UITextView` stays on TextKit 2 (no `_UITextViewEnablingCompatibilityMode` log) once attachments are added.
