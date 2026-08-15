# Halal Map Polskie Frontend Development Constitution

**Purpose**: Self-contained frontend development guide for the Flutter mobile app — tech stack, design system, component library, screen vocabulary, interaction specs, and standards. The design handoff at `specs/design/design_handoff_halal_map_polskie/` was the input; **this file is the authoritative source** going forward. Do not refer back to the handoff for any decision encoded here.

---

## I. Technology Stack

### 1.1 Current Stack (greenfield — current = chosen)

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **Framework** | Flutter | TBD (pin once initialized — stable channel) | Cross-platform iOS + Android UI |
| **Language** | Dart with sound null safety | TBD (matches Flutter SDK constraint) | Application language |
| **State Management** | TBD — Riverpod, BLoC, or Provider | - | Application state (decision pending — resolve in an ADR before the first feature) |
| **Controls** | Material 3 + Cupertino, plus the custom design system in `lib/core/theme/` (see §II) | - | UI component library |
| **Styling** | Flutter `ThemeData`, design tokens (§II), RTL-aware spacing | - | Styling system |
| **Build** | Flutter CLI | matches framework | Build, run, package |
| **Map** | **MapLibre GL via `maplibre_gl`** (Flutter package) with custom style JSON, wrapped behind a `MapEngine` abstraction in `lib/core/map/` | - | Interactive halal map. Vanilla provider styles do not meet the design. **Introduced by 003-map-screen** |
| **Map tiles** | Self-hosted or community provider — MapTiler / Stadia Maps / Protomaps (**recommended MapTiler for launch; final choice deferred to ADR per 003-map-screen R17**); key via `--dart-define`, never committed | - | Vector tiles for the custom warm cocoa/cream basemap |
| **Location** | `geolocator` (only-while-using, **approximate accuracy** by default per `constitution.md` §1.7), wrapped behind a `LocationService` in `lib/core/location/`; prompt via existing `permission_handler` | - | Device location → user-location dot, locate-me, distance (haversine), "Najbliższe" sort. **Introduced by 003-map-screen** |
| **Geocoding** | External API (TBD — Nominatim / MapTiler / Mapbox Geocoding) | - | Address → coordinates for submission flow |
| **Prayer times** | **Mawaqit only** (product decision 2026-07-17, supersedes the earlier Adhan plan): mosques carry a `Mawaqit Link` sheet column; the app fetches the mosque page's embedded `confData` JSON (`lib/core/prayer_times/`) and caches the yearly calendar in prefs for offline use. No on-device calculation | - | Mosque prayer times (incl. Jumu'ah) on the place detail + the Home next-prayer pill (nearest Mawaqit mosque) |
| **Qibla / compass** | `flutter_compass` heading stream behind `CompassService` (`lib/core/qibla/`); great-circle bearing to the Kaaba computed in-app; static from-north fallback when no sensor | - | Qibla compass screen (Profile → Preferences). Introduced 2026-07-17 |
| **Localization** | Flutter `intl` + ARB | - | pl (primary), en, ar (with RTL) |
| **Local Storage** | TBD — Drift, Isar, or Hive | - | On-device cache of places, saved places, draft submissions |
| **Local Preferences** | `shared_preferences` | - | Non-sensitive on-device prefs and the guest **bookmark** id set (`bookmarked_place_ids`). Never used for PII/tokens (those use Secure Storage). Introduced by 002-home-screen |
| **External links** | `url_launcher` | - | Deep-link to the OS maps app / Google Maps for "view place" / "navigate" (stands in for in-app place detail at launch). Introduced by 002-home-screen. **Extended by 004-profile-screen**: opens the guest Profile's external destinations (suggest/notify form, website, privacy, terms) via a shared `ExternalLinkLauncher` (`lib/core/links/`); placeholder URLs held in `Env`, overridable via `--dart-define`. Open-source licenses uses Flutter's native `showLicensePage` (no URL) |
| **Data parsing** | `csv` | - | Parse the published Google-Sheet CSV (the launch place list) into the shared `Place` model. Introduced by 002-home-screen |
| **Place data source (v1)** | Published Google Sheet (CSV) via `dio` | - | Hand-maintained place list (name/category/coordinates) loaded by the shared `PlaceRepository` in `lib/core/places/`; consumed by Home and the Map. Pre-backend; replaced by the API later |
| **Secure Storage** | `flutter_secure_storage` | - | Auth tokens, owner-claim evidence |
| **HTTP** | `dio` or `http` | - | Backend API client |
| **Crash Reporting (opt-in)** | TBD — self-hosted Sentry or equivalent | - | Crash diagnostics only. **No product analytics** (see `constitution.md` §1.7) |
| **Icons** | Lucide / Phosphor / Material Symbols (1.8–2 px stroke, rounded caps) | - | UI iconography. Never hand-rolled inline SVGs |

### 1.2 Target Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| **Framework** | Flutter (stable) | Long-term commitment |
| **Language** | Dart with sound null safety, strict analysis | `analysis_options.yaml` extends `flutter_lints`, consider `very_good_analysis` |
| **State Management** | Resolved during first feature ADR | Pick one and apply consistently |
| **Map** | MapLibre + finalised tile provider | Decision affects cost and styling fidelity |
| **Testing** | `flutter_test` + `integration_test` package | No Playwright (Flutter is not a web app) |

<!-- manual additions start -->
<!-- manual additions end -->

---

## II. Design System

The design system is derived from the app icon's warm cocoa / umber / sand / parchment palette. Every visual decision in the product traces back to the tokens below.

### 2.1 Color Tokens — Brand Palette

| Token | Hex | Use |
|---|---|---|
| `cocoa-950` | `#1a100e` | Primary ink / dark background base / phone bezel |
| `cocoa-900` | `#261713` | Headings on light, dark surface base |
| `cocoa-800` | `#3b2622` | Primary text on light, secondary dark surface, primary CTA on light |
| `cocoa-700` | `#4d3530` | Body text on light, tertiary dark surface |
| `cocoa-600` | `#5d4039` | Subtle borders on dark |
| `umber-600` | `#7a5a3f` | Eyebrow / italic accent / muted dark on light |
| `umber-500` | `#8d6c4d` | Hover / secondary accent |
| `sand-400` | `#d9c5a3` | Primary CTA on dark, hairline borders |
| `sand-300` | `#e6d6b6` | Subtitle on dark surfaces |
| `sand-200` | `#ecdfc4` | Section background variant |
| `cream-100` | `#f4ede0` | Card tone-sand background, ghost button |
| `cream-50` | `#faf5e9` | Primary light background |
| `parchment` | `#fbf8ef` | Alternate light background |
| `ink` | `#1a100e` | Base text colour (alias of cocoa-950) |
| `muted` | `#6a5147` | Meta text, placeholder text |

### 2.2 Color Tokens — Functional Accents

| Token | Hex | Use |
|---|---|---|
| `verify` | `#5a7a55` | Community-verified, halal-verified, success states |
| `warn` | `#b67437` | Conflicting reports, caution |
| `pending` | `#b69247` | Verification pending |
| `closed` | `#9a4a3f` | Closed places, destructive report action |

### 2.3 Color Tokens — Map Category Tints

Tonal palette — all five share lightness so they read as a family.

| Token | Hex | Category |
|---|---|---|
| `cat-rest` | `#8a4a36` | Halal restaurants — terracotta |
| `cat-mosque` | `#3f6b5a` | Masjids — muted teal-green |
| `cat-groc` | `#b07a2a` | Grocery — saffron |
| `cat-shop` | `#5b4a8a` | Islamic shops — muted plum |
| `cat-cem` | `#5a6473` | Cemeteries — stone |

### 2.4 Map Style

The custom map style is part of the brand — do not fall back to a vanilla MapLibre / Mapbox street style.

| Surface | Light | Dark |
|---|---|---|
| Base | `#ece1cb` (warm cream) | `#1a100e` (cocoa-950) |
| Radial gradient centre | `#f1e8d4` → `#e6d8ba` → `#d8c69b` | `#2c1a16` → `#1f120f` → `#120907` |
| Roads | sand-coloured (`#c9a979`) | warm brown (`#5b3a2a`) |
| Parks / green | muted green (`#a8b89a`) | muted teal-green (`#3f6b5a`) |
| Water | matches parks | matches parks |
| User-location dot | `#2a6fdb` blue, 16–22 px, 4 px white border, translucent ring shadow | same |

### 2.5 Typography

Four families, used purposefully. Bundle them with the app; do not depend on system availability.

| Family | Weights | Use |
|---|---|---|
| **Plus Jakarta Sans** | 400, 500, 600, 700, 800 | UI, body, buttons, meta — default for everything outside headings and Arabic |
| **Lora** (italic + upright) | 400, 500, 600 | Display headings. **Italic 500 is the brand voice** — used for emphasis (`<em>` equivalent) and for hadith/dua callouts |
| **Amiri** | 400, 700 | **Arabic-language text only** (greeting "السلام عليكم", prayer-time labels, dua snippets). Fallback: SF Arabic or Noto Naskh Arabic |
| **JetBrains Mono** | 400, 500 | Small chrome labels (version numbers, locale codes, kicker rows). Fallback: SF Mono / Roboto Mono |

Letter-spacing rules:
- Headings (Lora): `-0.015em` to `-0.01em` (tight)
- Eyebrows / kickers / tiny labels: `+0.18em`, `UPPERCASE`, `font-weight: 600`
- Body: default

### 2.6 Type Scale (Mobile)

Standard mobile sp values used in the running app:

| Role | Token | sp |
|---|---|---|
| Screen H1 (display, Lora 500) | `m-h1` | 32 |
| Section H2 (Plus Jakarta Sans 700) | `m-h2` | 22 |
| Body | `m-body` | 17 |
| Meta | `m-meta` | 15 |
| Tiny / kicker (uppercase, +0.18em) | `m-tiny` | 13 |

Note: the design deck shows larger pixel values (30/26/24/22/20) because phones are rendered inside scaled containers on 1920×1080 slides. On a real device, the values above are correct. What carries across is the **hierarchy** and **font-family assignment**, not the literal numbers.

### 2.7 Spacing & Layout

4 px base unit.

| Surface | Value |
|---|---|
| Screen horizontal padding | 20 sp |
| Card internal padding | 16–20 sp |
| Vertical gap between sections | 18–22 sp |
| Tab bar height (incl. home-indicator safe area) | 88–110 sp |
| Phone bezel (presentational only — not in app) | 12 px border, 54 px outer radius, 44 px inner |
| Notch / status / home indicator | Use Flutter's `SafeArea` and OS chrome — do not render a bezel |

### 2.8 Border Radius

| Surface | Radius |
|---|---|
| Cards (standard) | 22 sp |
| Cards (compact) | 18 sp |
| Search bars, inputs | 16–18 sp |
| Buttons | 16 sp |
| Chips / pills (fully round) | 999 sp |
| Square pill-style category tiles | 14 sp |
| Bottom sheet top corners | 22–26 sp |
| Small icon containers (40×40) | 10–12 sp |

### 2.9 Shadow Tokens

Shadows are **cocoa-tinted**, not neutral black.

| Token | CSS reference (design source) | Flutter Material elevation equivalent |
|---|---|---|
| `sh-card` | `0 1px 0 rgba(38,23,19,.04), 0 12px 30px -16px rgba(38,23,19,.18)` | elevation 2 |
| `sh-pop` | `0 6px 22px -8px rgba(38,23,19,.28), 0 30px 60px -30px rgba(38,23,19,.35)` | elevation 8 |
| `sh-phone` | `0 30px 80px -30px rgba(26,16,14,.45), 0 10px 30px -10px rgba(26,16,14,.25)` | (presentational only) |

When using Flutter Material elevation: override the default neutral shadow with a cocoa-tinted shadow colour (`shadowColor: cocoa-950 @ ~0.45`) so the warm tone reads through.

### 2.10 Theme Implementation

- All tokens live in `lib/core/theme/tokens.dart` as `const` values keyed by the token names above.
- Light and dark `ThemeData` are built in `lib/core/theme/theme.dart` from those tokens — never hand-rolled per widget.
- Custom Material colour scheme: `primary: cocoa-800` (light) / `sand-400` (dark); `surface: cream-50` / `cocoa-950`; `error: closed`.
- **Current shipped state: the app is locked to the light theme** (`app.dart` sets `themeMode: ThemeMode.light`). The widget layer is built with light brand tokens and does not yet branch on brightness, so following the device's dark-mode setting renders a broken light/dark mix. `AppTheme.dark` is retained as the foundation for the future dark-mode feature but is not active. Re-enabling `ThemeMode.system` requires the full dark-mode pass described in §6.6. See also §4.8 (ProfileGuest deliberately ships **no Dark-mode row**).

---

## III. Component Library

The widgets below are reused across every screen. They live in `lib/shared/widgets/` (or `lib/core/widgets/` for theme primitives) and are the only place their visual specs are implemented — never re-rolled inline.

### 3.1 Button — `PrimaryButton`, `OutlineButton`, `GhostButton`

- Padding: `16 sp` vertical × `22 sp` horizontal
- Radius: `16 sp`
- Font: Plus Jakarta Sans 600, `m-body` size
- Leading icon: 10 sp gap
- `.fullWidth` variant fills its container
- **Primary (light)**: `cocoa-800` bg / `cream-50` text
- **Primary (dark)**: `sand-400` bg / `cocoa-900` text
- **Outline (light)**: transparent bg / `cocoa-800` text / `1.5px solid rgba(38,23,19,.18)` border
- **Outline (dark)**: transparent bg / `cream-100` text / `rgba(244,237,224,.22)` border
- **Ghost (light)**: `cream-100` bg / `cocoa-800` text
- **Ghost (dark)**: `cocoa-800` bg / `cream-100` text

### 3.2 Chip / Badge — `Chip`

- Padding: `8 sp` × `14 sp`
- Radius: `999 sp` (fully round)
- Font: Plus Jakarta Sans 600, `m-meta` size
- States:
  - **Default**: `cream-100` bg / `cocoa-800` text
  - **Active**: `cocoa-800` bg / `cream-50` text
  - **Verify**: `verify @ 14%` bg / `verify` text / `verify @ 25%` border
  - **Warn**: `warn @ 14%` bg / `warn` text / `warn @ 25%` border
  - **Pending**: `pending @ 14%` bg / `pending` text / `pending @ 28%` dashed border

### 3.3 Verification Badge — `VerificationBadge` (central to product trust)

Three tiers, visually distinct, used on place cards (top-left corner of hero), in place-detail headers, and inline next to user names in reviews.

| Tier | Visual | Polish label | English label |
|---|---|---|---|
| `verifiedOwner` | Solid pill, `verify` bg (`#5a7a55`), white text + white checkmark icon | "Zweryfikowany właściciel" | "Verified Owner" |
| `community` | Outlined pill, `verify` border + text, `verify @ 14%` bg, ✓ glyph | "✓ Społeczność" | "✓ Community" |
| `pending` | Dashed `pending` outline, `pending` text, ⏳ glyph | "⏳ Oczekuje" | "⏳ Pending" |

Tapping a badge opens an explainer sheet (see §3.9 BottomSheet) describing the tier and listing confirmers.

### 3.4 Place Card — `PlaceCard`

- Min width when in horizontal scroller: 220 sp
- Full width in list mode
- Image area: 120 sp tall, category-coloured gradient placeholder until a real photo loads
- Verification badge: top-left corner of image, inset 8 sp
- Save toggle (heart): top-right, 28 sp circle, `rgba(255,255,255,.9)` bg
- Body: name (Plus Jakarta Sans 700, 14 sp), category + meta (`m-meta`), bottom row with `★ rating` left and `open-status · distance` right
- Radius: 18 sp
- Shadow: `sh-card`

### 3.5 Search Bar — `SearchBar`

- Bg: `#fff` (light) / `cocoa-800` (dark)
- Radius: 16–18 sp
- Padding: 12–16 sp
- Leading: search glyph (Lucide `Search` or equivalent), `umber-600` colour
- Trailing: mic / filter glyph, same colour
- Placeholder colour: `muted` (light) / `sand-400` (dark)
- Translucent variant (over map): `rgba(255,253,247,.95)` light / `rgba(58,38,34,.92)` dark, with `backdrop-filter: blur(10px)`

### 3.6 Category Pill — `CategoryPill`

- Inline-flex with a 20 sp coloured square + label
- Square colour: the `cat-*` token for that category
- 8 sp gap between pills in horizontal scroll
- Active state: inverts to `cocoa-800` solid bg / `cream-50` text
- Used in: Map filter row, Submit category picker, Saved filter chips (with count badge appended)

### 3.7 Tab Bar — `TabBar` (5-tab bottom nav)

- Height: 110 sp including home-indicator safe area
- Bg: `rgba(255,255,255,0.92)` light / `rgba(26,16,14,0.85)` dark, with `backdrop-filter: blur(18px)`
- Top border: `rgba(38,23,19,.06)` light / `rgba(244,237,224,.08)` dark
- 5 equal-width columns
- Active tab: `cocoa-900` (light) / `cream-50` (dark); inactive: `muted` (light) / `sand-400 @ 0.7 opacity` (dark)
- Tab labels: Plus Jakarta Sans 600, 11 sp
- **Add tab (middle) optional treatment**: raised circular FAB variant — both flat and FAB renderings are valid; pick one per the chosen state-management / navigation approach

### 3.8 Map Pin — `MapPin` (teardrop) + `ClusterBubble`

`MapPin`:
- Container: 44 sp × 52 sp
- Inner bubble: 44 sp × 44 sp, rotated `-45°`, radius `50% 50% 50% 4px` for teardrop shape
- Border: 2.5 sp `cream-50`
- Drop shadow: `0 6px 10px rgba(26,16,14,.35)` (cocoa-tinted)
- Glyph inside is rotated back `+45°` to read upright
- Category bg colours: `cat-rest`, `cat-mosque`, `cat-groc`, `cat-shop`, `cat-cem`

States:
- **Selected**: `translateY(-4 sp) scale(1.08)`, 200ms ease-out; adds 4 sp ring shadow
- **Pulse** (mosque pins during prayer-time window): see §VI.1

`ClusterBubble`:
- 56 sp circle, `cocoa-800` bg, `cream-50` numeric count
- Border: 3 sp `cream-50`
- Shadow: `0 8px 22px -8px rgba(26,16,14,.5)`

### 3.9 Bottom Sheet — `AppBottomSheet`

- Rounded top corners: 22–26 sp
- Drag handle: 40 sp × 4 sp pill, `rgba(0,0,0,.15)`, centred 16 sp from top
- Snap points: 35% / 75% / full screen
- Drag-to-dismiss enabled (from any snap point downward dismisses)
- Bg: `cream-50` (light) / `cocoa-900` (dark)
- Used for: place peek (Map), filters (Map), confirm-halal (Place detail), language picker (Settings), gallery / photo viewer, search suggestions

### 3.10 Trust Strip — `TrustStrip`

Horizontal banner placed on Home (variant A).
- Leading icon: 36 sp rounded square, `verify` bg, white shield-check icon
- Copy: bold Polish — e.g. "147 miejsc zweryfikowanych" + meta "przez społeczność w tym tygodniu"
- Trailing chevron-right
- Whole row is tappable → navigates to a "Recently verified" list

---

## IV. Screen Catalogue

The names below are the canonical screen vocabulary. Every feature spec, route, and analytics event (if/when enabled) must use these names verbatim.

### 4.1 Bottom-Nav Structure (5 tabs, Polish labels)

| # | Polish | English (internal) | Route prefix |
|---|---|---|---|
| 1 | **Strona** | Home | `/home` |
| 2 | **Mapa** | Map | `/map` |
| 3 | **Dodaj** | Add (Submit) | `/contribute` |
| 4 | **Zapisane** | Saved | `/saved` |
| 5 | **Profil** | Profile | `/profile` |

### 4.2 Onboarding & Auth
- **Splash** — app icon centred, brand wordmark, soft fade-in
- **Onboard1 · Find** — "Find halal life everywhere in Polska"
- **Onboard2 · Trust** — explains the 3-tier verification system
- **Onboard3 · Community** — "Built by Muslims in Poland", encourages contribution
- **LocationPermission** — pre-prompt explaining why, before OS prompt
- **Login** — email + Apple + Google sign-in (light)
- **Register** — same options (dark variant)
- **GuestMode** — visible badge "Tryb gościa"; account creation is optional; persistent sign-in CTA without blocking

### 4.3 Home — three variants
- **HomeA · Personal · Light** — warm cream gradient; greeting with Arabic salaam + user's name; search; category chips; mini-map preview; trust strip; nearby horizontal scroll; community activity feed
- **HomeB · Map-first · Dark** — large interactive map preview as hero; floating search overlay; prayer-time pill ("🌙 Maghrib za 12 min · 4 meczety"); category chips; trust strip; featured carousel
- **HomeC · Guest** — guest-mode badge; persistent sign-in CTA; no personal data; popular-in-city carousel; featured city card

### 4.4 Map
- **MapLight** — light variant with custom warm basemap, search overlay, category chips, pins, user-location dot, nearby strip
- **MapDark** — dark variant; includes the Maghrib banner (prayer time + nearby masjid count)
- **SearchSuggest** — full-screen search modal with recent searches + suggestions
- **Filters** — bottom-sheet filter panel (category, verification level, amenities chips, distance slider)
- **MapPeek** — selected-pin bottom sheet preview with Navigate / Save / Share actions
- **Explore** — editorial view (featured city of the month, trending restaurants, newly added masjids)
- **CityDetail** — full city page (e.g. Kraków · 87 miejsc) with category breakdown stats and popular places

### 4.5 Place Detail
- **PlaceDetail** — hero photo (gallery dots), title + verification badge, category + address, action row (Navigate / Call / Web / Share), hours & address rows, amenity chips, verification preview, reviews preview
- **Gallery** — full-screen dark photo viewer with photo metadata
- **Reviews** — rating distribution histogram, filter chips, review cards with "Confirmed halal" badge
- **Verification** — full panel: who-confirmed list with role chips (`moderator` / `imam`), 24h conflict SLA note, Confirm + Report buttons
- **ConfirmHalalSheet** — bottom sheet with `sourceType` checklist (Saw certificate / Asked staff / Imam recommendation / Personal experience) + primary Confirm button
- **MasjidDetail** — dark hero; today's 5 prayer times grid (next prayer highlighted in `sand-400`); jamaat offsets banner; Jumu'ah card with khutbah languages; Navigate / Call / Qibla action row; facilities chips

### 4.6 Submit / Contribute (multi-step)
- **SubmitLanding** — 3-option landing: Add a place / Suggest an edit / Report an issue; live submission stats footer
- **SubmitCategory** (Step 1 of 4) — 2×3 grid of category tiles (Restaurant / Masjid / Grocer / Butcher / Shop / Cemetery); selected tile inverts to its `cat-*` colour
- **SubmitBasics** (Step 2 of 4) — name (pl required, en/ar optional), address with map drop-pin, hours, phone, photos
- **SubmitDetails** (Step 3 of 4) — `halalSource` radio (Certified / Owner Muslim / Halal menu items / Not sure); optional certificate photo
- **SubmitThanks** (Step 4 of 4) — "JazakAllah khair" confirmation; submission queued with `pending` status; "We'll notify you when it's live"
- **SuggestEdit** — for existing places: checklist of editable fields + free-text note
- **Donations** *(post-MVP)* — Sadaqah Jariyah framing with hadith quote; tier amounts (10/25/50/100/250/custom zł); transparency breakdown bars; anonymous, no-account-required

### 4.7 Saved
- **Saved** — filter chips (All / Restaurants / Mosques / Shops with counts); list with category-icon avatars; save heart toggle
- **SavedEmptyGuest** — empty state for unauth'd users with sign-in CTA

### 4.8 Profile
- **Profile** — avatar + name + city + member-since; "Verified contributor" chip if applicable; stats row (Submitted / Confirmed / Saved); recent activity feed. *(Account-bearing; post-login.)*
- **Contributions** — leaderboard rank card (#N w Polsce); My-submissions list with status badges (live / pending / rejected). *(Account-bearing; post-login.)*
- **ProfileGuest (shipped — 004-profile-screen)** — the launch guest experience for the Profil tab while login is "coming soon": a coming-soon banner + minimal settings (Language / Suggest-a-place / About / Privacy) on one page, plus pushed **Language** (pl/en/ar radios, live locale switch via `localeNotifierProvider`) and **About** screens. No accounts/avatar/stats/contributions; no Dark-mode row; no GitHub link (repo private); external links via `ExternalLinkLauncher`. Shared `BackHeader`/`SettingRow`/`GroupCard` widgets in `lib/shared/widgets/`. Replaces the account-centric Profile until sign-in ships.

### 4.9 Settings
- **Settings** — grouped sections: **Wygląd** (Theme, Text size), **Język i region** (Language, Region, Units), **Prywatność** (Location, Accuracy, Analytics — all with privacy-default values per `constitution.md` §1.7), **Powiadomienia** (Prayer times, New places nearby), **Konto** (Email, Sign out, Delete account)
- **Language** — list with locale codes (PL / EN / AR); footer note about RTL for Arabic
- **About** — app icon, version + build, GitHub link, Community guidelines, Privacy policy, Open-source licenses, Contact email; tagline "Made with love by the polish muslim community"

### 4.10 Post-MVP / Out-of-scope-for-now (catalogued for future reference)
- **Donations** — design exists (§4.6 above); the *flow* is post-MVP. The architecture entity (`Donation`) and integration row exist so it can be turned on without re-architecting.
- **TR / UK locales** — design's Language picker shows Turkish + Ukrainian options; **out of MVP scope**. Do not implement these locales; do not add them to the Settings picker.
- **Imam-moderator workflows beyond confirmation** — basic role chip is in MVP; advanced imam moderation tooling (e.g. khutbah scheduling, halal-certificate verification queue) is post-MVP.

---

## V. Localization & RTL

### 5.1 MVP Language Scope

| Locale | Status | Notes |
|---|---|---|
| `pl` | **Primary** (UI default, source of truth for all copy) | Polish is what the designer wrote; English and Arabic are derived |
| `en` | User-selectable | Translation derived from Polish; never hard-coded English in widgets |
| `ar` | User-selectable | **Full RTL support required**. Translation must be reviewed by a native speaker — never machine-translated for Islamic terminology |

**Out of MVP**: Turkish (TR), Ukrainian (UK), Urdu. Do not add these to the language picker even though the design source includes them.

**Picker location**: TBD — either in-app Settings → Język only, or both in-app Settings and via OS settings. Decide before implementing the Language screen.

### 5.2 Canonical Polish UI Vocabulary

These strings appear across many screens. Use them verbatim; never rephrase.

| Surface | Polish | English (for translator reference) |
|---|---|---|
| Tab 1 | Strona | Home |
| Tab 2 | Mapa | Map |
| Tab 3 | Dodaj | Add |
| Tab 4 | Zapisane | Saved |
| Tab 5 | Profil | Profile |
| Filter sheet title | Filtry | Filters |
| Reset filters | Reset | Reset |
| Category: all | Wszystko | All |
| Category: restaurants | Restauracje | Restaurants |
| Category: mosques | Meczety | Mosques |
| Category: shops | Sklepy | Shops |
| Category: grocery | Spożywczy | Grocery |
| Category: cemetery | Cmentarz | Cemetery |
| Verified by community | Zweryfikowane przez społeczność | Community-verified |
| Verification pending | Oczekuje weryfikacji | Pending verification |
| Submission queued | Twoje zgłoszenie oczekuje na weryfikację społeczności | Your submission is pending community verification |
| Settings group: appearance | Wygląd | Appearance |
| Settings group: language | Język i region | Language & region |
| Settings group: privacy | Prywatność | Privacy |
| Settings group: notifications | Powiadomienia | Notifications |
| Settings group: account | Konto | Account |
| Privacy: location only-while-using | Tylko podczas użycia | Only while using |
| Privacy: accuracy approximate | Przybliżona | Approximate |
| Privacy: analytics disabled | Wyłączone | Disabled |
| Donations title (post-MVP) | Wsparcie | Support |
| Submit CTA on donations | Wesprzyj · 25 zł | Support · 25 zł |
| Thanks (Submit) | JazakAllah khair. | JazakAllah khair. (kept as Arabic transliteration in all locales) |
| Greeting (Home) — Arabic | السلام عليكم | (kept as Arabic, rendered in Amiri font) |

### 5.3 Arabic / RTL Rules

- App enables `Directionality.rtl` app-wide when locale is `ar`.
- **Never use `EdgeInsets.only(left:)` / `right:`** — always `EdgeInsetsDirectional.only(start:, end:)`.
- **Icons that should flip in RTL**: back-arrow, chevron-right (becomes left in RTL), "navigate" arrows. Use Flutter's `Directionality`-aware icon variants where they exist, or wrap in `Transform`.
- **Icons that must NOT flip**: brand mark, app icon, prayer-related glyphs (mosque silhouette, moon, qibla compass), category icons (rooted in real-world objects).
- **Numbers**: Arabic locale may use Eastern Arabic numerals (٠١٢٣٤٥٦٧٨٩) for display; the data layer keeps Western Arabic numerals. Use `intl` `NumberFormat` with the correct locale.

### 5.4 Translation Discipline

- **No machine translation of Islamic terminology** — `masjid`, `iftar`, `qibla`, `wudu`, `khutbah`, `madhab`, `jamaat`, `Sunnah`, etc. should be kept in their canonical form (transliterated, not translated) or reviewed by a human translator with religious literacy.
- **Hadith / dua quotes** stay in Arabic (Amiri font) with optional translation/source line in the user's locale, never replaced by machine translation.
- **Polish is canonical** — every ARB key has a Polish value first; English and Arabic are populated by translators.

---

## VI. Interaction & Animation

### 6.1 Map Pin Pulse (`pinPulse`)

Applied to mosque pins when a prayer time is within the next 30 minutes.

- Keyframes:
  - `0%`: `transform: scale(0.6); opacity: 0.4`
  - `100%`: `transform: scale(1.6); opacity: 0`
- Duration: 2.4 s
- Easing: ease-out
- Iteration: infinite
- The pulse element sits behind the pin (`z-index: -1`) and inherits the pin's `currentColor` for tint.

### 6.2 Selected Pin Lift

- Transform: `translateY(-4 sp) scale(1.08)`
- Duration: 200 ms
- Easing: ease-out
- Adds a 4 sp ring shadow around the pin bubble.

### 6.3 Bottom Sheet Behavior

- Drag handle visible at top (40 × 4 sp).
- Snap points: **35% / 75% / full screen**.
- Drag-to-dismiss from any snap point downward.
- Backdrop scrim: `rgba(26,16,14,.45)` on full-screen sheets; lighter (.18) on partial sheets.

### 6.4 Save Toggle

- Heart icon outline → fills `cat-rest` colour on tap.
- **Haptic feedback**: light impact (`HapticFeedback.lightImpact()`).
- **Optimistic UI** — flip the heart immediately; reconcile with the server response in the background; surface a snackbar if the persist fails.

### 6.5 Prayer-Time Pill (Home B / Map dark)

- Updates **every 60 seconds** to refresh the countdown.
- Shows the next prayer (Fajr / Dhuhr / Asr / Maghrib / Isha) + countdown ("za 12 min") + nearby masjids count.
- Tapping it opens MapDark filtered to mosques near user.

### 6.6 Theme — Light / Dark

- **Current state: locked to light.** `app.dart` sets `themeMode: ThemeMode.light`, so the device's system dark-mode setting is intentionally ignored until dark mode is fully implemented. Following the system setting today produces a broken mix because the widget layer (~44 files) hard-codes light brand tokens and does not branch on brightness. See §2.10.
- **Target (not yet shipped): follows system by default**, with Settings → Wygląd → Motyw as the manual override (`Auto` / `Jasny` / `Ciemny`).
- All design tokens have a light and dark equivalent — when dark mode is built, no widget should hand-check the theme to pick a colour; use `Theme.of(context)` and the theme-aware tokens. Re-enabling `ThemeMode.system` is the final step of that work, gated by golden tests covering light + dark (§XII).

### 6.7 Submit Flow

- Stepwise navigation. Each step validates required fields before allowing `Continue`.
- Progress bar at top: 4 sp tall, `cocoa-800` fill, `rgba(38,23,19,.1)` track; width = step / 4.
- Form drafts persist to local storage so the user can leave and return without losing input.

### 6.8 Confirm Halal Modal

- 1-tap entry from Place detail or Map peek.
- Optional `sourceType` multi-select (default = nothing selected; user can confirm without selecting any source).
- Submission updates `confirmationCount` optimistically and posts to the backend.

---

## VII. Commands

### Prerequisites
- Flutter SDK (stable channel) — `flutter --version`
- Dart SDK (bundled)
- Android Studio + Android SDK
- Xcode (macOS only, for iOS builds)
- A target device or emulator/simulator

### Setup

```bash
flutter pub get
flutter doctor
```

### Build

```bash
flutter run                                       # debug on connected device/emulator
flutter run --flavor dev -t lib/main_dev.dart     # flavor (once configured)
flutter build apk --release                       # Android APK
flutter build appbundle --release                 # Android App Bundle (Play Store)
flutter build ios --release                       # iOS
```

### Test

```bash
flutter test                                                          # unit + widget
flutter test test/features/map/map_view_model_test.dart               # single file
flutter test integration_test/                                        # E2E on device/emulator
flutter test --coverage                                               # with coverage
```

### Quality

```bash
flutter analyze                                  # must be clean before commit
dart format .                                    # also runs in pre-commit
flutter gen-l10n                                 # regenerate after editing ARB files
```

---

## VIII. Code Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── theme/                   # tokens.dart, theme.dart (see §II.10)
│   ├── api/                     # Backend API client
│   ├── map/                     # MapLibre wrapper, style JSON, geocoder
│   ├── prayer_times/            # Mawaqit fetch/parse/cache (mawaqit.dart + mawaqit_service.dart)
│   ├── qibla/                   # Qibla bearing math + compass heading service
│   ├── storage/                 # Local cache (Drift/Isar/Hive — TBD)
│   ├── routing/                 # go_router / auto_route — TBD
│   ├── logging/                 # Logger abstraction
│   └── auth/                    # Token storage, session, guest mode
├── features/
│   ├── map/                     # Interactive halal map + nearby discovery
│   ├── home/                    # Home variants
│   ├── places/                  # Place detail, photos, reviews, hours
│   ├── contribute/              # Add place / suggest edit / upload photo / write review
│   ├── trust/                   # Verification panel, reports, moderation
│   ├── auth/                    # Onboarding, sign-in, guest
│   ├── saved/                   # Saved places
│   ├── profile/                 # Profile, contributions, leaderboard
│   └── settings/                # Settings groups, language picker, about
├── shared/
│   └── widgets/                 # PlaceCard, VerificationBadge, MapPin, etc. (see §III)
└── l10n/                        # app_pl.arb, app_en.arb, app_ar.arb

test/
├── features/                    # Mirrors lib/features/
└── core/

integration_test/                # End-to-end flows
```

Per-feature internal layout (when complexity warrants):
```
lib/features/<feature>/
├── data/                        # API clients, DTOs, repositories
├── domain/                      # Entities, use-cases, value objects
└── presentation/                # Screens, widgets, view models / notifiers
```

---

## IX. State Management

### 9.1 Current
- **TBD**: Decision deferred to an ADR before the first feature spec. Options: Riverpod (modern, compile-time safe), BLoC (explicit event/state), `ChangeNotifier + Provider` (lightweight).
- **Server state**: Cached in repository layer (`lib/features/*/data/`) with explicit refresh policies.
- **URL/route state**: Deep links into place details and map regions must survive navigation.
- **Local state**: Form drafts (add-place, review composition) persist to local storage.

### 9.2 Target
- **Server State**: Repository pattern + chosen state-management solution + on-device cache for offline-friendly browsing.
- **URL State**: `go_router` or `auto_route` — deep-linkable to specific places, categories, map regions.
- **Local State**: Scoped to feature, lifted only when shared.

---

## X. Code Quality

### 10.1 Standards
- Follow Effective Dart (https://dart.dev/effective-dart).
- `flutter analyze` clean — no warnings tolerated in CI.
- `dart format .` applied before every commit (pre-commit hook recommended).
- Sound null safety throughout — no `// ignore: ...` without a written justification.

### 10.2 Patterns
- **Feature-first structure**: organise by feature, not by technical layer.
- **Small composable widgets**: many small widgets over deeply nested `build` methods.
- **Strict analysis**: extend `flutter_lints`; consider `very_good_analysis`.
- **No widget files over ~300 lines** — refactor into smaller widgets.
- **Theme tokens, not magic numbers** — colours and spacing must reference `tokens.dart`, never hex/sp literals in widget code.

---

## XI. Accessibility

- **WCAG 2.1 AA** target.
- **Semantic labels** on every interactive widget (`Semantics`, `tooltip:`).
- **Keyboard navigation** supported (external keyboards on tablets are common).
- **Screen reader** compatibility (TalkBack / VoiceOver) verified for core flows.
- **Dynamic type scaling**: layout must remain usable at OS-maximum text scale.
- **Color contrast**: 4.5:1 for body text, 3:1 for large text + UI components. The cream-background + umber-text pairings are tight — verify each one.
- **Hit targets ≥ 44 sp**.
- **RTL parity**: Arabic locale renders mirror-correctly per §V.3.

---

## XII. Testing

### 12.1 Mandatory test types (per `.ai/0_core_memory/coding-standards.md`)
- **Unit tests** — `test/` — Dart logic, view models, domain services. `flutter test`.
- **Widget tests** — `test/` — widget behaviour with `WidgetTester`, including RTL variants for text-heavy widgets.
- **Integration tests** — `integration_test/` — end-to-end flows (sign-in, add place, submit review, confirm halal, moderation report). `flutter test integration_test/`.
- **Golden tests** (recommended for the design system) — screenshot diffs for shared widgets across light / dark and LTR / RTL.

### 12.2 No Playwright
Flutter is not a web app. Playwright-based skills do not apply; integration tests use the `integration_test` package and `flutter drive`.

---

## XIII. Anti-Patterns (Avoid)

### Flutter
- **Hard-coded user-visible strings** in widget code — must live in ARB files.
- **`EdgeInsets.only(left:)` / `right:`** — use `EdgeInsetsDirectional` so Arabic RTL doesn't break.
- **Magic colour / spacing literals** in widgets — reference `tokens.dart`.
- **Massive `build()` methods** — break into smaller widgets once a `build` exceeds ~50 lines.
- **Logic in widgets** — extract to view models / notifiers / use-cases.
- **Mutable global state** — funnel through the chosen state-management solution.
- **`setState` chains across multiple `StatefulWidget`s** — that's a state-management gap; fix the structure, not the symptom.
- **Hand-rolled SVG icons** — use the icon library (Lucide / Phosphor / Material Symbols); the design's inline SVGs are illustrative.

### Trust & Halal Context
- **Showing "halal" without a verification source** — every halal claim must reference its underlying `verification.tier` + `sourceType`.
- **Auto-translating Islamic terminology** — see §V.4.
- **Generic "directory app" aesthetics** — the product is positioned as premium; resist defaulting to generic list UIs. Use the design system's cocoa/cream warmth, Lora italic 500 emphasis, and the verification trust strip as differentiators.
- **Vanilla map provider styles** — must use the custom MapLibre style; falling back to Mapbox Streets / Google Maps default breaks the brand.

### Privacy & Trust
- **Enabling analytics by default** — violates `constitution.md` §1.7.
- **Requesting precise location** without explicit user opt-in — default is approximate.
- **Linking donation activity to user identity** — donations are anonymous by design.

---

**Related Documents**:
- [Architecture](./architecture.md) - Domain model, verification workflow, integrations
- [General Overview](./general-overview.md) - Project identity, operating model, funding
- [Universal Constitution](./constitution.md) - Privacy defaults (§1.7), security, git workflow, testing requirements
