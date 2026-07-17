# Contract: Shared Profile components (BackHeader · SettingRow · GroupCard)

**Feature**: `004-profile-screen` | **Location**: `lib/shared/widgets/`

The three reusable building blocks the Profile screens compose (FR-017). Implemented once, styled only from `tokens.dart` (`HmpColors`/`HmpSpacing`/`HmpRadii`/`HmpFonts`), reusable by the future full Settings screen (§4.9). All honor RTL (`EdgeInsetsDirectional`, chevrons/arrows flip) and reduced motion.

---

## `BackHeader`

```dart
BackHeader({
  required String title,     // Lora 24, w500
  String? kicker,            // optional uppercase umber 12px (e.g. "Ustawienia")
  bool showBack = true,      // 38dp parchment-glass back-chevron tile; pops the route
})
```
- **S1** uses `showBack: false` (tab root, title `Profil`/`Profile`, no kicker).
- **S2/S3** use `showBack: true` with kicker `Ustawienia`/`Settings` and `Informacje`/`Info`.
- Back chevron is `Directionality`-aware (points left in LTR, right in RTL); `onTap` pops via the router. Semantic label "Back". Tap target ≥ 44 dp.

## `SettingRow`

```dart
SettingRow({
  required IconData icon,        // 36dp rounded-10 icon tile
  required String label,         // 14px w600
  String? sub,                   // 11.5px cocoa700
  String? trailingValue,         // 12px cocoa700 (e.g. "Polski", "v 1.0.0")
  SettingRowTrailing trailing =  // chevron | external | radio | none
      SettingRowTrailing.chevron,
  bool accent = false,           // umber glyph on umber@12% tile (e.g. Suggest)
  bool selected = false,         // radio selected state
  VoidCallback? onTap,
  String? semanticLabel,         // external rows announce "opens externally"
})
```
- **trailing** variants:
  - `chevron` — `Directionality`-aware chevron (Language, About).
  - `external` — 45° external-link arrow, umber (Suggest, Website, Privacy, Terms). Semantics announce the row opens an external destination.
  - `radio` — 22dp selected = green (`HmpColors.verify`) filled check / unselected = hollow ring (Language list rows). Animates the check ~150 ms on select (gated by reduced motion).
  - `none` — plain row.
- Wrapped in `PressableScale` for press feedback; `InkWell`-style tint on press. 1px divider between rows (handled by `GroupCard`), none after the last.
- Reused across S1 (settings rows), S2 (language radio rows), S3 (links rows).

## `GroupCard`

```dart
GroupCard({
  String? sectionLabel,          // 11px w700 uppercase umber, +0.5 ls, pad-left 28
  required List<Widget> rows,    // SettingRows, stacked
})
```
- Card: `HmpColors.parchment`-ish translucent fill, `BorderRadius.circular(18)`, hairline border, soft cocoa-tinted shadow (`sh-card`).
- Inserts a 1px hairline divider (`cocoa @ ~5%`) **between** rows; none after the last.
- Optional uppercase section label above the card (PREFERENCES / COMMUNITY / INFO / LINKS).

---

## Test surface (widget)
- `BackHeader`: renders title/kicker; back chevron present only when `showBack`; tapping pops (verify with a test router); chevron mirrors in RTL.
- `SettingRow`: each `trailing` variant renders the right affordance; `external` rows expose the "opens externally" semantics; `radio` reflects `selected`; tap fires `onTap`; ≥ 44 dp; accent variant tints correctly; reduced motion disables the radio-check animation.
- `GroupCard`: N rows → N-1 dividers; section label rendered when provided.
- All three: pl/en/ar incl. RTL; tokens only (no magic literals — guarded by review/lint).

## Contract guarantees
1. Implemented once in `lib/shared/widgets/`; the three screens never re-roll these inline (FR-017).
2. Styled exclusively from `tokens.dart` (Constitution §X / §XIII).
3. RTL-correct (`EdgeInsetsDirectional`; directional chevrons) and reduced-motion-correct.
4. Every interactive instance is semantically labeled and ≥ 44 dp (FR-020).
