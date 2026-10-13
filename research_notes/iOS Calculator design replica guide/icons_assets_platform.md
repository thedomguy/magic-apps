# iOS Calculator — Icons, Assets & Platform Details

Research scope: app icon history/current look, in-app iconography / SF Symbols, button glyph type (text vs symbols), status bar / navigation chrome, Home Screen / App Library, Control Center / Lock Screen affordances, haptics, sound, localization/RTL, Dynamic Type / VoiceOver / Switch Control, and legal/IP constraints for a lookalike. Focus on iOS 18+ where sources allow. **Not legal advice.** Proprietary Apple asset files are not extracted or redistributed here.

---

## What does the current Calculator app icon look like and how has it evolved?

### Takeaway
The Calculator icon has been revised nearly every major OS era: from skeuomorphic leather/aluminum faceplates (iPhone OS 1.x–iOS 6) to flat four-button tiles (iOS 7–11), then a flat full-calculator glyph (iOS 11–17), an iOS 18 key-layout tweak, and further Liquid Glass–era revisions documented for iOS 26 betas/shipping builds.

### Cited Findings
- Pre-launch 2006 prototypes used a Mac OS X Dashboard-widget–style Calculator icon (unused on shipping iPhone OS 1.0); documented via court exhibits in *Samsung Electronics Co., Ltd. v. Apple Inc.*, Case No. 11-CV-01846 (N.D. Cal.). — [Logopedia: Calculator (iOS)](https://logos.fandom.com/wiki/Calculator_(iOS)); [AllThingsD archive cited there](https://web.archive.org/web/20120730153902/http://allthingsd.com/20120729/court-case-offers-rare-glimpse-at-dozen-of-iphone-and-ipad-prototype-designs/#slideshow-1-27)
- iPhone OS 1.0 shipped a matte aluminum face with brown keys; iPhone OS 1.1 switched to a dark gray leather background with black/orange keys and replaced the division sign with an equals sign on the icon face. — [Logopedia: Calculator (iOS)](https://logos.fandom.com/wiki/Calculator_(iOS))
- iPhone OS 2 made icon buttons more square; iOS 4–6 enlarged keys and removed the silver border. Contemporaneous coverage noted Calculator as unusually frequently redesigned among stock apps. — [Logopedia: Calculator (iOS)](https://logos.fandom.com/wiki/Calculator_(iOS)); [Engadget (2008)](https://www.engadget.com/2008-03-07-new-icons-for-itunes-and-calculator-on-the-iphone-2-0.html); [Macenstein (2010)](https://macenstein.com/2010/04/why-is-apple-obsessed-with-the-calculator-icon/)
- iOS 7 flattened the icon (inverted/simpler colors) through iOS 11; iOS 11 betas introduced a flat depiction of a **full calculator** rather than only four large keys. — [Logopedia: Calculator (iOS)](https://logos.fandom.com/wiki/Calculator_(iOS)); [Jim Nielsen — Short History of iOS App Icons](https://blog.jim-nielsen.com/2022/short-history-of-ios-app-icons/)
- iOS 18 replaced the large grey bottom key on the icon with **two smaller keys** (icon used 2024–2025 per Logopedia’s dating). — [Logopedia: Calculator (iOS)](https://logos.fandom.com/wiki/Calculator_(iOS))
- With the Liquid Glass redesign wave, Logopedia records an unused 2025 variant, an iOS 26 beta change, and a “2026-present” icon; Basic Apple Guy likewise frames iOS 26 system icons as shifting from solid materials to softer, glassier treatments. — [Logopedia: Calculator (iOS)](https://logos.fandom.com/wiki/Calculator_(iOS)); [Basic Apple Guy — iOS Icon History](https://basicappleguy.com/basicappleblog/ios-icon-history)
- Platform-wide, iOS app icons remain a square canvas with system-applied corner masking; iOS 7 introduced the continuous-curvature “squircle” mask still used on modern Home Screens. — [Jim Nielsen — Short History of iOS App Icons](https://blog.jim-nielsen.com/2022/short-history-of-ios-app-icons/)

### Inferences
- For an iOS 18-era replica, expect a flat, dark calculator face with orange operator accents and a bottom row that no longer uses a single wide grey key in the icon artwork.
- For an iOS 26+ / Liquid Glass–era replica, treat glass/specular treatment as part of the current system icon language, but verify on-device because community icon archives update mid-cycle and Logopedia marks some variants “tentative/unused.”
- Home Screen presentation always uses Apple’s system mask; replicas should supply a full-bleed square asset and let the system round it—do not ship a pre-rounded proprietary Apple PNG.

### Gaps
- No official Apple Design Resources page publishes a downloadable “Calculator.app icon” specification or layered source for third parties (by design).
- Pixel-accurate color values, exact key proportions, and current Liquid Glass material parameters for the shipping icon are not published by Apple; archive sites show images but are secondary.
- Whether the iOS 26+ icon differs between light/dark Home Screen appearances is not covered in the sources consulted.

---

## Are there official SF Symbol names for calculator-related glyphs? Are button glyphs text or symbols?

### Takeaway
Apple documents that SF Symbols includes mathematical operators (addition, subtraction, multiplication, division) and publicly named symbols such as `plus`, `minus`, `multiply`, `divide`, `equal`, `plusminus`, `percent`, and `function`—but Apple does **not** publish that the stock Calculator app’s keypad is implemented with those symbols versus Unicode/text labels.

### Cited Findings
- Apple’s UIKit documentation states the system provides symbol images for mathematical operators for addition, subtraction, multiplication, and division, and uses `multiply` (with variants such as `circle`, `circle.fill`, `square`, `square.fill`) as the example. — [Configuring and displaying symbol images in your UI](https://developer.apple.com/documentation/uikit/configuring-and-displaying-symbol-images-in-your-ui)
- Community-maintained SF Symbols catalogs list calculator-relevant names including: `plus`, `minus`, `plusminus`, `plus.slash.minus`, `minus.slash.plus`, `multiply`, `divide`, `equal`, `percent`, `function`, `sum`, `delete.left` / `delete.left.fill`, `clear` / `clear.fill`. — [andrewtavis/sf-symbols-online](https://github.com/andrewtavis/sf-symbols-online)
- SF Symbols is a library of 7,000+ symbols that align with San Francisco, support Dynamic Type–related traits, adapt to reading direction, and include localized designs for many scripts; Apple directs developers to the SF Symbols app to look up exact names. — [SF Symbols — Apple Developer](https://developer.apple.com/sf-symbols/)
- HIG button guidance: a button always includes a text label or a symbol (or both); prefer SF Symbols when an interface icon makes sense. — [HIG — Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)
- iOS 18 Calculator chrome (secondary sources): history is opened via a **three horizontal lines** control (top-left); mode switching (Basic / Scientific / Math Notes / Convert) uses a **calculator** control (bottom-left); a dedicated **backspace** key was added because the prior swipe-to-delete digit gesture now opens history. — [MacRumors — iOS 18 Calculator](https://www.macrumors.com/guide/ios-18-calculator-app/); [MacStories — iOS/iPadOS 18 Review](https://www.macstories.net/stories/ios-and-ipados-18-the-macstories-review/6/); [The Mac Observer](https://www.macobserver.com/iphone/features-calculator-ios-ipados-18/); [Apple Support — Math Notes](https://support.apple.com/guide/iphone/solve-math-with-math-notes-iph46efa613a/ios)
- Apple Support describes mode switching as: tap the (icon) control, then Basic / Scientific / Math Notes / Convert—without naming SF Symbol identifiers. — [Apple Support — Use the basic calculator (via search synthesis / guide)](https://support.apple.com/guide/iphone/use-the-basic-calculator-iph1ac0b5cc/ios); [Apple Support — Math Notes](https://support.apple.com/guide/iphone/solve-math-with-math-notes-iph46efa613a/ios)

### Inferences
- **Likely approximation mapping for a replica (not confirmed as Calculator’s internals):**
  - Operators: `plus`, `minus`, `multiply`, `divide`, `equal` **or** Unicode `+ − × ÷ =` as text
  - Sign toggle: `plusminus` or `plus.slash.minus`
  - Percent: `percent` or `%` text
  - Scientific “f(x)” style key: `function`
  - Backspace: `delete.left`
  - History sidebar: `list.bullet` or `line.3.horizontal` (name must be verified in current SF Symbols app; catalogs also list `list.dash` / `list.bullet`)
  - Mode menu affordance: often approximated with a calculator-like glyph; confirm name in SF Symbols app (do not assume a private asset name)
- Digits `0`–`9` and locale decimal separators are almost certainly **text**, not SF Symbols numeral badges (`0.circle` etc.), because Calculator buttons historically show plain numerals matching locale digit style.
- Using SF Symbols for operators is a legitimate, Apple-approved way to **approximate** the look without shipping extracted Calculator assets; matching Apple’s exact stroke weight/optical size may still require custom drawing.

### Gaps
- Apple has not published the stock Calculator’s asset catalog, SF Symbol names (if any), or confirmation that operators are `UIImage(systemName:)` vs attributed Unicode strings.
- Exact SF Symbol name for the iOS 18+ history “three lines” control and the mode-switcher “calculator” glyph is not stated in Apple Support articles (icons are inline images without alt-text names in the fetched pages).
- Whether scientific keys (sin, cos, ln, etc.) are localized strings or fixed Latin glyphs is not covered in official docs reviewed here.

---

## What system chrome is shown or hidden in the app? (status bar, navigation, Home Screen / App Library, Control Center / Lock Screen)

### Takeaway
Calculator is a full-screen, dark keypad experience with **no traditional navigation bar**; the status bar remains visible with light content over the black UI; iOS 18+ adds lightweight chrome (history list control, mode menu). System surfaces expose Calculator via Home Screen, App Library (Utilities-class apps), and an optional Control Center control that can open from the Lock Screen when allowed.

### Cited Findings
- Calculator’s classic UI is a black background with dark gray keypad, light gray / orange modifier keys, and white entry/results text; it does not follow Light/Dark Mode appearance switching the way many apps do. — [Gadget Hacks — Calculator color mods](https://ios.gadgethacks.com/how-to/update-your-iphone-calculators-look-with-these-easy-color-mods-0384541/)
- For dark backgrounds, Apple’s guidance is to use `UIStatusBarStyle.lightContent` so status-bar glyphs remain readable. — [TN3105 — Customizing the UIKit status bar style](https://developer.apple.com/documentation/technotes/tn3105-customizing-uistatusbar-syle) (also mirrored at [apple-docs.everest.mt TN3105](https://apple-docs.everest.mt/docs/technotes/tn3105-customizing-uistatusbar-syle/))
- iOS 18 adds: history (top-left list control), mode menu (Basic / Scientific / Math Notes + Convert), portrait scientific mode, and Math Notes (dark by default; optional light background). — [MacRumors](https://www.macrumors.com/guide/ios-18-calculator-app/); [Apple Support — Math Notes](https://support.apple.com/guide/iphone/solve-math-with-math-notes-iph46efa613a/ios); [MacStories](https://www.macstories.net/stories/ios-and-ipados-18-the-macstories-review/6/)
- App Library organizes apps into categories intelligently; users cannot manually move apps between categories. — [Apple Support — App Library](https://support.apple.com/guide/iphone/find-and-use-your-apps-in-app-library-iph87abad19a/ios)
- Apple’s Calculator product listing is categorized under **Utilities**. — [App Store — Calculator (Apple)](https://apps.apple.com/us/app/calculator/id1069511488)
- Control Center: users can add a Calculator control; tapping opens Calculator; Cult of Mac notes Lock Screen access without unlocking (when Control Center is allowed when locked) and a press-and-hold that copies the last result. — [Cult of Mac](https://www.cultofmac.com/how-to/calculator-app-inside-control-center); [TechBloat — iOS 18 Control Center](https://www.techbloat.com/how-to-add-calculator-to-control-center-on-iphone-ios-18.html)
- Lock Screen Control Center access is gated by Settings → Face ID / Touch ID & Passcode → Allow Access When Locked → Control Center. — [TechBloat — Disable CC on Lock Screen](https://www.techbloat.com/how-to-disable-control-center-on-the-iphone-lock-screen-in-ios-26.html)
- iOS 18 WidgetKit **Controls** can appear in Control Center, Lock Screen, and Action button; system apps (including Calculator’s control) participate in this model. — [WWDC24 — Extend your app’s controls across the system](https://developer.apple.com/videos/play/wwdc2024/10157/)
- Older Cult of Mac guidance said Calculator was not on iPad; that is outdated for iPadOS 18+, which ships Calculator with Math Notes / Pencil support. — [Cult of Mac (2021)](https://www.cultofmac.com/how-to/calculator-app-inside-control-center); [MacRumors — iOS 18 Calculator](https://www.macrumors.com/guide/ios-18-calculator-app/)

### Inferences
- Replica chrome checklist: visible status bar (light content), **no** UINavigationBar title, safe-area–aware bottom home indicator, edge-to-edge black canvas, overlay history panel (iOS 18+), bottom-leading mode control, optional Convert toggle in that menu.
- Home Screen: standard labeled icon (“Calculator”); App Library: expect Utilities cluster + alphabetical list.
- Control Center icon is a system-provided control glyph (not the full Home Screen app icon art); long-press copy-last-result is a system control behavior to be aware of when comparing “exact” platform parity.

### Gaps
- Apple does not publish whether Calculator uses `prefersStatusBarHidden`, custom safe-area insets, or a specific `UIStatusBarStyle` override in code.
- Exact Control Center Calculator symbol name / template rendering for iOS 18+ Controls is not documented as a public asset name.
- StandBy / Lock Screen widget behavior for **stock** Calculator (vs third-party calculator widgets) is not clearly documented in the sources reviewed; third-party apps advertise Lock Screen / Control Center widgets separately.

---

## What haptic engine feedback occurs on button press? Is there sound?

### Takeaway
There is **no Apple-published specification** that stock Calculator plays Taptic Engine feedback or button sounds on key press; historical jailbreak tweaks and third-party calculators market haptics as an *addition* to the stock experience, which strongly suggests the built-in app traditionally has neither per-key haptics nor click sounds.

### Cited Findings
- In 2018, the EinsteinVibes jailbreak tweak was described as bringing haptic feedback to the **stock** Calculator app—implying stock taps were silent/haptic-free at that time. — [iDownloadBlog — EinsteinVibes](https://www.idownloadblog.com/2018/08/16/einsteinvibes/)
- MacRumors’ iOS 18 Calculator feature guide documents Math Notes, history, portrait scientific mode, and conversions—**not** haptics or key sounds. — [MacRumors — iOS 18 Calculator](https://www.macrumors.com/guide/ios-18-calculator-app/)
- Third-party calculators (e.g., Calcora) advertise haptic feedback as a differentiator versus the default iPhone calculator. — [Calcora](https://calcora.app/); [App Store — Calcora](https://apps.apple.com/us/app/calculator-calcora/id6742111022)
- Apple’s general haptic APIs for custom controls include `UIImpactFeedbackGenerator`, `UINotificationFeedbackGenerator`, `UISelectionFeedbackGenerator`, and SwiftUI `.sensoryFeedback`; HIG/docs emphasize preparing generators and using haptics sparingly. — [Hacking with Swift — Adding haptic effects](https://www.hackingwithswift.com/books/ios-swiftui/adding-haptic-effects); [SerialCoder — Integrating Haptic Feedback](https://serialcoder.dev/text-tutorials/swiftui/integrating-haptic-feedback-in-swiftui-projects/)
- Apple’s Playing Haptics HIG page exists as the normative design reference for when/how to use haptics (page fetch returned limited extractable body text in this research pass). — [HIG — Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)

### Inferences
- For an **exact behavioral replica** of stock Calculator: default to **no** impact haptic and **no** key-click audio on digit/operator press.
- If building a portfolio “inspired by” calculator with better UX, optional light impact (`UIImpactFeedbackGenerator(style: .light)` or SwiftUI soft impact) is a common enhancement—but it is a **deviation** from stock, not fidelity.
- System sounds used in sample third-party code (e.g., `AudioServicesPlaySystemSound(1104)`) are not evidence of Calculator’s behavior.

### Gaps
- No primary Apple source states “Calculator does / does not use UIImpactFeedbackGenerator.”
- Behavior may differ on newer hardware or iOS 26+ Liquid Glass interactions; on-device verification is required for exact fidelity claims.
- Whether Math Notes handwriting/scrubber interactions use selection haptics is undocumented in sources reviewed.

---

## How is the app localized (decimal separators, numeral systems, RTL)?

### Takeaway
Number formatting on Apple platforms is locale-driven (decimal/grouping separators via `NumberFormatter` / `Locale`); Math Notes explicitly supports Western Arabic numerals plus typed Arabic (Eastern & Western) and Devanagari numerals; RTL layout and digit shaping follow system internationalization guidance, but Calculator’s private localization tables are not public.

### Cited Findings
- Locale settings affect decimal separators, thousands separators, etc. (e.g., `1,234.56` vs Italian `1.234,56`); apps should use `NumberFormatter`. — [Apple — Internationalizing Locale Data (archive)](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/InternationalizingLocaleData/InternationalizingLocaleData.html)
- `NSDecimalNumber` documents that locale determines whether the decimal separator is a period (US) or comma (France). — [decimalNumberWithString:locale:](https://developer.apple.com/documentation/foundation/nsdecimalnumber/decimalnumberwithstring:locale:?language=objc)
- Math Notes / Notes math: supports math written with Western Arabic numerals and common symbols, or typed using Arabic (Eastern & Western) and Devanagari numerals and common mathematical symbols; feature availability varies by region. — [Apple Support — Math Notes](https://support.apple.com/guide/iphone/solve-math-with-math-notes-iph46efa613a/ios); [Apple Support — Enter formulas in Notes](https://support.apple.com/guide/iphone/enter-formulas-and-equations-iphb9c2b948f/ios); [MacRumors](https://www.macrumors.com/guide/ios-18-calculator-app/)
- WWDC22 “Get it right (to left)” stresses using `String(localized:)` / proper formatting so digits render in the user’s preferred numeral system (e.g., Arabic-Indic vs Latin), including user preferences beyond locale alone. — [WWDC22 — Get it right (to left)](https://developer.apple.com/videos/play/wwdc2022/10107/) (transcript mirror: [apple-docs.everest.mt](https://apple-docs.everest.mt/docs/wwdc/wwdc2022-10107/))
- Math Notes evaluates horizontal expressions with standard operator precedence; variable names must use Latin alphabet characters; reading order for declarations is top-left to bottom-right. — [Apple Support — Math Notes](https://support.apple.com/guide/iphone/solve-math-with-math-notes-iph46efa613a/ios)
- SF Symbols automatically adapt to reading direction for a global audience. — [SF Symbols — Apple Developer](https://developer.apple.com/sf-symbols/)

### Inferences
- Replica keypad decimal key should show `Locale.current.decimalSeparator` (`.` or `,`), not a hardcoded period.
- Display and parsing of results should go through locale-aware formatters; do not assume ASCII digits exclusively if targeting Arabic/Hindi digit preferences.
- Operator keys (`÷ × − +`) are usually kept as mathematical symbols (not mirrored), while chrome that is directional (history chevrons, backspace) should use leading/trailing layout and RTL-aware symbols.
- “Exact” parity for Eastern Arabic / Devanagari digit keys on the **basic keypad** (not only Math Notes) needs on-device checks per region—docs emphasize Math Notes/typed math more clearly than the classic button grid.

### Gaps
- No public Apple document lists Calculator.strings keys or confirms whether the basic keypad relabels digits to Eastern Arabic-Indic forms in ar-SA.
- RTL mirroring behavior of the iOS 18 history sidebar and mode menu is not documented.
- Currency/unit conversion localization (symbols, ISO codes, rate sources) is only partially described (“match Convert mode”) without a public unit table in the Math Notes article.

---

## Dynamic Type, VoiceOver, Switch Control, and related accessibility notes

### Takeaway
Apple’s accessibility frameworks (VoiceOver labels/traits, Dynamic Type, Switch Control) apply to any calculator replica; a third-party accessibility write-up claims stock Calculator marks keys with the keyboard-key trait—useful as a behavioral target—but Apple does not publish Calculator’s accessibility audit results or Dynamic Type scaling behavior.

### Cited Findings
- VoiceOver relies on accessibility labels, traits, and hints; HIG instructs providing alternative labels for glyph-only controls. — [HIG — VoiceOver](https://developer.apple.com/design/human-interface-guidelines/voiceover)
- Keeping Score! documents matching Apple Calculator by giving calculator buttons the `.isKeyboardKey` trait so VoiceOver announces familiar key behavior; icon-only operators need explicit labels (e.g., “plus”, “multiply”). — [Keeping Score! — VoiceOver](https://www.keepingscore.app/docs/accessibility/voiceover/)
- Dynamic Type: prefer system text styles; content should not truncate/overlap at larger accessibility sizes; UIKit uses `adjustsFontForContentSizeCategory` / `UIFontMetrics`. — [Tech Talks — Accessibility Nutrition Labels](https://developer.apple.com/videos/play/tech-talks/111433/); [Dmytro’s Blog — Accessibility UIKit](https://dmytros.blog/posts/accessibility-ios-uikit/)
- Switch Control is listed among core iOS accessibility features apps should remain usable with (focus movement + select). — [Dmytro’s Blog — Accessibility UIKit](https://dmytros.blog/posts/accessibility-ios-uikit/)
- AppleVis notes on third-party PCalc show common calculator a11y pitfalls (results not auto-spoken, custom gestures). Useful as contrast cases, not as stock Calculator specs. — [AppleVis — PCalc](https://www.applevis.com/apps/ios/utilities/pcalc)

### Inferences
- Replica a11y checklist: each key is an accessibility element; digits labeled “0”–“9”; operators labeled by function (“divide”, “equals”); `accessibilityTraits` include `.keyboardKey` (UIKit) / `.isKeyboardKey` (SwiftUI); announce display/result changes with `UIAccessibility.post(notification:argument:)`; ensure Switch Control can reach every key in a sensible order.
- Dynamic Type: stock Calculator’s large fixed keypad historically **does not** reflow like Settings text—replicas aiming for visual fidelity may keep fixed key geometry while still exposing larger Dynamic Type on the **display** readout; treat this as an inference pending device testing.
- Reduce Motion / Bold Text / Increase Contrast interactions with the orange operator keys are undocumented for Calculator specifically; follow general HIG contrast guidance.

### Gaps
- No Apple Accessibility Nutrition Label or audit report for Calculator was found.
- Official confirmation of `.keyboardKey` usage in stock Calculator is absent (only third-party claim).
- Exact VoiceOver reading order, rotor custom actions, and braille output for Calculator are unpublished.

---

## What trademark/copyright constraints apply when building a lookalike (personal/portfolio use)?

### Takeaway
You may build an original calculator that is *inspired by* common calculator UX, and you may use **SF Symbols** and public HIG patterns; you must **not** copy Apple’s app icon, trade dress, packaging/web distinctive look, or ship extracted Apple assets—and App Store distribution of a near-identical UI/name risks Guideline 4.1 rejection and IP claims. Personal/portfolio use lowers App Store risk but does **not** erase copyright/trademark exposure. **This is not legal advice.**

### Cited Findings
- Apple’s Guidelines for Using Apple Trademarks and Copyrights prohibit using Apple-owned graphic symbols, logos, or **icons** on products/sites without express written license; also prohibit imitating distinctive Apple packaging, website design, logos, or typefaces (trade dress). — [Apple — Guidelines for Using Apple Trademarks and Copyrights](https://www.apple.com/legal/intellectual-property/guidelinesfor3rdparties.html)
- Product/company names may not use Apple trademarks or Apple-owned icons/alterations as part of the name. — [Same guidelines](https://www.apple.com/legal/intellectual-property/guidelinesfor3rdparties.html)
- Apple’s Trademark List is non-exhaustive; if a name is not listed, it should not get ™/® credit-line treatment as an Apple mark—but that does **not** grant rights to copy Apple artwork or trade dress. — [Apple Trademark List](https://www.apple.com/legal/intellectual-property/trademark/appletmlist.html)
- App Review Guideline **4.1 Copycats**: don’t copy a popular app with minor UI/name changes; impersonation can lead to Developer Program removal; don’t use another developer’s icon, brand, or product name in your icon/name without approval. — [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/); [Apple Developer Forums — Preventing Copycats](https://developer.apple.com/forums/thread/782175)
- Forum guidance from Apple explicitly: don’t copy look and feel / identical UI; don’t use icons similar to a popular app in metadata. — [Apple Developer Forums — Preventing Copycats](https://developer.apple.com/forums/thread/782175)
- Secondary legal commentary (Germany-focused): ideas/functions are often free to compete on, but creative UI expression, trademarks, and design rights can still protect against lookalikes; confusion with the original brand is a key risk. — [IT-Medienrecht — Copycat apps](https://itmedialaw.com/blog/protection-against-copycat-apps-what-is-legally-protected-and-what-can-be-copied)

### Inferences
| Generally safer to approximate | Avoid / do not copy |
| --- | --- |
| Four-function calculator layout as a *genre* pattern | Pixel-identical Apple Calculator.app icon |
| SF Symbols `plus` / `multiply` / etc. | Extracted PNGs/PDFs/USDz from IPSW or app bundles |
| Locale-aware decimals, orange accent *inspired* by hardware calculators | Claiming “Apple Calculator” name/branding or implying Apple endorsement |
| Original color tokens close-but-distinct | Shipping App Store listing with near-identical screenshots/UI and confusing metadata |
| Personal learning project with original assets + disclaimer | Distributing a clone that users could mistake for the system app |

- Portfolio framing (“recreation study,” original assets, different name/icon) reduces **practical** confusion risk but is not a legal safe harbor.
- San Francisco / SF Symbols usage in your own app is allowed under Apple’s developer/symbol terms when used as intended API assets—not when you redistribute the SF Symbols app binary or Apple’s proprietary Calculator artwork.

### Gaps
- No court opinion specific to “iOS Calculator UI clone for portfolio” was reviewed; trade-dress outcomes are fact-specific.
- Apple’s full Software License Agreement / SF Symbols license terms were not fetched in full in this pass—implementers should read current Xcode/SF Symbols license text before shipping.
- Jurisdiction-specific design-patent or unfair-competition rules beyond Apple’s published guidelines are out of scope here.

---

## Cross-cutting platform notes (iOS 18+)

### Takeaway
iOS 18 transformed Calculator from a minimal keypad into a multi-mode utility (Basic, Scientific in portrait, Convert, Math Notes, History) while keeping the classic dark keypad visual language; replicas that only clone the pre-iOS 18 four-row pad are incomplete relative to current iOS.

### Cited Findings
- Math Notes entry: Calculator → mode control → Math Notes; supports typed/handwritten expressions, variables, graphs, unit/currency conversion aligned with Convert mode; default dark canvas with optional light background. — [Apple Support — Math Notes](https://support.apple.com/guide/iphone/solve-math-with-math-notes-iph46efa613a/ios); [Apple Support — Graphs in Math Notes](https://support.apple.com/guide/iphone/work-with-graphs-in-math-notes-iph09ad8b507/ios)
- History stores Basic/Scientific calculations; Math Notes live in Notes. — [MacRumors](https://www.macrumors.com/guide/ios-18-calculator-app/)
- Backspace key replaces prior swipe-on-display digit delete (gesture repurposed for history). — [MacStories](https://www.macstories.net/stories/ios-and-ipados-18-the-macstories-review/6/)

### Inferences
- Asset/platform parity for “current Calculator” means modeling **three layers**: (1) classic pad iconography/colors, (2) iOS 18 chrome symbols/controls, (3) system integration (Control Center control, App Library Utilities, status bar light content).
- Do not redistribute Apple’s Math Notes pen/tool icons; approximate with SF Symbols (`pencil`, `trash`, etc.) after verifying names in the SF Symbols app.

### Gaps
- Exact SF Symbol / asset names for Math Notes toolbar controls are not listed in Apple Support text (icons are non-textual in the guide).
- iPad multitasking / sidebar history iconography differs from iPhone; only partially described in secondary reviews.
