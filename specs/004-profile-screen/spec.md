# Profile Tab — Guest (v1) Specification

**Feature Branch**: `004-profile-screen`
**Created**: 2026-05-31
**Status**: Draft
**Priority**: High
**Input**: User description: "Now lets specify the profile part, for now the login functionality is coming soon, however we need to implement some components, read the design specs from specs/design/profile"

---

## 1. Primary User Story

As a guest user (not logged in) opening the **Profil** tab of Halal Map Polskie, I want a warm, brand-styled landing that honestly tells me accounts are coming soon while still giving me the things I can use today — switch the app language, jump to an "About" page that explains the mission, suggest a place through an external form, and reach the app's links — so that the Profile tab feels intentional and useful at launch even though sign-in, reviews, and saved-to-account features are not built yet.

---

## 2. Details

**Problem:** At launch there are no user accounts (sign-in is a later feature), so the **Profil** tab — the fifth tab in the existing nav shell — cannot show the account-centric Profile/Contributions screens catalogued in the frontend constitution (§4.8). A blank "coming soon" tab wastes the slot and feels broken. The design handoff (`specs/design/profile/`) resolves this with a **guest experience**: a single scrollable landing that pairs a "login coming soon" banner with the genuinely useful, login-independent settings (language, suggest-a-place, about, privacy/terms/licenses), plus two pushed sub-screens — a **Language** picker and an **About** page. This feature delivers that whole guest experience, fully wired, on top of the app's existing locale controller, theme, navigation shell, and shared widgets — without building any login/account functionality.

**Clarifications:**

### Round 1 — Specify (2026-05-31)

- Q: How much of the Profile tab should this feature deliver (login is deferred)? → A: **All three screens, fully wired** — Screen 1 (Coming-soon + settings), Screen 2 (Language), Screen 3 (About), with navigation, external-link actions, and the shared components (BackHeader, SettingRow, Group card, footer). Login stays a "coming soon" banner only; no account functionality is built.
- Q: The design's Language screen lists 5 languages (Polski, English, العربية, Українська, Türkçe), but the constitution and `AppLocale` restrict MVP to pl/en/ar and explicitly exclude TR/UK. How should the picker behave? → A: **Three selectable languages only (pl/en/ar).** Show Polski, English, العربية as radios; omit Українська and Türkçe.
- Q: The "Dark mode — Auto" row needs a theme-mode setting, but the app hard-codes `ThemeMode.system` (no controller exists). Build it, defer it, or…? → A: **Do not include the Dark-mode row at all** in this feature. The app keeps following the system theme; a theme-mode control is out of scope here.
- Q: Several rows open external destinations (Notify/Suggest form, Website, Privacy policy, Terms of use, Open-source licenses). What real targets exist today? → A: **Keep every row with placeholder configuration URLs** (form, website, privacy, terms) opened via the external-link launcher; real URLs are filled in a later feature. **Open-source licenses uses the platform's native license page** (no URL).
- Q: Keep the Screen 2 "Brakuje Twojego języka? Daj nam znać ↗ / Missing your language? Let us know ↗" helper link? → A: **Remove it.** The language selection list is enough; the Language screen has no "missing your language" helper / external link.

### Session 2026-05-31 (Clarify)

- Q: The constitution says the About screen carries a GitHub link (open-source), but the design omits one — add a GitHub/source row? → A: **No dedicated GitHub/source row.** The app is still under development and the repository is not exposed yet; the source is surfaced only implicitly through the native "Open-source licenses" page. A GitHub link returns when the repo goes public (Deferred Decisions).
- Q: The router has an orphaned `/profile/settings` route + `SettingsScreen` stub that the guest design has no place for — keep, remove, or repurpose? → A: **Remove** the orphaned `/profile/settings` route and the `SettingsScreen` stub; the new **Language** and **About** screens become the Profile sub-routes. The comprehensive Settings screen (constitution §4.9) is a separate future feature that reintroduces its own route.

**Requirement Conflicts (design `specs/design/profile/` vs constitution / current code):**

- **Custom floating "Dock"** (design: a 5-slot floating glass dock with a centre "Dodaj/Add" FAB, Profile tab active on all three screens): the app uses the existing **5-tab Material nav shell** (`ScaffoldWithTabs` / `StatefulShellRoute`). **Resolution:** the Profile screens render content **only inside that shell** and draw **no dock of their own** — identical to the 002 (FR-001) and 003 (FR-001) decisions. The Profile tab is the active tab by virtue of the shell, not a re-drawn dock.
- **Five-language picker** (design Screen 2 lists Polski / English / العربية / Українська / Türkçe): the constitution §5.1 and `AppLocale` (pl/en/ar) explicitly exclude Turkish and Ukrainian from MVP ("Do not add these to the language picker"). **Resolution:** the picker offers **only pl/en/ar** as selectable rows; TR/UK are omitted. Returns when those locales enter scope (Deferred Decisions).
- **"Missing your language" helper** (design Screen 2: a tappable "Daj nam znać ↗" external-form link below the list): **Resolution:** dropped per PO — the language list is the whole of Screen 2's interactivity; no external link on the Language screen.
- **Dark-mode setting row** (design Screen 1 PREFERENCES group: "Tryb ciemny — Auto"): no theme-mode controller exists and the PO scoped it out. **Resolution:** the Dark-mode row is **dropped**; the PREFERENCES group contains the Language row only. The app continues to follow the system theme. Returns with a theme-mode controller (Deferred Decisions).
- **Live external destinations** (design: Suggest form, Website, Privacy, Terms): real production URLs do not exist yet. **Resolution:** rows are present and open **placeholder configuration URLs** via the external-link launcher; the actual URLs are supplied later without changing the screens. Open-source licenses uses the **native license page** instead of a URL.
- **Account-centric Profile/Contributions screens** (frontend constitution §4.8: avatar, stats, contributions, leaderboard): depend on accounts, which do not exist at launch. **Resolution:** **not built**; the guest landing stands in for the Profile tab until sign-in ships. No avatar, stats row, activity feed, or contributions list.
- **Orphaned `/profile/settings` route + `SettingsScreen` stub** (current `app_router.dart` nests a `settings` route under Profile pointing at a "coming soon" stub; the guest design has no separate Settings landing): **Resolution:** **remove** the orphaned route and the `SettingsScreen` stub; the new **Language** and **About** screens are the Profile sub-routes. Per the constitution's no-dead-code rule, the stub is not left dangling. The comprehensive Settings screen (frontend constitution §4.9) is a separate future feature that reintroduces its own route.
- **GitHub / source-code link** (constitution says the open-source About "carries a GitHub link"; the design's About LINKS group omits one): **Resolution:** **no GitHub row** for now — the repository is not exposed during development; the source is surfaced only implicitly via the native "Open-source licenses" page. The link returns when the repo goes public (Deferred Decisions).
- **App version string** ("v 1.0.0" in the banner footer, About card, and footers): a presentation value. **Resolution:** sourced from the app's package metadata (or a single constant) and shown verbatim per the design; not hard-coded per-widget.
- **Requirement conflict check** completed against `specs/001-onboarding-flow`, `specs/002-home-screen`, and `specs/003-map-screen` — no blocking logical conflicts. This feature **reuses** 001's locale controller (`localeNotifierProvider` / `AppLocale`) and language-selection pattern, the shared external-link launching used elsewhere, the 5-tab shell, and the shared entrance/press animation widgets, rather than contradicting them.

---

## 3. Workflow

**Business Workflow** — *guest selects the Profil tab:*

1. The user selects the **Profil** tab. **Screen 1 (Coming-soon + settings)** renders as one scrollable column inside the existing 5-tab nav shell, over the warm vertical gradient background, with the Profile tab active. Major blocks fade/scale in, staggered, on open.
2. Top of the column is a **header** showing the title `Profil` / `Profile` (tab root — no back affordance).
3. Below it sits the **coming-soon banner** — a cocoa→umber gradient card with a glowing clock ring, a "● Wkrótce / ● Coming soon" badge, the headline "Konta są już *w drodze* / Accounts are *on the way*", an explanatory subline, and a primary **"Powiadom mnie, gdy będzie gotowe" / "Notify me when it's ready"** button that opens the external suggest/notify form.
4. Then the minimal settings, grouped in cards:
   - **PREFERENCES** (`Preferencje` / `Preferences`): a **Language** row showing the current language as its value (`Polski` / `English` / `العربية`) with a chevron.
   - **COMMUNITY** (`Społeczność` / `Community`): a **Suggest a place** (`Zaproponuj miejsce`) row — accent icon, sub "Open the form…", external-link arrow.
   - **INFO** (`Informacje` / `Info`): an **About** row (value `v 1.0.0`, chevron) and a **Privacy policy** (`Polityka prywatności`) row.
5. A centered two-line **footer** (app + version / mission line) closes the column.
6. Tapping the **Language** row pushes **Screen 2 (Language)**: a header with kicker `Ustawienia` / `Settings` and title `Język` / `Language`, a section label `Wybierz język aplikacji` / `Choose the app language`, and a single group listing the selectable languages (Polski, English, العربية — Arabic rendered in the Amiri serif), each with its English name as a trailing value and a trailing **radio**; exactly one is selected (the active app language). Selecting a different language updates the app locale **immediately and app-wide — no app restart** (the root reacts to the locale change and re-renders, including RTL for Arabic). The user **stays on the Language screen**, which itself re-renders in the chosen language; they tap back when ready, and Screen 1's Language value reflects the change. (No "missing your language" helper.)
7. Tapping the **About** row pushes **Screen 3 (About)**: a header with kicker `Informacje` / `Info` and title `O aplikacji` / `About`; an **app-mark card** (gradient pin glyph with ambient glow, app name, version line, mission paragraph); a **Suggest-a-place** CTA card (opens the external form); a **LINKS** group — **Website** (`Strona internetowa`, external), **Privacy policy**, **Terms of use** (`Regulamin`), **Open-source licenses** (native license page); and a centered two-line footer (mission / © 2026 Halal Map Polskie).
8. Each **external-link** row/button opens its destination in the device's browser / external app via the external-link launcher; **Open-source licenses** opens the platform's built-in license page in-app.
9. Back chevrons on Screens 2 and 3 pop to the previous screen.
10. If the OS reduced-motion setting is on, all entrance and ambient animation (stagger, clock/app-mark glow, badge float, shimmer, press-scale) is skipped — final/resting states are rendered instantly; selection still updates the radio state.

*External destination cannot be opened (no browser / launch fails):* the app shows a brief, non-blocking, localized message; it does not crash and does not leave a dead-end.

**Test Cases / Acceptance Scenarios:**

- **TC-1: Renders inside the 5-tab shell** — selecting Profil shows Screen 1 inside the existing 5-tab nav shell with the Profile tab active; the Profile screens draw no dock of their own. {FR-001, Conflict: Dock}
- **TC-2: Coming-soon banner content** — Screen 1 shows the gradient banner with the clock-ring, the "● Wkrótce / ● Coming soon" badge, the headline with its final word italic + sand, the subline, and the primary "Powiadom mnie…/Notify me…" button; the banner sits on the same page as the settings (not a separate route). {FR-002}
- **TC-3: No login/account UI** — Screen 1 presents no sign-in/sign-up form, no avatar, no stats row, no contributions/activity feed; the only account reference is the coming-soon banner. {FR-003}
- **TC-4: Settings groups & rows (Screen 1)** — the PREFERENCES group shows a single **Language** row (with the current language as value) and **no Dark-mode row**; the COMMUNITY group shows **Suggest a place** (external); the INFO group shows **About** (value `v 1.0.0`, chevron) and **Privacy policy**. {FR-004, FR-005, Conflict: Dark mode}
- **TC-5: Language row reflects active language** — the Language row's trailing value equals the currently active app language (`Polski` / `English` / `العربية`) and updates after a change made on Screen 2. {FR-006}
- **TC-6: Footer (Screen 1)** — a centered two-line footer shows the app + version line and the mission line, localized. {FR-007}
- **TC-7: Navigate to Language & back** — tapping the Language row pushes Screen 2 with kicker `Ustawienia`/`Settings` + title `Język`/`Language`; the back chevron pops to Screen 1. {FR-008}
- **TC-8: Language list = pl/en/ar only** — Screen 2 lists exactly Polski, English, and العربية as selectable rows; Українська and Türkçe are **not** shown; the Arabic native name renders in the Amiri serif; English names appear as trailing values. {FR-009, Conflict: 5-language picker}
- **TC-9: Single-select radio + live locale change** — exactly one language is selected (the active locale); selecting another moves the radio, changes the app locale immediately and app-wide with no app restart (via the shared locale controller; Screen 2 itself re-renders in the new language and Arabic flips to RTL), persists it; the user remains on Screen 2 and the change is reflected by the Screen 1 Language value on return. {FR-010}
- **TC-10: No helper link on Language** — Screen 2 shows no "Brakuje Twojego języka? / Missing your language?" helper and no external link; its only interactive elements are the back chevron and the language radios. {FR-011, Conflict: helper link}
- **TC-11: Navigate to About & back** — tapping the About row pushes Screen 3 with kicker `Informacje`/`Info` + title `O aplikacji`/`About`; the back chevron pops to Screen 1. {FR-012}
- **TC-12: About content** — Screen 3 shows the app-mark card (gradient pin glyph, app name `Halal Map Polskie`, version line, mission paragraph), the Suggest-a-place CTA card, the LINKS group (Website, Privacy policy, Terms of use, Open-source licenses), and the two-line footer. {FR-013}
- **TC-13: External-link rows open the launcher** — the banner button, the Suggest-a-place row/card, Website, Privacy policy, and Terms of use each open their configured (placeholder) URL via the external-link launcher (browser/external app). {FR-014, FR-016}
- **TC-14: Open-source licenses → native page** — tapping Open-source licenses opens the platform's built-in license page in-app, not an external URL. {FR-015}
- **TC-15: Launch failure is graceful** — when an external destination cannot be opened, a brief localized message is shown; no crash, no dead-end. {FR-014}
- **TC-16: Shared component reuse** — the BackHeader, SettingRow, and Group-card components are implemented once and reused across Screens 1–3 (and are styled from theme tokens, not magic literals). {FR-017}
- **TC-17: Entrance & ambient motion** — on each screen, blocks fade/scale in staggered (~100 ms steps); the clock ring (Screen 1) and app-mark (Screen 3) glow; the coming-soon badge floats; press-scale on rows/cards — matching `ANIMATIONS.md`. {FR-018}
- **TC-18: Reduced motion** — with OS disable-animations on, entrance stagger, glow, badge-float, shimmer, and press-scale are all disabled (final states rendered instantly); radio selection still updates. {FR-018}
- **TC-19: Localization + RTL** — all Profile copy renders from ARB in pl/en/ar; the Polish design copy is canonical and verbatim; Arabic mirrors to RTL correctly (chevrons flip; the Amiri font is used for Arabic); no hard-coded user-visible strings. {FR-019}
- **TC-20: Accessibility** — every row, button, radio, back chevron, and external-link control has a semantic label; external-link rows are announced as opening externally; tap targets ≥ 44 dp; screens are usable at OS-maximum font scale; RTL parity holds. {FR-020}
- **TC-21: Privacy guardrails** — opening or using any Profile screen fires no product analytics/tracking; nothing on these screens collects or transmits PII. {FR-021}

**Edge Cases:**

- *No browser or external app available when an external link is tapped* → a brief localized "couldn't open" message; no crash; the user stays on the screen.
- *Very long localized strings* (e.g., long headline/subline in English/Arabic) → text wraps/truncates without breaking the card or row layout.
- *Maximum OS font scale* → all text scales; the banner, group cards, language rows, and footers remain readable and reachable; controls stay ≥ 44 dp.
- *Arabic (RTL) locale* → the entire Profile UI mirrors; back chevrons and external-link arrows flip; the Arabic native language name uses the Amiri serif and reads right-to-left; numerals follow the locale convention.
- *Switching language on Screen 2 then immediately popping* → the new locale is already applied app-wide; Screen 1's Language value and all chrome reflect it on return.
- *Reduced-motion enabled mid-session* → newly opened screens render at final state with no ambient loops.
- *Backgrounding/resuming on any Profile screen* → the screen and any navigation depth are preserved; no reset.
- *Device locale not pl/en/ar* → the app defaults to Polish (per 001 FR-005); the picker shows Polski selected.
- *Placeholder URL still in place* → the row still opens the (placeholder) destination; no row is hidden because a URL is a placeholder.

---

## 4. Requirements

**Requirement Documents:**

- **Design handoff:** `specs/design/profile/claude_code_handoff_profile/` — `README.md` (screens, shared building blocks, behavior, string tables, tokens), `PROMPT.md` (build brief), `ANIMATIONS.md` (motion source of truth), `reference/Profile Screens Reference.html` + `reference/styles.css` (pixel + motion target), `reference/screens-overview.png` + `reference/01-coming-soon.png` (visual reference), `tokens/app_colors.dart` + `tokens/app_text.dart` (Dart tokens). The Dock, the five-language picker, the "missing language" helper, the Dark-mode row, and live URLs are adapted per §2.
- **Locale controller (reused):** `localeNotifierProvider` / `AppLocale` (`lib/features/auth/...`) — the single source of truth for the active app language.

**Functional Requirements:**

*Shell, structure & the coming-soon landing (Screen 1)*
- **FR-001**: The Profile screens MUST render as the "Profil" tab content (and pushed sub-routes) inside the existing 5-tab nav shell and MUST NOT render their own bottom navigation/dock; the Profile tab is the active tab via the shell. {Conflict: Dock; mirrors 002/003 FR-001}
- **FR-002**: Screen 1 MUST present, on a single scrollable page over the warm vertical gradient, a coming-soon banner (gradient card, glowing clock ring, "● Wkrótce / ● Coming soon" badge, headline "Konta są już *w drodze* / Accounts are *on the way*" with the final word italic + sand, an explanatory subline, and a primary "Powiadom mnie, gdy będzie gotowe / Notify me when it's ready" button that opens the external form) **together with** the minimal settings — not on separate routes. {Design Screen 1}
- **FR-003**: The Profile tab MUST NOT present any login, sign-up, account, avatar, stats, activity-feed, or contributions UI in this feature; the only account reference is the coming-soon banner. Sign-in and account-bearing Profile/Contributions screens are out of scope. {User description; Conflict: account screens}
- **FR-004**: Screen 1 MUST group the settings into cards: a **PREFERENCES** (`Preferencje`/`Preferences`) group containing a **Language** row (current language as trailing value, chevron → Screen 2); a **COMMUNITY** (`Społeczność`/`Community`) group containing a **Suggest a place** (`Zaproponuj miejsce`) row (accent icon, sub, external-link arrow → external form); and an **INFO** (`Informacje`/`Info`) group containing an **About** row (trailing value `v 1.0.0`, chevron → Screen 3) and a **Privacy policy** (`Polityka prywatności`) row. {Design Screen 1}
- **FR-005**: Screen 1 MUST NOT include a Dark-mode / theme-mode row; the PREFERENCES group contains the Language row only. The app continues to follow the system theme. {Clarify R1; Conflict: Dark mode}
- **FR-006**: The Screen 1 Language row's trailing value MUST display the currently active app language (`Polski`/`English`/`العربية`) and MUST update to reflect a language change made on Screen 2. {Design "behavior"; reuses locale controller}
- **FR-007**: Screen 1 MUST end with a centered two-line footer showing the app + version line and the mission line, localized. {Design Screen 1 footer}

*Language picker (Screen 2)*
- **FR-008**: Tapping the Language row MUST push Screen 2 (Language), whose header shows the kicker `Ustawienia`/`Settings` and title `Język`/`Language`, with a section label `Wybierz język aplikacji`/`Choose the app language`; the back chevron MUST pop to Screen 1. {Design Screen 2}
- **FR-009**: Screen 2 MUST list **only the three MVP languages** as selectable rows — **Polski**, **English**, and **العربية** — each showing its native name (the Arabic name rendered in the Amiri serif) and its English name as a trailing value. It MUST NOT list Українська or Türkçe. {Conflict: 5-language picker; Constitution §5.1}
- **FR-010**: Exactly one language row MUST be selected at a time (the active app locale), shown with the selected radio (green filled check) versus the unselected hollow ring. Selecting a different language MUST update the app locale **immediately and app-wide without an app restart** via the shared `localeNotifierProvider` (single source of truth) — the UI (including RTL direction for Arabic) re-renders reactively — and MUST persist the choice. The user MUST **remain on the Language screen** after selecting (the screen re-renders in the chosen language); Screen 1's Language value MUST reflect the change on return. {Design "behavior"; reuses 001 locale controller}
- **FR-011**: Screen 2 MUST NOT show a "missing your language" helper line or any external link; its only interactive elements are the back chevron and the language radios. {Clarify R1; Conflict: helper link}

*About (Screen 3)*
- **FR-012**: Tapping the About row MUST push Screen 3 (About), whose header shows the kicker `Informacje`/`Info` and title `O aplikacji`/`About`; the back chevron MUST pop to Screen 1. {Design Screen 3}
- **FR-013**: Screen 3 MUST present: (a) an **app-mark card** with a gradient map-pin glyph (ambient glow), the app name `Halal Map Polskie`, a version line, and the mission paragraph; (b) a **Suggest-a-place** CTA card that opens the external form; (c) a **LINKS** (`Linki`/`Links`) group with **Website** (`Strona internetowa`, external), **Privacy policy** (`Polityka prywatności`), **Terms of use** (`Regulamin`), and **Open-source licenses**; and (d) a centered two-line footer (mission line / `© 2026 Halal Map Polskie`). {Design Screen 3}

*External destinations*
- **FR-014**: Every external-link control (the banner "Notify" button, the Suggest-a-place row and card, Website, Privacy policy, and Terms of use) MUST open its configured destination in the device's browser / external app via the external-link launcher. If launching fails, the app MUST show a brief localized message and MUST NOT crash. {Design "External form"; Constitution error-handling §1.3}
- **FR-015**: **Open-source licenses** MUST open the platform's built-in license page in-app (not an external URL). {Clarify R1; native licenses}
- **FR-016**: The external destination URLs (suggest/notify form, website, privacy policy, terms of use) MUST be sourced from a single configuration point as **placeholder values** for this feature, replaceable later without changing the screens; no real production URLs are required to ship this feature. {Clarify R1; Design "External form" placeholder constants}

*Shared components, motion, localization, accessibility, privacy*
- **FR-017**: The shared building blocks — **BackHeader** (back-chevron tile + optional kicker + title), **SettingRow** (icon tile + label + optional sub + optional trailing value + trailing chevron or external-link arrow, with the accent variant), and **Group card** (translucent parchment card with hairline border, soft shadow, stacked rows with hairline dividers) — MUST be implemented once as reusable widgets and used consistently across Screens 1–3, styled from theme tokens (no magic colour/spacing literals). {Design "Shared building blocks"; Constitution §III/§X}
- **FR-018**: The Profile screens MUST implement the motion in `ANIMATIONS.md` — staggered fade-up/scale-in entrance (~100 ms steps), the clock-ring (Screen 1) and app-mark (Screen 3) ambient glow, the coming-soon badge float, the app-mark shimmer, and row/card press-scale — and MUST disable all of it under OS reduced-motion (final/resting states rendered instantly; radio selection still updates). {ANIMATIONS.md; Constitution §XI}
- **FR-019**: All user-visible Profile copy MUST come from the ARB localization layer with Polish canonical (the design's Polish strings verbatim and unchanged); the screens MUST render correctly in pl/en/ar including full RTL parity for Arabic (chevrons/arrows flip; Arabic uses the Amiri serif where specified); no hard-coded user-visible strings. {Constitution §1.5, §V}
- **FR-020**: The Profile screens MUST meet accessibility: semantic labels on every interactive control (rows, buttons, radios, back chevrons, external-link rows — announced as opening externally); interactive targets ≥ 44 dp; usable at OS-maximum font scale; RTL parity. {Constitution §XI}
- **FR-021**: The Profile screens MUST fire no product analytics/tracking and MUST NOT collect or transmit PII; the only network actions are the user-initiated external-link hand-offs. {Constitution §1.7}

**Feature-Specific Non-Functional Requirements:**

- **NFR-001**: Entrance, ambient (glow/float/shimmer), and press animations MUST sustain 60 fps on the Pixel 7 (API 34) reference device; ambient loops MUST be low-CPU (polish, not focus) per `ANIMATIONS.md`.
- **NFR-002**: The Profile screens MUST be functionally and visually correct in pl/en/ar including RTL — verified by widget tests per locale.
- **NFR-003**: The screens MUST meet WCAG 2.1 AA contrast/touch-target standards per Constitution §XI; the cream-background + umber/cocoa-text pairings MUST be contrast-verified.
- **NFR-004**: Screen 1 MUST render its first frame within ~1 s of tab selection; navigation to Language/About MUST use the platform default page transition with no perceptible jank.

**Out of Scope:**

- **Login / sign-up / account management** — the reason the tab is a guest experience; only the coming-soon banner references accounts. A later auth feature builds these.
- **Account-bearing Profile & Contributions screens** (avatar, stats, activity feed, leaderboard, my-submissions) — depend on accounts; deferred to the auth feature.
- **Dark-mode / theme-mode control** — no controller exists and it was scoped out; the app follows the system theme until a theme-mode feature ships.
- **Turkish & Ukrainian locales** — excluded from MVP by the constitution; the picker shows pl/en/ar only.
- **"Missing your language" helper on the Language screen** — dropped per PO; the selection list is sufficient.
- **Real production URLs** for the suggest form, website, privacy policy, and terms of use — placeholders ship now; real URLs land later via the single config point.
- **Notification opt-in capture** — the "Notify me" button opens the external form; building an in-app email-capture / push opt-in is a later feature.
- **The full Settings screen** (frontend constitution §4.9: Appearance / Language & region / Privacy / Notifications / Account groups) — only the minimal guest settings on the Profile landing are in scope; the comprehensive Settings screen is separate.

**Clarifications:**
- 2026-05-31 Q: Scope — how much of the Profile tab? → A: All three screens fully wired (Coming-soon+settings, Language, About); login is a banner only.
- 2026-05-31 Q: How many languages in the picker? → A: Three (pl/en/ar) only; TR/UK omitted per constitution.
- 2026-05-31 Q: Dark-mode row? → A: Do not include it; app follows the system theme.
- 2026-05-31 Q: External destinations? → A: Keep all rows with placeholder config URLs via the launcher; Open-source licenses uses the native license page.
- 2026-05-31 Q: Keep the Language-screen "Daj nam znać ↗ / Let us know ↗" helper? → A: Remove it; language selection is enough.
- 2026-05-31 (Clarify) Q: Add a GitHub/source link to About? → A: No — repo not exposed during development; source surfaced only via the native licenses page.
- 2026-05-31 (Clarify) Q: Fate of the orphaned `/profile/settings` route + `SettingsScreen` stub? → A: Remove both; Language + About become the Profile sub-routes.
- 2026-05-31 (Clarify) Q: After picking a language, stay or auto-pop? (And does it need an app restart?) → A: Stay on the Language screen (re-renders live in the new language); no app restart — locale change is reactive app-wide.

---

## 5. Deferred Decisions

- **Real external URLs** — the actual suggest/notify form, website, privacy-policy, and terms-of-use URLs replace the placeholders once they exist. **Rationale:** content/legal dependency, not a UI decision. **Resolution phase:** Implementation/content (config-only change).
- **Dark-mode / theme-mode controller** — add a persisted `ThemeMode` controller (Auto/Light/Dark) and reinstate the PREFERENCES Dark-mode row. **Rationale:** scoped out of this feature. **Resolution phase:** follow-up feature.
- **TR/UK (and further) locales + "missing language" helper** — when Turkish/Ukrainian enter scope, add them to `AppLocale`, the ARB set, and the picker; the "missing your language" helper can return alongside. **Rationale:** out of MVP per constitution §5.1. **Resolution phase:** Data/translation + follow-up.
- **Account-bearing Profile/Contributions** — replace the guest landing's banner with the real account experience when sign-in ships. **Rationale:** depends on auth/backend. **Resolution phase:** auth feature.
- **GitHub / source-code link in About** — add a public repository link to About's LINKS group once the codebase is public. **Rationale:** the project is open-source (general-overview Operating Model) but the repo is not exposed during development. **Resolution phase:** when the repo goes public (config-only row addition).
- **App version source** — whether the version string reads from package metadata or a build constant (and whether to show build number). **Rationale:** minor implementation detail. **Resolution phase:** Implementation.
- **EN/AR translations** — Polish canonical; English/Arabic human-translated (Islamic terms not machine-translated); placeholders accepted for v1. **Resolution phase:** Implementation.

---

## 6. Definition of Done

- All functional requirements (FR-001 … FR-021) implemented and verified.
- All test cases (TC-1 … TC-21) pass on the Pixel 7 API 34 emulator.
- Edge cases (launch failure, long strings, max font scale, Arabic RTL + Amiri, language-change-then-pop, reduced motion, background/resume, unsupported locale, placeholder URLs) handled and tested.
- All three screens ship fully wired inside the existing 5-tab shell with no own dock; Screen 1 pairs the coming-soon banner with the minimal settings on one page; Language and About push and pop correctly.
- No login/account UI is present beyond the coming-soon banner; no Dark-mode row; the language picker offers pl/en/ar only with no "missing language" helper; no GitHub/source link (repo not yet public).
- The orphaned `/profile/settings` route and the `SettingsScreen` stub are removed; Language and About are the only Profile sub-routes; `flutter analyze` reports no unused-import/dead-code from the removal.
- The Language picker reuses the shared `localeNotifierProvider` (single source of truth) — selecting a language changes the locale app-wide, persists it, and updates Screen 1's value; no duplicate locale state.
- Shared components (BackHeader, SettingRow, Group card) are implemented once and reused across all three screens; styled from theme tokens (no magic literals).
- External-link rows open via the external-link launcher with a graceful failure message; Open-source licenses opens the native license page; destination URLs come from a single placeholder config point.
- Motion per `ANIMATIONS.md` is implemented and fully disabled under OS reduced-motion (final states; selection still updates); ambient loops are low-CPU.
- Localization complete for PL/EN/AR — Polish canonical (design copy verbatim); EN/AR placeholders allowed in v1 with a deferred note; RTL parity (chevron/arrow flip, Amiri for Arabic) verified.
- Accessibility audit passes WCAG 2.1 AA — semantic labels on all controls, external rows announced as external, ≥ 44 dp targets, contrast verified on the warm palette.
- Privacy verified: no analytics/tracking fires; no PII collected on these screens (Constitution §1.7).
- Mandatory test types present: unit (locale-change/selected-language derivation, language-list = pl/en/ar invariant, URL-config resolution), widget (all three screens, group cards/rows, banner, radios, per-locale + RTL, reduced-motion, launch-failure path), integration (open Profil → change language → see it applied app-wide → open About → tap an external link → tap Open-source licenses → back navigation).
- `flutter analyze` clean; `dart format` applied; widgets reference theme tokens per Constitution §X.

---

## 7. Solution Overview

The Profile tab is the fifth tab of Halal Map Polskie, and at launch there are no accounts — so instead of an empty "coming soon" placeholder it ships as a deliberate **guest experience** drawn from the design handoff at `specs/design/profile/`. Screen 1 pairs an honest "accounts are on the way" banner with the settings a guest can actually use today: a language switch, a suggest-a-place form link, an About entry, and a privacy link — all on one scrollable page over the brand's warm cocoa/cream gradient. Two pushed sub-screens complete the experience: a **Language** picker that changes the app language live, and an **About** page that carries the mission, the app mark, a suggest-a-place call to action, and the app's links. Login, sign-up, and the account-centric Profile/Contributions screens are explicitly **not** built here — only the banner references accounts.

The feature is built almost entirely on what already exists. The Language picker reuses the app's single locale controller (`localeNotifierProvider` / `AppLocale`) so a change made here updates the whole app immediately and persists — and it honors the constitution by offering only the three MVP languages (Polish, English, Arabic), omitting the Turkish and Ukrainian rows the design mockup shows. The screens render inside the existing 5-tab navigation shell with no dock of their own (the design's floating "Dock" is the app's nav shell), reuse the shared entrance/press animation widgets, and are styled entirely from theme tokens. Three new reusable components — a BackHeader, a SettingRow, and a Group card — are implemented once and shared across all three screens. Every motion in `ANIMATIONS.md` is honored and every one is disabled under OS reduced-motion.

Because real production URLs and a theme-mode controller don't exist yet, two pragmatic decisions keep the feature shippable: external destinations (suggest form, website, privacy, terms) open **placeholder** URLs from a single config point through the external-link launcher (Open-source licenses uses the platform's native license page), and the design's Dark-mode row is dropped (the app follows the system theme). The Language screen is reduced to just its selection list — its "missing your language" helper is dropped. All Polish copy is verbatim and final; the screens are fully localized (pl/en/ar with RTL and the Amiri serif for Arabic), meet WCAG 2.1 AA, and fire no analytics or tracking. As accounts, a theme-mode control, real URLs, and more locales arrive, each slots into the same structure without re-architecting.

---

## 8. Key Entities

This feature is presentational and reuses existing state; it introduces no new persisted domain entities.

**App Locale** (reused — `AppLocale` / `localeNotifierProvider`): the active app language.
- **Purpose:** drives the whole app's localization; the Profile Language picker reads and writes it (single source of truth) and Screen 1 displays it.
- **Key attributes:** one of `pl` / `en` / `ar` (MVP set); persisted to secure storage; resolved at bootstrap with a Polish fallback.
- **Relationships:** read by every localized widget; written by the Language picker (FR-010) and previously by onboarding (001).

**External Destination Config** (new, configuration-only): the set of outbound URLs and the native-license action.
- **Purpose:** the targets for the suggest/notify form, website, privacy policy, and terms-of-use rows; plus the native license page action.
- **Key attributes:** placeholder URL strings held at a single config point (replaceable later); a flag/marker for the native-license action (no URL).
- **Relationships:** consumed by the external-link controls (FR-014–FR-016); not persisted, not user data.

---

## 9. UX Considerations

- **Primary user actions:** read the coming-soon banner and tap "Notify me" (external form); change the app language (live, app-wide); open About; suggest a place / open links (external); view open-source licenses (native page); navigate back.
- **User journey touchpoints:** the Profil tab is the app's settings/identity home; at launch it is the guest stand-in for the future account experience, reachable any time from the bottom nav.
- **Accessibility:** WCAG 2.1 AA — semantic labels on every row/button/radio/chevron; external rows announced as opening externally; ≥ 44 dp targets; usable at max font scale; full RTL parity with the Amiri serif for Arabic.
- **Usability:** calm, premium, brand-warm — the cocoa→umber banner, parchment group cards, Lora headings with the italic-500 accent word, and subtle ambient motion are the differentiators. With accounts absent, the screen must still feel complete and intentional, never like a disabled or stripped-down tab.

**Design References:**
- Handoff: [`specs/design/profile/claude_code_handoff_profile/`](../design/profile/claude_code_handoff_profile/) — `README.md`, `PROMPT.md`, `ANIMATIONS.md`, `reference/` (HTML + screenshots + styles.css), `tokens/` (`app_colors.dart`, `app_text.dart`). (Dock, 5-language picker, "missing language" helper, Dark-mode row, and live URLs adapted per §2.)
- Design system: `constitution-frontend.md` §II (tokens), §III (shared widgets), §IV.8/§IV.9 (Profile/Settings/Language/About catalogue), §V (Polish vocabulary), §VI (interaction/animation).

---

## 10. Integration Context

**External Systems:**

- **External form provider (e.g., Google Forms):** the destination for "Notify me" and "Suggest a place".
  - **Business purpose:** lets guests express interest and contribute place suggestions before any account/backend exists.
  - **Data exchange:** the app opens the form URL in the browser/external app; nothing flows back into the app. Placeholder URL for now (FR-016).
  - **Timing:** on tapping the relevant button/row.
- **Website / Privacy policy / Terms of use (web):** informational destinations.
  - **Data exchange:** the app opens each URL externally; read-only; placeholder URLs for now.
  - **Timing:** on tapping the relevant LINKS/INFO row.
- **Platform license registry (native):** the source for Open-source licenses.
  - **Data exchange:** the OS/Flutter built-in license page renders bundled package licenses in-app; no network call.
  - **Timing:** on tapping Open-source licenses.

**Integration Constraints:**
- All outbound navigation is a user-initiated, one-way external hand-off; no product analytics/tracking fires (Constitution §1.7).
- A failed launch shows a brief localized message and never crashes (Constitution §1.3).
- Destination URLs are placeholders held at a single config point, never hard-coded per widget; real URLs replace them later without screen changes.

---

## 11. Feature-Specific Constraints

**FC-1:** Profile screens render content only — navigation is owned by the app shell (no own dock; cross-tab actions go through the shell). {Mirrors 002/003 FC-1}

**FC-2:** The active language is owned by the shared locale controller — the Language picker reads/writes `localeNotifierProvider`; the Profile feature keeps no private locale state. {Constitution §1.5; reuses 001}

**FC-3:** Honest-to-reality surface — because accounts, a theme-mode control, and real URLs do not exist yet, the tab shows a coming-soon banner (not a fake login), omits the Dark-mode row, and uses placeholder URLs rather than faking destinations. {§2 conflicts; Constitution §1.6}

**FC-4:** MVP-locale invariant — the language picker MUST offer exactly pl/en/ar; adding TR/UK requires a constitution amendment (Constitution §5.1).

### Feature-Specific Assumptions

**FA-1:** Polish-first copy — Polish canonical and verbatim from the design; EN/AR derived; Islamic terms human-translated.
**FA-2:** An external-link launching mechanism is available (used elsewhere in the app) for opening URLs and degrades gracefully when no handler exists.
**FA-3:** The platform's built-in license page is acceptable for "Open-source licenses" at launch.
**FA-4:** Placeholder external URLs are acceptable for shipping this feature; replacing them is a config-only change.

---

## 12. References

**Project Context:**
- **Constitution:** `.ai_project_memory/constitution.md` — §1.3 (error handling/graceful failure), §1.5 (Localization & RTL), §1.6 (trust/guest browsing), §1.7 (privacy defaults — no analytics, no PII), §2 (security/config).
- **Frontend Constitution:** `.ai_project_memory/constitution-frontend.md` — §II (tokens), §III (shared widgets), §IV.8/§IV.9 (Profile/Settings/Language/About catalogue), §V (Polish vocabulary & MVP locale scope §5.1), §VI (interaction/animation), §X, §XI, §XII.
- **Architecture:** `.ai_project_memory/architecture.md` — User entity (future), localization toolchain, integration rows.

**Related Specifications:**
- `specs/001-onboarding-flow/spec.md` — establishes the `AppLocale` / `localeNotifierProvider` locale controller and language-selection pattern this feature reuses, and the Polish-fallback rule.
- `specs/002-home-screen/spec.md` — establishes the 5-tab shell, external-link/maps launching, and lean-v1 guardrails.
- `specs/003-map-screen/spec.md` — the conflict-resolution pattern (design vs constitution/data) mirrored here, and the no-own-dock decision.

**Design Reference:** Profile v1 handoff bundle: `specs/design/profile/claude_code_handoff_profile/` (`README.md`, `PROMPT.md`, `ANIMATIONS.md`, `reference/`, `tokens/`).

---

## Review & Acceptance Checklist

### Content Quality
- [x] No implementation details in functional requirements (mechanisms named only where a PO decision requires it)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

### Traceability & Context
- [x] Design handoff (`specs/design/profile/`) referenced
- [x] Constitution references included
- [x] All clarifications documented with timestamps
- [x] Deferred decisions documented
- [x] Conflicts (design vs constitution/current code) documented and resolved

---

## Execution Status
- [x] User description parsed
- [x] Key concepts extracted (guest Profile tab, coming-soon banner, minimal settings, Language picker, About, shared BackHeader/SettingRow/GroupCard, external links, motion, locale reuse, 5-tab shell)
- [x] Ambiguities resolved through clarification: specify round (scope, language count, dark-mode, external links) + disambiguation (which external rows, Language helper)
- [x] User scenarios defined (TC-1 through TC-21)
- [x] Requirements generated (FR-001 through FR-021, NFR-001 through NFR-004)
- [x] Entities identified (reused App Locale + External Destination Config; no new persisted entities)
- [x] Review checklist passed
