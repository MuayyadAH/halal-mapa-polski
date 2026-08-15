import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/location/distance.dart';
import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/maps/maps_launcher.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/places/presentation/category_style.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/features/home/presentation/state/bookmarks_notifier.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/geometric_motif.dart';

import 'prayer_times_card.dart';

/// In-app place page (design "PlaceDetail", adapted to the lean v1 sheet
/// data). Editorial layout: category-tinted hero with the khatam-lattice
/// watermark, Lora display name, community-verification chip, the sheet
/// comment as a pull-quote, and a pinned Navigate/Save action bar. Mosques
/// with a Mawaqit link get a prayer-times row (in-app times land with the
/// prayer-times feature).
class PlaceDetailScreen extends ConsumerWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(placesProvider);

    return Scaffold(
      backgroundColor: HmpColors.cream50,
      body: placesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: HmpColors.cocoa800),
        ),
        error: (_, __) => const _MissingState(),
        data: (places) {
          Place? place;
          for (final p in places) {
            if (p.id == placeId) {
              place = p;
              break;
            }
          }
          if (place == null) return const _MissingState();
          return _DetailBody(place: place);
        },
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userLatLngProvider);
    final distance = user == null
        ? null
        : formatDistance(
            distanceMeters(user.lat, user.lng, place.lat, place.lng),
            Localizations.localeOf(context).toString(),
          );

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Hero(place: place)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    HmpSpacing.screenH,
                    18,
                    HmpSpacing.screenH,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _KickerRow(place: place),
                      const SizedBox(height: 8),
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontFamily: HmpFonts.display,
                          fontWeight: FontWeight.w500,
                          fontSize: 30,
                          height: 1.12,
                          letterSpacing: -0.4,
                          color: HmpColors.cocoa900,
                        ),
                      ),
                      if (distance != null) ...[
                        const SizedBox(height: 10),
                        _DistancePill(distance: distance),
                      ],
                      const SizedBox(height: 20),
                      const MotifDivider(),
                      if (place.comment != null &&
                          place.comment!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _CommentQuote(place: place),
                      ],
                      if (place.category == Category.masjid &&
                          place.mawaqitLink != null &&
                          place.mawaqitLink!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        PrayerTimesCard(mawaqitUrl: place.mawaqitLink!),
                      ],
                      const SizedBox(height: 16),
                      _CoordinatesRow(place: place),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _ActionBar(place: place),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [place.category.color, HmpColors.cocoa900],
              ),
            ),
          ),
          GeometricMotif(
            color: HmpColors.cream50.withValues(alpha: 0.09),
            cell: 96,
          ),
          // Soft vignette so the medallion + chrome read against any tint.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33150C0A), Color(0x00000000)],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: HmpColors.cream50.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: HmpColors.cream50.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                place.category.glyph,
                style: const TextStyle(fontSize: 34),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                HmpSpacing.screenH,
                HmpSpacing.chromeV,
                HmpSpacing.screenH,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GlassBackTile(
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  _HeroBookmarkButton(placeId: place.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBackTile extends StatelessWidget {
  const _GlassBackTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HmpRadii.iconSm),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HmpColors.cocoa950.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(HmpRadii.iconSm),
            border: Border.all(
              color: HmpColors.cream50.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            isRtl ? Icons.chevron_right : Icons.chevron_left,
            size: 22,
            color: HmpColors.cream50,
          ),
        ),
      ),
    );
  }
}

class _HeroBookmarkButton extends ConsumerWidget {
  const _HeroBookmarkButton({required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bookmarked = ref.watch(
      bookmarksProvider.select((s) => s.contains(placeId)),
    );
    return Semantics(
      button: true,
      toggled: bookmarked,
      label: bookmarked ? l10n.bookmarkRemove : l10n.bookmarkAdd,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(bookmarksProvider.notifier).toggle(placeId);
        },
        borderRadius: BorderRadius.circular(HmpRadii.iconSm),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HmpColors.cream50.withValues(alpha: bookmarked ? 0.92 : 0.2),
            borderRadius: BorderRadius.circular(HmpRadii.iconSm),
            border: Border.all(
              color: HmpColors.cream50.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(
            bookmarked ? Icons.bookmark : Icons.bookmark_border,
            size: 20,
            color: bookmarked ? HmpColors.cocoa800 : HmpColors.cream50,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Content rows
// ---------------------------------------------------------------------------

class _KickerRow extends StatelessWidget {
  const _KickerRow({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            place.category.label(l10n).toUpperCase(),
            style: const TextStyle(
              fontFamily: HmpFonts.ui,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: HmpType.kickerSpread * 12,
              color: HmpColors.umber600,
            ),
          ),
        ),
        const _CommunityChip(),
      ],
    );
  }
}

/// v1 list is hand-curated â†’ every place carries the community tier
/// (constitution Â§1.6: never show "halal" without a verification source).
class _CommunityChip extends StatelessWidget {
  const _CommunityChip();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: HmpColors.verify.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(HmpRadii.pill),
        border: Border.all(color: HmpColors.verify.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 13, color: HmpColors.verify),
          const SizedBox(width: 4),
          Text(
            l10n.verifiedByCommunity,
            style: const TextStyle(
              fontFamily: HmpFonts.ui,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: HmpColors.verify,
            ),
          ),
        ],
      ),
    );
  }
}

class _DistancePill extends StatelessWidget {
  const _DistancePill({required this.distance});

  final String distance;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.near_me, size: 15, color: HmpColors.umber600),
        const SizedBox(width: 5),
        Text(
          distance,
          style: const TextStyle(
            fontFamily: HmpFonts.display,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: HmpColors.cocoa800,
          ),
        ),
      ],
    );
  }
}

/// The sheet's free-text comment, staged as an editorial pull-quote with a
/// category-tinted side rule.
class _CommentQuote extends StatelessWidget {
  const _CommentQuote({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.only(start: 16),
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(color: place.category.color, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.detailCommunityNote.toUpperCase(),
            style: const TextStyle(
              fontFamily: HmpFonts.ui,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: HmpType.kickerSpread * 11,
              color: HmpColors.umber600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            place.comment!,
            style: const TextStyle(
              fontFamily: HmpFonts.display,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              fontSize: 18,
              height: 1.4,
              color: HmpColors.cocoa700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordinatesRow extends StatelessWidget {
  const _CoordinatesRow({required this.place});

  final Place place;

  String get _text =>
      '${place.lat.toStringAsFixed(5)}, ${place.lng.toStringAsFixed(5)}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.detailCoordinates,
      child: InkWell(
        borderRadius: BorderRadius.circular(HmpRadii.cardCompact),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: _text));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.detailCopied)),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: HmpColors.cream100,
            borderRadius: BorderRadius.circular(HmpRadii.cardCompact),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.place_outlined,
                size: 18,
                color: HmpColors.umber600,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _text,
                  style: const TextStyle(
                    fontFamily: HmpFonts.mono,
                    fontSize: 12.5,
                    color: HmpColors.cocoa700,
                  ),
                ),
              ),
              const Icon(Icons.copy, size: 16, color: HmpColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pinned action bar
// ---------------------------------------------------------------------------

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bookmarked = ref.watch(
      bookmarksProvider.select((s) => s.contains(place.id)),
    );
    return Container(
      decoration: const BoxDecoration(
        color: HmpColors.cream50,
        border: Border(top: BorderSide(color: Color(0x0F261713))),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(
        HmpSpacing.screenH,
        12,
        HmpSpacing.screenH,
        0,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      ref.read(mapsLauncherProvider).openPlace(place),
                  style: FilledButton.styleFrom(
                    backgroundColor: HmpColors.cocoa800,
                    foregroundColor: HmpColors.cream50,
                    padding: const EdgeInsets.symmetric(
                      vertical: HmpSpacing.buttonV,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(HmpRadii.button),
                    ),
                  ),
                  icon: const Icon(Icons.navigation_outlined, size: 18),
                  label: Text(
                    l10n.mapNavigate,
                    style: const TextStyle(
                      fontFamily: HmpFonts.ui,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Semantics(
                button: true,
                toggled: bookmarked,
                label: bookmarked ? l10n.bookmarkRemove : l10n.bookmarkAdd,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(bookmarksProvider.notifier).toggle(place.id);
                  },
                  borderRadius: BorderRadius.circular(HmpRadii.button),
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          bookmarked ? HmpColors.cocoa800 : Colors.transparent,
                      borderRadius: BorderRadius.circular(HmpRadii.button),
                      border: Border.all(
                        color: bookmarked
                            ? HmpColors.cocoa800
                            : const Color(0x2E261713),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      bookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: 20,
                      color:
                          bookmarked ? HmpColors.cream50 : HmpColors.cocoa800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Not-found / error state
// ---------------------------------------------------------------------------

class _MissingState extends StatelessWidget {
  const _MissingState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: GeometricMotif(
              color: HmpColors.cocoa900.withValues(alpha: 0.04),
              cell: 96,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              HmpSpacing.screenH,
              HmpSpacing.chromeV,
              HmpSpacing.screenH,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GlassBackTileOnLight(
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const Spacer(),
                Center(
                  child: Column(
                    children: [
                      const Text('ðŸ•Œ', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 14),
                      Text(
                        l10n.detailNotFoundTitle,
                        style: const TextStyle(
                          fontFamily: HmpFonts.display,
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
                          color: HmpColors.cocoa900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.detailNotFoundSub,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: HmpFonts.ui,
                          fontSize: 14,
                          color: HmpColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBackTileOnLight extends StatelessWidget {
  const _GlassBackTileOnLight({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HmpRadii.iconSm),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HmpColors.parchment.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(HmpRadii.iconSm),
            border: Border.all(color: const Color(0x0D261713)),
          ),
          child: Icon(
            isRtl ? Icons.chevron_right : Icons.chevron_left,
            size: 22,
            color: HmpColors.cocoa800,
          ),
        ),
      ),
    );
  }
}
