# Apple Notes (iPhone): Screens, Layout Geometry and UI Structure

Research target: Apple Notes on iPhone as it ships in **iOS 26.x** (Liquid Glass). The test device is an iPhone 12 (390×844 pt, @3x) on iOS 26.6.2, built with Xcode 26.6 and the iOS 26.5 SDK. iOS 27 shipped on 2026-09-14, and its Notes differences are kept in a separate labeled section near the end. iOS 26 is the primary target. Every finding carries a provenance label. **[Apple-doc]** means Apple Support, HIG or WWDC text. **[Apple-shot]** means an official Apple Support screenshot of iOS 26 (iPhone 17 Pro, 402×874 pt), which is first-party visual evidence but not a spec. **[Community]** means press, forum or reverse-engineered material. **[Estimate]** means a value measured from screenshots or inferred. Apple publishes no pt-level spec for Notes. Pixel numbers below come from Apple's 640×1320 px support screenshots, where the 402 pt screen spans 586 px (about 1.458 px per pt). They are accurate to roughly ±2 pt.

---

## What screens exist and how does the user navigate between them?

### Takeaway
iPhone Notes is a three-level push stack: **Folders list → Notes list (one folder, smart folder, tag filter or account "All") → Note editor**. The other surfaces are layered on that stack. They are search (an in-place results list driven by the bottom search field), menus that morph out of glass buttons (the "…" folder and note actions, the attachments menu), sheets (folder picker or Move, the share and collaborate panel, New Folder, Smart Folder filters, Quick Note), alerts (Recently Deleted "Recover"), and selection (edit) mode. The basic structure is the same as in iOS 18. Liquid Glass reskinned and moved the chrome.

### Cited Findings
- [Apple-doc] The folders list hosts New Folder, a Tags section "at the bottom of the folders list", an Edit button "at the top of the folders list", Quick Notes, and Recently Deleted. Recently Deleted appears only when it contains notes ("If you don't see Recently Deleted, you don't have any notes in that folder"). — [Organize with tags](https://support.apple.com/guide/iphone/organize-with-tags-iphedddbfdf9/26/ios/26); [Delete and recover notes](https://support.apple.com/guide/iphone/delete-and-recover-notes-iph904eee369/26/ios/26); [Use Quick Notes](https://support.apple.com/guide/iphone/use-quick-notes-iph5084c0387/26/ios/26)
- [Apple-shot] The iOS 26 folders list, from top to bottom: an ungrouped card holding **Quick Notes (4)** and **Shared (10)** with yellow line icons; an account header **"iCloud"** with a yellow collapse chevron on the right; a card holding **All iCloud (45), Notes (34)** and user folders (a gear icon marks a Smart Folder); then a **"Tags"** header with a chevron and a card of tag chips (All Tags, #California, #Gardening…). — [Apple screenshot: iOS 26 folders](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-folders.png) via [Apple Support 118442](https://support.apple.com/en-us/118442)
- [Apple-doc] Accounts. Notes supports iCloud, an "On My iPhone" account (turned on under Settings › Apps › Notes) and Exchange, Google or Yahoo accounts. Each account becomes its own section in the folders list. — [Add or remove accounts](https://support.apple.com/guide/iphone/add-or-remove-accounts-iph7262fd4fe/26/ios/26)
- [Apple-doc] Smart Folders are created from New Folder → "Make Into Smart Folder" or from the folder "…" menu → "Convert to Smart Folder". Tag browsing works by tapping All Tags or individual tags, which opens a filtered notes list. — [Use Smart Folders](https://support.apple.com/guide/iphone/use-smart-folders-iphc43adabc2/26/ios/26); [Organize with tags](https://support.apple.com/guide/iphone/organize-with-tags-iphedddbfdf9/26/ios/26)
- [Apple-doc] Moving back up the stack uses "the Back button" (a chevron). Quick Notes: "You may have to tap [Back] to see your folders." — [Use Quick Notes](https://support.apple.com/guide/iphone/use-quick-notes-iph5084c0387/26/ios/26); [Apple Support 118442](https://support.apple.com/en-us/118442)
- [Apple-doc] Quick Notes created from Control Center or the Share sheet present as an overlay with **Save** at the top left. In Notes they live in the Quick Notes folder. — [Use Quick Notes](https://support.apple.com/guide/iphone/use-quick-notes-iph5084c0387/26/ios/26)
- [Apple-shot] The Share-extension "save to note" sheet has a glass **×** circle on the left, a centered inline title "Notes", and a yellow prominent **Save** capsule on the right. Below them sit an inset-grouped "SAVE TO" row with a disclosure chevron, a footer, and a text and attachment card. — [Apple screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-safari-share-save-to-note-attachment.png)
- [Apple-doc] Opening a note in Recently Deleted shows an alert, "Recently Deleted Note – Recently deleted notes can't be edited… – Cancel / Recover". In iOS 26 the alert has two side-by-side capsule buttons. — [Apple Support 118442](https://support.apple.com/en-us/118442); [Apple screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-recently-deleted-note-tap-recover.png)

### Inferences
- Model the replica as `NavigationStack { Folders → NotesList(scope) → Editor(note) }`. Scope is one of: a folder, All‹Account›, Quick Notes, Shared, Recently Deleted, a Smart Folder, or a tag filter. The magic routine only needs the stack, the bottom search and compose bar, and the editor. Sheets and menus can be stubs, but they must still *appear* on tap.
- On a fresh device with no shared notes and nothing deleted, the **Shared** and **Recently Deleted** rows are absent. Show or hide them to match the state you want the audience to see.

---

## What is in the navigation bar and bottom bar of each screen in iOS 26?

### Takeaway
iOS 26 removed the iOS 18 yellow text chrome. Bar items are now **monochrome (label-colored) glyphs on floating glass circles and capsules**. Back is a **chevron-only circle** with no "Folders" or "Notes" text. **Search lives at the bottom** as a capsule field (magnifier, "Search" placeholder, mic) next to a separate circular **compose** button. The note count moved from the iOS 18 bottom-toolbar label to a **subtitle under the large title** ("45 Notes"). Yellow is now reserved for prominent actions (the Done checkmark and Save), selection checkmarks, chevrons, icons and tags.

### Cited Findings
- [Apple-doc] In iOS 26, bars "float above the content" and the system groups bar items into shared glass backgrounds. "Text buttons, the system 'Done' and 'Close' buttons, and prominent style buttons have separate glass backgrounds." Bar buttons "use labelColor by default", and a prominent style tints the background. `navigationItem.subtitle` renders "below the title". "On iPhone, the search bar moves automatically to the toolbar." — [WWDC25 284: Build a UIKit app with the new design](https://developer.apple.com/videos/play/wwdc2025/284/)
- [Apple-doc] Apple's iOS 26 feature list says search sits "at the bottom of iPhone" in Notes, Mail, Messages and Music. — [All New Features iOS 26 (PDF)](https://www.apple.com/os/pdf/All_New_Features_iOS_26_Sept_2025.pdf); [Community: 9to5Mac](https://9to5mac.com/2025/10/16/heres-everything-new-for-apple-notes-in-ios-26/)

**Folders list** [Apple-shot] — [screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-folders.png)
- Top right has two separate glass pieces: a **New Folder** circle (SF `folder.badge.plus`) and an **Edit** text capsule. There is nothing at top left. Below them is the large title **"Folders"**.
- The bottom row has a **Search** capsule (magnifier, "Search", mic glyph on the right) and a separate **compose** circle (`square.and.pencil`). In iOS 18 the bottom toolbar held New Folder on the left and compose on the right. — [Apple-doc iOS 18 vs 26 guides both say "Tap New Folder" without position](https://support.apple.com/guide/iphone/organize-in-folders-ipha61270292/26/ios/26)

**Notes list** [Apple-shot] — [list/swipe screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-swipe-delete.png); [gallery screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-more-view-as-gallery.png)
- The top left has a back chevron circle and the top right a **"…" circle** (Apple calls it "Folder Actions"). The large title is the folder name ("All iCloud"), with a gray subtitle **"45 Notes"** under it. The bottom has the same Search capsule and compose circle.
- [Community] A 9to5Mac beta screenshot shows the same structure ("Imported" / "1 Note", a "Today" header, then Search and compose). — [9to5Mac image](https://9to5mac.com/wp-content/uploads/sites/6/2025/06/apple-notes-ios-26.jpg); [Ark newsletter: counts shown under the title, search at the bottom](https://ark.beehiiv.com/p/apple-notes-just-got-smarter-in-ios-26-heres-whats-new)

**Note editor, viewing (keyboard down)** [Apple-shot] — [trip note](https://help.apple.com/assets/69F8EBBDF3B89A4F6E0C704C/69F8EBC43862495245036393/en_US/059245e26a9ae3372de1906e5bbbebd1.png); [attachments](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-attachment.png)
- The top left has a back chevron circle. The top right has one glass capsule grouping **Share** (`square.and.arrow.up`) and **"…"** (Note Actions). After an edit, a separate **Undo** circle (`arrow.uturn.backward`) appears to the left of that capsule. The editor has no visible title in the nav bar.
- The bottom left is one glass capsule of tools: **Checklist, Attachments (paperclip), Markup (`pencil.tip.crop.circle`), Writing Tools** (shown only with Apple Intelligence). The bottom right is a separate **compose** circle.
- [Apple-doc] Apple names these "the Checklist button", "the Attachments button", "the Handwriting Tools/Markup button" and "the New Note button". — [Get started with Notes](https://support.apple.com/guide/iphone/get-started-with-notes-iph9e04f3be2/26/ios/26)

**Note editor, editing (keyboard up)** [Apple-shot] — [format panel](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-text-formatting-options.png); [edit menu + keyboard bar](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-formatting-add-link-callout.png)
- The top right has Undo (circle), a Share and "…" capsule, and a **yellow filled circle with a white checkmark (Done)**. In iOS 18 Done was the text "Done". The iOS 26 guide says "To save the note, tap [the Done button]", where the 18.0 guide said "tap Done". — [iOS 26 guide](https://support.apple.com/guide/iphone/create-and-format-notes-iph1ac0b3a2/26/ios/26); [iOS 18 guide](https://support.apple.com/guide/iphone/create-and-format-notes-iph1ac0b3a2/18.0/ios/18.0)
- While drawing, Share disappears and the top right shows only "…" and the yellow Done circle. The PencilKit tool palette sits in a bottom glass panel. — [Apple screenshot](https://help.apple.com/assets/69F8EBBDF3B89A4F6E0C704C/69F8EBC43862495245036393/en_US/81ae6b5d764388bcb1c16c3e8515b19b.png)

**Search active** [Apple-shot] — [screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-search.png)
- The field rides up above the keyboard with a clear (⊗) glyph inside. The compose circle is replaced by a **× close circle**. Results are grouped under the plain headers **Top Hits / Notes / Attachments**, each with a trailing gray count ("1 Found", "None Found"), and every result is an inset card row. Matches are highlighted in yellow text.

### Inferences
- In SwiftUI, a `.searchable` modifier on the stack plus a bottom-bar `ToolbarItem` holding compose reproduces the Search and compose row (`DefaultToolbarItem(kind: .search, placement: .bottomBar)` + `ToolbarSpacer`). — [Community: Nil Coalescing](https://nilcoalescing.com/blog/SwiftUISearchEnhancementsIniOSAndiPadOS26). In UIKit, put `navigationItem.searchBarPlacementBarButtonItem, .flexibleSpace(), compose` in `toolbarItems`. — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- Use `navigationItem.subtitle` (or SwiftUI `.navigationSubtitle`) for "45 Notes". Don't draw a custom label.
- Pull-to-reveal search, the iOS 18 behavior where the field hid under the large title, no longer applies because search is pinned at the bottom (inference; see the gaps list).

---

## What does the editor toolbar and keyboard accessory bar contain?

### Takeaway
With the keyboard up, the bottom capsule is replaced by a **full-width floating glass capsule above the keyboard**. It scrolls horizontally and is **adaptive**. The first items are Aa (Format), Checklist, Table, Attachment, Markup and Writing Tools (on AI devices), followed by about 12 more formatting tools. The set changes with context: inline styles while typing, list and indent tools when several lines are selected. Tapping Aa opens a **Format card** that floats above the keyboard area.

### Cited Findings
- [Apple-shot] The keyboard bar order seen on an iPhone 17 Pro screenshot is **Aa, checklist, table, paperclip, markup, B…** (cut off, so it scrolls). The keyboard has the iOS 26 rounded glass top. — [Apple screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-formatting-add-link-callout.png)
- [Community] There are 18 tools in total. "The first six are the same as iOS 18" (format, checklist, table, attachment, markup, Writing Tools) and the rest are reached by swiping. Typing shows bold, italic, underline and highlight. A multi-line selection shows list tools and indent and outdent. — [9to5Mac](https://9to5mac.com/2025/10/16/heres-everything-new-for-apple-notes-in-ios-26/); [Everyeye (citing 9to5Mac)](https://tech.everyeye.it/notizie/ios-26-rivoluziona-note-toolbar-cambia-davvero-820050.html); [9to5Mac adaptive toolbar image](https://9to5mac.com/wp-content/uploads/sites/6/2025/08/apple-notes-ios-26-adaptive-toolbar-list.jpg)
- [Apple-doc] "Tap [Format], then choose a style such as Heading, bold or italic font, highlight… You can also **swipe over the format bar options**." Checklist and Add Table are separate buttons. — [Create and format notes](https://support.apple.com/guide/iphone/create-and-format-notes-iph1ac0b3a2/26/ios/26)
- [Apple-shot] The Format card has a "Format" header and an × circle. Row 1 is a scrolling style strip (**Title** in a yellow pill when active, Heading, Subheading, Body…). Row 2 is segmented **B I U S** plus highlight and color. Row 3 is bulleted, dashed and numbered lists, outdent and indent, and block quote. — [Apple screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-text-formatting-options.png)
- [Apple-shot] The text edit menu in iOS 26 is a vertical glass menu with a top icon row (Paste, Delete in red, Select) followed by Select All, AutoFill ›, Add Link, Attach File, Format ›, and Find Selection. — [Apple screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-formatting-add-link-callout.png)
- [Apple-shot] The Attachments menu morphs up from the paperclip as a glass menu: **Scan Text, Scan Documents, Take Photo or Video, Choose Photo or Video, a divider, Record Audio, Attach File**. — [Apple screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-attachment.png)
- [Community] iOS 18 changed the attachment glyph from a camera to a **paperclip**. — [MacRumors iOS 18 Notes guide](https://www.macrumors.com/guide/ios-18-notes-app)

### Inferences
- **iPhone 12 has no Apple Intelligence**, so expect no Writing Tools button. The viewing capsule is probably **Checklist · Paperclip · Markup** plus the separate compose button, and the keyboard bar starts **Aa, checklist, table, paperclip, markup, then B/I/U…** (estimate; verify on device).
- Build the keyboard bar as an `inputAccessoryView` or `.toolbar(placement: .keyboard)` holding a horizontally scrolling `HStack` inside a glass capsule (`.glassEffect(.regular, in: .capsule)`), inset about 16 pt from the screen edges.

---

## What are the menus ("…"), swipe actions and context menus?

### Takeaway
iOS 26 menus are glass popovers that **morph out of their source button**. Notes-list rows use **trailing swipe: Share (blue), Move (indigo), Delete (red)**, drawn as circular buttons with labels below, and **leading swipe: Pin** (yellow or orange). Touch and hold gives a context menu with a note preview.

### Cited Findings
- [Apple-doc] "When a presentation, like a menu or a popover is originated from a glass button, the button morphs into the overlay." Action sheets on iPhone now anchor to their source. — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- [Apple-doc] The **Folder Actions "…"** menu offers View as Gallery or List, Sort By (Title / Date Edited / Date Created; Oldest First or Descending), Group By Date, View Attachments, Select Notes, Convert to Smart Folder ("scroll to the bottom"), Share Folder or Manage Shared Folder, and Create Smart Folder in tag views. — [Organize in folders](https://support.apple.com/guide/iphone/organize-in-folders-ipha61270292/26/ios/26); [Use Smart Folders](https://support.apple.com/guide/iphone/use-smart-folders-iphc43adabc2/26/ios/26); [Share and collaborate](https://support.apple.com/guide/iphone/share-and-collaborate-iphe4d04f674/26/ios/26); [118442](https://support.apple.com/en-us/118442)
- [Community] The beta menu order was **View as Gallery | Share Folder, Add Folder, Move This Folder, Rename, Select Notes, Sort By (subtitle "Default (Date Edited)") ›, Group By Date ("Default (On)") ›, View Attachments | Convert to Smart Folder**. — [9to5Mac beta screenshot](https://9to5mac.com/wp-content/uploads/sites/6/2025/06/apple-notes-ios-26.jpg)
- [Apple-doc] The **Note Actions "…"** menu includes Find in Note, Lines & Grids, Lock / Remove, Attachment View (Set All to Small/Large), Pin, and Delete. — [Search notes](https://support.apple.com/guide/iphone/search-notes-iphb8628c6b8/26/ios/26); [Change the Notes view](https://support.apple.com/guide/iphone/change-the-notes-view-iph65637affe/26/ios/26); [Lock notes](https://support.apple.com/guide/iphone/lock-notes-iphf177bb154/26/ios/26); [Add photos…](https://support.apple.com/guide/iphone/add-photos-video-and-more-iph23f4d9aa9/26/ios/26); [118442](https://support.apple.com/en-us/118442). [Community] In iOS 18 the same menu also had Recent Notes, Move Note and a Math Notes toggle. — [MacRumors](https://www.macrumors.com/guide/ios-18-notes-app)
- [Apple-doc] Swipes on notes: "swipe right on the note, then tap the pin". "Swipe left… tap [Move Folder]". "Swipe left… tap Delete". [Apple-shot] The iOS 26 trailing actions are three **circular** buttons labeled **Share / Move / Delete** in blue, indigo and red, with the row content sliding left as a rounded card. — [Organize in folders](https://support.apple.com/guide/iphone/organize-in-folders-ipha61270292/26/ios/26); [Apple screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-swipe-delete.png)
- [Apple-doc] Touch and hold a note to get **Pin Note**, **Move**, and **Delete**. [Community] Lock Note and Share or Send a Copy are also reported. — [Organize in folders](https://support.apple.com/guide/iphone/organize-in-folders-ipha61270292/26/ios/26); [Community: Cult of Mac](https://www.cultofmac.com/496878/how-to-pin-notes-other-secret-ios-11-notes-app-tricks/)
- [Apple-doc] Folders: swipe left → Delete (red trash). Touch and hold gives **Rename, Delete, Show Folder Activity** (shared), and **Edit Smart Folder**. Drag one folder onto another to make it a subfolder. Tags: touch and hold gives **Rename Tag / Delete Tag**. — [Organize in folders](https://support.apple.com/guide/iphone/organize-in-folders-ipha61270292/26/ios/26); [Smart Folders](https://support.apple.com/guide/iphone/use-smart-folders-iphc43adabc2/26/ios/26); [Tags](https://support.apple.com/guide/iphone/organize-with-tags-iphedddbfdf9/26/ios/26)
- [Apple-doc] Recently Deleted rows: swipe left → **Move** or **Delete** (which then confirms with "Delete Note"). — [Delete and recover](https://support.apple.com/guide/iphone/delete-and-recover-notes-iph904eee369/26/ios/26)
- [Apple-shot] The Share button opens a **glass panel anchored near the top**. It holds a note icon and title, a "Collaborate ⌃⌄" pop-up, "Only invited people can edit ›", a row of app icons (AirDrop, Messages, Mail, Reminders), and action circles (Copy, Export as Markdown, Save N Images, More). — [Apple screenshot](https://help.apple.com/assets/69F8EBBDF3B89A4F6E0C704C/69F8EBC43862495245036393/en_US/46f3e39541f4f1baa5734ad64c588221.png)

### Inferences
- Use `.swipeActions(edge: .trailing)` with Share, Move and Delete (`.destructive`), and `.swipeActions(edge: .leading)` with Pin and `allowsFullSwipe`. iOS 26's `List` renders the circular style automatically.
- Folder swipe on device probably also shows Share and Move next to Delete, as in iOS 18 (verify).

---

## What do selection (edit) mode and Recently Deleted look like?

### Takeaway
"Select Notes" from the "…" menu turns the large title into **"N Selected"** (keeping the "45 Notes" subtitle) and adds leading circular checkboxes, filled yellow when selected, with selected rows shaded gray. In iOS 26 the bottom bar shows the text capsules **Move · Tags · Delete**, and a plain checkmark circle at the top right exits. In the folders list, Edit enables reorder, delete and tag rename.

### Cited Findings
- [Apple-shot] iOS 26 selection mode: the top right is a glass **✓** circle, black and not prominent. The title reads "3 Selected" over "45 Notes". The bottom has separate glass text buttons **Move**, **Tags** and **Delete**. — [Apple screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-more-select-notes-select-move.png)
- [Apple-doc] "In the Notes list, tap the More button, then tap Select Notes. Tap the notes… Tap the Folder button." — [118442](https://support.apple.com/en-us/118442)
- [Apple-doc] In the folders list, Edit lets you tap a tag to rename it or tap Delete. Edit, then Folder Actions, adds, moves and renames folders. — [Tags](https://support.apple.com/guide/iphone/organize-with-tags-iphedddbfdf9/26/ios/26); [Smart Folders](https://support.apple.com/guide/iphone/use-smart-folders-iphc43adabc2/26/ios/26)
- [Apple-shot] A Recently Deleted note opens read-only. Its bottom bar has a capsule of **Trash + Folder (move)** on the left and a dimmed compose button on the right. — [Apple screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-recently-deleted-note-tap-recover.png)
- [Apple-doc] Locked notes keep their title visible in the list. You re-lock with "Tap [Unlock] at the top of the screen" or "Tap **Lock Now** at the top of the notes list". — [Lock notes](https://support.apple.com/guide/iphone/lock-notes-iphf177bb154/26/ios/26)

### Inferences
- Selection mode in SwiftUI is `List(selection:)` with `EditMode`. Set the title to "\(n) Selected", and use `.tint(.yellow)` or the Notes accent so the checkmarks render yellow.

---

## How are the notes list and its sections laid out (list vs gallery, date groups)?

### Takeaway
By default the list is **inset-grouped**, with one rounded card per section on the `systemGroupedBackground` (#F2F2F7) page. Sections have **bold plain headers** in sentence case, such as "Today", not uppercase footnote style. Date grouping is on by default: **Pinned → Today → Yesterday → Previous 7 Days → Previous 30 Days → month names (this year) → years**. Each row shows a **bold title**, then a **secondary line of date + first-line preview**, then a third **folder line** (folder glyph + name) only in aggregate scopes (All iCloud, Smart Folders, tags, search). A thumbnail sits on the right when the note has media. Gallery view is a 3-column grid of note previews with the title, date and folder centered under each tile.

### Cited Findings
- [Apple-doc] "By default, the notes are grouped by date. To turn this off, tap [Folder Actions], then tap Group By Date." You can't group by date when sorting by title. — [Organize in folders](https://support.apple.com/guide/iphone/organize-in-folders-ipha61270292/26/ios/26); [Apple Notes for Mac: headings such as Today, Yesterday, Previous 30 Days](https://support.apple.com/guide/notes/apd000074a4e/mac)
- [Community] Headings include "Today, Previous 7 Days, 30 Days, and so on". — [MacMost](https://macmost.com/10-ways-to-organize-your-notes.html); [Apple Community thread](https://origin-discussions2-us-dr-prz.apple.com/thread/254472113)
- [Apple-doc] Pinned notes go "to the top of the notes list". An **orange dot left of a title** marks a shared note changed since you last viewed it. — [Organize in folders](https://support.apple.com/guide/iphone/organize-in-folders-ipha61270292/26/ios/26); [Share and collaborate](https://support.apple.com/guide/iphone/share-and-collaborate-iphe4d04f674/26/ios/26)
- [Apple-shot] Row anatomy: title in semibold body ("Lacy's Birthday"), then the secondary line "9:41 AM  Make treats, order pizza…" (time today, "Yesterday", or a date), then "📁 Notes". A **shared-person glyph** sits in the leading gutter for shared notes. The thumbnail is a rounded square on the right. — [Apple screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-swipe-delete.png)
- [Community] In a normal folder, rows show only two lines (title, then time + preview). — [9to5Mac beta image](https://9to5mac.com/wp-content/uploads/sites/6/2025/06/apple-notes-ios-26.jpg)
- [Apple-shot] Gallery view: three tiles per row with rounded, bordered previews of the note's first content. Below each tile come the title (up to 2 lines, centered), the date, and the "📁 Notes" folder line. The same Today and Yesterday headers are used. — [Apple screenshot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-more-view-as-gallery.png)
- [Apple-doc] Settings › Apps › Notes › Viewing sets the default sort, Lines & Grids, and group-by-date. — [Change Notes settings](https://support.apple.com/guide/iphone/change-notes-settings-iph92579feda/26/ios/26)

### Inferences
- Compute the date buckets against the current calendar day: Today, Yesterday, then ≤7 days, ≤30 days, then month names for the current year and the year number for earlier years. Pinned always comes first, regardless of date.
- The leading gutter of about 29 pt before the title text is reserved for the pin, lock, shared and unread indicators. Don't left-align the title to the card edge.

---

## What are the measurable geometry values (rows, insets, bars) and how do they map to iPhone 12?

### Takeaway
All values are **[Estimate]**, measured from Apple's iOS 26 iPhone 17 Pro screenshots at 1.458 px/pt. Horizontal values carry over to the iPhone 12 because margins are fixed and cards stretch. Vertical safe areas on the iPhone 12 are 47 pt at the top and 34 pt at the bottom.

### Cited Findings
- [Community] iPhone 12 is 390×844 pt at @3x. Its portrait safe-area insets are reported as (top 47, bottom 34). — [Use Your Loaf: iPhone 12 screen sizes](https://useyourloaf.com/blog/iphone-12-screen-sizes/); [LiveCode forum measurement](https://forums.livecode.com/viewtopic.php?p=219133)
- [Apple-doc] Large titles now "scroll with the content underneath the bar". Scroll views under bars get an automatic **scroll edge effect** (soft blur and fade), and `.hard` mimics iOS 18. The bar background is transparent by default. — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- [Estimate] Measured from the [folders](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-folders.png), [notes list](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-swipe-delete.png), [gallery](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-more-view-as-gallery.png) and [editor](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-attachment.png) screenshots:

| Element | Measured (402-pt device) | iPhone 12 (390 pt) value to use |
|---|---|---|
| Page background | RGB ≈ 241,241,246 (systemGroupedBackground) | `Color(.systemGroupedBackground)` |
| Card side margin | 16 pt each side | 16 pt → card width 358 pt |
| Card corner radius | ≈ 24–26 pt (continuous) | 24–26 pt (iOS 18 was ≈10 pt) |
| Folder row height | 52 pt (row pitch 76 px) | 52 pt |
| Folder row: icon x / text x | icon ≈16 pt, text and separator ≈56 pt from card edge | same |
| Note row (3-line, aggregate scope) | ≈ 80 pt | ≈ 80 pt; 2-line rows ≈ 62–66 pt (estimate) |
| Note row text inset | title x ≈ 29 pt from card edge; thumbnail ≈ 56–58 pt square, right inset ≈ 12 pt | same |
| Glass nav buttons | circle ≈ 44 pt; "Edit" capsule ≈ 63×44 pt; 16 pt from screen edge; gap ≈ 8–11 pt | same |
| Nav button center | ≈ 84 pt from screen top (≈22 pt below a 62 pt safe area) | ≈ 47 + 22 = 69 pt |
| Large title | ≈ 34 pt bold (cap height ≈ 24.7 pt), x = 16 pt | 34 pt bold |
| Note-count subtitle | ≈ 17 pt regular, secondary gray, directly under title | same |
| Section header ("iCloud", "Today") | ≈ 20–22 pt semibold/bold, x = 16 pt; ≈ 62 pt between cards incl. header | same |
| Bottom Search capsule | ≈ 282 × 48 pt, x = 16 pt | width = 390 − 16 − 16 − 48 − ~10 gap ≈ 300 pt |
| Compose circle | ≈ 48 pt, 16 pt from right edge | 48 pt |
| Bottom bar baseline | capsule bottom ≈ 28 pt above screen bottom (inside the 34 pt home-indicator inset) | same |
| Gallery tile | ≈ 112 × 84 pt, 3 columns, ≈ 16 pt gutter | (358 − 2·16)/3 ≈ 109 pt wide |
| Editor text inset | glyphs start ≈ 26–28 pt from screen edge; images inset the same | ≈ 26 pt (verify; iOS 18 looked ≈ 20 pt) |
| Editor title | first line auto-styled Title ≈ 28–30 pt bold | same |

### Inferences
- Use `List { }.listStyle(.insetGrouped)` on the iOS 26 SDK. It already gives 52 pt rows, the large corner radius and 16 pt margins. Hand-tune only the note-row content and the bottom bar.
- Because large titles now scroll with content, a scroll view that doesn't extend under the bar will clip the title. Use `.ignoresSafeArea(edges: .top)`-style behavior or the default `NavigationStack`.

---

## What changed in iOS 26 vs iOS 18 (layout only)?

### Takeaway
The structure is unchanged, but the chrome is completely different. A replica built from iOS 18 references will look wrong.

### Cited Findings

| Area | iOS 18 | iOS 26 | Source |
|---|---|---|---|
| Bar style | Opaque or blurred bars, **yellow** text and glyphs | Floating **glass** circles and capsules, black glyphs, yellow only for prominent items | [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/); [iOS 18 shot](https://help.apple.com/assets/69F8EBBDF3B89A4F6E0C704C/69F8EBC43862495245036393/en_US/f8f765907903fd2836d60b4ac70e7025.png) [Apple-shot] |
| Back button | "‹ Folders" / "‹ Notes" in yellow text | Chevron-only glass circle | same |
| Search | Field under the large title (pull-to-reveal) | Bottom capsule with mic, beside compose | [Apple PDF](https://www.apple.com/os/pdf/All_New_Features_iOS_26_Sept_2025.pdf) |
| Note count | Centered "N Notes" label in the bottom toolbar | Subtitle under the large title | [Apple-shot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-swipe-delete.png); iOS 18 position is [Community] memory, unverified |
| New Folder | Bottom-left toolbar button | Top-right glass circle beside Edit | [Apple-shot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-folders.png) |
| Editor bottom bar | 4 evenly spaced yellow glyphs (checklist, paperclip, markup, compose) | Tool capsule (left) + separate compose circle (right) | [iOS 18 shot](https://help.apple.com/assets/69F8EBBDF3B89A4F6E0C704C/69F8EBC43862495245036393/en_US/f8f765907903fd2836d60b4ac70e7025.png) vs [iOS 26 shot](https://help.apple.com/assets/69F8EBBDF3B89A4F6E0C704C/69F8EBC43862495245036393/en_US/152554c95a46d5ff877d02c2d842358d.png) |
| Done | Text "Done" | Yellow ✓ circle | [iOS 26 guide](https://support.apple.com/guide/iphone/create-and-format-notes-iph1ac0b3a2/26/ios/26) |
| Note date stamp | Centered gray "June 10, 2024 at 9:41 AM" above the title | Not visible in any iOS 26 Apple screenshot (verify) | [iOS 18 shot](https://help.apple.com/assets/69F8EBBDF3B89A4F6E0C704C/69F8EBC43862495245036393/en_US/f8f765907903fd2836d60b4ac70e7025.png) |
| Keyboard bar | Fixed row of 6 tools | Scrolling, adaptive glass capsule with 18 tools | [9to5Mac](https://9to5mac.com/2025/10/16/heres-everything-new-for-apple-notes-in-ios-26/) |
| Lists | Inset-grouped, ≈10 pt corners, 44 pt rows | Inset-grouped, ≈24–26 pt corners, 52 pt rows | [Estimate] |
| Swipe buttons | Full-height rectangles | Circular buttons with labels below | [Apple-shot](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-17-pro-notes-swipe-delete.png) |
| Editor typography | — | "Line spacing has been tweaked" | [9to5Mac](https://9to5mac.com/2025/07/17/heres-everything-new-for-apple-notes-in-ios-26/) |

### Inferences
- The MacRumors forum describes Notes as a "subtler" Liquid Glass adopter than Camera. — [MacRumors forums](https://forums.macrumors.com/threads/ios-26-whats-new-with-notes-and-reminders.2461629/). Mostly stock UIKit chrome, which favors building the replica with system `List`, `NavigationStack` and toolbars over custom drawing.

---

## iOS 27 (shipped 2026-09-14): Notes layout differences, secondary target

### Takeaway
iOS 27 runs on the iPhone 12, since it supports iPhone 11 and later, so **don't update the test phone** if the replica has to match iOS 26. The layout is nearly identical. The differences are new Shared and Quick Notes icons, a reworked selection mode, a reordered attachment menu, and new edit-menu items.

### Cited Findings
- [Community] iOS 27 was released on 14 September 2026 for iPhone 11 and later. [Apple-doc] Apple's Notes support article was republished on that date with iOS 27 screenshots. — [WRDW](https://www.wrdw.com/2026/09/15/what-tech-ios-27/); [GIGA](https://www.giga.de/tech/ab-dieser-uhrzeit-steht-ios-27-heute-zum-download-bereit--01M1E0JRTB765KKPWREMWMQXWN); [Apple Support 118442](https://support.apple.com/en-us/118442)
- [Community] iOS 27 brings a refreshed app icon, "Liquid Glass updates for buttons, menus", a new icon for the Shared folder at the top of the folders list, updated shared folder and note icons, Insert Divider Line, Link to Section, Copy as Markdown, Markdown paste, and Siri AI. — [9to5Mac](https://9to5mac.com/2026/09/28/heres-everything-new-for-apple-notes-in-ios-27/); [MacRumors](https://www.macrumors.com/2026/06/17/ios-27-apple-notes-app-new-features/)
- [Apple-shot] In the iOS 27 folders list, Quick Notes and Shared use **filled colored rounded-square icons** (yellow and cyan) where iOS 26 used yellow line glyphs. The rest of the screen matches iOS 26. — [iOS 27 folders](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-27-iphone-17-pro-notes-folders.png)
- [Apple-shot] iOS 27 selection mode adds a **"Select All"** capsule at the top left and a **yellow prominent ✓** at the top right. The bottom bar becomes **icon** circles (folder, #, trash) instead of the Move, Tags and Delete text. — [iOS 27 select](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-27-iphone-17-pro-notes-more-select-notes-select-move.png)
- [Apple-shot] The iOS 27 attachments menu runs in reverse order: Attach File, Record Audio | Image Playground, Choose Photo or Video, Take Photo or Video, Scan Documents, Scan Text. The edit menu adds Writing Tools and **Insert Divider Line**. — [iOS 27 attachment](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-27-iphone-17-pro-notes-attachment.png); [iOS 27 edit menu](https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-27-iphone-17-pro-notes-formatting-add-link-callout.png)

---

## Verification gaps (check on device)
1. The editor bottom capsule on the **non-AI iPhone 12**: is it 3 tools (checklist, paperclip, markup), or does Table or Aa fill the Writing Tools slot? Also the exact keyboard-bar order and the full list of 18 tools, and whether a keyboard-dismiss button exists.
2. Is the **note date stamp** ("October 14, 2026 at 9:41 AM") still shown above the note text in iOS 26, perhaps revealed only on pull-down?
3. Leading swipe on a note: Pin only, or Pin plus Lock? Does the folder trailing swipe also include Share and Move?
4. The exact long-press context menus for a note and a folder (item order, preview style), and the final iOS 26.6 order of the Folder "…" and Note "…" menus. The beta order may have changed.
5. The **Pinned** section header: is it collapsible, does it have a pin glyph, and is it styled like "Today"?
6. Two-line note row height in a normal folder, the thumbnail size and radius, and the secondary-text font size. Measure with a screenshot at 3 px/pt on the iPhone 12.
7. Whether pulling down still reveals anything (search, date) in the lists, and the scroll-edge blur strength under the large title and bottom bar.
8. Empty states (an empty folder, the "No Notes" text) and the Quick Notes and On My iPhone sections with real accounts.
9. Dark-mode rendering of the glass bars and cards. The colors themselves are covered in a separate topic file.
10. Make sure the device stays on **26.6.2**. iOS 27 is offered as an update and changes the icons and selection mode noted above.
