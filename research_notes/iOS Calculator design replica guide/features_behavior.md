# iOS Calculator — Features & Calculation Behavior (iOS 18+)

Research target: behavioral parity for a replica of Apple’s current iOS Calculator (iOS 18+), with explicit version labels where behavior changed. Findings are citation-backed; quirks not in official docs are labeled reverse-engineered / community-observed.

---

## Exact list of buttons/functions in basic and scientific modes?

### Takeaway
Basic mode is four-function arithmetic plus percent, sign toggle, clear/delete, and (from iOS 18) mode/history chrome; Scientific adds memory, parentheses-capable expression entry, powers/roots/logs, trig/hyperbolic (+ 2nd inverses), Rad/Deg, π/ℯ, Rand, EE, and related inverses—available in portrait as well as landscape since iOS 18.

### Cited Findings
- Calculator modes on iPhone: Basic, Scientific, Convert (toggle), and Math Notes, chosen via the calculator/mode control. — [Get started with Calculator on iPhone](https://support.apple.com/guide/iphone/get-started-with-calculator-iph6a38eb783/ios)
- Scientific covers powers, roots, exponents, fractions, logarithms, trigonometry, and more; Basic is for ordinary arithmetic. — [Get started with Calculator on iPhone](https://support.apple.com/guide/iphone/get-started-with-calculator-iph6a38eb783/ios); [Use the scientific calculator on iPhone](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- Scientific uses **standard order of operations** (e.g. multiplication before addition/subtraction); parentheses group subexpressions. Full expressions with parentheses and multiple operations can be viewed before tapping `=`. — [Use the scientific calculator on iPhone](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- **Memory keys (Scientific):** `m+` (add display to memory), `m-` (subtract from memory), `mr` (recall), `mc` (clear memory). — [Use the scientific calculator on iPhone](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- **Exponential / log / related (Scientific):** `x²`, `x³`, `xʸ`, `eˣ`, `10ˣ`, `x!`, `1/x`; row below for inverses: square root, cube root, yth root, `ln`, `log`; `EE` for scientific-notation entry shortcut; **`2nd`** unlocks additional functions (e.g. `yˣ`, powers of 2). — [Use the scientific calculator on iPhone](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- **Trig / hyperbolic:** `sin`, `cos`, `tan`, `sinh`, `cosh`, `tanh`; **`2nd`** for inverses (e.g. arcsine, arctangent). — [Use the scientific calculator on iPhone](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- **Angle mode:** defaults to **degrees**; `Rad` switches to radians (label `Rad` appears; key becomes `Deg`). Portrait: Rad/Deg just above `÷`; landscape: near bottom center. — [Use the scientific calculator on iPhone](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- **Constants / random:** `π`, `ℯ` (Euler’s number), `Rand` (random in [0, 1]). Rand placement differs by orientation (portrait: just above `.`; landscape: bottom left). — [Use the scientific calculator on iPhone](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- **iOS 18 UI chrome (community):** mode button bottom-left (Basic / Scientific / Math Notes + Convert switch); history control (list icon / swipe); full expression shown while typing; result shown with expression above after `=`. — [Gadget Hacks — iOS 18 Calculator features](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); [MacRumors — iOS 18 Calculator](https://www.macrumors.com/guide/ios-18-calculator-app/)
- **Pre-iOS 18 Scientific access:** rotate to landscape (Orientation Lock off); portrait = basic only. — [How to Open the Hidden Scientific Calculator on iPhone](https://www.howtogeek.com/707141/how-to-open-the-hidden-scientific-calculator-on-iphone/); [MacRumors — portrait Scientific in iOS 18](https://www.macrumors.com/guide/ios-18-calculator-app/)
- **Clear / edit keys (current Apple Support, reflects C/AC + delete):** backspace deletes last digit; **C** clears the last entered number; **AC** (or touch-and-hold backspace or C) clears the expression. — [Use the basic calculator on iPhone](https://support.apple.com/guide/iphone/use-the-basic-calculator-iph1ac0b5cc/ios)
- **iOS 18 launch quirk (community):** Delete/backspace replaced the classic C/AC key; long-press Delete cleared everything; swipe-on-display digit delete removed. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- **iOS 26 (community):** dedicated backspace **and** C/AC restored side-by-side; `±` relocated in that redesign. — [9to5Mac — iOS 26 Calculator clear button](https://9to5mac.com/2025/08/12/ios-26-iphone-calculator-clear-button/)
- **Basic keypad (inferred from product + docs, not an official button inventory):** digits `0–9`, decimal `.`, operators `+ − × ÷`, `=`, `%`, sign change `±` (placement version-dependent), clear/delete family, mode button (iOS 18+). — [Use the basic calculator on iPhone](https://support.apple.com/guide/iphone/use-the-basic-calculator-iph1ac0b5cc/ios); [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- Convert categories (community inventory): angle, area, currency, data, energy, force, fuel, length, power, pressure, speed, temperature, time, volume, weight (~105 currencies / ~110 units claimed). — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); official examples include length, weight, power, pressure, speed, currency. — [Get started with Calculator](https://support.apple.com/guide/iphone/get-started-with-calculator-iph6a38eb783/ios); [Convert units or currency](https://support.apple.com/guide/iphone/convert-units-or-currency-iph69d274dde/ios)

### Inferences
- A parity replica should treat **Scientific as expression-oriented with PEMDAS**, not classic immediate-execution only; Basic remains closer to classic four-function UX but iOS 18+ also shows the running expression.
- Button layout and which clear/sign keys exist are **version-sensitive** (pre-18 landscape Scientific; iOS 18 Delete-centric; later docs/iOS 26 restore C/AC + backspace). Target “current Support docs” vs “iOS 18.0 launch” must be chosen explicitly for the replica.

### Gaps
- Apple does not publish a complete labeled keypad diagram (parentheses keys, exact `2nd` secondary legend, basic `%`/`±` placement per OS version).
- No official confirmation of every Convert category/unit list or currency count.
- Exact visual grouping separators (thousand separators) and locale rules for the display are not documented in Calculator Support pages.

---

## How does percent, chained operations, and repeating equals behave (Apple Calculator quirks)?

### Takeaway
Apple documents percent as a “last operand” modifier usable with repeating/`=` reuse (e.g. `100 + 15%` → 115; then `150 =` → 172.5), and documents repeating `=` for the last binary operation; iOS 18 changed when percent intermediates appear and (per launch reporting) briefly altered `=` repeat—treat percent and `=` as high-risk parity areas.

### Cited Findings
- **Repeat last operation (official, current Support):** After an operation, tap `=` again to re-apply the last operation to the current result. Example: `1 × 2 =` → 2; further `=` → 4, 8, 16, 32, … — [Use the basic calculator on iPhone](https://support.apple.com/guide/iphone/use-the-basic-calculator-iph1ac0b5cc/ios)
- **Apply last operation to a new number (official):** Enter a new number then `=`. Example: `100 + 15% =` → 115; then enter `150` and `=` → `150 + 15%` = **172.5**. — [Use the basic calculator on iPhone](https://support.apple.com/guide/iphone/use-the-basic-calculator-iph1ac0b5cc/ios)
- **iOS 18 launch report (community):** claimed `=` became “final” and no longer repeated the last op (contrasts current Apple Support). — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); contradicted by [Apple Support — Repeat the last operation](https://support.apple.com/guide/iphone/use-the-basic-calculator-iph1ac0b5cc/ios)
- **Classic percent algorithm (industry analysis, used to explain Apple/pocket calculators):** For `A + B%` / `A − B%`, percent replaces the second operand with `A × B / 100`, so result is `A ± (A×B/100)`. Chained example: `72 − 20% + 5%` → intermediate 14.4 then 2.88 → **60.48**. — [Raymond Chen — How does the calculator percent key work?](https://devblogs.microsoft.com/oldnewthing/20080110-00/?p=23853)
- **iOS 18 percent UX change (community / Apple Discussions):** Pre-iOS 18, pressing `%` after `A + B` often **immediately showed** the percentage amount (e.g. `831.26 + 25%` → showed ~207.82 before `=`); after iOS 18/Sequoia-era updates, `%` may **not** show that intermediate—only the final result after `=`. Users also report confusion on sequences like `100 − 75%`. — [Apple Community — Functionality Change After Update](https://discussions.apple.com/thread/255778039); [Apple Community — Percentages in Calculator update](https://discussions.apple.com/thread/255796027)
- **Historical iPhone vs Mac `%` / chaining difference (community):** Older macOS Calculator could re-bind `%` result into the ongoing multiply chain differently than iPhone (e.g. `2000 × 19% ÷ 12` diverging); later macOS versions reportedly aligned. — [Ask Different](https://apple.stackexchange.com/questions/214839/how-to-solve-the-issue-of-on-calculator-giving-different-results-on-iphone-v)
- **Scientific precedence:** multiplication before addition; use parentheses for intended grouping. — [Use the scientific calculator on iPhone](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- **iOS 18 expression UX (community):** full expression visible while typing; after `=`, expression remains above the result. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)

### Inferences
- For parity with **current documented** Apple behavior: implement (1) last-op repeat on `=`, (2) last-op reuse when a fresh operand + `=` is entered, (3) percent as operand transform relative to the left-hand value for `+`/`−` tip/discount style—not “divide by 100 only.”
- For parity with **iOS 18 user complaints**: suppress intermediate percentage display on `%` press unless/until device testing shows otherwise on the target OS build.
- `%` with `×`/`÷` and multi-operator chains remains under-specified by Apple; Chen’s model is the best public algorithmic description but is not Apple documentation.

### Gaps
- No official Apple algorithm for `%` with `×`, `÷`, or nested chains.
- Conflict between Gadget Hacks (iOS 18 killed repeating `=`) and current Apple Support (documents repeating `=`) needs **on-device verification** per iOS build.
- Exact display timing of operator highlighting / pending operator state is undocumented.

---

## What is the precision/rounding model (decimal vs floating; known quirks)?

### Takeaway
Apple does not publish Calculator’s numeric engine; historical accuracy testing and community reports show high-quality results for common cases but also binary-float-style quirks (e.g. `1/9×9` → `0.999…` reports on iOS 18), while display digit limits and scientific-notation thresholds changed sharply in iOS 18.

### Cited Findings
- **Display digit limits (pre-iOS 18, community):** portrait/basic ~**9** digits/characters; landscape ~**16** before scientific notation. Example: `1,738,658,088` → `1.738658e9`. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); older Engadget accuracy piece similarly reported 9 portrait / 16 landscape display digits on iOS 5–7. — [Engadget — calculator accuracy in iOS](https://www.engadget.com/2013-11-12-calculating-the-difference-a-look-at-calculator-accuracy-in-ios.html)
- **iOS 18 display (community):** “no apparent” fixed digit cap; long expressions/results scroll horizontally instead of forcing scientific notation as aggressively. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); user reports that large products (e.g. `250000 × 522`) display in ordinary form after iOS 18.1. — [Apple Community — scientific notation in basic](https://discussions.apple.com/thread/255821302)
- **Scientific notation policy (community):** EE inputs scientific notation; results use SN when they exceed display capacity; **no user setting** to force SN always. — [Apple Community — cannot force SN display](https://discussions.apple.com/thread/253647338); EE tip in official Scientific docs. — [Use the scientific calculator](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios)
- **Accuracy tests (historical, iOS 5–7 era):** Engadget suite (√2×√2, sin of tiny radians, `1/9×9`, divide-by-zero error) generally passed on stock Calculator across those OS versions. — [Engadget](https://www.engadget.com/2013-11-12-calculating-the-difference-a-look-at-calculator-accuracy-in-ios.html)
- **iOS 18 float quirk (community comment):** MacRumors commenter reported `1 ÷ 9 =` then `× 9` yielding `0.99999999` instead of `1`. — [MacRumors — iOS 18 Calculator comments](https://www.macrumors.com/guide/ios-18-calculator-app/)
- **Platform decimal guidance (Apple frameworks, not Calculator-specific):** `NSDecimalNumber` is base-10 with large mantissa for currency-safe math; binary float can produce artifacts—relevant as an implementation choice for a replica, not a statement of Calculator internals. — [Apple NSDecimalNumber docs (archive)](https://developer.apple.com/library/archive/documentation/LegacyTechnologies/WebObjects/WebObjects_3.5/Reference/Frameworks/ObjC/Foundation/Classes/NSDecimalNumber/Description.html)
- **macOS Calculator decimal places (Mac-only Control):** View → Decimal Places; stores full value, displays rounded. — [Calculator User Guide for Mac](https://support.apple.com/guide/calculator/welcome/10.16/mac/11.0)

### Inferences
- Replica should assume **IEEE-754–like intermediate quirks are acceptable** if matching stock iOS 18+ complaints, unless targeting “ideal decimal” UX instead of Apple parity.
- Display policy for a modern replica: prefer **scrollable full decimal strings** (iOS 18+) over hard 9/16 truncation; keep SN as fallback for extreme magnitudes.
- Do not expose Mac-style “decimal places” preference on iPhone unless inventing a feature.

### Gaps
- No official statement whether Calculator uses `double`, decimal arithmetic, rational intermediates, or a hybrid.
- No published rounding mode, guard digits, or exact SN threshold formula for iOS 18+.
- Limited formal accuracy testing published for iOS 18+ vs older Engadget suite.

---

## What new features landed in iOS 18 Calculator (history, conversions, Math Notes)?

### Takeaway
iOS 18 overhauled Calculator with Math Notes (shared with Notes), calculation history, unit/currency Convert mode, portrait Scientific, expression display, and first-party Calculator on iPad; Math Notes is **not** branded as Apple Intelligence, though AI features exist elsewhere in Notes.

### Cited Findings
- **Modes overview:** Basic/Scientific calculations, unit conversion, Math Notes (handwrite/type, variables, graphs). — [Get started with Calculator on iPhone](https://support.apple.com/guide/iphone/get-started-with-calculator-iph6a38eb783/ios)
- **History (official):** In Basic or Scientific, open history; tap entry to reload; touch-and-hold → Copy Expression / Copy Result; swipe left to delete; Edit → Clear All / Clear History or multi-delete. — [See previous calculations in Calculator on iPhone](https://support.apple.com/guide/iphone/see-previous-calculations-iph14c31d991/ios)
- **History scope (community):** Only Basic/Scientific (and conversions per Gadget Hacks); Math Notes live in Notes’ Math Notes folder. Swipe right can open history; `=` saves entries. — [MacRumors](https://www.macrumors.com/guide/ios-18-calculator-app/); [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- **Convert (official):** From Basic/Scientific, enable Convert; pick units/currencies; enter either field for live conversion; reverse with swap control; also in Math Notes (e.g. `50 m in feet =`). Categories include Speed, Time, Weight, etc. — [Convert units or currency in Calculator on iPhone](https://support.apple.com/guide/iphone/convert-units-or-currency-iph69d274dde/ios)
- **Math Notes — solve (official):** Type or write expression + `=`; stacked vertical addition with a line; order of operations for horizontal; top-to-bottom for vertical stacks; auto unit/currency conversion; red dotted = unsolvable/unrecognized (incl. divide by zero); blue dotted = ambiguous handwriting. — [Solve math with Math Notes](https://support.apple.com/guide/iphone/solve-math-with-math-notes-iph46efa613a/ios); [How to handle errors in Math Notes](https://support.apple.com/en-us/120852)
- **Math Notes — variables (official):** Declare `name = value` before use; Latin-alphabet names; cannot use variables in vertical math; reading order top-left → bottom-right. — [Solve math with Math Notes](https://support.apple.com/guide/iphone/solve-math-with-math-notes-iph46efa613a/ios)
- **Math Notes — results modes:** Insert Results / Suggest Results / Off. — [Solve math with Math Notes](https://support.apple.com/guide/iphone/solve-math-with-math-notes-iph46efa613a/ios)
- **Math Notes — value scrubbing:** Tap number, slide scrubber to adjust; dependent results/graphs update. — [Solve math with Math Notes](https://support.apple.com/guide/iphone/solve-math-with-math-notes-iph46efa613a/ios)
- **Graphs (official):** 2D: equation with exactly two undefined variables → Insert Graph (`y = f(x)` convention); 3D: `z` left, `x`/`y` right → Insert 3D Graph; overlay multiple equations; combine/hide graphs. — [Work with graphs in Math Notes](https://support.apple.com/guide/iphone/work-with-graphs-in-math-notes-iph09ad8b507/ios); [Get started with Calculator](https://support.apple.com/guide/iphone/get-started-with-calculator-iph6a38eb783/ios)
- **Numeric systems / availability:** Western Arabic + common symbols for written math; typed Arabic (Eastern & Western) and Devanagari also called out; see Feature Availability site. — [MacRumors](https://www.macrumors.com/guide/ios-18-calculator-app/); [Solve math with Math Notes](https://support.apple.com/guide/iphone/solve-math-with-math-notes-iph46efa613a/ios)
- **iPadOS 18:** Calculator arrives on iPad with Math Notes + Apple Pencil handwriting. — [Apple Newsroom — iPadOS 18](https://www.apple.com/newsroom/2024/06/ipados-18-introduces-powerful-intelligence-features-and-apps-for-apple-pencil/); [MacRumors](https://www.macrumors.com/guide/ios-18-calculator-app/)
- **Portrait Scientific:** selectable without rotating. — [MacRumors](https://www.macrumors.com/guide/ios-18-calculator-app/)
- **Apple Intelligence:** iOS 18 introduces Apple Intelligence systemwide (Writing Tools, etc.); iPadOS newsroom pairs Intelligence with the OS release that also ships Calculator/Math Notes, but Math Notes is described as Calculator/Notes math solving—not as an Intelligence generative feature. Notes can use Intelligence for other tasks (e.g. transcript summary) separately. — [Apple Newsroom — iOS 18](https://www.apple.com/newsroom/2024/06/ios-18-makes-iphone-more-personal-capable-and-intelligent-than-ever/); [Apple Newsroom — iPadOS 18](https://www.apple.com/newsroom/2024/06/ipados-18-introduces-powerful-intelligence-features-and-apps-for-apple-pencil/); [MacRumors — Notes iOS 18](https://www.macrumors.com/guide/ios-18-notes-app/)
- **Math “everywhere” (community):** equations in Spotlight Search / Messages can evaluate similarly. — [MacRumors — Math Notes how-to](https://www.macrumors.com/how-to/ios-use-math-notes-calculator-app/)
- **Copy result (official):** touch-and-hold calculation result → Copy; paste elsewhere. — [Use the basic calculator on iPhone](https://support.apple.com/guide/iphone/use-the-basic-calculator-iph1ac0b5cc/ios)
- **Settings entry (community):** Settings → Apps → Calculator (Siri/Search/Cellular/language prefs). — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)

### Inferences
- Parity for iOS 18+ means four product surfaces: Basic, Scientific, Convert overlay, Math Notes—not a single keypad.
- Math Notes should share persistence with Notes (Math Notes folder), while keypad history is Calculator-local.
- Do not market/implement Math Notes as “Apple Intelligence” unless separately adding Writing Tools on notes text.

### Gaps
- History retention duration / iCloud sync for Calculator history not officially specified (community: survives months on device).
- Currency rate source/update cadence undocumented in Support pages reviewed.
- Exact Math Notes symbol grammar and function parity matrix vs Scientific keypad not published beyond “same operations as scientific calculator.”

---

## What happens on overflow, invalid ops, long-press, swipe gestures?

### Takeaway
Invalid ops surface as error strings or Math Notes dotted underlines (divide-by-zero called out); gestures evolved from swipe-to-delete-digits (pre-18) to history/pan + dedicated delete (18+), with long-press for copy and all-clear; haptics/audio for Calculator keys are not officially specified.

### Cited Findings
- **Math Notes divide-by-zero:** red dotted underline; details can say divide-by-zero; user corrects the equation. — [How to handle errors in Math Notes](https://support.apple.com/en-us/120852)
- **Keypad divide-by-zero (community / recent):** nonzero ÷ 0 may show **“divide by zero”** (not classic “Error”/∞); 0÷0 reported variously as Error / Not a Number / Indeterminate across OS versions; copying “divide by zero” into Notes reportedly pastes as `0` (community bug report). — [LinkedIn / tester report](https://www.linkedin.com/posts/satyam-bhosure-0a0265252_softwaretesting-bugreport-ios-activity-7309808197555425280-8LJz); [Apple Community — banned from calculator (meme thread)](https://discussions.apple.com/thread/255707998); older Engadget: divide-by-zero produced an error (pass). — [Engadget](https://www.engadget.com/2013-11-12-calculating-the-difference-a-look-at-calculator-accuracy-in-ios.html)
- **Clear / long-press (official):** C clears last number; AC or **touch-and-hold** backspace or C clears whole expression; backspace deletes last digit. — [Use the basic calculator on iPhone](https://support.apple.com/guide/iphone/use-the-basic-calculator-iph1ac0b5cc/ios)
- **Copy long-press (official):** touch-and-hold result → Copy; history entries → Copy Expression / Copy Result. — [Use the basic calculator](https://support.apple.com/guide/iphone/use-the-basic-calculator-iph1ac0b5cc/ios); [See previous calculations](https://support.apple.com/guide/iphone/see-previous-calculations-iph14c31d991/ios)
- **Swipe — history (iOS 18, community):** swipe right opens history, swipe left closes; swipe left on a history row deletes. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/); [See previous calculations](https://support.apple.com/guide/iphone/see-previous-calculations-iph14c31d991/ios)
- **Swipe — digit delete (pre-iOS 18, community):** swipe left/right on the number display deletes one digit per swipe; replaced in iOS 18 by Delete key / expression editing. — [How-To Geek — swipe delete digits](https://www.howtogeek.com/262640/quickly-delete-digits-in-ios-calculator-with-a-swipe/); [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- **Shake to Undo (community):** remains disabled in Calculator. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- **Siri:** Support shows asking Siri e.g. “What’s 18 percent of 225?” as an alternate path. — [Use the basic calculator on iPhone](https://support.apple.com/guide/iphone/use-the-basic-calculator-iph1ac0b5cc/ios)
- **Accessibility:** VoiceOver system gestures apply generally; no Calculator-specific VoiceOver guide found in Support results. VoiceOver sounds/haptics are global VoiceOver settings, not Calculator docs. — [Use VoiceOver gestures on iPhone](https://support.apple.com/guide/iphone/use-voiceover-gestures-iph3e2e2281/ios); [AppleVis — VoiceOver Sounds & Haptics](https://atlas-entry.applevis.com/guides/deep-dive-voiceover-settings-ios-ipados)
- **Button click feel:** no official documentation found that Calculator plays key click sounds or Taptic feedback per key (gap for replica; many third-party calcs add optional haptics).

### Inferences
- Error UX for keypad should prefer a **short textual error** (current community: “divide by zero”) that blocks chaining until cleared—not Infinity.
- Gesture map must be version-gated: swipe-delete-digits (≤17) vs history/pan + backspace (≥18).
- Long-press is the primary clipboard affordance; paste-into-display is commonly reported in older tip articles but not emphasized in current Support snippets reviewed.

### Gaps
- Official overflow / magnitude-limit messages (beyond SN) not documented.
- Official paste-into-Calculator behavior, selection, and clipboard typing of error strings not in Support pages reviewed.
- No official Calculator haptic/audio specification.
- Factorial of non-integers, domain errors for `log`/`asin`, etc., not documented.

---

## Any differences vs macOS Calculator?

### Takeaway
macOS Calculator now shares much of the iOS 18+/Sequoia redesign (history, Convert, Math Notes bridge) but uniquely keeps **Programmer** and **RPN** modes and Mac-only display controls; iPhone lacks Programmer/RPN and historically lagged Mac on Convert until iOS 18.

### Cited Findings
- **macOS modes:** Basic, Scientific, **Programmer**, Convert, **RPN Mode**, Math Notes (opens Notes; can access Math Notes from iPhone/iPad). — [Choose the right mode in Calculator on Mac](https://support.apple.com/en-sa/guide/calculator/calc22d50970/mac)
- **iPhone modes:** Basic, Scientific, Convert, Math Notes—**no Programmer, no RPN** in Support materials reviewed. — [Get started with Calculator on iPhone](https://support.apple.com/guide/iphone/get-started-with-calculator-iph6a38eb783/ios)
- **Memory:** Scientific memory (`mc`/`m+`/`m-`/`mr`) documented on iPhone; Mac Scientific similarly described in third-party guides. — [Use the scientific calculator on iPhone](https://support.apple.com/guide/iphone/use-the-scientific-calculator-iphb977c4c0e/ios); [OWC — macOS Calculator power user](https://eshop.macsales.com/blog/64388-how-to-become-a-macos-calculator-app-power-user/)
- **History on Mac:** View → Show History (or Ctrl-Command-S); click to reuse; context menu copy. — [iDownloadBlog — history on iPhone/Mac](https://www.idownloadblog.com/2024/11/19/how-to-see-calculator-history-iphone-mac/)
- **Mac-only decimal places preference** and programmer integer truncation caveats. — [Calculator User Guide for Mac](https://support.apple.com/guide/calculator/welcome/10.16/mac/11.0)
- **Keyboard shortcuts:** Mac documents extensive keyboard shortcuts by mode; iPhone is primarily touch (external keyboard/VoiceOver possible via system a11y, not Calculator-specific shortcut tables). — [Calculator User Guide for Mac](https://support.apple.com/guide/calculator/welcome/10.16/mac/11.0)
- **UI convergence (community):** macOS Sequoia Calculator updated to match iOS 18 rounded UI / features; older Mac UI looked like classic square buttons. — [Gadget Hacks](https://ios.gadgethacks.com/how-to/all-must-try-new-features-make-apples-iphone-calculator-force-be-reckoned-with-0385567/)
- **Historic `%` divergence** between iPhone and Mac (see percent section); largely treated as fixed/improved on newer macOS in community answers. — [Ask Different](https://apple.stackexchange.com/questions/214839/how-to-solve-the-issue-of-on-calculator-giving-different-results-on-iphone-v)
- **iPad:** Calculator absent before iPadOS 18; now aligned with iPhone + Pencil for Math Notes. — [Apple Newsroom — iPadOS 18](https://www.apple.com/newsroom/2024/06/ipados-18-introduces-powerful-intelligence-features-and-apps-for-apple-pencil/)

### Inferences
- An **iPhone** replica should omit Programmer/RPN unless expanding scope to Mac.
- Shared parity surface with Mac Sequoia: expression calculator, history, Convert, Math Notes/Notes sync concepts.
- Mac decimal-places menu and ASCII/Unicode programmer views are out of scope for iOS parity.

### Gaps
- Side-by-side official comparison matrix (iOS vs macOS vs iPadOS) does not exist.
- Whether iCloud syncs Calculator **history** across devices (vs only Math Notes via Notes) is unclear from sources reviewed.
- Touch Bar / Mac window chrome behaviors are Mac-only and not fully inventoried here.

---

## Cross-cutting notes for replica implementers

### Version labels (quick)
| Era | Notable behavior |
| --- | --- |
| **≤ iOS 17** | Landscape-only Scientific; 9/16 digit display caps → SN; swipe display deletes digits; C/AC classic; `%` often shows intermediate amount; no History/Convert/Math Notes in-app |
| **iOS 18** | Mode menu; portrait Scientific; History; Convert; Math Notes; expression display; Delete-key era; digit swipe removed; SN less aggressive |
| **iOS 18+ Support (current docs)** | Documents C + AC + backspace; repeating `=` and `%` reuse examples |
| **iOS 26 (community)** | Backspace **and** C/AC both present again |

### Highest-risk parity items (device-verify)
1. Repeating `=` vs “equals is final” (Support vs iOS 18 launch reporting).
2. Percent intermediate display and `%` with `×`/`÷`.
3. Exact error strings for ÷0 and 0÷0.
4. Clear-key state machine (C vs AC vs Delete) per OS.
5. Float vs “nice decimal” results for recurring expansions.
