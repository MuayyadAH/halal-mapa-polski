# Halal Map Polskie System Architecture

**Target Audience**: All developers and architects
**Purpose**: System-level architecture, integration points, and cross-cutting concerns

*Greenfield — concrete paths and provider choices are TBD; this document captures the **intended** shape so it can be refined as decisions land.*

---

## System Components Overview

### Core Components

1. **Flutter Mobile App** (`lib/`) - Cross-platform iOS + Android client. Single Flutter codebase delivers all user-facing functionality.
   - `lib/features/map/` - Interactive halal map, place discovery, nearby search, filters
   - `lib/features/places/` - Place detail screens, photo galleries, reviews, hours, directions
   - `lib/features/contribute/` - Add-place, suggest-edit, photo upload, review composition flows
   - `lib/features/business/` - Owner-claim flow, verified-owner listing management, badges
   - `lib/features/trust/` - Verification state surfacing, reporting, moderation transparency
   - `lib/features/auth/` - Guest vs logged-in flows, sign-in/sign-up, profile management
   - `lib/l10n/` - Polish (pl), English (en), Arabic (ar with RTL) ARB resources

2. **Shared App Infrastructure** (`lib/core/`) - Cross-cutting concerns shared across features.
   - `lib/core/api/` - Backend API client (typed, generated where possible)
   - `lib/core/map/` - Map provider abstraction so the map SDK choice stays swappable
   - `lib/core/storage/` - Local cache (Hive / Drift / Isar — TBD) for offline-friendly browsing
   - `lib/core/theme/` - Design system, premium-feel tokens, light/dark, RTL-aware spacing

3. **Backend API** (external — separate repository, future) - REST or GraphQL service owning all server-side data and business logic. This repo treats it as an external integration.

4. **Backend Database** (external — managed by backend repo) - Persistent store for places, users, reviews, photos, verification state, moderation history.

5. **Database Layer** (local-only, in app) - On-device cache (TBD: Drift, Isar, or Hive) for last-fetched places, offline map tiles where permitted, and saved-places.

---

## Integration Architecture

### External Systems

*All third-party choices are TBD pending early architectural decisions.*

| System | Protocol | Purpose |
|--------|----------|---------|
| **Backend API** | HTTPS (REST or GraphQL) | Places, users, reviews, photos, verification, moderation |
| **Map Provider** | **MapLibre GL** (Flutter package: `maplibre_gl`) with self-hosted or community tile source (e.g. MapTiler, Stadia Maps, Protomaps) + custom style JSON | Map tiles and rendering. **Custom warm cocoa/cream basemap (light) and cocoa basemap (dark) is part of the brand — vanilla provider styles do not meet the design.** |
| **Geocoding & Directions** | External API (TBD — Nominatim / MapTiler Geocoding / Mapbox Geocoding) | Address → coordinates for the submission flow; "Navigate" action deep-links to the OS maps app rather than rendering directions in-app |
| **Prayer Times** | **Mawaqit** (mosque pages' embedded `confData` JSON, fetched over HTTPS; yearly calendar cached on-device for offline). Product decision 2026-07-17 — supersedes the earlier on-device Adhan plan | Real mosque times (incl. jamaat/Jumu'ah) for mosques carrying a `Mawaqit Link`; powers the Home next-prayer pill and the masjid detail times grid |
| **Auth Provider** | OAuth / OIDC or backend-issued JWT | Sign-in, guest sessions, owner-claim identity proof. Must support guest browsing without an account |
| **Image Storage** | HTTPS (signed URLs) | User-uploaded photos for places and reviews. Clients never get long-lived bucket credentials |
| **Push Notifications** | FCM (HTTP/2) | Moderation updates, community announcements, prayer reminders (if user opts in), event reminders |
| **Crash Reporting (opt-in)** | TBD — self-hosted Sentry or equivalent | Crash diagnostics only. **No product analytics.** Analytics is OFF BY DEFAULT and only enabled if the user explicitly opts in (see `constitution.md` §1.7 Privacy Defaults). No third-party trackers |
| **Donation Payments (post-MVP)** | Payment provider TBD — Stripe / Przelewy24 / BLIK | Anonymous one-time donations in PLN; no account required; tiered amounts (10/25/50/100/250/custom zł) + public transparency on fund allocation |

### Data Flow

```
User device (Flutter app)
    ↓ (Map interaction, search, view place)
Backend API (HTTPS)
    ↓ (Query)
Backend Database (places, users, reviews, photos, verification)
    ↓ (Expose via API)
Backend API
    ↓ (Response)
Flutter app → local cache → UI

User contribution flow:
Flutter app (add place / review / photo)
    ↓ (POST + multipart upload)
Backend API → moderation queue → Database
    ↓ (Push notification on state change)
Flutter app
```

---

## Domain Model

The backend owns persistence; the Flutter app consumes typed entities. The shapes below are the canonical vocabulary every feature spec, view-model, API client, and ARB key must use.

### Place (core entity, polymorphic by category)

Common fields:
- `id` (uuid)
- `category` (enum: `restaurant` | `masjid` | `grocer` | `butcher` | `shop` | `cemetery`)
- `name` (localized: `{ pl: required, en?: optional, ar?: optional }` — app falls back to `pl` when a requested locale is missing)
- `description` (localized, optional)
- `location` (`{ lat, lng }`)
- `address` (string, Polish-formatted)
- `city` (string — Warsaw / Kraków / etc.)
- `phone` (string, optional)
- `website` (url, optional)
- `hours` (per-weekday open/close ranges, optional)
- `photos` (array of `{ url, thumbnailUrl, uploadedBy, uploadedAt, caption? }`)
- `verification` (Verification — see below)
- `addedBy` (UserRef)
- `createdAt`, `updatedAt`
- `amenities` (set of enum values — see category-specific below)
- `priceLevel` (`$` | `$$` | `$$$` | `$$$$`, optional — restaurants only)

Restaurant-specific:
- `cuisine` (string, e.g. "Middle Eastern")
- `halalSource` (enum: `certified` | `owner_muslim` | `menu_items` | `unsure`)
- `halalCertificatePhotoUrl` (optional)
- `amenities` subset: `women_friendly`, `accessible`, `prayer_room`, `family_friendly`, `parking`, `card_payment`

Masjid-specific:
- `madhab` (enum: `sunni` | `shia` | `other`, optional)
- `prayerTimes` (today's Fajr / Dhuhr / Asr / Maghrib / Isha — fetched from the mosque's Mawaqit page, cached on-device, not stored server-side)
- `jamaatTimes` (`{ fajr?, dhuhr?, asr?, maghrib?, isha? }` — the masjid's chosen congregational offsets, manually entered)
- `jumuah` (`{ time, khutbahLanguages: string[] }`)
- `amenities` subset: `women_section`, `wheelchair`, `parking`, `wudu`, `madrasah`, `children_area`

Grocer / Butcher / Shop / Cemetery: common fields only; no category-specific extensions in MVP.

### Verification (cross-cutting trust concern, present on every Place)

- `tier` (enum: `verified_owner` | `community` | `pending`)
- `confirmedBy` (array of `{ userId, displayName, role, confirmedAt, sourceType, note? }`)
- `sourceType` per confirmation (enum: `certificate_seen` | `asked_staff` | `imam_recommendation` | `personal_experience`)
- `lastReviewedAt`
- `confirmationCount` (denormalized)
- `conflictingReports` (count; >0 triggers moderator escalation within 24h)

### User

- `id` (uuid)
- `displayName` (string)
- `city` (string)
- `language` (enum: `pl` | `en` | `ar`)
- `avatarUrl` (optional)
- `joinedAt`
- `role` (enum: `user` | `moderator` | `imam_moderator`)
- `stats` (`{ submittedCount, confirmedCount, savedCount }` — denormalized)

### Submission (a Place awaiting moderation)

- `id` (uuid)
- *All Place fields* (denormalized at submission time)
- `submittedBy` (UserRef)
- `submittedAt`
- `status` (enum: `pending` | `approved` | `rejected` | `live`)
- `moderatorNotes` (string, optional — visible to submitter on rejection)
- `reviewedBy` (UserRef, optional)
- `reviewedAt` (optional)

### Review

- `id` (uuid)
- `placeId` (ref)
- `author` (UserRef)
- `rating` (integer 1–5)
- `body` (string, in the author's locale)
- `photos` (array)
- `halalConfirmed` (bool — when true, the review carries the "✓ Confirmed halal" badge)
- `createdAt`

### SavedItem

- `userId` (ref)
- `placeId` (ref)
- `savedAt`
- `lastVisitedAt` (optional)

### Donation *(post-MVP)*

- `id` (uuid, opaque)
- `amount` (decimal, PLN)
- `currency` (`PLN`)
- `paidAt`
- `provider` (enum, TBD)
- `paymentRef` (provider's reference)
- **No `userId` reference** — donations are anonymous by design.

### Persistence target

TBD by backend repo. Likely **PostgreSQL with PostGIS** for geospatial queries on Place. Decision deferred until backend repo is initialized; the Flutter app's API client is built against the entity shapes above, not against a specific persistence choice.

---

## Verification Workflow

The verification system is the product's trust moat. Every place displays a tier; every tier has a clear path to advance.

### Tier definitions
- **Verified Owner** — Solid green pill, white checkmark. Place officially claimed by its business owner with ownership proof submitted and approved by a moderator. Highest trust.
- **Community** — Amber outlined pill. Place confirmed halal by ≥1 community member (with role chip — `moderator` or `imam` — when applicable). Default tier for community-added places once any confirmation is recorded.
- **Pending** — Dashed amber pill. Newly submitted, no confirmations yet, awaiting community verification.

### Confirmation flow
1. A user opens a place and taps "I confirm this is halal" on the detail screen.
2. They optionally select one or more `sourceType` values: `certificate_seen`, `asked_staff`, `imam_recommendation`, `personal_experience`.
3. Their confirmation appears in the place's verification panel with timestamp and role chip.
4. The `confirmationCount` increments. The tier advances from `pending` → `community` on the first confirmation.

### Conflict & report flow
1. Any user can report a place (`not_halal_anymore`, `closed`, `mislabeled`, etc.).
2. Reports queue for moderators; **conflicting reports are escalated to community moderators within 24 hours**.
3. The moderator decision is logged and visible — reasoning is surfaced to the submitter and to subsequent viewers if the place state changes.

### Roles & rights
| Role | Confirm halal | Report | Resolve reports | Promote tier |
|---|---|---|---|---|
| `user` | yes | yes | no | no |
| `moderator` | yes (with `moderator` role chip) | yes | yes | community → verified_owner (after owner-proof review) |
| `imam_moderator` | yes (with `imam` role chip — highest community trust) | yes | yes | community → verified_owner |

---

## Security Architecture

### System-Level Security
- Backend API credentials never embedded in the Flutter app binary — all server-side secrets live in the backend repo's environment config.
- Map provider keys and any client-needed API keys are configured per build flavor (`--dart-define` or Flutter env config), restricted by package name + signing certificate where the provider supports it.
- Auth tokens stored in secure platform storage (`flutter_secure_storage`).
- Image uploads use signed URLs issued by the backend — clients never get long-lived bucket credentials.
- All network traffic over HTTPS; certificate pinning to be evaluated post-MVP.

### Security Rules
- **NEVER** commit secrets, signing certificates, keystores, or API keys to git.
- **NEVER** store auth tokens in `SharedPreferences` — use `flutter_secure_storage`.
- Use build-time configuration (`--dart-define`, flavor configs) for environment-specific values; never hard-code endpoints.
- Personally identifiable information (PII) handling must align with EU GDPR — relevant since the app targets users in Poland.
- See `.ai/0_core_memory/security-rules.md` for the full ruleset.

---

## Modernization Strategy

*Not applicable — Halal Map Polskie is a greenfield project. This section is retained for template compatibility and will remain empty unless the project absorbs legacy code in the future.*

---

**Related Documents**:
- [General Overview](./general-overview.md) - Project overview and context
- [Frontend Constitution](./constitution-frontend.md) - Flutter tech stack, commands, patterns
