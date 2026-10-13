# iOS Calculator — Screens, Layout Geometry & UI Structure

Research scope: Apple Calculator as of iOS/iPadOS 18+ (2024–2026). Older iOS behaviors are labeled when cited. Values marked **estimate** are reverse-engineered or clone-derived, not Apple-published specs. Apple does not publish official Calculator pt/hex design tokens in HIG.

---

## What screens/modes exist and when does each appear?

### Takeaway
iOS 18+ Calculator is a multi-mode app: Basic, Scientific, Math Notes, and Convert (overlay on Basic/Scientific), plus a History sheet/sidebar. Mode choice is explicit via a bottom-left calculator control; orientation no longer auto-switches Basic↔Scientific.

### Cited Findings
- Apple documents four primary task paths in Calculator: basic math, scientific calculator, unit/currency conversion, and Math Notes (handwrite/type problems and graphs). — [Apple Support: Get started with Calculator on iPhone](https://support.apple.com/guide/iphone/get-started-with-calculator-iph6a38eb783/ios)
- Mode switching: tap the calculator control, then choose **Basic** or **Scientific**. — [Apple Support: Get started with Calculator on iPhone](https://support.apple.com/guide/iphone/get-started-with-calculator-iph6a38eb783/ios); [Apple Support: Use the scientific calculator](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- Convert mode: while in basic or scientific, tap the mode control, then tap **Convert**; pick from/to units; reverse with a swap control. Also works from Math Notes via expressions like “50 m in feet =”. — [Apple Support: Convert units or currency](https://support.apple.com/guide/iphone/convert-units-or-currency-iph69d274dde/ios)
- Math Notes entry from Calculator: tap mode control → **Math Notes** → new-note control; results appear when an equals sign is used; graphs via equations with variables. — [Apple Support: Get started with Calculator](https://support.apple.com/guide/iphone/get-started-with-calculator-iph6a38eb783/ios); [MacRumors iOS 18 Calculator guide](https://www.macrumors.com/guide/ios-18-calculator-app/)
- History: available in Basic/Scientific; tap history control; reload, copy expression/result, swipe-delete, Edit → Clear All / multi-delete. Math Notes are **not** stored in Calculator history (they live in Notes). — [Apple Support: See previous calculations](https://support.apple.com/guide/iphone/see-previous-calculations-iph14c31d991/ios); [MacRumors](https://www.macrumors.com/guide/ios-18-calculator-app/)
- **iOS 18 UI change:** bottom-left “Change Mode” calculator button opens Basic / Scientific / Math Notes plus a Convert toggle; `0` is no longer double-width. — [Gadget Hacks iOS 18 Calculator features](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- **Pre-iOS 18:** Scientific mode appeared automatically on landscape rotate; Basic returned on portrait. Scientific portrait was unavailable. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); [The Verge (landscape scientific since iOS 2 / 2008)](https://www.theverge.com/22197381/apple-ios-calculator-scientific-mode-landscape); [Apple Discussions on iOS 17](https://discussions.apple.com/thread/255500634)
- **iPadOS 18:** first official Calculator on iPad; same feature set as iPhone plus Apple Pencil handwriting in Math Notes; multitasking (Split View / Slide Over / Stage Manager) supported. — [Apple Newsroom (iPadOS 18)](https://www.apple.com/ca/newsroom/2024/06/ipados-18-introduces-powerful-intelligence-features-and-apps-for-apple-pencil/); [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); [MacRumors WWDC coverage](https://www.macrumors.com/2024/06/10/apple-calculator-ipad-apple-pencil/)
- WWDC24 Keynote demo: Math Notes via calculator button; write `=` → live solve in user’s handwriting style; variables; graph insert; adjust variables with Pencil hover. — [WWDC24 Keynote transcript](https://developer.apple.com/videos/play/wwdc2024/101/?time=797)
- Control Center: Calculator can be added as a **control** that launches the full Calculator app (including from Lock Screen if Control Center access when locked is enabled). Long-press Control Center Calculator copies last result (reported). — [Cult of Mac](https://www.cultofmac.com/how-to/calculator-app-inside-control-center); [Apple Support: Control Center](https://support.apple.com/en-au/HT210981); [Apple Support: Lock Screen access](https://support.apple.com/guide/iphone/access-features-from-the-lock-screen-iphcd5c65ccf/26/ios/26)
- No first-party evidence found of a dedicated **inline Lock Screen Calculator widget** that embeds a keypad on the Lock Screen itself; Lock Screen widgets are a general system feature, and Calculator’s quick path is Control Center. — [Apple Support: Lock Screen](https://support.apple.com/guide/iphone/access-features-from-the-lock-screen-iphcd5c65ccf/26/ios/26) (documents widgets generally, not a Calculator keypad widget)

### Inferences
- Treat “screens” as: (1) Basic keypad, (2) Scientific keypad (portrait stacked or landscape expanded), (3) Convert chrome over keypad, (4) Math Notes document UI (Notes-like), (5) History list overlay/sheet/sidebar.
- Orientation switching rules **changed in iOS 18**: rotate no longer implies mode change; mode is sticky until user changes it.

### Gaps
- Exact History presentation (full-screen sheet vs edge swipe sidebar vs bottom sheet) differs slightly across reviews (MacStories “sidebar”; Gadget Hacks notes iOS 18.1 slides up from bottom)—no Apple dimensional spec.
- No Apple documentation of StandBy / Dynamic Island Calculator surfaces.
- Whether a Home Screen / Lock Screen **Calculator widget** (beyond Control Center) ships first-party was not confirmed in Support docs reviewed.

---

## What is the exact button layout for basic and scientific modes (row-by-row labels)?

### Takeaway
Basic is a fixed 4×5 grid. Scientific adds function keys (portrait: above the basic pad; landscape: left of the basic pad). Apple documents key *roles* and a few positions (Rad/Deg, Rand, 2nd); full grids below are reverse-engineered from long-standing public screenshots and teardown articles—not an Apple-published keymap.

### Cited Findings

#### Basic mode — structural facts (documented)
- iOS 18+: `0` is **same size** as other digit keys; bottom-left cell is the **mode / calculator** button. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- iOS 18+: dedicated **backspace/Delete** replaces AC when there is content; long-press Delete clears all; swipe-on-display digit delete removed (swipe now opens history / pans long expressions). — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); [MacStories](https://www.macstories.net/stories/ios-and-ipados-18-the-macstories-review/6/)
- Pre-iOS 18: `0` was **double-width** (two columns); bottom-left was part of the wide zero. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); [EveryCalculators design notes](https://calculator.everycalculators.com/iphone-calculator-design/)

#### Basic mode — row-by-row labels (**reverse-engineered consensus**)
**iOS 18+ Basic (portrait):**

| Row | Col0 | Col1 | Col2 | Col3 |
|-----|------|------|------|------|
| 1 | AC or ⌫ (Delete) | +/− | % | ÷ |
| 2 | 7 | 8 | 9 | × |
| 3 | 4 | 5 | 6 | − |
| 4 | 1 | 2 | 3 | + |
| 5 | Mode (calculator icon) | 0 | . | = |

**Pre-iOS 18 Basic (portrait):** same rows 1–4; row 5 was `[ 0 (span 2) | . | = ]`. — layout pattern corroborated by clone writeups and iOS 18 change notes: [Liquid-Calculator README](https://github.com/0xatrilla/Liquid-Calculator); [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)

#### Scientific — Apple-documented keys & positions
- Memory: `m+`, `m-`, `mr`, `mc`. — [Apple Support: Scientific](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- Powers/logs: `x²`, `x³`, `xʸ`, `eˣ`, `10ˣ`, `x!`, `1/x`, `EE`; inverse functions (√, ∛, ʸ√x, ln, log) via the row below those keys / `2nd`. — [Apple Support: Scientific](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- Trig/hyperbolic: `sin`, `cos`, `tan`, `sinh`, `cosh`, `tanh`; inverses via `2nd`. — [Apple Support: Scientific](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- Constants: `π`, `ℯ`; random: `Rand`. — [Apple Support: Scientific](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- Angle mode: degrees default; `Rad` / `Deg` toggle.  
  - **Portrait:** Rad/Deg **just above ÷**; Rand **just above** the mode control (`.`).  
  - **Landscape:** Rad/Deg **near bottom center**; Rand **bottom left**. — [Apple Support: Scientific](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- Portrait scientific: function keys sit **above** the primary/basic pad. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); [MacRumors](https://www.macrumors.com/guide/ios-18-calculator-app/)
- iOS 18 Rand/Rad relocation vs iOS 17 (to keep mode icon bottom-left). — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)

#### Scientific landscape — full grid (**reverse-engineered; pre-iOS 18 classic, still largely applicable**)
Widely reproduced public layout is a **10-column × 5-row** keypad: 6 scientific columns + 4 basic columns. Community/online clones document the same key set. — [Calculator Library iPhone Scientific writeup](https://www.calculatorlibrary.com/blog/iphone-scientific-calculator); [The Verge](https://www.theverge.com/22197381/apple-ios-calculator-scientific-mode-landscape)

**Classic landscape (iOS ≤17) — estimate / reverse-engineered:**

| | c0 | c1 | c2 | c3 | c4 | c5 | c6 | c7 | c8 | c9 |
|--|----|----|----|----|----|----|----|----|----|-----|
| r0 | ( | ) | mc | m+ | m− | mr | C/AC | +/− | % | ÷ |
| r1 | 2nd | x² | x³ | xʸ | eˣ | 10ˣ | 7 | 8 | 9 | × |
| r2 | 1/x | √x | ∛x | ʸ√x | ln | log₁₀ | 4 | 5 | 6 | − |
| r3 | x! | sin | cos | tan | e | EE | 1 | 2 | 3 | + |
| r4 | Rad | sinh | cosh | tanh | π | Rand | 0 (×2) | | . | = |

**iOS 18+ landscape deltas (documented, not full grid):** `0` single-width; `Rand` still beside `0` / bottom-left area; `Rad`/`Deg` bottom-right of scientific block / near bottom center; mode icon reserved bottom-left of chrome. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); [Apple Support Rad/Rand positions](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)

#### Portrait scientific stacking (**structural, not full label map**)
- Documented structure only: scientific function strip **above** the 4-column primary pad; Rand bottom-left of scientific strip; Rad/Deg above ÷. Exact number of scientific rows/columns in portrait is not published by Apple. — [Apple Support](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios); [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)

### Inferences
- Replica builders should treat the classic 10×5 landscape map as the best public baseline, then apply iOS 18 deltas (`0` width, mode button, Rand/Rad positions).
- Portrait scientific likely reflows the same key *set* into denser smaller keys above the basic 4-col pad rather than inventing new keys.

### Gaps
- No Apple-published row-by-row portrait scientific keymap.
- Exact iOS 18 landscape remapping of every scientific cell (beyond Rand/Rad/0/mode) was not found as a complete labeled table in text sources (Gadget Hacks references comparison screenshots but does not enumerate all cells).
- 2nd-key alternate labels (e.g., sin⁻¹, log₂, 2ˣ, yˣ) are documented functionally but not as a full alternate grid by Apple. — partial lists in [Calculator Library](https://www.calculatorlibrary.com/blog/iphone-scientific-calculator) and [Apple Support](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)

---

## What are button sizes, corner radii, padding, gaps, and display typography scaling behavior as numbers grow?

### Takeaway
Apple publishes only general HIG touch-target floors (44×44 pt), not Calculator-specific metrics. Public reverse-engineering and clone projects converge on circular digit keys (~75–80 pt on modern iPhones), ~12–16 pt gutters, and a large right-aligned SF display that auto-shrinks; hex accents cluster around black / gray / `#FF9500`.

### Cited Findings

#### Publicly documented (Apple / HIG)
- Minimum recommended button hit region: **44×44 pt** (iOS). — [Apple HIG: Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)
- HIG does **not** specify Calculator button diameter, gap, or colors. — [Apple HIG: Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons) (general button guidance only)

#### Colors (**reverse-engineered / community; widely reused**)
- Common palette attributed to Calculator icon / UI clones: Light Gray `#D4D4D2`, near-black `#1C1C1C`, Heather Grey `#505050`, operator orange `#FF9500`. — [SchemeColor: Apple Calculator App Icon 2017](https://www.schemecolor.com/apple-calculator-app-icon-2017-colors.php)
- iOS 18 cosmetic shift: AC / +/− / % move to **white text on dark gray** (were light-gray fills); number-key fills slightly darker. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- App background is effectively always dark/black (not a light “Light Mode” Calculator). — [EveryCalculators](https://calculator.everycalculators.com/iphone-calculator-design/)

#### Button geometry (**estimates / reverse-engineered**)
- Grid math formula used by designers:  
  `D = (W − 2M − (C−1)G) / C` with C=4 for basic; typical M ≈ 12–20 pt, G ≈ 10–16 pt. Example: W=393, M=16, G=14 → **D ≈ 79.75 pt**. Default tool output with M=16, G=16 → **78.25 pt**. — [EveryCalculators iPhone Calculator Design](https://calculator.everycalculators.com/iphone-calculator-design/)
- Corner radius for digit keys: **perfect circles** → `radius = D/2`. Wide `0` (legacy): capsule width `2D + G`. — [EveryCalculators](https://calculator.everycalculators.com/iphone-calculator-design/)
- Open-source clone claims (not Apple): **80×80** circular buttons, **16 pt** spacing, wide zero **160×80**. — [Liquid-Calculator](https://github.com/0xatrilla/Liquid-Calculator)
- Medium/SwiftUI tutorial pattern (**estimate**): `buttonWidth = (containerWidth − 50) / 4`, spacing **10**, display font **80**, `minimumScaleFactor(0.5)`, button label font **32**. — [Medium SwiftUI clone tutorial](https://medium.com/@hendralijaya/tutorial-clone-calculator-ios-swiftui-part-1-cloning-the-ui-a35f72ce7378) *(URL returned 403 at fetch time; snippets from search index)*
- Pre-iPadOS-18 SwiftUI clone states UI was built by “inspecting its colours and button positions” (no numeric table in README). — [bofeiw/ios-calculator-clone-for-ipados](https://github.com/bofeiw/ios-calculator-clone-for-ipados/)
- FAQ-style estimate: button label SF Pro ~**30–40 pt**; display uses Thin/Light. — [EveryCalculators](https://calculator.everycalculators.com/iphone-calculator-design/)
- Stack Overflow recreations of pre-iOS 18 swipe-delete display often use ~**75 pt** system font. — [Stack Overflow: swipe backspace like iOS Calculator](https://stackoverflow.com/questions/68757093/how-to-create-backspace-functionality-in-swift-ui-with-a-swipe-gesture-same-as)

#### Display typography & growth behavior
- **iOS ≤17 digit limits (reported):** basic portrait ~**9** characters before scientific notation; landscape ~**16** before notation. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- **iOS 18+:** “no apparent” hard character cap for entry; when expression overflows, content continues off-screen and user can **swipe left/right** to pan. Full expression shown while typing; after `=`, expression appears above result. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- Auto-shrink of large display text is a common clone technique (`adjustsFontSizeToFitWidth` / `minimumScaleFactor`); Apple’s own Calculator pt sizes are **not published**. — [OmerSah/Calculator-App](https://github.com/OmerSah/Calculator-App); [Apple docs: minimumScaleFactor](https://developer.apple.com/documentation/swiftui/view/minimumscalefactor(_:)) (API docs, not Calculator-specific)

#### Interaction / press feedback (peripheral)
- WWDC “Designing Fluid Interfaces” sample includes a Calculator-style button with press animation (behavioral reference, not layout tokens). — [nathangitter/fluid-interfaces](https://github.com/nathangitter/fluid-interfaces/)

### Inferences
- For a pixel-faithful replica on a 390–430 pt-wide iPhone: start with **~16 pt** outer margin, **~14–16 pt** equal H/V gutter, circular keys, orange right-column operators, and dynamic `D` from width.
- Display: large **right-aligned** SF Pro Light/Thin; prefer shrink-to-fit for short results, and **horizontal scroll** for long iOS 18 expressions rather than only shrinking to illegible sizes.
- iOS 18 function-row colors should use **dark fills + white labels**, not the older light-gray function keys.

### Gaps
- No authoritative Apple pt values for: exact button diameter per device, vertical padding above keypad under Dynamic Island, display baseline font size, tracking, or expression/result secondary line size.
- Scientific portrait key diameter / gap not measured in any sourced teardown with published numbers.
- Operator highlight/selected state (orange invert when active) is visible in screenshots historically but not formally specified here.

---

## How does the display truncate/shrink/scroll?

### Takeaway
Behavior changed materially in iOS 18: from hard digit caps + scientific notation + swipe-to-delete, to expression tape + horizontal panning + dedicated Delete key.

### Cited Findings
- iOS 18 shows the **full expression** as the user types (not only the latest operand). After equals, expression remains visible **above** the result. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- Overflow: long strings continue off-screen; **swipe horizontally** to view. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- Delete: tap Delete/backspace for one character/token; long-press clears; swipe-on-number for delete removed because swipe opens history / pans. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); [MacStories](https://www.macstories.net/stories/ios-and-ipados-18-the-macstories-review/6/)
- Pre-iOS 18: swipe left/right on display deleted last digit; portrait capped ~9 digits / landscape ~16 with `e` notation beyond that. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); [Stack Overflow recreating swipe delete](https://stackoverflow.com/questions/68757093/how-to-create-backspace-functionality-in-swift-ui-with-a-swipe-gesture-same-as)
- Equals no longer repeats the last operation on subsequent taps (iOS 18). — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- Order of operations is standard algebraic (×/÷ before +/−); parentheses for grouping—Apple-documented for scientific/Math Notes. — [Apple Support: Scientific](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)

### Inferences
- Replica of **current** Calculator should implement: dual-line display (expression + result), horizontal scroll view for overflow, Delete key morphing from AC, history edge-swipe—not the old swipe-delete gesture.

### Gaps
- Exact animation curves, max scroll extent, whether font continues to shrink *and* scroll simultaneously, and scientific-notation thresholds in iOS 18 for extreme magnitudes (overflow of Double vs UI) are undocumented in sources reviewed.

---

## What differs on iPhone vs iPad / Dynamic Island / home indicator devices?

### Takeaway
Feature parity is high on iPadOS 18+, but iPad gains Pencil Math Notes, larger chrome, and windowed history entry points. Device chrome (Dynamic Island, home indicator) is not specially documented by Apple for Calculator; designers must inset for safe areas.

### Cited Findings
- **iPadOS 18** introduces Calculator with Math Notes, history, unit conversion, basic + scientific; Math Notes sync into Notes’ Math Notes folder; Pencil handwriting + graphing emphasized. — [Apple Newsroom](https://www.apple.com/ca/newsroom/2024/06/ipados-18-introduces-powerful-intelligence-features-and-apps-for-apple-pencil/); [MacRumors](https://www.macrumors.com/2024/06/10/apple-calculator-ipad-apple-pencil/)
- iPad history: different affordances in **full-screen** vs **smaller windows** (Support shows distinct controls). — [Apple Support: History on iPad](https://support.apple.com/guide/ipad/see-previous-calculations-ipad53f2084d/ipados)
- iPhone history: single history control path in Basic/Scientific. — [Apple Support: History on iPhone](https://support.apple.com/guide/iphone/see-previous-calculations-iph14c31d991/ios)
- Convert UI on iPad described as using more space / same unit categories. — [MacStories](https://www.macstories.net/stories/ios-and-ipados-18-the-macstories-review/6/); [Apple Support Convert on iPad](https://support.apple.com/guide/ipad/convert-units-or-currency-ipadc8aa1771/ipados)
- Design commentary: iPad should not merely stretch iPhone circles; often keeps scientific keys or sidebar to fill width. — [EveryCalculators](https://calculator.everycalculators.com/iphone-calculator-design/)
- Safe areas: home-indicator devices need bottom inset so `0` / `=` are not under the indicator; modern phones have curved corners affecting minimum margins (~12–16+ pt). — [EveryCalculators](https://calculator.everycalculators.com/iphone-calculator-design/) (design guidance, not Apple Calculator spec)
- No sourced Apple document describing Calculator layout changes specifically for **Dynamic Island** vs notch vs Home-button SE beyond general safe-area layout.

### Inferences
- Use Auto Layout / SwiftUI safeAreaInsets; pin keypad above home-indicator inset; leave flexible spacer between status/Dynamic Island region and display.
- iPad replica: larger hit targets optional; prefer showing scientific + history sidebar in regular size classes rather than scaling a phone grid to fill the stage.

### Gaps
- Measured pt differences between iPhone 16 Pro (Dynamic Island) vs SE (home button) Calculator layouts were not found.
- iPad split-view minimum widths / keypad reflow breakpoints undocumented.

---

## Are there secondary screens (history, converter, Math Notes) and how are they entered?

### Takeaway
Yes: History, Convert, and Math Notes are first-class secondary surfaces entered from chrome inside Calculator (and Math Notes also from Notes). Control Center is a launcher, not a second calculator UI.

### Cited Findings

#### History
- Entry: history/list control (top-left on iPhone per reviews); also swipe gestures reported (swipe right open / left close on iOS 18; bottom sheet Clear on 18.1). — [Apple Support](https://support.apple.com/guide/iphone/see-previous-calculations-iph14c31d991/ios); [MacStories](https://www.macstories.net/stories/ios-and-ipados-18-the-macstories-review/6/); [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- Contents: Basic/Scientific calculations and conversions; **not** Math Notes. — [MacRumors](https://www.macrumors.com/guide/ios-18-calculator-app/)
- Actions: tap to resume; touch-and-hold → Copy Expression / Copy Result; swipe delete; Edit clear. — [Apple Support](https://support.apple.com/guide/iphone/see-previous-calculations-iph14c31d991/ios)

#### Convert
- Entry: mode menu → enable **Convert** while in Basic or Scientific. — [Apple Support](https://support.apple.com/guide/iphone/convert-units-or-currency-iph69d274dde/ios); [MacStories](https://www.macstories.net/stories/ios-and-ipados-18-the-macstories-review/6/)
- UI: dual unit fields; category list (Angle, Area, Currency, Data, Energy, Force, Fuel, Length, Power, Pressure, Speed, Temperature, Time, Volume, Weight—per reviews); ~105 currencies / ~110 units reported. — [Apple Support](https://support.apple.com/guide/iphone/convert-units-or-currency-iph69d274dde/ios); [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- Also available via Math Notes natural language (“50 m in feet =”). — [Apple Support](https://support.apple.com/guide/iphone/convert-units-or-currency-iph69d274dde/ios)

#### Math Notes
- Entry from Calculator: mode control → **Math Notes** → new note. Return via mode control → Basic/Scientific. — [MacRumors how-to](https://www.macrumors.com/how-to/ios-use-math-notes-calculator-app/); [Apple Support Get started](https://support.apple.com/guide/iphone/get-started-with-calculator-iph6a38eb783/ios)
- Also in Notes app (Math Notes folder / any note with math). — [Apple Newsroom](https://www.apple.com/ca/newsroom/2024/06/ipados-18-introduces-powerful-intelligence-features-and-apps-for-apple-pencil/); [MacRumors](https://www.macrumors.com/guide/ios-18-calculator-app/)
- Capabilities: typed or handwritten equations, variables, live updates, graphs, unit conversion; iPad Pencil mimic-handwriting results. — [WWDC24 Keynote](https://developer.apple.com/videos/play/wwdc2024/101/?time=797); [Apple Support Math Notes (iPad)](https://support.apple.com/en-au/guide/ipad/ipadeb38d0f8/ipados)
- Numeral systems: Western Arabic + common symbols; typed Arabic (Eastern & Western) and Devanagari also supported (Apple). — [MacRumors](https://www.macrumors.com/guide/ios-18-calculator-app/)

#### Control Center / Lock Screen
- Control Center Calculator control launches app; usable from Lock Screen when allowed. — [Cult of Mac](https://www.cultofmac.com/how-to/calculator-app-inside-control-center); [Apple Support Lock Screen](https://support.apple.com/guide/iphone/access-features-from-the-lock-screen-iphcd5c65ccf/26/ios/26)
- Not a separate Calculator “widget screen” with its own keypad layout in Apple docs reviewed.

#### Settings
- iOS 18 adds Settings → Apps → Calculator (Siri/Search/Cellular/language-type prefs). — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)

### Inferences
- Secondary UIs to replica for fidelity: mode action sheet/menu, Convert dual-field chrome, History list, Math Notes canvas (or deep-link stub), Control Center icon behavior optional.

### Gaps
- Pixel measurements for Convert unit pickers, History row height, Math Notes toolbars, and mode menu styling are not in public Apple docs.
- Graph UI chrome dimensions / colors undocumented beyond feature description.

---

## Cross-version changelog (layout-relevant)

### Takeaway
iOS 7 established flat circular keys; scientific-via-landscape lasted until iOS 18, which is the largest Calculator redesign in years (modes, history, convert, Math Notes, expression display, button coloring, zero width).

### Cited Findings
| Era | Layout / UI notes | Source |
|-----|-------------------|--------|
| iOS 2 (2008) | Landscape scientific introduced | [The Verge](https://www.theverge.com/22197381/apple-ios-calculator-scientific-mode-landscape) |
| iOS 7+ | Flat circular buttons (vs skeuomorphic) | [EveryCalculators](https://calculator.everycalculators.com/iphone-calculator-design/) |
| ≤ iOS 17 | Rotate = mode switch; wide `0`; swipe-delete digits; light-gray function keys; 9/16 char caps | [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/) |
| **iOS / iPadOS 18** | Explicit Basic/Scientific/Math Notes; Convert; History; portrait scientific; single-width `0` + mode button; expression tape + horizontal pan; Delete key; darker function keys; iPad app debut; Mac Sequoia rounded to match | [Apple Newsroom](https://www.apple.com/ca/newsroom/2024/06/ipados-18-introduces-powerful-intelligence-features-and-apps-for-apple-pencil/); [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); [MacRumors](https://www.macrumors.com/guide/ios-18-calculator-app/) |
| iOS 18.1 (reported) | History presentation tweak (bottom sheet + Clear) | [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/) |

### Gaps
- Incremental visual tweaks between iOS 18.0 → 18.x → 26 were not exhaustively catalogued beyond the 18.1 history note in secondary press.

---

## Source quality legend (for report writer)

| Tier | Examples |
|------|----------|
| **Primary** | Apple Support Calculator guides; Apple Newsroom iPadOS 18; WWDC24 Keynote; Apple HIG Buttons |
| **High-quality secondary** | MacRumors guides; MacStories review; Gadget Hacks feature teardown with screenshots |
| **Reverse-engineered / clone** | SchemeColor palette; EveryCalculators grid math; GitHub/Medium clones; Calculator Library web clone |
| **Not found as public Apple assets** | Official Figma kit with Calculator tokens; exact SF point sizes; private SF Symbols asset names for mode/history icons |

**Recommendation for pixel-faithful build:** use Primary for interaction model and mode map; use reverse-engineered grid math + device screenshots (side-by-side) for final pt tuning; do not claim Apple-private asset fidelity.
