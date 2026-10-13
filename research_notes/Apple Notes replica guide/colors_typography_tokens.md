# Apple Notes Visual Design Tokens (Colors, Typography, Materials, Paper)

> Scope: what Notes on **iOS 26.x** looks like (target: iPhone 12, iOS 26.6.2; built with Xcode 26.6 / iOS 26.5 SDK), so a SwiftUI/UIKit replica can match it pixel for pixel. Each finding is labelled **Apple-documented**, **reverse-engineered (RE)** or **community/estimate**. Most hard numbers below come from Notes' own code and asset catalogs, read straight from the iOS 26.5 Simulator runtime (method under *Source key*). That is stronger evidence than color-picking screenshots, but it still needs a final check on the device. iOS 27 shipped on 2026-09-14; its Notes changes are in a separate labelled section, and iOS 26 stays the primary target.

### Source key
**[SIM-RE]** = read on 2026-10-14 from Xcode's *iOS 26.5 (23F77)* Simulator runtime, `…/RuntimeRoot/System/Library/PrivateFrameworks/{NotesUI,NotesEditor,NotesShared}.framework`. There were two methods: (a) `xcrun assetutil --info NotesUI.framework/Assets.car`, which dumps the named colors; and (b) a small ObjC CLI run with `xcrun simctl spawn` on an iPhone 17 sim. The CLI `dlopen`s the Notes frameworks and calls their own class methods: `+[UIColor(IC) ICTintColor…]`, `+[UIFont(IC) ic_preferredFontFor…]`, `-[ICTTTextController preferredAttributesForICTTTextStyle:]`, `ICColorForEmphasisColorType()` and `+[ICPaperStyle drawPaperStyleType:inRect:]`. Colors were resolved for light, dark and Increase Contrast at content size L. The same assets in the iOS 18.6 runtime give the same tint values, so they have been stable across releases. `MobileNotes.app` in the sim has no executable, so the live app could not be launched there.

---

## What is the Notes accent (yellow/gold) color, and does it map to `systemYellow`?

### Takeaway
No, it is not `systemYellow`. Notes uses its own fixed gold, **`#E4AF0A`** (sRGB 228/175/10). It is the **same in light and dark mode**, and under Increase Contrast it darkens to **`#B68C08`**. `systemYellow` (`#FFCC00` / `#FFD600`) is lighter and more lemon-colored, so using it would be a visible mismatch.

### Cited Findings
- **RE:** the asset `notes_tint_color` is `#E4AF0A` for both *Any* and *Dark*. `+[UIColor ICTintColor]` resolves to `#E4AF0A` in light, dark, light-HC and dark-HC alike. `ICHashtagColor` is also `#E4AF0A`. — [SIM-RE: NotesUI Assets.car + ICTintColor probe](#source-key)
- **RE:** `+[UIColor ICDarkenedTintColor]` and `ic_darkerAccessibilityColorForColor:(ICTint)` both give `#B68C08`. The asset `quick_note_tint_color` uses `#B58B08` for its HighContrast variants, so Notes swaps to the darker gold for accessibility. — [SIM-RE](#source-key)
- **RE:** `+[UIColor ic_tintColorWithTraitCollection:]` returned `systemBlue` in the probe process. Inference: Notes falls back to the system tint when it is hosted outside the Notes app (Quick Note, extensions), and uses ICTintColor inside the app. — [SIM-RE](#source-key)
- **RE (iOS 18.6 runtime):** `notes_tint_color` there is also `#E4AF0A`, and `notes_selection_tint_color` is `#E4AF0A`@20% / `#FFD966`@50%, so these values have not changed across releases. — [SIM-RE](#source-key)
- **Apple-documented:** the iOS 26 `systemYellow` is R255 G204 B0 (light) / R255 G214 B0 (dark), and the accessible variants are R161 G106 B0 / R254 G223 B67. The probe confirmed these at runtime. — [Apple HIG Color (JSON)](https://developer.apple.com/tutorials/data/design/human-interface-guidelines/color.json)
- **Community:** links in Notes are drawn in the app's yellow accent. On the Mac this follows the system accent setting, and on iOS it is fixed. — [Gadget Hacks – yellow links in Notes](https://ios.gadgethacks.com/how-to/sick-yellow-links-notes-make-them-any-color-you-want-with-these-hidden-iphone-ipad-and-mac-settings-0385154/); [TidBITS Talk](https://talk.tidbits.com/t/can-i-change-the-link-colour-in-apples-notes/22523)
- **Community (low trust):** brand-palette sites list "Sunglow `#FFD52E`" for Notes. That comes from the **app icon**, not the UI tint. — [brandpalettes.com](https://brandpalettes.com/apple-notes-colors/)
- **RE:** the icon gradient assets are `BackgroundGradientStartColor #FFD800` and `BackgroundGradientStopColor #FABB00`. These are for the icon or empty-state artwork, not for controls. — [SIM-RE](#source-key)

### Where the tint shows (RE + community)
- Window/app tint, which covers back chevrons, toolbar glyphs (checklist, camera, compose), "Edit"/"Done", folder SF Symbols in the folders list, swipe-action highlights, the text caret, links and hashtags: `#E4AF0A`. This list is inferred from `ICTintColor` being the app tint, and from the [Gadget Hacks](https://ios.gadgethacks.com/how-to/sick-yellow-links-notes-make-them-any-color-you-want-with-these-hidden-iphone-ipad-and-mac-settings-0385154/) report on links.
- Text selection fill (`ICTintedSelectionColor`): `#E4AF0A` at **α 0.20** in light (about `#FAEFCE` over white) and `#FFD966` at **α 0.50** in dark (about `#806D33` over black). — [SIM-RE](#source-key)
- Find-in-note match: `ICFindInNoteHighlightColor` is `#EABB00` at α 0.30. The current match, `selected_search_highlight`, is `#704716`. `ICListStatusIndicatorColor` (the unread/updated dot) is `#EABB00`. — [SIM-RE](#source-key)
- `ICControlAccentColor` is **systemBlue** (`#0088FF` / `#0091FF`), so system switches and controls inside Notes keep the blue accent. — [SIM-RE](#source-key)

### Inferences
- Define a **static** `notesTint = #E4AF0A`, plus an Increase-Contrast variant `#B68C08`. Set it as the window/root `.tint`. Do not use `Color.yellow`.
- On iOS 26 glass bars the system renders symbols monochrome by default (see the Liquid Glass section). Set `.tint` explicitly on the bar items you want gold.

---

## Which backgrounds, separators and card colors do the folders list, notes list, editor and gallery use?

### Takeaway
Notes uses stock semantic colors. The folders and notes lists sit on **`systemGroupedBackground`** (`#F2F2F7` light / `#000000` dark), with inset-grouped cells on **`secondarySystemGroupedBackground`** (`#FFFFFF` / `#1C1C1E`). The editor is **`systemBackground`** (`#FFFFFF` / `#000000`). The only custom color in these surfaces is the gold.

### Cited Findings
- **RE:** `ICGroupedBackgroundColor` resolves to `#F2F2F7` / `#000000` (HC `#EBEBF0` / `#000000`), the same as `systemGroupedBackground`. `ICBackgroundColor` and `ic_noteEditorBackgroundColor` resolve to `#FFFFFF` / `#000000`. — [SIM-RE](#source-key)
- **RE:** the editor text color `ic_noteEditorLabelColor` is `label` (`#000000` / `#FFFFFF`). `ic_noteEditorSecondaryLabelColor` is `secondaryLabel` (`#3C3C43`@60% / `#EBEBF5`@60%). — [SIM-RE](#source-key)
- **RE:** note-preview / gallery cards use `ic_noteEditorPreviewColorForceLightContent:NO`, which is `#FFFFFF` / `#1C1C1E` (HC dark `#242426`). Thumbnail wells use `list_thumbnail_background_color`: gray 0.94 @ α 0.5 (light) and gray 0.18 @ α 0.5 (dark). Table and attachment borders use **systemGray4** (`#D1D1D6` / `#3A3A3C`). — [SIM-RE](#source-key)
- **RE:** `ICNoteEditorToolbarColor` is `secondarySystemBackground` (`#F2F2F7` / `#1C1C1E`). It is probably a legacy, pre-glass toolbar fill. — [SIM-RE](#source-key)
- **RE:** the swipe-action fills are Pin `#FF9400`, Move `#787AFF`, Share `#3293FC` and Lock `#C7C7CC`. Delete uses systemRed (not probed). — [SIM-RE](#source-key)
- **Apple-documented:** the separators are `separator`, `#3C3C43`@12% (light) / `#545458`@50% (dark), and `opaqueSeparator`, `#C6C6C8` / `#38383A`. These are UIKit standard values, which the probe confirmed. — [UIKit UI element colors](https://developer.apple.com/documentation/uikit/ui-element-colors)

### Inferences
- In SwiftUI, use `List { … }.listStyle(.insetGrouped)` (which gives these colors by default) and `Color(uiColor: .systemBackground)` for the editor. Leave the default separators in place.

---

## How does Liquid Glass affect the bars and buttons in iOS 26 Notes?

### Takeaway
Notes uses the **stock iOS 26 glass bars**. The navigation-bar buttons are glass circles and pills. The bottom toolbar is a floating glass capsule, with **search moved to the bottom**. "Done" is a glass **checkmark** button tinted with the app accent. Glass has no color of its own; it picks up color from the content behind it.

### Cited Findings
- **Apple-documented:** "Liquid Glass has no inherent color, and instead takes on colors from the content directly behind it." On toolbars and tab bars, "symbols and text … follow a monochromatic color scheme" by default, and color should be applied sparingly, for example to a primary action. — [Apple HIG Color (Liquid Glass color)](https://developer.apple.com/design/human-interface-guidelines/color); [WWDC25 Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
- **Apple-documented:** "search within easy reach at the bottom of iPhone in apps like … Notes". — [Apple – All New Features iOS 26 (PDF)](https://www.apple.com/os/pdf/All_New_Features_iOS_26_Sept_2025.pdf)
- **Community:** the iOS 26 Notes changes reported are a Liquid Glass design, updated and moved buttons, search at the bottom, "**line spacing is tweaked**", and a toolbar you can swipe horizontally. — [9to5Mac – Notes in iOS 26](https://9to5mac.com/2025/10/16/heres-everything-new-for-apple-notes-in-ios-26/)
- **Community:** in iOS 26, Done is a glass checkmark circle that "can be tinted to the app's accent color", and Close (X) is not tinted. — [Joe Cieplinski – iOS 26 protip](https://micro.joecieplinski.com/2025/07/04/protip-if-you-are-looking.html)

### Inferences
- Use the system `NavigationStack` / `.toolbar` with no custom backgrounds; on the iOS 26 SDK they become glass automatically. Give the compose and Done items `.tint(notesTint)`, and give Done `.buttonStyle(.glassProminent)` (estimate).

---

## What are the editor paragraph styles (Title, Heading, Subheading, Body, Monostyled, lists, block quote)?

### Takeaway
All of these are **SF Pro (system font, not Rounded)** except Monostyled, which is **SF Mono**. They scale with Dynamic Type through the Body text style, so at the default size (L) the numbers below are exact.

| Style (ICTT id) | Font @ size L | Weight | lineSpacing | paragraphSpacing |
|---|---|---|---|---|
| Title (0) | 28 pt | Bold (`.SFUI-Bold`) | 1 | 3 |
| Heading (1) | 22 pt | Bold | 0 | 4 |
| Subheading (2) | 17 pt | Bold | 4 | 0 |
| Body (3) | 17 pt | Regular | 4 | 0 |
| Monostyled (4) | 15 pt SF Mono (`.AppleSystemUIFontMonospaced`) | Regular | 2 | 0 |
| Bulleted / Dashed / Numbered list (100/101/102) | inherits (Body 17) | — | 2 | 0 |
| Checklist (103) | inherits (Body 17) | — | 0 | 3.5 + 3.5 before |
| Block quote (paragraph attribute `blockQuoteLevel`) | inherits | — | 4 | 0 |

### Cited Findings
- **RE:** the `ic_preferredFontFor{Title,Heading,Subheading,Body,FixedWidth}Text` calls and `preferredFontForICTTTextStyle:0…4` return exactly the font, size and weight in the table. The text-style attribute is `UICTFontTextStyleBody` for all except Mono. — [SIM-RE](#source-key)
- **RE:** the paragraph metrics come from `preferredAttributesForICTTTextStyle:` and `nsParagraphStyleForICTTParagraphStyle:` (lineHeightMultiple 1, tab interval 28). Lists use `NSTextList` with markers U+FFFC (a bullet drawn by Notes), U+2013 "–" and "0.". The default paragraph style has lineHeightMultiple **1.2**. Attachments get paragraphSpacing 8 and spacingBefore 9. — [SIM-RE](#source-key)
- **RE: Dynamic Type scaling (Title / Heading / Subheading+Body / Mono)** — XS 23/18/14/12.4 · S 25/19/15/13.2 · M 26/21/16/14.1 · **L 28/22/17/15** · XL 31/25/19/16.8 · XXL 35/27/21/18.5 · XXXL 38/30/23/20.3 · AX-M 46/36/28/24.7 · AX-XXXL 87/69/53/46.8. — [SIM-RE](#source-key)
- **RE:** the named styles are 0 Title, 1 Heading, 2 Subheading, 3 Body, 4 Monostyled, 100 "• Bulleted List", 101 "– Dashed List", 102 "1. Numbered List" and 103 checklist. `noteDefaultNamedStyle` = 0 (Title). — [SIM-RE](#source-key)
- **Apple-documented:** the paragraph styles are title, heading, subheading and body, plus Monostyled, block quote and lists. — [Apple – Format notes on Mac (Notes 4.13, macOS 26)](https://support.apple.com/en-az/guide/notes/apd1955d3b21/4.13/mac/26)
- **Apple-documented:** the first-line default lives in Settings > Apps > Notes > **New Notes Start With** (Title, Heading, Subheading, Body), and the default is Title. — [Apple Vision Pro User Guide – Notes](https://support.apple.com/guide/apple-vision-pro/tan55c811e92/visionos); [9to5Mac – notes without bold headings](https://9to5mac.com/2024/06/01/how-to-make-iphone-notes-without-bold-headings/)
- **Community:** "Heading is a bigger font size and bolded; Subheading is the same font size as Body, but bold." This matches the RE values. — [9to5Mac](https://9to5mac.com/2024/06/01/how-to-make-iphone-notes-without-bold-headings/)
- **Community:** a block quote is a **vertical gray bar** on the left with the text indented slightly (iOS 17+). Monostyled is inset text on a distinct background. — [MacRumors – block quotes](https://www.macrumors.com/how-to/use-block-quotes-apple-notes/); [iGeeksBlog](https://www.igeeksblog.com/how-to-use-block-quotes-in-apple-notes-on-iphone-ipad-mac/)
- **RE:** the block-quote bar color is `ICBlockQuoteBackgroundColor`, which is `tertiaryLabel` (`#3C3C43`@30% / `#EBEBF5`@30%, HC @70/55%). The Monostyled border is `ICMonostyledBorderColor`: `#3C3C43`@18% (light) / `#EBEBF5`@16% (dark). `ICMonostyledBackgroundColor` reported an opaque `#AAAAAA`, which is probably drawn at reduced alpha, so verify it. — [SIM-RE](#source-key)

### Inferences
- In a UITextView replica, use `UIFont.preferredFont(forTextStyle: .body)`, take its point size as the scaled base, and apply the ratios Title 28/17, Heading 22/17 and Mono 15/17. Alternatively use `UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 28, weight: .bold))`. The list/indent head-indent values (bullet column width) could not be probed headless; they need a device measurement.

---

## What text styles does the chrome use (list rows, section headers, gallery, date line, large titles)?

### Takeaway
List rows use **Headline 17 semibold** for the title and **Subheadline 15 regular** for the date + preview line. Section headers ("Pinned", "Today", "iCloud") are **20 pt semibold**. Navigation titles are standard large titles.

### Cited Findings
- **RE:** `ic_listViewTitleFont` = 17 pt Semibold (`UICTFontTextStyleHeadline`). `ic_listViewDetailFont` = 15 pt Regular (`…Subhead`). `ic_groupInsetHeaderFont` = **20 pt Semibold**. `ic_preferredFontForDateText` (the date line at the top of a note) = 15 pt Regular. `ic_attachmentBrowserTitleFont` = 20 pt Semibold (Title3-emphasized). — [SIM-RE](#source-key)
- **RE (gallery view):** `ic_gridViewNoteTitleFont` = 15 pt Regular, `ic_gridViewNoteSubtitleFont` = 12 pt Regular, `ic_gridViewFolderFont` = 12 pt Regular, `ic_gridViewSectionTitleFont` = 17 pt Semibold. — [SIM-RE](#source-key)
- **RE:** the list title color `list_title_text_color` asset is `#454545` / `#F0F0F0` (HC `#000` / `#FFF`). `ICListTitleTextColor` returned nil in the probe, so the iOS 26 list most likely uses `label`. Detail text uses `secondaryLabel`. — [SIM-RE](#source-key) *(estimate on which is live)*
- **Apple-documented:** the Dynamic Type defaults at L are Large Title 34, Title1 28, Title2 22, Title3 20, Headline 17 semibold, Body 17, Subheadline 15, Footnote 13 and Caption1 12. — [Apple HIG Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
- **Community:** a typical replica uses a 17 bold title and a 15 detail line on the yellow tint, which is close but too heavy. — [AnukarOP/iOS-26-clone NotesApp.swift](https://github.com/AnukarOP/iOS-26-clone/blob/main/iOS/NotesApp.swift)

### Inferences
- Row: `Text(title).font(.headline)` + `HStack { Text(date).font(.subheadline) ; Text(preview).font(.subheadline).foregroundStyle(.secondary) }`. The date color (label vs secondary) needs a device check. The "N Notes" count in the bottom toolbar is estimated at Caption1/Footnote in secondary.

---

## What do checklist circles, tables, and highlight and text colors look like?

### Takeaway
An empty checklist item is the SF Symbol **`circle`** (17 pt Regular, scale .large) in **tertiaryLabel gray**. A checked item is **`checkmark.circle.fill`** (17 pt **Medium**, .large) in **Notes gold**. Table borders are systemGray4. Text highlights use exactly the five system colors **purple / pink / orange / mint / blue**, and the text takes the same color as its highlight.

### Cited Findings
- **RE:** in `-[ICTodoButton imageForChecked:withHighlight:]`, unchecked gives `circle` (pointSize 17, Regular, Large, 25.7 pt image) and checked gives `checkmark.circle.fill` (17, Medium, Large, 26 pt). `+defaultSize` = 25×25 and `+defaultImageSize` = 22×22. — [SIM-RE](#source-key)
- **RE:** the unchecked color, `ICGrayTodoButtonColor`, is `#3C3C43`@30% / `#EBEBF5`@30% (= `tertiaryLabel`). The checked color is the tint `#E4AF0A` (inferred from the button's `updateTintColor` path plus the app tint). — [SIM-RE](#source-key)
- **RE:** `ICTableContentView innerBorderColor` and `outerBorderColor` are both **systemGray4** (`#D1D1D6` / `#3A3A3C`; HC `#BCBCC0` / `#444446`). — [SIM-RE](#source-key)
- **RE:** `ICColorForEmphasisColorType(n)` gives 1 = systemPurple `#CB30E0`/`#DB34F2`, 2 = systemPink `#FF2D55`/`#FF375F`, 3 = systemOrange `#FF8D28`/`#FF9230`, 4 = systemMint `#00C8B3`/`#00DAC3`, 5 = systemBlue `#0088FF`/`#0091FF`. `ICStyleEmphasisColorsCount` = 5 and the default is 1 (purple). The background (`ic_emphasisBackgroudColorFromColor:`) is the color ×0.85 at **α 0.15** (for example `#AD29BE`@15%). Notes also maps these to UIKit's `NSTextHighlightColorScheme` (`ICNSTextHighlightColorSchemeForEmphasisColorType`). — [SIM-RE](#source-key)
- **Community:** iOS 18 added five highlight colors (purple, pink, orange, mint, blue) with no custom colors, and both the text and its background change color. — [MacRumors – iOS 18 Notes colors](https://www.macrumors.com/2024/06/11/ios-18-notes-app-colors); [Nerds Chalk](https://nerdschalk.com/notes-app-in-ios-18-lets-you-highlight-text-in-5-colors-heres-how/)

### Inferences
- In UIKit (iOS 18+), set `.foregroundColor = UIColor.systemPurple` + `.textHighlightStyle = .default` + `.textHighlightColorScheme = .purple`. That lets UIKit draw the exact pill the way Notes does. The manual fallback is a `.backgroundColor` of the color ×0.85 at α 0.15.

---

## What do the Lines & Grids paper styles look like?

### Takeaway
There are six patterns besides None: three line spacings and three grid sizes. Settings > Apps > Notes > Lines & Grids sets the default for new notes, and the ••• menu changes it per note. Notes draws the lines as roughly **1 pt light-gray hairlines** whose **spacing scales with the width of the drawing**.

### Cited Findings
- **Community:** the options are single, double and triple-spaced lines, and small, medium and large grids. The setting applies to new notes only, and each note can override it. — [iGeeksBlog – paper style](https://www.igeeksblog.com/change-paper-style-notes-app-on-iphone-ipad/); [AppleInsider](https://appleinsider.com/articles/21/07/10/how-to-add-lines-and-grids-to-your-notes-on-ios-and-ipados)
- **Apple-documented:** "Lines & Grids: Set the default line or grid style for new notes." — [iPhone User Guide – Notes settings](https://support.apple.com/bn-in/guide/iphone/iph7262fd4fe/12.0)
- **RE:** these were rendered with `+[ICPaperStyle drawPaperStyleType:inRect:]` into a 400 pt-wide rect at 3×. Types 0–1 are blank. Grid pitch is 14.33 / 29.0 / 58.33 pt (types 2/3/4), and line pitch is 14.33 / 22.0 / 29.0 pt (types 5/6/7). At 200 pt wide every pitch halves, so the pitch is about width × {0.0358, 0.0725, 0.146} for grids and width × {0.0358, 0.055, 0.0725} for lines. The peak line value is `#D5D5D5` on white and `#2A2A2A` on black, which matches label color at about 16% opacity, antialiased over about 1.3 pt. — [SIM-RE](#source-key)

### Inferences
- This API might only draw picker thumbnails, while the in-note pattern could use a fixed reference width (for example, the PaperKit canvas). Measure the line pitch in a real note on the iPhone 12 before you hard-code it.

---

## Consolidated token table (drop-in)

| Role | Light | Dark | Source class | SwiftUI / UIKit |
|---|---|---|---|---|
| Accent / tint (bars, compose, caret, links, hashtags, checked circle) | `#E4AF0A` | `#E4AF0A` | RE | `Color(red: 228/255, green: 175/255, blue: 10/255)` |
| Accent, Increase Contrast | `#B68C08` | `#B68C08` | RE | switch on `colorSchemeContrast == .increased` |
| Text selection fill | `#E4AF0A` α .20 | `#FFD966` α .50 | RE | `UITextView.tintColor` + custom selection |
| Find match / current match | `#EABB00` α .30 / `#704716` | same | RE | |
| List & folder background | `#F2F2F7` | `#000000` | Apple sys / RE | `.systemGroupedBackground` |
| List cell / gallery card | `#FFFFFF` | `#1C1C1E` | Apple sys / RE | `.secondarySystemGroupedBackground` |
| Editor background | `#FFFFFF` | `#000000` | Apple sys / RE | `.systemBackground` |
| Editor text | `#000000` | `#FFFFFF` | RE | `.label` |
| Secondary text (date, preview, counts) | `#3C3C43` α .60 | `#EBEBF5` α .60 | Apple sys / RE | `.secondaryLabel` |
| Unchecked circle, block-quote bar | `#3C3C43` α .30 | `#EBEBF5` α .30 | RE | `.tertiaryLabel` |
| Table borders | `#D1D1D6` | `#3A3A3C` | RE | `.systemGray4` |
| Monostyled border | `#3C3C43` α .18 | `#EBEBF5` α .16 | RE | |
| Separators | `#3C3C43` α .12 | `#545458` α .50 | Apple sys | `.separator` |
| Highlight purple/pink/orange/mint/blue (text) | `#CB30E0` `#FF2D55` `#FF8D28` `#00C8B3` `#0088FF` | `#DB34F2` `#FF375F` `#FF9230` `#00DAC3` `#0091FF` | Apple sys / RE | `.systemPurple` … `.systemBlue` |
| Highlight background | text color ×0.85, α .15 | same rule | RE | `.textHighlightColorScheme` |
| Paper lines | ≈`#D5D5D5` | ≈`#2A2A2A` | RE (estimate) | |
| Title | SF Pro Bold 28 | | RE | `.systemFont(ofSize: 28, weight: .bold)` scaled by `.body` metrics |
| Heading | SF Pro Bold 22 | | RE | `.systemFont(ofSize: 22, weight: .bold)` |
| Subheading | SF Pro Bold 17 | | RE | `.body.bold()` |
| Body | SF Pro Regular 17, lineSpacing 4 | | RE | `.body` |
| Monostyled | SF Mono Regular 15, lineSpacing 2 | | RE | `.monospacedSystemFont(ofSize: 15, weight: .regular)` |
| List row title / detail | Semibold 17 / Regular 15 | | RE | `.headline` / `.subheadline` |
| Section header (Pinned, iCloud) | Semibold 20 | | RE | `.title3.weight(.semibold)` |
| Note date line | Regular 15, secondary | | RE (+estimate on color) | `.subheadline` |
| Gallery title / subtitle | Regular 15 / Regular 12 | | RE | |
| Nav large title | Bold 34 | | Apple sys | `.navigationBarTitleDisplayMode(.large)` |
| Checklist glyphs | `circle` 17 Regular L / `checkmark.circle.fill` 17 Medium L | | RE | `Image(systemName:)` + `.imageScale(.large)` |

---

## iOS 27 (shipped 2026-09-14): Notes differences (secondary)

### Cited Findings
- **Apple/press:** iOS 27 went public on Sept 14, 2026, iOS 27.0.1 followed on Sept 28, and it runs on the same devices as iOS 26, including the iPhone 11/12. — [AppleInsider](https://appleinsider.com/articles/26/09/14/ios-27-is-now-available-with-big-changes-to-photos-and-siri); [MacRumors 27.0.1](https://www.macrumors.com/2026/09/28/apple-releases-ios-27-0-1/)
- **Community:** the Notes changes are a refreshed app icon, "Liquid Glass updates for buttons, menus, and more", new shared-folder and shared-note icons, **Insert Divider Line**, Link to Section, Markdown paste and "Copy as Markdown", and Siri AI content. — [9to5Mac – Notes in iOS 27](https://9to5mac.com/2026/09/28/heres-everything-new-for-apple-notes-in-ios-27/); [MacRumors](https://www.macrumors.com/2026/06/17/ios-27-apple-notes-app-new-features/)

### Inferences
- No color or font changes have been reported. The iOS 27 runtime is not installed locally, so none of its tokens were probed. If the phone moves to iOS 27, re-run the [SIM-RE](#source-key) probe against a 27.x runtime and add the divider-line style (color and thickness unknown).

---

## Verification gaps (check on device)
1. Screenshot the back chevron, compose glyph and Done button on the iPhone 12 and pixel-sample them. Expect `#E4AF0A` in both modes. Also check whether iOS 26 glass bar items show gold or monochrome glyphs by default.
2. List row: is the date `label` or `secondaryLabel`? Is the title `#454545` or pure `label`? Check the color and size of the bottom-toolbar "N Notes" count.
3. Body text color: `ic_noteEditorLabelColor` (`label`) vs `preferredDefaultFontColor` (`#454545` / `#DCDCDC`). Sample a plain Body line.
4. List indents: measure the bullet / dash / number column width and the indent step, the block-quote bar width, inset and corner radius, and the Monostyled background alpha and corner radius.
5. Paper styles: the actual line and grid pitch in a note at 390 pt wide (iPhone 12), and the line color in dark mode.
6. The selection-handle color, and whether the caret uses the tint.
7. The size and hit target of the checklist circle inside text, and the strike or gray-out of checked items when "Sort Checked Items" is on.
8. Increase Contrast: confirm that the tint switches to `#B68C08`.
9. Confirm the iOS 26.6.2 values match the 26.5 runtime. iOS 18.6 and 26.5 were identical for the tint assets, so a difference is unlikely.
