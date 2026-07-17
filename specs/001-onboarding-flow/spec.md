# Onboarding Flow Specification

**Feature Branch**: `001-onboarding-flow`
**Created**: 2026-05-27
**Status**: Draft
**Priority**: High
**Input**: User description: "Onboarding flow: splash to first map view"

---

## 1. Primary User Story

As a new user opening Halal Map Polskie for the first time, I want to be welcomed warmly, understand what the product does and why I can trust it, and reach the main map with minimal friction — in my language and without being forced to create an account — so that I can immediately start discovering halal-friendly places in Poland.

---

## 2. Details

**Problem:** Without an onboarding flow, first-time users would land directly on a map of unfamiliar pins with no context about what the product does, who built it, how its verification system establishes trust, or which languages are supported. The result: low first-impression trust, low contribution rates, and confusion about the three-tier verification model that is central to the product's value.

**Clarifications:**

### Round 1 (2026-05-27)
- Q: Which screens are in this feature's scope? → A: Splash + 3 Onboard intro screens + LocationPermission. Login and Register are deliberately out of scope; sign-in lives in a separate feature.
- Q: How do we know the user has completed onboarding? → A: A persisted "onboarding-completed" flag in secure storage; checked on subsequent launches.
- Q: Is sign-in required at any point in onboarding? → A: No. The app is fully usable as a guest; sign-in is prompted only at the moment of contribution.
- Q: What happens if the user denies location? → A: The app proceeds normally. The Map opens to a wide Poland view with the five target cities (Warsaw, Kraków, Wrocław, Gdańsk, Poznań) marked. The user can grant location later from Settings.
- Q: Does the user choose a language at onboarding? → A: Yes. A small top-right corner language picker (PL / EN / ع) is visible on every onboarding screen and defaults to the device's system locale.

### Round 2 (2026-05-27)
- Q: How many intro pages — match the design's single Welcome screen, or build a 3-page intro (Onboard 1/2/3)? → A: 3-page intro. Copy and visuals will be drafted to match the README's "Find / Trust / Community" descriptions, going beyond what the HTML mocks specify.
- Q: Splash strategy — native-only, or full animated in-app splash? → A: Full animated in-app splash matching the design (pin strokes, crescent fade, wordmark rise, loader) with ~2.2s auto-advance.
- Q: What distinguishes "Kontynuuj" from "Przeglądaj jako gość" on Onboard 3? → A: "Kontynuuj" routes to LocationPermission → Map. "Przeglądaj jako gość" routes directly to Map, skipping LocationPermission.
- Q: How does the LocationPermission screen behave on repeat visits? → A: It is shown only if the user has not previously decided. If location is already granted or already denied at the OS level, skip the pre-prompt and go straight to Map.

### Session 2026-05-27 (Clarify)
- Q: When location is unavailable, what should the Map's default state be? → A: A wide Poland view with the five target cities (Warsaw, Kraków, Wrocław, Gdańsk, Poznań) marked at country-level zoom. Replaces the earlier "Warsaw default" answer from Round 1.
- Q: Should the splash play its full 2.2s animation on every cold launch, or shorter for returning users? → A: Full ~2.2s for first-time users; truncated ~1s for returning users (onboarding-completed flag set). Native splash + 1s in-app splash + Map for returning; native splash + 2.2s in-app splash + Onboard 1 for first-time.
- Q: How does the splash interact with OS-level "Reduce Motion" accessibility setting? → A: When Reduce Motion / Disable Animations is enabled, the in-app splash animation is skipped entirely; native splash → next screen directly. Applies to both first-time and returning users.

**Requirement Conflicts:** Requirement conflict check completed — no conflicts found (no prior specifications exist; this is the first feature in `specs/`).

---

## 3. Workflow

**Business Workflow:**

*First-time user (onboarding not yet completed):*

1. App launches → Splash screen displays for ~2.2 seconds with animated brand reveal (pin strokes, crescent fade, wordmark rise, loader).
2. Splash auto-advances to **Onboard 1 · Find**.
3. User reads the headline ("Find halal places in all of Poland" — in chosen language) and views a stylised map preview. A top-right corner language picker (PL / EN / ع) lets the user switch language at any time; an top-left "Pomiń" (Skip) link lets the user jump to the last page.
4. User taps "Dalej" (Next) or swipes left → **Onboard 2 · Trust**, which explains the three-tier verification system (Verified Owner / Community / Pending) and reinforces that every halal claim is backed by a visible source.
5. User taps "Dalej" → **Onboard 3 · Community**, which invites participation ("Built by Muslims in Poland") and shows two CTAs: a primary "Kontynuuj" (Continue) and a secondary "Przeglądaj jako gość" (Browse as guest).
6. If the user taps **"Kontynuuj"**:
   - If location has not been previously decided → **LocationPermission** screen explains why location is needed and offers "Pozwól" (Allow) → triggers the OS prompt, or "Nie teraz" (Not now) → proceeds without location.
   - If location is already granted or already denied → skip LocationPermission and proceed directly to Map.
7. If the user taps **"Przeglądaj jako gość"** on Onboard 3 → skip LocationPermission entirely → go directly to Map.
8. The onboarding-completed flag is persisted at the moment the user first reaches the Map (via any path).

*Returning user (onboarding already completed):*

- App launches → Splash plays a **truncated ~1-second animation** → Map. No onboarding screens are shown.

*Skip path within onboarding:*

- On Onboard 1 and Onboard 2, a "Pomiń" link in the top-left advances directly to Onboard 3, allowing fast access to the final CTAs.

**Test Cases / Acceptance Scenarios:**

- **TC-1: First-time launch shows full onboarding** — Given a fresh install with no onboarding flag, when the user opens the app, then the flow Splash → Onboard 1 → Onboard 2 → Onboard 3 → LocationPermission → Map proceeds in order.
- **TC-2: Returning user skips onboarding** — Given the onboarding-completed flag is set, when the user opens the app, then the Splash plays its truncated ~1-second animation and then the Map appears directly (no intro pages shown).
- **TC-3: "Browse as guest" skips LocationPermission** — Given the user reaches Onboard 3, when they tap "Przeglądaj jako gość", then the Map appears immediately without the LocationPermission screen, and the onboarding-completed flag is set.
- **TC-4: "Continue" with location granted** — Given a first-time user on Onboard 3 with location never decided, when they tap "Kontynuuj" then "Pozwól" and accept the OS prompt, then they reach Map with location enabled and the onboarding-completed flag is set.
- **TC-5: "Continue" with location denied** — Given the same context but the OS prompt is denied (or the user taps "Nie teraz"), then Map opens to a wide Poland view with the five target cities marked (Warsaw, Kraków, Wrocław, Gdańsk, Poznań) and a non-blocking "Enable location for nearby places" affordance; onboarding-completed flag is still set.
- **TC-6: Skip link advances to last page** — Given the user is on Onboard 1, when they tap "Pomiń", then Onboard 3 is shown (Onboard 2 is skipped); the language selection is preserved.
- **TC-7: Language switch persists across screens** — Given the user is on Onboard 1 with system locale Polish, when they tap "EN" in the top-right picker, then all onboarding text switches to English immediately, and the choice survives navigation to Onboard 2 and 3.
- **TC-8: Arabic enables RTL** — Given the user taps "ع" (Arabic) in the language picker, then the entire screen mirrors to right-to-left layout, Arabic text renders in the Amiri font, and the language selection persists across screens.
- **TC-9: LocationPermission skipped when previously decided** — Given the user previously granted or denied location and then cleared the onboarding flag (e.g. via app data clear), when they tap "Kontynuuj" on Onboard 3, then they reach Map directly without seeing the LocationPermission screen.
- **TC-10: Splash auto-advance** — Given the user opens the app, when the Splash animation completes (~2.2s for first-time, ~1s for returning users), then the next screen (Onboard 1 for first-time, Map for returning) appears automatically without user input.
- **TC-11: Onboarding language persists into main app** — Given the user selects Arabic on Onboard 2 and completes onboarding, when they reach Map, then the Map screen renders in Arabic with RTL layout; the language choice is the new app default until changed in Settings.
- **TC-12: Backgrounding mid-onboarding does not reset progress** — Given the user is on Onboard 2 and backgrounds the app, when they resume, then the app returns to Onboard 2 with the same language selection (flag still not set; onboarding can still complete normally).
- **TC-13: Reduce Motion bypasses in-app splash** — Given the OS-level "Reduce Motion" / "Disable Animations" setting is enabled, when the user opens the app, then the in-app splash animation is skipped entirely and the next screen (Onboard 1 for first-time, Map for returning) appears immediately after the native splash. Behavior is the same for first-time and returning users when this setting is on.

**Edge Cases:**

- *User kills the app during onboarding* → On next cold launch, onboarding restarts from Splash → Onboard 1 (flag was not set; selected language is also not yet persisted across launches until onboarding completes).
- *User backgrounds the app mid-onboarding* → On resume, same screen and same language selection (in-memory state preserved by OS).
- *Device rotation* → Layout adapts; selection state preserved.
- *Back gesture/button* → On Onboard 2 or Onboard 3, back navigates to the previous onboarding page. On Onboard 1 or LocationPermission, back exits the app (standard platform behavior).
- *User taps "Pozwól" but denies the OS prompt* → The onboarding-completed flag is still set; the Map opens to the default city view as if denied at the pre-prompt.
- *Device locale is not pl/en/ar* (e.g. Ukrainian, Turkish, German) → Default to Polish; user can switch in the corner picker.
- *Offline at launch* → Onboarding completes normally; the flow does not require network. Only the Map (which lands after) shows a degraded state if network is unavailable.

---

## 4. Requirements

**Requirement Documents:**

- **Design handoff:** `specs/design/design_handoff_halal_map_polskie/` (HTML mocks, design system tokens)
- **Specifically:** `Auth & Onboarding.html` (Splash A/B, Welcome A/B variants), `Animated Onboarding.html` (animation timing reference)

**Functional Requirements:**

- **FR-001**: System MUST display a Splash screen on every cold launch of the app, auto-advancing without user input. For **first-time users** (onboarding-completed flag not set), the splash plays the **full brand animation lasting approximately 2.2 seconds**. For **returning users** (onboarding-completed flag set), the splash plays a **truncated animation lasting approximately 1 second**. {Source: AI/Specify, refined via Clarify session 2026-05-27 Q2}
- **FR-002**: System MUST detect on launch whether the user has completed onboarding previously and route accordingly: first launch → Onboard 1; subsequent launches → Map. {Source: AI/Specify}
- **FR-003**: System MUST display three onboarding intro pages in order — Onboard 1 · Find, Onboard 2 · Trust, Onboard 3 · Community — each conveying a distinct message (discovery, verification, community contribution). {Source: AI/Specify}
- **FR-004**: System MUST allow users to switch between Polish, English, and Arabic at any time during onboarding via a persistent language picker (PL / EN / ع) visible on every onboarding screen. {Source: Design — Welcome B variant}
- **FR-005**: System MUST default the onboarding language to the device's system locale, falling back to Polish if the device language is not one of pl, en, or ar. {Source: AI/Specify}
- **FR-006**: System MUST mirror layout to right-to-left and render Arabic text in the appropriate script font when the Arabic language is selected. {Source: Constitution §V.3}
- **FR-007**: System MUST provide a "Pomiń" (Skip) affordance on Onboard 1 and Onboard 2 that jumps directly to Onboard 3, preserving the user's selected language. {Source: AI/Specify}
- **FR-008**: System MUST present two final CTAs on Onboard 3: a primary "Kontynuuj" (Continue) and a secondary "Przeglądaj jako gość" (Browse as guest). {Source: Design — Welcome B}
- **FR-009**: System MUST route "Kontynuuj" to LocationPermission (if location not yet decided) and then Map, and MUST route "Przeglądaj jako gość" directly to Map (skipping LocationPermission). {Source: AI/Specify}
- **FR-010**: System MUST display the LocationPermission pre-prompt screen only if location has not been previously decided at the device level; if already granted or denied, the system MUST skip directly to Map. {Source: AI/Specify}
- **FR-011**: LocationPermission MUST explain why location is needed in clear copy (translated to all three locales) and offer two actions: "Pozwól" (Allow → triggers the OS prompt) and "Nie teraz" (Not now → proceeds without location). {Source: AI/Specify}
- **FR-012**: System MUST set the onboarding-completed flag at the moment the user first reaches the Map, regardless of the path taken (Kontynuuj + grant, Kontynuuj + deny, Przeglądaj jako gość). {Source: AI/Specify}
- **FR-013**: System MUST NOT require account creation, sign-in, or any personally-identifying input during onboarding. {Source: Constitution §1.6}
- **FR-014**: System MUST handle location denial silently — Map opens to a wide Poland view with the five target cities (Warsaw, Kraków, Wrocław, Gdańsk, Poznań) marked, and the app remains fully browsable. No blocking dialog or error is shown. {Source: AI/Specify, refined via Clarify session 2026-05-27 Q1}
- **FR-015**: System MUST display a page indicator (three dots) on Onboard 1, Onboard 2, and Onboard 3 showing the user's position in the sequence. {Source: AI/Specify}
- **FR-016**: System MUST allow backward navigation between onboarding pages via the standard platform back gesture/button: from Onboard 2 or 3, back returns to the previous page; from Onboard 1 or LocationPermission, back exits the app per platform convention. {Source: AI/Specify}
- **FR-017**: System MUST persist the selected language across onboarding pages and into the main app — the language chosen during onboarding becomes the active app language until the user changes it in Settings. {Source: AI/Specify}
- **FR-018**: System MUST NOT make any backend API call during onboarding (Splash, Onboard 1/2/3, LocationPermission). The flow MUST be fully functional offline. {Source: AI/Specify}
- **FR-019**: System MUST NOT fire any analytics or tracking events during onboarding. {Source: Constitution §1.7}
- **FR-020**: When the OS-level "Reduce Motion" / "Disable Animations" accessibility setting is enabled, the system MUST skip the in-app splash animation entirely and route directly to the next screen (Onboard 1 for first-time users, Map for returning users). The native splash continues to display normally during app boot. {Source: AI/Clarify session 2026-05-27 Q3, Constitution §XI WCAG 2.1 AA}

**Feature-Specific Non-Functional Requirements:**

- **NFR-001**: The fastest path through onboarding (Splash → Onboard 1 → Pomiń → Onboard 3 → Przeglądaj jako gość) MUST complete within 10 seconds from cold launch to Map first frame.
- **NFR-002**: Onboarding MUST be functionally and visually correct in all three MVP locales (Polish, English, Arabic) including RTL parity for Arabic — verified by widget tests with each locale set.
- **NFR-003**: Onboarding screens MUST meet WCAG 2.1 AA contrast and touch-target standards per constitution §XI.
- **NFR-004**: Splash and Onboard page transitions MUST maintain 60fps on the Pixel 7 emulator (API 34) reference device.

**Out of Scope:**

- **Login / Register screens** — Sign-in is intentionally excluded from onboarding per the guest-friendly principle. It ships as a separate feature, prompted at the moment of contribution.
- **Welcome screen as a separate page** — The design's Welcome A/B variant is being consolidated; its content (verification badge demo, multilingual rotation) is being absorbed into Onboard 1 and Onboard 2 rather than shown as a fourth screen.
- **Tutorial / coachmarks on the Map** — Post-MVP.
- **Onboarding analytics** — No tracking of where users drop off; analytics is off by default.
- **Returning-user "Welcome Back" splash variant** — The design has a `welcomeBack` screen for signed-in returning users. Not applicable until login lands.
- **Hero illustrations as commissioned art** — Placeholder SVG/icon-based visuals are used in v1; commissioned illustrations are post-MVP polish.

---

## 5. Deferred Decisions

- **Hero illustrations for Onboard 1 / 2 / 3** — Placeholders (SVG/icon-based, matching the design system palette) for v1; commissioned illustrations post-MVP. **Resolution phase:** Implementation (placeholders) → Post-MVP (real assets).
- **English and Arabic translations of all onboarding copy** — Polish copy is canonical and locked at spec time. EN and AR translations to be drafted by a human translator with religious literacy (Islamic terminology must not be machine-translated). Placeholders accepted for v1 if translator is not yet engaged. **Resolution phase:** Implementation.
- ~~**Full splash animation sequence vs simplified version**~~ — **RESOLVED in implementation 2026-05-27**: full four-stage animation built via `CustomPaint` (pin stroke-draws, cocoa-gradient fill fades in, sand+cocoa crescent scales in, wordmark fades up, "ŁADOWANIE" loader appears) timed to 2200ms for first-time / 1000ms truncated for returning users. See `lib/features/auth/presentation/screens/animated_splash_screen.dart`.
- **Onboard-page transition animation** — Per-page **entrance cascades** are implemented (each page fades up its hero, then headline, then subtitle, with 80ms stagger; Onboard 1 also drops pins in with elastic overshoot). Page-to-page **swipe transitions** still use default `PageView`; richer transitions (parallax, cross-page shared elements) remain post-MVP polish. **Status:** entrance animations done in v1; swipe transitions deferred.

---

## 6. Definition of Done

- All functional requirements (FR-001 through FR-019) implemented and verified
- All test cases (TC-1 through TC-12) pass on the Pixel 7 API 34 emulator
- Edge cases (backgrounding, app kill, device rotation, back gesture, unsupported locales, offline launch) handled and tested
- Localisation complete for PL/EN/AR — Polish is canonical; EN and AR may use placeholder translations in v1 with a deferred-decision note in the spec
- RTL parity verified for Arabic locale on every onboarding screen (no broken paddings, no incorrectly flipped icons)
- Accessibility audit passes WCAG 2.1 AA — semantic labels on every CTA and language pill, contrast verified on cocoa/cream surfaces, hit targets ≥ 44 sp
- Persistence layer for onboarding-completed flag and selected language survives app kill, OS-level cache clear, and reinstallation that preserves keychain (iOS) / encrypted shared preferences (Android)
- No backend API calls fire during onboarding (verified by network monitor in integration test)
- No analytics events fire during onboarding (per constitution §1.7)
- Integration test covers the cold-launch → Map happy path for both first-time and returning users

---

## 7. Solution Overview

The onboarding flow is the user's first impression of Halal Map Polskie. It is built to feel calm, premium, and trustworthy — closer to Airbnb's first-launch experience than to a typical directory app's tutorial. The flow is short (4 screens after the splash), language-friendly (PL/EN/AR selectable from the first screen), guest-friendly (no account required, "Browse as guest" is a first-class option), and privacy-respecting (no tracking, no network calls, location requested politely and with a graceful fallback if denied).

The core narrative across the three intro pages mirrors the product's value proposition: **Find** (you can discover halal places near you), **Trust** (each place is verified through a three-tier system rooted in community confirmations and owner claims), **Community** (the app is built by Muslims in Poland, and the user is invited to contribute). The flow ends with a clear binary choice — continue with a chance to enable location (the "warmer" path) or browse anonymously immediately — and from there the user is in the main Map experience.

This feature is foundational: every subsequent feature (Map, Place Detail, Submit, etc.) assumes the user has either passed through onboarding or has the onboarding-completed flag set, and assumes the user's language has been chosen.

---

## 9. UX Considerations

**User Interface Context:**

- **Primary user actions:** advance through onboarding (Next / Skip), switch language, choose Continue vs Browse as guest, grant or deny location.
- **User journey touchpoints:** first cold launch after install (most common); also after a data wipe or fresh install.
- **Accessibility needs:** WCAG 2.1 AA — semantic labels on every CTA and the language pills (a screen reader must distinguish "Switch language to English" from "Switch language to Polish"); contrast must be verified on cream-on-cocoa and umber-on-cream surfaces (the constitution explicitly flags these combinations as tight); 44 sp minimum hit targets on the corner language pills.
- **Usability considerations:** The tone is welcoming, not pushy; copy is Polish-canonical with the same warmth and trust framing used throughout the product. The skip path exists for users who want to dive in fast; the full path exists for users who want context first.

**Design References:**

- Design handoff: [`specs/design/design_handoff_halal_map_polskie/`](../design/design_handoff_halal_map_polskie/)
- Splash + Welcome mocks: `Auth & Onboarding.html` (Splash A/B and Welcome A/B variants)
- Animation reference: `Animated Onboarding.html` (timing for splash and inter-screen transitions)
- Design system: `constitution-frontend.md` §II (color/type/spacing tokens), §III (Button, Chip, BottomSheet, language pill widgets), §V (Polish UI vocabulary), §VI (interaction & animation specs)

---

## 11. Feature-Specific Constraints

**FC-1:** Onboarding must complete fully offline
- **Description:** No network calls during Splash, Onboard 1/2/3, or LocationPermission. The first network-dependent screen is the Map (and even the Map has a cached/default-tiles fallback).
- **Impact:** No analytics, no remote config, no user-account creation; all state is held on-device until the Map screen.

**FC-2:** Onboarding state is gated by the secure storage layer
- **Description:** The onboarding-completed flag and the selected language MUST persist using the same secure storage layer that holds future auth tokens. This ensures the flag survives app kill and aligns with the privacy-defaults posture.
- **Impact:** The app's bootstrap (in `main.dart`) must initialise the secure storage layer before deciding which screen to show.

### Feature-Specific Assumptions

**FA-1:** Polish-first translation discipline
- The Polish copy on each onboarding screen is the canonical source of truth. English and Arabic translations are derived from Polish, never reverse-engineered.
- **Validation plan:** Polish copy is locked at spec sign-off. Arabic translation is reviewed by a native speaker with religious literacy before release (Islamic terminology must not be machine-translated).

**FA-2:** Device locale signal is reliable enough for default-language selection
- We can read the device's system locale at app start and use it as the default. Falling back to Polish for locales not in {pl, en, ar}.
- **Validation plan:** Tested on the Pixel 7 emulator with system locale set to each of: pl, en, ar, tr, uk, de — confirming Polish fallback for tr / uk / de and confirming RTL kicks in for ar.

---

## 12. References

**Project Context:**

- **Constitution:** `.ai_project_memory/constitution.md` — universal principles incl. §1.5 (Localization & RTL First-Class), §1.6 (Trust & Community UX), §1.7 (Privacy Defaults)
- **Frontend Constitution:** `.ai_project_memory/constitution-frontend.md` — design system (§II), component library (§III), screen catalogue (§IV), localization rules (§V), interaction specs (§VI)
- **Architecture:** `.ai_project_memory/architecture.md` — verification workflow (the three-tier system explained on Onboard 2)
- **General Overview:** `.ai_project_memory/general-overview.md` — funding model, moderation model, and target user segments

**Design Reference:**

- Design handoff bundle: `specs/design/design_handoff_halal_map_polskie/`
- Auth & Onboarding mocks: `specs/design/design_handoff_halal_map_polskie/Auth & Onboarding.html`
- Animated Onboarding timing: `specs/design/design_handoff_halal_map_polskie/Animated Onboarding.html`

**Related Specifications:**

- *(none — this is the first feature spec)*

---

## Review & Acceptance Checklist

### Content Quality

- [x] No implementation details (languages, frameworks, APIs) in functional requirements
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Scope is clearly bounded (Out of Scope explicit)
- [x] Dependencies and assumptions identified

### Traceability & Context

- [x] Design handoff referenced
- [x] Constitution references included
- [x] All clarifications documented with timestamps
- [x] Deferred decisions documented

---

## Execution Status

- [x] User description parsed
- [x] Key concepts extracted (Splash, Onboard 1/2/3, LocationPermission, language picker, guest path, secure-storage persistence)
- [x] Ambiguities resolved through two rounds of Socratic dialogue
- [x] User scenarios defined (TC-1 through TC-12)
- [x] Requirements generated (FR-001 through FR-019, NFR-001 through NFR-004)
- [x] Entities identified (no new domain entities — onboarding-completed flag + selected language are user-preference state, not first-class entities)
- [x] Review checklist passed
