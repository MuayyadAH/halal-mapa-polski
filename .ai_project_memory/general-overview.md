# Halal Map Polskie (Halal Map PL) - Project Overview

**Project**: Modern Muslim-focused mobile platform that helps Muslims in Poland discover trusted halal-friendly places — restaurants, masjids, grocery stores, Islamic shops, and Muslim cemeteries — through an interactive map, community contributions, and business-owner verification.

## Executive Summary

Halal Map Polskie is a Flutter-based mobile application targeting Muslims living in or visiting Poland. It combines map discovery, community contributions, business verification, and localized Muslim lifestyle tools into a single trustworthy halal-discovery experience. The product positioning is closer to Google Maps / Airbnb / Apple Maps / Muslim Pro than to a traditional business directory — simplicity, trust, accessibility, and high-quality UX are the primary product values.

**Key Facts**:
- **System**: Halal Map PL — Flutter mobile app (iOS + Android) with a future server-side backend in a separate repository
- **Current Phase**: Greenfield — initial product build
- **Users**: Muslims in Poland — residents, students, and travelers — plus Muslim business owners and community moderators
- **Target cities**: Warsaw (Warszawa), Kraków, Wrocław, Gdańsk, Poznań, with nationwide coverage growing community-driven
- **Languages (MVP)**: Polish (primary, UI default), English and Arabic (user-selectable; Arabic with full RTL support). Picker location — OS settings vs in-app Settings — TBD
- **Data Scale**: TBD — early-stage, expected hundreds of places at launch
- **Timeline**: TBD — long-term ecosystem growth oriented; no fixed delivery deadline declared

## Problem & Solution

**Problem**: Muslims in Poland struggle to verify whether places are truly halal, discover nearby masjids or prayer spaces, and find halal grocery stores while traveling. Today's information is scattered across Google reviews, Facebook groups, mosque forums, blogs, and word-of-mouth — outdated, fragmented, and lacking trust signals.

**Solution**: A modern, community-powered halal discovery app that combines an interactive map, community contributions with moderation, verified business-owner listings, and trust indicators — accessible to younger users, older users, travelers, and non-technical users alike, in Polish (primary), English, and Arabic with full RTL support.

See [Architecture](./architecture.md) for system architecture.

## Operating Model

### Funding & Business Model
- **Open-source, community-built.** The codebase is intended to be public; the About screen carries a GitHub link.
- **No ads, no third-party tracking, no paywalls — ever.** This is a constitutional commitment, not an MVP convenience. See `constitution.md` §1.7 (Privacy Defaults) for how this is encoded.
- **Sustainability via community donations** (Sadaqah Jariyah model — anonymous, no account required, with public transparency of where funds go: server costs, community moderation, field verification trips, open-source contributions). The donation flow is **staged post-MVP**; the architecture catalogues it so it can be turned on later without re-architecting.
- **No data sale.** User data is never sold or shared with third parties beyond what is operationally required (e.g. map tile provider, push delivery, crash reporting).

### Community Moderation
- **Two-tier moderator roles**: regular community moderators and imam-moderators (religious-knowledge verification carries an `imam` role chip in UI).
- **24-hour SLA** for submission review and for escalating conflicting reports.
- **Transparency surface**: users see who confirmed a place (with role labels), when it was last reviewed, and the count of community confirmations.
- **Appeal paths** for removed or rejected content; moderation reasoning is surfaced rather than hidden.

## System Components

*Greenfield — components below describe the **planned** product structure. Component boundaries may evolve during early development.*

1. **Map & Discovery (Flutter app)** - Interactive halal map UI: nearby discovery, category filters (restaurant / masjid / grocery / shop / cemetery), trust indicators, place detail views.
2. **Community Contributions (Flutter app)** - Add-new-place flow, suggest-edit flow, photo uploads, reviews, and report-content workflows.
3. **Business Owner Listings (Flutter app)** - Two listing modes: community-added and verified-owner. Verified-owner mode includes claim, ownership proof, and enhanced credibility surface (official badges).
4. **Trust & Verification System** - Verification states, community confirmations, moderation queues, reporting and dispute workflows. Cross-cutting concern surfaced in every place card and detail screen.
5. **Localization & Accessibility** - Polish (primary), English, and Arabic (with RTL) translations and locale-aware formatting; designed for younger users, older users, travelers, and non-technical users.
6. **Featured Content & Donations (post-MVP)** - Featured halal businesses, community announcements, local event promotions, and a Sadaqah Jariyah donation flow (anonymous, no-account-required, with public transparency on fund allocation). Elegant, integrated, non-intrusive — and never advertising.
7. **Backend API & Data (separate repository, future)** - REST/GraphQL service, place + user + review + photo + verification data, moderation tooling. Tracked separately; this repo consumes it via a defined API client.

## Key Integration Points

*Most integrations are **planned** — final providers will be chosen during architecture decisions.*

- **Backend API (planned, separate repo)**: REST or GraphQL. Owns place data, user accounts, reviews, photos, verification state, moderation.
- **Map provider (TBD)**: Google Maps Platform, Mapbox, or OpenStreetMap-based stack (Flutter packages: `google_maps_flutter`, `mapbox_maps_flutter`, or `flutter_map`). Decision affects licensing, offline support, and styling.
- **Auth provider (TBD)**: Firebase Auth, Supabase Auth, or backend-issued tokens. Must support guest browsing without an account.
- **Image storage (TBD)**: Firebase Storage, S3-compatible, or backend-proxied uploads.
- **Push notifications (planned)**: FCM (iOS + Android) for moderation updates, community announcements, and event reminders.
- **Localization toolchain**: Flutter `intl` + ARB files for Polish, English, Arabic. Arabic requires verified RTL layout testing.

## Documentation Structure

- **Project memory**: `.ai_project_memory/` (this folder)
- **Coding standards & security**: `.ai/0_core_memory/`
- **Templates**: `.ai/2_templates/` (spec, plan, ADR, etc.)
- **Feature specs**: `specs/` (created per feature via `/ai1st-po-specify`)

---
