# Apple Notes (iPhone): Features & Interaction Behavior (iOS 26, with an iOS 27 delta)

Research target: behavioral parity for a sideloaded replica of Apple's Notes app as it ships on **iOS 26.x** (test device: iPhone 12, iOS 26.6.2). A spectator should be able to open the app, see a few notes, open one and type, and notice nothing different. The sections below cover the note lifecycle, list and date presentation, editing tools, organization, and motion/keyboard feel. Each finding is labeled **[Apple-documented]** (Apple Support / Newsroom), **[community-observed]** (press reviews, Apple Community, Reddit, forums), or **[estimate]** (inferred from UIKit conventions or older behavior, not confirmed for iOS 26). iOS 27 shipped on 2026-09-14, so its differences are in a separate labeled section near the end. iOS 26 is the primary target.

> Device note: the iPhone 12 **cannot run Apple Intelligence**. On the test device, no Writing Tools button, Image Wand, audio summaries or Apple Intelligence toolbar entry should appear. Audio *transcription* does work on the iPhone 12 (iPhone 12 and later). Build the replica to match the iPhone 12, not a 15 Pro.

---

## How is a note created, titled, saved and discarded?

### Takeaway
Tap the compose button. A blank note opens in edit mode with the keyboard up. The **first line becomes the title**, styled by the "New Notes Start With" setting (default **Title**). Every edit saves continuously, with no save step. The checkmark (the iOS 26 replacement for "Done") only dismisses the keyboard and ends editing. A new note left empty is silently thrown away when you leave it, and an untitled note is called "New Note".

### Cited Findings
- **[Apple-documented]** To create a note, tap New Note and enter text. "The first line of the note becomes the note's title." To save, tap the Done button. — [Create and format notes (iOS 26)](https://support.apple.com/guide/iphone/create-and-format-notes-iph1ac0b3a2/26.0/ios/26.0)
- **[Apple-documented]** The same New Note button appears inside an open note, so you can start a new note from the editor. — [Enter formulas and equations (iOS 26)](https://support.apple.com/guide/iphone/enter-formulas-and-equations-iphb9c2b948f/26.0/ios/26.0)
- **[community-observed]** iOS 26 replaces the text "Done" button with a larger **circular checkmark** and replaces "Close" with an X. Buttons in the top bar are Liquid Glass circles or pills. — [MacStories iOS 26 review — Buttons/Toolbars](https://www.macstories.net/stories/ios-and-ipados-26-the-macstories-review/3); [MacRumors iOS 26 Notes guide](https://www.macrumors.com/guide/ios-26-notes-app-reminders-app/)
- **[community-observed]** "Changes save automatically while editing." The iPhone keeps a checkmark that iPadOS 26.2 dropped. On iPad, opening a note "immediately enters edit mode". — [Apple Community 256226821](https://discussions.apple.com/thread/256226821)
- **[community-observed]** An untouched new note is auto-deleted when focus moves elsewhere. Other note apps cite this as the "Apple Notes pattern". — [Bear forum](https://community.bear.app/t/preference-to-not-auto-save-empty-notes/13207); [Amplenote request](https://amplenote.featureupvote.com/suggestions/44980/comment/664714)
- **[community-observed]** The automatic title of an empty or new note is **"New Note"**. In a reported data-loss bug, a note's "auto title is returned back to 'New Note'". — [Apple Community 255349925](https://discussions.apple.com/thread/255349925)
- **[community-observed]** **New Notes Start With** (Settings > Apps > Notes) has four options. **Title** is the default (large, bold). **Heading** is large and bold. **Subheading** is body size and bold. **Body** is plain. After a title or heading line, pressing Return switches the next line to Body. — [9to5Mac](https://9to5mac.com/2024/06/01/how-to-make-iphone-notes-without-bold-headings/); [iMore](https://www.imore.com/how-format-notes-iphone-and-ipad)
- **[Apple-documented]** A handwriting-only note takes its suggested title from the first line of handwriting. To edit that title, scroll to the top of the note and tap Edit. — [Add drawings and handwriting (iOS 26)](https://support.apple.com/guide/iphone/add-drawings-and-handwriting-iphd939f0a1c/26.0/ios/26.0)
- **[estimate]** On a fresh note, the caret sits on line 1 in Title style with no placeholder text, and the keyboard animates up with the push.

### Inferences
- Persist on every text change (debounced around 0.5–1 s) and again on disappear, so a force-quit never loses what the spectator typed. If the body is entirely whitespace when the note disappears, delete the note without animation and leave no trace in Recently Deleted.
- Take the title from the first non-empty line, trimmed. If there is none, the title is "New Note".

---

## How does the notes list show titles, previews, dates, sorting, grouping and pins?

### Takeaway
Each row shows a **bold title** (the first line). Under it is one secondary line: the **date** (last *edited* date, whatever the sort order), then a preview taken from the next line of text. If there is no further text, the preview reads **"No additional text"**. Lists are grouped by date by default ("Today", "Yesterday", "Previous 7 Days", "Previous 30 Days", then months, then years). **Pinned** notes sit in their own section at the top.

### Cited Findings
- **[community-observed]** When sorted by date edited, the list shows "the time (if today), day (if this week) or date last edited by the first line in the entry" (iPhone SE, iOS 18). — [Apple Community 255949735](https://discussions.apple.com/thread/255949735)
- **[community-observed]** "Regardless of the default sort selection, the only date that is shown is the date edited." The created date is only visible inside the note. — [Apple Community 255665025](https://discussions.apple.com/thread/255665025)
- **[community-observed]** The phrase **"No additional text"** appears as the preview when a note has only a title. Users mostly report it as a sync bug where the body is missing, which confirms the exact string. — [Apple Community 251344114](https://discussions.apple.com/thread/251344114); [Apple Community 250972715](https://discussions.apple.com/thread/250972715)
- **[Apple-documented]** Notes are **grouped by date by default**, and the grouping can be turned off with Folder Actions > Group By Date. Sort By offers Title, Date Edited or Date Created. To reverse the order, choose **Oldest First** for dates or **Descending** for title. The default for all folders is set in Settings > Apps > Notes > Sort Notes By. — [Organize in folders (iOS 26)](https://support.apple.com/guide/iphone/organize-in-folders-ipha61270292/26.0/ios/26.0)
- **[Apple-documented]** The Viewing settings cover sort order, lines and grids, and "group notes by date". — [Change Notes settings (iOS 26)](https://support.apple.com/guide/iphone/change-notes-settings-iph92579feda/26.0/ios/26.0)
- **[Apple-documented (Mac)]** Group labels include "Today, Yesterday, or Previous 30 Days". Grouping by date is unavailable when sorting by title. — [Notes for Mac — group by date](https://support.apple.com/guide/notes/apd000074a4e/mac)
- **[community-observed]** The full group sequence is Today, Yesterday, Previous 7 Days, Previous 30 Days, then month names (e.g. "February"), then years (e.g. "2021"). It arrived in iOS 16. — [Gadget Hacks iOS 16 Notes](https://ios.gadgethacks.com/how-to/apple-notes-has-13-new-features-upgrades-ios-16-you-should-know-about-0385084); [Apple Community 254472113](https://discussions.apple.com/thread/254472113); [MacRumors iOS 16 guide](https://www.macrumors.com/guide/notes-reminders-ios-16/)
- **[Apple-documented]** To pin, touch and hold a note and choose **Pin Note**, or swipe right and tap the pin. — [Organize in folders (iOS 26)](https://support.apple.com/guide/iphone/organize-in-folders-ipha61270292/26.0/ios/26.0)
- **[community-observed]** A full swipe right pins without a tap. Pinned notes form a "Pinned" section at the top, which can be collapsed with a chevron. The context menu shows Unpin Note for a pinned note. — [Cult of Mac](https://www.cultofmac.com/how-to/how-to-pin-notes-other-secret-ios-11-notes-app-tricks); [iGeeksBlog](https://www.igeeksblog.com/how-to-pin-notes/)
- **[Apple-documented]** A locked note keeps its title visible in the list. Gallery view shows thumbnails. — [Lock notes (iOS 26)](https://support.apple.com/guide/iphone/lock-notes-iphf177bb154/26.0/ios/26.0); [Change the Notes view (iOS 26)](https://support.apple.com/guide/iphone/change-the-notes-view-iph65637affe/26.0/ios/26.0)
- **[Apple-documented]** In shared notes, an orange dot to the left of the title means the note changed since you last viewed it. — [Share and collaborate (iOS 26)](https://support.apple.com/guide/iphone/share-and-collaborate-iphe4d04f674/26.0/ios/26.0)
- **[estimate]** Date tokens follow system short styles. Today shows a time ("9:41 AM", following the 12/24-hour setting). Yesterday shows "Yesterday". Within roughly 6 days it shows the weekday ("Monday"). Older notes show a numeric short date ("10/3/25" in en_US). In views that mix folders (All iCloud, search results), a third line shows a folder icon and the folder name. If the note has an image, a thumbnail sits on the right.

### Inferences
- In a fresh demo list, the "Today" group header and time-only dates are the most visible signals. Get the header style and the "time + two spaces + preview" layout exactly right.
- Use `Calendar.isDateInToday` / `isDateInYesterday` for the row dates, and a fixed-date formatter so values match the device locale.

---

## What does the editor show at the top (date/time header)?

### Takeaway
At the very top of the note body, above the title, sits a small centered gray timestamp. It scrolls with the content and is hidden when you scroll down. **[community-observed]** If you pull down on an open note, the date shows. Tapping it toggles between the created and edited dates.

### Cited Findings
- **[community-observed]** "Swipe down to reveal the date, and tap it to switch" between the creation and edited dates (iOS 18). — [Apple Community 256180691](https://discussions.apple.com/thread/256180691); [Apple Community 255665025](https://discussions.apple.com/thread/255665025)
- **[Apple-documented (Mac)]** Click the date at the top of the note to view the created or last-edited date. — [Notes for Mac search result: date at top](https://support.apple.com/guide/notes/apd8b73d28be/mac)
- **[estimate]** The format is a long date plus time, for example "14 October 2026 at 9:41 AM" (locale dependent), in caption-sized secondary text.

### Inferences
- Render the timestamp as the first non-editable element in the scroll view, not in the navigation bar. A typed new note should show "Today at …" or the full date immediately. Check this on the device.

---

## What is in the editing chrome (top bar, keyboard toolbar, Aa panel)?

### Takeaway
In iOS 26, the editor uses Liquid Glass. A back chevron circle sits top-left. Share and More (…) circles sit top-right, plus undo/redo and the checkmark while editing. A floating, rounded toolbar rides above the keyboard. It has **18 buttons that scroll horizontally** and adapts to context: B/I/U/highlight while typing, list and indent tools when more than one line is selected. The first six are unchanged from iOS 18: **Aa (Format), Checklist, Table, Attachments (paperclip), Markup, and Apple Intelligence**. The last is absent on the iPhone 12.

### Cited Findings
- **[community-observed]** There are 18 buttons in total, "the first six the same as before". These are the Formatting menu, Checklist, Tables, Attachments, Markup, and Apple Intelligence writing tools. You swipe horizontally for more. Typing shows bold, italic, underline and highlight. Selecting multiple lines shows indent/outdent, lists "and more". — [9to5Mac toolbar](https://9to5mac.com/2025/10/10/ios-26s-notes-app-adds-a-clever-new-way-to-use-its-many-tools/); [9to5Mac iOS 26 Notes](https://9to5mac.com/2025/10/16/heres-everything-new-for-apple-notes-in-ios-26/)
- **[community-observed]** The toolbar has rounded corners and a compact frosted-glass look, and the keyboard has rounded edges. Tapping an icon still opens submenus for formatting, lists, tables and so on. Line spacing changed in iOS 26. — [MacRumors iOS 26 Notes guide](https://www.macrumors.com/guide/ios-26-notes-app-reminders-app/); [9to5Mac iOS 26 Notes](https://9to5mac.com/2025/10/16/heres-everything-new-for-apple-notes-in-ios-26/)
- **[Apple-documented]** The Format button lets you "choose a style such as Heading, bold or italic font, highlight, and more", and you can "swipe over the format bar options" for common styles. The Checklist and Add Table buttons sit in the same bar. — [Create and format notes (iOS 26)](https://support.apple.com/guide/iphone/create-and-format-notes-iph1ac0b3a2/26.0/ios/26.0)
- **[community-observed]** The Aa panel contents are as follows. Paragraph styles: Title, Heading, Subheading, Body, Monostyled. Inline: Bold, Italic, Underline, Strikethrough. Lists: Bulleted, Dashed, Numbered. Then indent/outdent and **Block Quote** (iOS 17+), plus the **highlight color dot** (iOS 18+). — [iMore](https://www.imore.com/how-format-notes-iphone-and-ipad); [MacRumors block quotes](https://www.macrumors.com/how-to/use-block-quotes-apple-notes/)
- **[community-observed]** iOS 18 added five highlight colors: **purple, pink, orange, mint, blue**. A highlight tints both the text and its background, and custom colors are not possible. — [MacRumors iOS 18 Notes colors](https://www.macrumors.com/2024/06/11/ios-18-notes-app-colors); [MacRumors iOS 18 Notes guide](https://www.macrumors.com/guide/ios-18-notes-app/)
- **[community-observed]** Undo/redo arrows appear at the top of the note while editing. Three-finger swipe left undoes and swipe right redoes, showing a banner at the top. A three-finger tap shows an undo/redo/cut/copy/paste bar. Shake to Undo works when enabled in Accessibility > Touch. — [Apple Community 256212502](https://discussions.apple.com/thread/256212502); [iPhone Life](https://iphonelife.com/content/how-to-undo-apple-notes); [Popular Science](https://www.popsci.com/diy/ios-undo-notes-app/)
- **[Apple-documented]** The note's More menu ("Note Actions") includes **Find in Note**, **Lines & Grids**, **Lock**, **Attachment View** and **Math Results**. The Share sheet includes **Collaborate / Send Copy**, **Export as Markdown** (shown as "Export as Markup" on the iOS 26 page, a doc typo), **Markup** (PDF), **Print** and **Open in Pages**. — [Search notes](https://support.apple.com/guide/iphone/search-notes-iphb8628c6b8/26.0/ios/26.0); [Change the Notes view](https://support.apple.com/guide/iphone/change-the-notes-view-iph65637affe/26.0/ios/26.0); [Export or print](https://support.apple.com/guide/iphone/export-or-print-notes-iphdf551cfa2/26.0/ios/26.0); [Add photos, video](https://support.apple.com/guide/iphone/add-photos-video-and-more-iph23f4d9aa9/26.0/ios/26.0)

### Inferences
- For a "spectator types" scenario, the toolbar above the keyboard must look right even if most buttons are inert. Aa, Checklist and Table should work, and the rest can be stubbed visually. Drop the Apple Intelligence icon for the iPhone 12.
- Show undo/redo in the top bar only after the first edit. Leaving them out entirely is a strong tell.

---

## How do checklists, lists, tables, links, tags and sections behave while typing?

### Takeaway
- Checklist rows have a hollow circle that fills with a yellow checkmark when tapped, and the item text turns gray (likely struck through; see below).
- Checked items can auto-sort to the bottom.
- Swiping a row right indents it and swiping left outdents it. Rows can be dragged to reorder.
- In lists, Return continues the list, and Return on an empty item ends it.
- Phone numbers, addresses, dates and URLs are auto-underlined.
- `#word` + space becomes a yellow tag, and `>>` starts a link to another note.
- Headings collapse via a chevron.

### Cited Findings
- **[Apple-documented]** Tap the empty circle to complete an item. Reorder items with drag and drop. "Swipe the list item right to indent and left to reverse the indent." Settings > Apps > Notes > **Sort Checked Items**: Manually or Automatically. — [Create a checklist with Notes](https://support.apple.com/102296)
- **[Apple-documented (Mac)]** In lists, Return adds an item and Return twice ends the list. Typing `* `, `- ` or `1. ` at the start of a line starts a bulleted, dashed or numbered list (Mac). — [Notes for Mac — lists](https://support.apple.com/guide/notes/apd93c815aa0/mac)
- **[community-observed]** On iPhone, "tap Return twice" leaves a list, and Return after a Title or Heading reverts to Body. — [iMore](https://www.imore.com/how-format-notes-iphone-and-ipad)
- **[Apple-documented]** Addresses, email addresses, phone numbers and dates become underlined, tappable data detectors, which also offer unit and currency conversion. Typing `>>` and a title creates a note link that updates when the target note is renamed. — [Add links (iOS 26)](https://support.apple.com/guide/iphone/add-links-iph908d1558b/26.0/ios/26.0)
- **[Apple-documented]** Type `#tag` then a space to activate a tag, which turns **yellow**. Tags are one word; dashes and underscores are allowed. An existing-tag menu appears above the keyboard. The **Auto Convert to Tag** setting controls this. — [Organize with tags (iOS 26)](https://support.apple.com/guide/iphone/organize-with-tags-iphedddbfdf9/26.0/ios/26.0); [Settings](https://support.apple.com/guide/iphone/change-notes-settings-iph92579feda/26.0/ios/26.0)
- **[Apple-documented]** Format a line as Heading or Subheading to make a section. Collapse and Expand buttons toggle it. — [Create and format notes (iOS 26)](https://support.apple.com/guide/iphone/create-and-format-notes-iph1ac0b3a2/26.0/ios/26.0)
- **[community-observed]** The chevron appears when the caret is on a heading line. It points down when expanded and flips when collapsed. Subheadings collapse into their heading, and a section runs until the next heading of the same or higher level. — [9to5Mac](https://9to5mac.com/2025/04/25/apple-notes-got-power-user-feature-in-ios-18-thats-rare-in-other-apps/); [MacRumors iOS 18 guide](https://www.macrumors.com/guide/ios-18-notes-app/)
- **[Apple-documented]** Tables are inserted with the Add Table button. Text selection works as follows: double-tap selects a word, triple-tap a paragraph, three-finger pinch copies and cuts, and three-finger spread pastes. The edit menu holds Cut, Copy, Paste, Select All, Replace and Format, and its forward arrow reveals more items such as Add Link. — [Select and edit text (iOS 26)](https://support.apple.com/guide/iphone/select-and-edit-text-iph1a9cae52c/26.0/ios/26.0); [Add links](https://support.apple.com/guide/iphone/add-links-iph908d1558b/26.0/ios/26.0)
- **[estimate]** A checked item's text turns gray (and, as far as I recall, struck through). Its circle fills with the system yellow accent. Auto-sort moves the item after a short delay, with an animation.

### Inferences
- The minimum is checklists with tap-to-check and list auto-continue on Return. Tables, tags, links and sections can come later. They are rare in a short spectator interaction.

---

## How does inline math (typing "12+30=") behave?

### Takeaway
In Notes, a result appears once you type `=` after a solvable expression. **By default it is a suggestion**: a gray result that **Return** inserts inline. Per note, the More menu > Math Results can switch to Insert Results (insert automatically), Suggest Results, or Off.

### Cited Findings
- **[Apple-documented]** "Mathematical expressions are solved inline when you write or type an equal sign." Variables, graphs (Insert Graph), dotted red lines for errors and dotted blue lines for ambiguous characters are supported. Notes has a Math Notes folder. — [Enter formulas and equations (iOS 26)](https://support.apple.com/guide/iphone/enter-formulas-and-equations-iphb9c2b948f/26.0/ios/26.0)
- **[Apple-documented]** The options under More > **Math Results** are Insert Results (answers appear automatically), Suggest Results (a Solve affordance inserts the answer), and Off. — [Solve math with Math Notes (iOS 26)](https://support.apple.com/guide/iphone/solve-math-with-math-notes-iph46efa613a/26.0/ios/26.0)
- **[Apple-documented (Mac)]** "By default, Math Results appear as suggestions. Press Return to insert the answer inline." — [Notes for Mac — solve math](https://support.apple.com/guide/notes/apda85974595/mac)
- **[community-observed]** iOS 26 adds 3D graphs (`z = …` → Insert 3D Graph). — [MacRumors iOS 26 Notes guide](https://www.macrumors.com/guide/ios-26-notes-app-reminders-app/)

### Inferences
- This feature carries real risk for a magic routine. A spectator who types arithmetic will see a ghost result. If the replica skips it, a savvy spectator could notice. Implement at least the gray "suggest" result for simple `a op b =` expressions, accepted with Return.

---

## Attachments, audio, Writing Tools, Markdown and Quick Note

### Takeaway
None of these are core to a spectator flow, but their entry points must exist. The paperclip menu offers Choose Photo or Video, Take Photo, Scan Text, Scan Documents, Record Audio and more. Audio recording transcribes live on the iPhone 12. Markdown export is in the Share sheet. Quick Note is reached through Control Center or the Share sheet.

### Cited Findings
- **[Apple-documented]** Record Audio is under the Attachments menu, with Record/Stop. Transcription requires iPhone 12 or later and a supported language. The More menu offers Find in Transcript, Add Transcript to Note and Copy Transcript. Deleting the audio also deletes its transcript. — [Record and transcribe audio (iOS 26)](https://support.apple.com/guide/iphone/record-and-transcribe-audio-iphbe11247b5/26.0/ios/26.0)
- **[Apple-documented]** The attachments menu covers photo/video, Scan Text and Scan Documents. Attachments can be shown as Small, Large or Plain Link. — [Add photos, video (iOS 26)](https://support.apple.com/guide/iphone/add-photos-video-and-more-iph23f4d9aa9/26.0/ios/26.0); [Scan text and documents (iOS 26)](https://support.apple.com/guide/iphone/scan-text-and-documents-iph653f28965/26.0/ios/26.0)
- **[Apple-documented]** Writing Tools needs Apple Intelligence. It is opened from the selection's Writing Tools button or a button in the keyboard's top-right corner, and offers Proofread, Rewrite, Friendly, Professional, Concise, Describe your change, Summarize, Key Points, List and Table. — [Use Writing Tools (iOS 26)](https://support.apple.com/guide/iphone/find-the-right-words-with-writing-tools-iph6f08da1d2/26/ios/26); summaries of recordings: [Apple Intelligence in Notes](https://support.apple.com/guide/iphone/use-apple-intelligence-in-notes-iph59143007d/26.0/ios/26.0)
- **[Apple-documented]** Export a note as Markdown from the Share sheet. — [Export or print notes (iOS 26)](https://support.apple.com/guide/iphone/export-or-print-notes-iphdf551cfa2/26.0/ios/26.0)
- **[community-observed]** Markdown import on iPhone works by sharing a `.md` file to Notes and tapping **Import**. The note lands in an "Imported Notes" folder. In iOS 26, typing or pasting Markdown is *not* converted. — [iPhoneIslam](https://iphoneislam.com/en/2025/09/ios-26-import-and-export-markdown-files-in-apple-notes/161014); [9to5Mac](https://9to5mac.com/2025/10/16/heres-everything-new-for-apple-notes-in-ios-26/)
- **[Apple-documented]** Quick Note on iPhone is opened from Control Center or Share > Add to Quick Note, with a **Save** button. Quick Notes live in their own Quick Notes folder and can't be locked. — [Use Quick Notes (iOS 26)](https://support.apple.com/guide/iphone/use-quick-notes-iph5084c0387/26.0/ios/26.0)
- **[community-observed]** Call recordings from Phone are saved to Notes with transcripts. — [MacRumors iOS 26 Notes guide](https://www.macrumors.com/guide/ios-26-notes-app-reminders-app/)

### Inferences
- Stub these menus with correct labels and icons, and let them present system pickers or do nothing. The Markdown and Writing Tools rows should not appear on the iPhone 12 where Apple Intelligence gates them. Markdown export is not gated, so keep it in the Share sheet.

---

## Folders, search, swipe actions, Recently Deleted, tags, smart folders, locking, sharing

### Takeaway
The folder list groups folders under accounts (iCloud / On My iPhone). It includes Quick Notes, Math Notes (when used), Shared, Recently Deleted (only when non-empty) and a Tags section. Swipes on a note row: right to pin, left for Move / Delete (and Share in recent builds; see below). Deleted notes keep 30 days in Recently Deleted. In iOS 26, search is a field docked at the bottom of the screen.

### Cited Findings
- **[Apple-documented]** Delete a note with swipe left > Delete, or touch and hold > Delete. The note goes to **Recently Deleted** for **30 days**. That folder is hidden when empty. To recover, swipe left > Move. To delete permanently, choose Delete > Delete Note. — [Delete and recover (iOS 26)](https://support.apple.com/guide/iphone/delete-and-recover-notes-iph904eee369/26.0/ios/26.0)
- **[Apple-documented]** Move with swipe left > Move Folder, or touch and hold > Move. Folders are created with the New Folder button. Dragging one folder onto another makes a subfolder. Swipe left on a folder to delete it. Touch and hold to Rename. — [Organize in folders (iOS 26)](https://support.apple.com/guide/iphone/organize-in-folders-ipha61270292/26.0/ios/26.0)
- **[community-observed]** In iOS 26 the folders view has an **always-visible search bar at the bottom**, where before you swiped down to reveal it. Search bars "transition nicely above the keyboard when tapped". The compose button sits in the bottom bar beside search and "looks almost identical to the search tab". — [MacRumors iOS 26 Notes](https://www.macrumors.com/guide/ios-26-notes-app-reminders-app/); [MacStories](https://www.macstories.net/stories/ios-and-ipados-26-the-macstories-review/3); [Ryan Wesley](https://ryanwesley.com/ios-26-tab-bar-beef/)
- **[Apple-documented]** Search covers typed and handwritten text, objects in images and scanned text, and offers suggested searches such as "Notes with Drawings". A locked note shows only its title in results. Find in Note can include attachments. — [Search notes (iOS 26)](https://support.apple.com/guide/iphone/search-notes-iphb8628c6b8/26.0/ios/26.0)
- **[Apple-documented]** Tags appear below the Tags section at the bottom of the folders list. Tags can be tapped together for include/exclude matching, and touch and hold offers Rename Tag / Delete Tag. A Smart Folder is made with New Folder > Make Into Smart Folder and filters by tags, dates, mentions and more. — [Tags](https://support.apple.com/guide/iphone/organize-with-tags-iphedddbfdf9/26.0/ios/26.0); [Smart Folders](https://support.apple.com/guide/iphone/use-smart-folders-iphc43adabc2/26.0/ios/26.0)
- **[Apple-documented]** To lock a note, choose Note Actions > Lock, using the device passcode/Face ID/Touch ID or a custom password. One unlock opens all locked notes "for several minutes". To relock, use **Lock Now** at the top of the list, close Notes, or lock the iPhone. Notes with PDF, audio or video attachments can't be locked, nor can shared notes or Quick Notes. — [Lock notes (iOS 26)](https://support.apple.com/guide/iphone/lock-notes-iphf177bb154/26.0/ios/26.0)
- **[Apple-documented]** Sharing: Share > Collaborate or Send Copy. Activity view supports Show Updates, All Activity and Highlights, and `@` mentions. — [Share and collaborate (iOS 26)](https://support.apple.com/guide/iphone/share-and-collaborate-iphe4d04f674/26.0/ios/26.0)
- **[Apple-documented]** Other settings: Default Account, "On My iPhone" Account, Mention Notifications, App Links, Save to Photos, and Access Notes from Lock Screen (Always Create New Note / Resume Last Note). — [Change Notes settings (iOS 26)](https://support.apple.com/guide/iphone/change-notes-settings-iph92579feda/26.0/ios/26.0)
- **[community-observed]** Swiping left on a note has offered Delete, Lock and Move since iOS 11. The current order of icons is unverified. — [Cult of Mac](https://www.cultofmac.com/how-to/how-to-pin-notes-other-secret-ios-11-notes-app-tricks)

### Inferences
- A spectator may swipe on a row or long-press it. Implement swipe right to pin and swipe left to Move/Delete, plus a context menu with a preview. Leave the rest inert.

---

## Keyboard, scrolling, haptics and navigation motion

### Takeaway
None of this is documented by Apple. Assume stock UIKit behavior:
- The list uses a large title ("Notes" or the folder name) that collapses into an inline title as you scroll. In iOS 26 the scroll-edge blur replaces the opaque bar.
- Opening a note is a standard push from the right, with an interactive edge-swipe pop.
- The editor's text view keeps the caret visible above the keyboard and toolbar. Dragging down dismisses the keyboard interactively.
- Haptics are system defaults: swipe-action thresholds, context-menu lift, and probably checklist taps.

### Cited Findings
- **[community-observed]** Most table views in Apple apps "no longer pin the title bar when scrolling". A scroll-edge effect blurs content under the top toolbar, and toolbars are floating rounded bars. — [MacStories](https://www.macstories.net/stories/ios-and-ipados-26-the-macstories-review/3)
- **[Apple-documented]** On long documents, touch and hold the right edge to drag the scroller. Touch and hold also shows the text magnifier for moving the insertion point. — [Select and edit text (iOS 26)](https://support.apple.com/guide/iphone/select-and-edit-text-iph1a9cae52c/26.0/ios/26.0)
- **[community-observed]** iPhone keeps a back/checkmark affordance; the iPad doesn't. — [Apple Community 256226821](https://discussions.apple.com/thread/256226821)
- **[estimate]** No public source documents haptics specific to Notes. Use `UIImpactFeedbackGenerator(.light)` / the system defaults only where UIKit adds them (swipe-action commit, context menu). Checklist toggles likely produce a light tap, but this is unverified.

### Inferences
- Build on `UINavigationController` / `NavigationStack` with large titles, `UISearchController` docked at the bottom (iOS 26 behavior), `UITextView` with TextKit 2, and `keyboardDismissMode = .interactive`. These give the native motion for free. Custom transitions are the fastest way to look fake.

---

## iOS 27 (shipped 2026-09-14): Notes differences, secondary target

### Takeaway
iOS 27 and 27.0.1 add **divider lines**, **section links**, **Markdown paste conversion** and **Copy as Markdown**, Siri AI note writing (15 Pro+), a refreshed icon, Liquid Glass button and menu tweaks, and new shared-folder icons. Group By Date gains sub-options. The core lifecycle and list behavior appear unchanged.

### Cited Findings
- **[community-observed]** iOS 27 released 2026-09-14 and iOS 27.0.1 on 2026-09-28. Apple is now pushing iOS 26 users to upgrade. — [MacRumors release](https://www.macrumors.com/2026/09/14/apple-releases-ios-27/); [MacRumors 27.0.1](https://www.macrumors.com/2026/09/28/apple-releases-ios-27-0-1/); [MacRumors push](https://www.macrumors.com/2026/10/08/apple-now-pushing-ios-27/)
- **[Apple-documented]** The edit menu gains Insert Divider Line. Add Link gains Link to Section, and `>>` followed by `/` links to a section in another note. Group By Date now leads to "choose an option". The Share sheet adds a View More step before Export as Markdown, Print and Markup. — [Create and format (iOS 27)](https://support.apple.com/guide/iphone/create-and-format-notes-iph1ac0b3a2/27.0/ios/27.0); [Add links (iOS 27)](https://support.apple.com/guide/iphone/add-links-iph908d1558b/27.0/ios/27.0); [Folders (iOS 27)](https://support.apple.com/guide/iphone/organize-in-folders-ipha61270292/27.0/ios/27.0); [Export (iOS 27)](https://support.apple.com/guide/iphone/export-or-print-notes-iphdf551cfa2/27.0/ios/27.0)
- **[community-observed]** Pasted Markdown auto-formats, "Copy as Markdown" is in the edit menu, the app icon is refreshed, and shared folders and notes get new icons. — [MacRumors iOS 27 Notes](https://www.macrumors.com/2026/06/17/ios-27-apple-notes-app-new-features/); [9to5Mac iOS 27 Notes](https://9to5mac.com/2026/09/28/heres-everything-new-for-apple-notes-in-ios-27/)

### Inferences
- Pin the test iPhone at 26.6.2. If the performer upgrades, the visible differences are the icon and the edit-menu items, which are low risk for a spectator flow.

---

## What must a minimal but indistinguishable replica implement first?

Priority order for "spectator opens app, sees a few notes, opens one, types":

1. **List screen chrome**: large "Notes" title that collapses on scroll, back to Folders, a More (…) circle, the iOS 26 bottom search field plus compose button, and the scroll-edge blur.
2. **Row rendering**: bold title, then date token (time / Yesterday / weekday / short date) plus preview or "No additional text". Include the "Pinned" section and date-group headers (Today, Yesterday, Previous 7 Days, …).
3. **Push/pop** with native animation and an interactive edge-swipe back.
4. **Editor**: top timestamp line; title line in Title style; Return switches to Body; caret and keyboard behavior; and an automatic first-line title back in the list.
5. **Continuous autosave**, empty-note discard on back, and the edited date updating to "now". The note moves to the top of the Today group when sorted by Date Edited.
6. **Editing top bar while editing**: back, undo/redo (after the first edit), share, …, and the checkmark that ends editing without leaving.
7. **Keyboard toolbar visuals**: Aa, Checklist, Table, Paperclip, Markup, with no Apple Intelligence icon on the iPhone 12. Swipeable, and adaptive on multi-line selection.
8. **Checklists and list auto-continue**: tap circle, Return continues, double Return exits.
9. **Inline math suggestion** for `expr =` (gray result, Return inserts).
10. **Row gestures**: swipe right to pin, swipe left to Move/Delete, long-press context menu. Compose from inside the editor.
11. Later: Aa panel styles and highlights, tags, links and data detectors, collapsible headings, Recently Deleted, folders, lock, search.

---

## Verification gaps (check on device)

- The exact iOS 26 top-bar layout in an open note, both editing and idle: which glass circles appear, whether undo and redo are separate buttons, and where they sit relative to the checkmark.
- The exact bottom bar on the list screen. Does the note count still appear ("N Notes")? Where is the compose button relative to the search field, and is a microphone shown in the field?
- The exact date-token formats in rows (short-date style; the weekday cutoff at 6 or 7 days) and the gap between the date and the preview.
- The editor timestamp string format ("… at …") and whether it shows the created or edited date by default.
- Group header strings and order in iOS 26 (e.g. "Previous 7 Days" vs "Previous 7 days"), plus month and year header rules.
- The empty-note discard rule: is a whitespace-only or title-only note discarded? Does a note created and abandoned leave any flash in the list?
- The current swipe-left action set and order (Share? Move, Delete; Lock?). Does a full swipe left delete without confirmation?
- The checked-item look (strikethrough or not; gray text) and the timing and animation of auto-sort.
- Whether math suggestions default to Suggest Results on iOS, and the ghost-text styling.
- Haptics: checklist toggle, pin, delete, and long-press on rows.
- The order of the 18 toolbar buttons on the iPhone 12 (without Apple Intelligence), and exactly what appears on a multi-line selection.
- Whether the keyboard appears immediately on a new note, and the caret's style and position on the title line.
