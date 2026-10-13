# iOS Calculator Visual Design Tokens (Colors, Typography, Materials, States)

> Scope: publicly documented Apple system colors + community-measured/replica tokens for matching Calculator’s look on iOS 18+. Distinguish **official system colors** from **community-extracted hex**. Estimates are marked.

---

## Exact or commonly measured hex/RGB/system color values for each button category and the screen background?

### Takeaway
Calculator’s palette is a black canvas with three button roles (digit dark gray, function lighter/darker gray, operator orange). Orange maps to Apple’s `systemOrange` (light `#FF9500` / dark `#FF9F0A`); digit/function fills are **community-extracted**, not Apple-published Calculator tokens.

### Cited Findings
- Apple documents iOS `systemOrange` as **R 255 G 149 B 0** (light) and **R 255 G 159 B 10** (dark), i.e. `#FF9500` / `#FF9F0A`. — [Apple HIG Color (archived)](https://web.archive.org/web/20230108012747/https://developer.apple.com/design/human-interface-guidelines/foundations/color); [swiftuicolors.com systemOrange](https://swiftuicolors.com/ios-colors/system-orange)
- Apple warns: documented system color RGB values are for design reference; **do not hard-code**—values can change by release and environment; use APIs like `UIColor.systemOrange` / SwiftUI `Color.orange`. — [Apple HIG Color (archived)](https://web.archive.org/web/20230108012747/https://developer.apple.com/design/human-interface-guidelines/foundations/color)
- Accessibility **Increase Contrast** changes Calculator operator orange (users report darker orange / “red” operators); disable via Settings → Accessibility → Display & Text Size → Increase Contrast (or Per-App Settings). — [Apple Discussions](https://discussions.apple.com/thread/255172808); [iPhoneTricks](https://www.iphonetricks.org/red-calculator-icons-on-iphone-fix/)
- Community “iOS 11 Calculator” palette table (widely reused in replicas): Display black `#000000` (text `#FFFFFF`); Number key gray `#333333` (text `#FFFFFF`); Function key gray `#A5A5A5` (text `#000000`); Operator orange `#FF9500` (text `#FFFFFF`); Secondary gray `#D4D4D2`. — [codingace.net iOS 11 Hex Color Codes Calculator](https://codingace.net/general/ios_11_hex_color_codes.html)
- JS web replica documents: digit `.btn` `#333333`, function `.gray_btn` `#a6a6a6` with **black** text, operator `.orange_btn` `#ff9705`, white digit/operator glyphs, circular `border-radius: 50%`, button font-size `40px`. — [Hephaest/iOSCalculator (GitHub)](https://github.com/Hephaest/iOSCalculator)
- Popular SwiftUI tutorial replica: operators `Color.orange`; function keys `Color(.lightGray)`; digits `UIColor(red: 55/255, green: 55/255, blue: 55/255)` ≈ `#373737`; screen `Color.black`; digit/op text white. — [AfrazCodes/SwiftUI-Calculator ContentView.swift](https://raw.githubusercontent.com/AfrazCodes/SwiftUI-Calculator/master/Calculator/ContentView.swift)
- Pre–iOS 18 community description of stock UI: black background, dark gray keypad, **light gray and orange** modifier keys, white entry/results text. — [Gadget Hacks – Calculator color mods](https://ios.gadgethacks.com/how-to/update-your-iphone-calculators-look-with-these-easy-color-mods-0384541/)
- iOS 18 cosmetic change (qualitative, not hex): AC / +/− / % use **white font on dark gray** (vs light gray fill on iOS 17); number keys “a little bit darker.” — [Gadget Hacks – iOS 18 Calculator features §11](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- Dark-mode system grays that often approximate digit keys when mapping to semantic APIs: `systemGray5` dark **R 44 G 44 B 46** (`#2C2C2E`); `systemGray4` dark **R 58 G 58 B 60** (`#3A3A3C`); `systemGray6` dark **R 28 G 28 B 30** (`#1C1C1E`). — [Apple HIG Color (archived)](https://web.archive.org/web/20230108012747/https://developer.apple.com/design/human-interface-guidelines/foundations/color)
- App-icon / marketing palette (not keypad): Light Gray `#D4D4D2`, Blackboard `#1C1C1C`, Heather Grey `#505050`, Vivid Gamboge `#FF9500`. — [SchemeColor – Apple Calculator App Icon 2017](https://www.schemecolor.com/apple-calculator-app-icon-2017-colors.php)
- Increase-contrast systemOrange (dark) reference from HIG table: **R 255 G 179 B 64** (distinct from default dark orange). — [Apple HIG Color (archived)](https://web.archive.org/web/20230108012747/https://developer.apple.com/design/human-interface-guidelines/foundations/color)

### Inferences
- For a dark Calculator replica targeting iOS 18+ keypad chrome: prefer **black `#000000` canvas**, digit fill near **`#333333`–`#373737`** (community), function fill **darker than classic `#A5A5A5`** with **white** labels (iOS 18), operators via **`systemOrange` / `#FF9F0A`** (dark) or `#FF9500` (classic tutorials).
- Classic `#A5A5A5` + black label is the **pre–iOS 18** function-key look; do not use it for an iOS 18+ visual match without noting the regression.
- Exact Apple asset hex for digit/function fills is unpublished; treat `#333333` / `#A5A5A5` / `#373737` as **estimated extractions**.

### Gaps
- No Apple-published Calculator-specific color asset catalog or Design Resources file with official keypad hex values.
- No verified screenshot-measured hex published for **iOS 18** function-key dark gray or the “slightly darker” digit gray (only qualitative reporting).
- No reliable public source for expression-line / secondary display gray used above the main result in iOS 18.

---

## What font is used (SF Pro / SF Pro Rounded / SF Compact / system) and at what sizes/weights for the main display and button glyphs?

### Takeaway
Apple does not publish Calculator’s type recipe. The system font is San Francisco (SF Pro); replicas commonly use `.system` at ~80–100 pt for the display and ~32–40 pt for buttons. Whether stock Calculator uses **SF Pro Rounded** vs default SF is **disputed** in community sources.

### Cited Findings
- Apple’s HIG states the system offers SF Pro (and others) in **rounded variants** “to coordinate text with the appearance of soft or rounded UI elements.” Tracking adjusts dynamically at every point size in a running app. — summarized via [appguidelines.com HIG Typography mirror](https://appguidelines.com/human-interface-guidelines/version/20/typography/) (mirrors Apple Typography guidance)
- UX Stack Exchange observation (2019): Apple uses SF Rounded for some large number UIs (e.g. Apple Pay) but **still uses regular SF** in examples including **Calculator** and Timer. — [UX Stack Exchange – SF Rounded](https://ux.stackexchange.com/questions/127272/when-to-use-apples-sf-rounded-font)
- Conflicting secondary writeup claims Calculator buttons use **SF Pro Rounded Bold ~22 pt** — treat as unverified blog claim vs the SE observation. — [wolfnhare iPad Typography](https://wolfnhare.com/ipad-typography-choices-sf-pro-display-and-text-pairings-for-legibility)
- SwiftUI replica patterns: display `.font(.system(size: 100)).bold()` white; buttons `.font(.system(size: 32))`. — [AfrazCodes/SwiftUI-Calculator](https://raw.githubusercontent.com/AfrazCodes/SwiftUI-Calculator/master/Calculator/ContentView.swift)
- Another SwiftUI replica: display `.system(size: 90, weight: .light)` with `minimumScaleFactor(0.6)`; buttons `.system(size: 35)`. — [Dima-Bulgakov/Calculator (search snippet / GitHub)](https://github.com/Dima-Bulgakov/Calculator)
- Medium SwiftUI clone (snippet): display size `80` with `minimumScaleFactor(0.5)`; buttons size `32`. — [Medium – Clone Calculator iOS SwiftUI](https://medium.com/@hendralijaya/tutorial-clone-calculator-ios-swiftui-part-1-cloning-the-ui-a35f72ce7378)
- Web replica: button `font-size: 40px`, white on dark/orange. — [Hephaest/iOSCalculator](https://github.com/Hephaest/iOSCalculator)
- HIG tracking guidance (mockups): at large display sizes (e.g. 80 pt) tracking → **0**; system font applies optical tracking automatically at runtime. — [appguidelines.com HIG Typography tracking tables](https://appguidelines.com/human-interface-guidelines/version/20/typography/)
- Enabling SF Rounded in SwiftUI: `.font(.system(size:weight:design: .rounded))` or `.fontDesign(.rounded)` (iOS 16.1+). — [Stack Overflow – SF Rounded in SwiftUI](https://stackoverflow.com/questions/56550064/how-to-use-sf-rounded-font-in-swiftui)

### Inferences
- Safest replica recipe without device measurement: **SF Pro (system)** default design, **light/thin/regular** large display (~72–100 pt) that **shrinks** via `minimumScaleFactor`, buttons **regular ~32–36 pt** (or ~40 CSS px on web), white digits/operators; optionally try `.rounded` and A/B against a device screenshot.
- Letter-spacing: rely on **system automatic tracking** rather than hard-coded CSS letter-spacing for native replicas; for Figma mockups use HIG tracking tables at the chosen point size.

### Gaps
- No official confirmation of SF Pro vs SF Pro Rounded for Calculator display or keys on iOS 18.
- No official point sizes, weights, or Dynamic Type text styles for Calculator (replicas hard-code pt sizes).
- No public measurement of letter-spacing / tracking on the Calculator display beyond HIG general SF tables.
- Dynamic Type behavior for Calculator is undocumented; community clones typically **ignore** Dynamic Type and use fixed sizes + scale-to-fit.

---

## How do pressed states look (darken, invert, orange fill for active operator)?

### Takeaway
There are two distinct behaviors: (1) **momentary press highlight** while a finger is down (often implemented as lighten/fade or redraw), and (2) **sticky selected operator** that stays highlighted until the next operand (commonly orange↔white invert in replicas). Apple’s stock implementation is custom drawing / touch tracking, not stock `UIButton` chrome.

### Cited Findings
- Stack Overflow (matt): Calculator keys are **drawings, not UIButtons**; a single background view uses `touchesBegan` / `touchesMoved` / `touchesEnded` and **redraws** under the finger—enabling slide-across highlighting. — [Stack Overflow – Calculator highlight effect](https://stackoverflow.com/questions/62856110/how-does-apple-do-the-uibutton-highlight-effect-in-the-calculator-app)
- Common replica press feedback pattern: while pressed, swap to **white fill + colored/black text** and/or reduce **opacity ~0.6**, with short ease animation (~0.25s). — [Stack Overflow – ButtonStyle isPressed](https://stackoverflow.com/questions/74407512/swiftui-combine-buttonstyle-functionality-with-different-functions-for-each-bu)
- UIButton.Configuration approaches often approximate system highlight by dropping **alpha to ~0.6** when highlighted. — [Stack Overflow – UIButton.Configuration highlight](https://stackoverflow.com/questions/77423953/how-to-make-uibutton-configuration-highlight-appearance-match-that-of-system-but)
- Operator “active” state in replicas: selected operator typically shows **inverted** styling (white/light fill with orange glyph) until cleared by the next digit or `=`. (Widely observed UX; replica code often toggles selected styling separately from momentary press.) — inferred from common clone behavior described alongside orange operators in [AfrazCodes/SwiftUI-Calculator](https://raw.githubusercontent.com/AfrazCodes/SwiftUI-Calculator/master/Calculator/ContentView.swift) and press-invert patterns in [SO ButtonStyle](https://stackoverflow.com/questions/74407512/swiftui-combine-buttonstyle-functionality-with-different-functions-for-each-bu)
- HIG guidance for toggled controls elsewhere: system reserves **white background + black text/icons** as a toggled-state visual in some button contexts (relevant as a design parallel for “selected” chrome, not Calculator-specific). — [Apple HIG Buttons (tutorial data)](https://developer.apple.com/tutorials/data/design/human-interface-guidelines/buttons.md)

### Inferences
- Matching Apple feel requires **finger-tracking across keys** (highlight follows drag), not only per-button highlight.
- For operator sticky state: **invert** (orange → white fill, orange glyph) is the community-standard match; momentary press on digits/functions is closer to **lighten or alpha fade** than darken.
- Exact Apple press fill colors / animation curves / durations are unpublished.

### Gaps
- No official hex for pressed digit, pressed function, or selected-operator fill/glyph.
- No measured animation duration, spring parameters, or haptic pairing for Calculator key press.
- Unclear from public sources whether iOS 18 changed press or selected-operator visuals independently of the function-key recolor.

---

## Light vs dark mode differences (Calculator is famously always dark — confirm for current iOS)?

### Takeaway
Yes for current iOS/iPadOS: Calculator’s basic keypad chrome remains **always dark** and does **not** follow system Light/Dark Mode (or Smart Invert). Math Notes inherits that dark-only constraint as of iPadOS/iOS 18 community reports.

### Cited Findings
- Gadget Hacks (updated through 2024): default Calculator has black background / dark gray keypad / light gray & orange modifiers / white text; **“stays the same whether you're using Dark Mode or not”**; Smart Invert also does not change Calculator; Shortcuts “Set Light/Dark Mode” has **no effect**. — [Gadget Hacks – Calculator color mods](https://ios.gadgethacks.com/how-to/update-your-iphone-calculators-look-with-these-easy-color-mods-0384541/)
- Apple Support Community (iPadOS 18): “The Calculator App and by extension the Math Notes feature **only support a dark background**.” — [Apple Discussions – Math Notes stuck in Dark Mode](https://discussions.apple.com/thread/255760114)
- Classic Invert / Color Filters *can* alter perceived Calculator colors globally via accessibility, but that is user theming—not a Light Mode appearance. — [Gadget Hacks – Calculator color mods](https://ios.gadgethacks.com/how-to/update-your-iphone-calculators-look-with-these-easy-color-mods-0384541/); [Apple Support – Change display colors](https://support.apple.com/guide/iphone/change-display-colors-iph3e2e1fb0/ios)

### Inferences
- A faithful replica should **force a dark appearance** (`colorScheme == .dark` or hard-coded black UI) rather than adapting fills for Light Mode.
- Prefer **dark** `systemOrange` (`#FF9F0A`) when using system colors inside that forced-dark UI.

### Gaps
- No Apple HIG page stating Calculator is appearance-locked; confirmation is from journalism + community support, not a formal design token doc.
- Behavior under future OS (e.g. Liquid Glass-era system chrome) not verified in this research pass for Calculator keypad specifically.

---

## Any glassmorphism, shadows, borders, or gradients on buttons?

### Takeaway
Classic and iOS 18 Calculator keypad buttons read as **flat, opaque, circular fills** (no glass, no border stroke, no drop shadow, no gradient) in community descriptions and replicas. Blur/vibrancy/Liquid Glass materials are system patterns for other chrome, not the documented Calculator key look.

### Cited Findings
- Community replicas implement solid fills + full circle/`cornerRadius = height/2` with **no** shadow/border/gradient in the primary CSS/SwiftUI samples. — [Hephaest/iOSCalculator](https://github.com/Hephaest/iOSCalculator); [AfrazCodes/SwiftUI-Calculator](https://raw.githubusercontent.com/AfrazCodes/SwiftUI-Calculator/master/Calculator/ContentView.swift)
- Pre–iOS 18 description: black background, dark gray keypad, light gray/orange keys—flat material language. — [Gadget Hacks – Calculator color mods](https://ios.gadgethacks.com/how-to/update-your-iphone-calculators-look-with-these-easy-color-mods-0384541/)
- iPadOS 18 intro: Calculator “features **round buttons**, with shades of **black and orange**” (no mention of glass/shadows). — [AppleInsider – iPad Calculator](https://appleinsider.com/articles/24/06/11/ipad-finally-has-a-calculator-app---heres-everything-it-can-do)
- Apple Materials / Liquid Glass docs describe blur, vibrancy, and glass for navigation/floating controls; they are **general platform materials**, not Calculator keypad specifications. — [Materials (Apple docs mirror)](https://apple-docs.everest.mt/docs/design/human-interface-guidelines/materials/); [Applying Liquid Glass](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views); [WWDC25 Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
- Experimental “Liquid Calculator” open-source projects that add `.ultraThinMaterial` are **aspirational redesigns**, not claims of matching stock Calculator. — [0xatrilla/Liquid-Calculator](https://github.com/0xatrilla/Liquid-Calculator)

### Inferences
- For a visual match through iOS 18: use **opaque circular disks**, ~equal spacing grid, no key shadows/borders/gradients/materials.
- History sidebar / mode menus may use standard system materials (unverified); keep that separate from keypad token work.

### Gaps
- No public Apple asset specs for button diameter, inter-button gutter, or bottom safe-area padding.
- No screenshot analysis in this pass measuring anti-alias fringe or subtle highlight on keys.
- iOS 26 / Liquid Glass era Calculator chrome not confirmed here.

---

## How do button labels use SF Symbols vs text characters (÷ × − + = % etc.)?

### Takeaway
Apple does not publish Calculator’s glyph source. Community clones split: many use **Unicode/text** (`÷`, `+`, `=`, `%`, `AC`); higher-fidelity SwiftUI clones often use **SF Symbols** (`divide`, `multiply`, `minus`, `plus`, `equal`, `percent`, `plus.forwardslash.minus`).

### Cited Findings
- SF Symbols catalog includes calculator-relevant names: `plus`, `minus`, `multiply`, `divide`, `equal`, and circle/square variants. — [andrewtavis/sf-symbols-online](https://github.com/andrewtavis/sf-symbols-online); [Apple SF Symbols / Design Resources](https://developer.apple.com/design/resources/)
- Medium SwiftUI clone maps operators to SF Symbol names: `divide`, `multiply`, `minus`, `plus`, `equal`, `percent`, and `plus.forwardslash.minus` for ±; digits/AC as `Text`. — [Medium – Clone Calculator iOS SwiftUI](https://medium.com/@hendralijaya/tutorial-clone-calculator-ios-swiftui-part-1-cloning-the-ui-a35f72ce7378)
- AfrazCodes replica uses string titles including `÷`, `x`, `+`, `-`, `=`, `%`, `AC`, `-/+` (text / ASCII-ish, not SF Symbols). — [AfrazCodes/SwiftUI-Calculator](https://raw.githubusercontent.com/AfrazCodes/SwiftUI-Calculator/master/Calculator/ContentView.swift)
- Apple HIG Buttons note: prefer symbols in gradient/system buttons because SF Symbols receive appropriate coloring for interaction states—general guidance, not Calculator-specific. — [Apple HIG Buttons](https://developer.apple.com/tutorials/data/design/human-interface-guidelines/buttons.md)

### Inferences
- For closest native feel: use **SF Symbols** for ÷ × − + = % ± and plain **Text** for digits, decimal, and `AC`/`C`/delete; match symbol weight/scale to button label size.
- Avoid literal `x` for multiply if matching Apple; prefer `multiply` symbol or `×` Unicode.

### Gaps
- No public confirmation whether stock Calculator embeds SF Symbols, private assets, or drawn paths.
- Delete/backspace glyph introduced in iOS 18 (replacing AC while typing) not identified to a specific SF Symbol name in sources reviewed.

---

## iOS 18+ Calculator look — what changed visually vs pre–iOS 18?

### Takeaway
iOS 18 kept the black/orange circular-key language but **recolored function keys** (light gray → dark gray with white labels), **darkened digit keys slightly**, shrank the wide zero to a standard circle (mode button takes bottom-left), and added chrome (history, expression line, mode menu)—plus Math Notes / Convert / portrait scientific.

### Cited Findings
- Function keys AC, +/−, %: **white font + dark gray background** on iOS 18 vs **white font + light gray background** on iOS 17; number keys slightly darker. — [Gadget Hacks – iOS 18 Calculator §11](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- Zero key no longer double-width; new **Change Mode** calculator button bottom-left (Basic / Scientific / Math Notes + Convert). — [Gadget Hacks – iOS 18 Calculator §1](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); [MacRumors – iOS 18 Calculator](https://www.macrumors.com/guide/ios-18-calculator-app/)
- Full expression visible while typing; expression shown above result after `=`. — [Gadget Hacks – iOS 18 Calculator §2–3](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- Portrait scientific calculator; history sidebar (list icon / swipe); AC becomes **Delete** while editing (long-press clears). — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); [MacStories iOS 18 review (Calculator)](https://www.macstories.net/stories/ios-and-ipados-18-the-macstories-review/6/)
- First-party Calculator on **iPad** with same round black/orange language; Math Notes handwriting on iPad. — [AppleInsider](https://appleinsider.com/articles/24/06/11/ipad-finally-has-a-calculator-app---heres-everything-it-can-do); [MacRumors](https://www.macrumors.com/guide/ios-18-calculator-app/)
- macOS Sequoia Calculator updated from older square-button look to match rounded iOS style. — [Gadget Hacks – iOS 18 Calculator §15](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)

### Inferences
- Token tables labeled “iOS 11 Calculator” (`#A5A5A5` function keys, wide zero) are **outdated** for iOS 18+ visual parity.
- Layout tokens matter as much as color: 4×5 grid with **unit-width zero** + mode control is part of the iOS 18 silhouette.

### Gaps
- No measured hex for iOS 18 function/digit fills.
- No official before/after design token sheet from Apple.
- Secondary UI (history sheet material, expression typography size/opacity, Convert unit pickers) lacks published visual tokens.

---

## Quick reference token table (replica-oriented)

| Role | Official / semantic | Common community hex | Notes |
|------|---------------------|----------------------|-------|
| Screen background | *(none; forced dark)* | `#000000` | Always-dark UI |
| Digit key fill | *(none)* | `#333333` or `#373737` | Estimate; iOS 18 slightly darker |
| Digit / operator label | white / label | `#FFFFFF` | |
| Function key fill (≤ iOS 17) | *(none)* | `#A5A5A5` / `#A6A6A6` | Black label |
| Function key fill (iOS 18+) | *(none)* | *(unmeasured dark gray)* | White label (qualitative) |
| Operator fill | `systemOrange` | `#FF9500` (light) / `#FF9F0A` (dark) | Prefer API |
| Selected operator | *(none)* | white fill + orange glyph | Community pattern |
| Pressed key | *(none)* | lighten / ~0.6 opacity / invert | Estimate |
| Display type | SF Pro (system) | ~80–100 pt, light/regular | Rounded disputed |
| Button type | SF Pro (system) ± Rounded | ~32–40 pt | Symbols or Unicode |

**Source classes:** Official = Apple HIG/UIKit system colors. Community = screenshot-era palettes & open-source replicas. Qualitative = journalism (esp. iOS 18 function-key recolor).
