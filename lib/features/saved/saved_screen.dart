import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:halal_map_polskie/core/location/distance.dart';
import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/places/presentation/category_style.dart';
import 'package:halal_map_polskie/core/routing/app_router.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/features/home/presentation/state/bookmarks_notifier.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/geometric_motif.dart';
import 'package:halal_map_polskie/shared/widgets/pressable_scale.dart';

/// The Zapisane tab (design "Saved", guest-first — no sign-in CTA). Lists the
/// bookmarked places from the shared guest bookmark set with category filter
/// chips (+ counts), nearest-first when located, and an unsave toggle per row.
/// Rows push the in-app place detail.
class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  Category? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final placesAsync = ref.watch(placesProvider);
    final bookmarks = ref.watch(bookmarksProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [HmpColors.parchment, HmpColors.homeBgGradientEnd],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: placesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: HmpColors.cocoa800),
            ),
            error: (_, __) => _EmptyState(l10n: l10n),
            data: (places) {
              final saved = places
                  .where((p) => bookmarks.contains(p.id))
                  .toList(growable: false);
              if (saved.isEmpty) return _EmptyState(l10n: l10n);
              return _SavedList(
                saved: saved,
                filter: _filter,
                onFilter: (c) => setState(() => _filter = c),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SavedList extends ConsumerWidget {
  const _SavedList({
    required this.saved,
    required this.filter,
    required this.onFilter,
  });

  final List<Place> saved;
  final Category? filter;
  final ValueChanged<Category?> onFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(userLatLngProvider);

    // Categories present among saved places, in enum order, with counts.
    final counts = <Category, int>{};
    for (final p in saved) {
      counts[p.category] = (counts[p.category] ?? 0) + 1;
    }

    final visible = (filter == null
            ? saved
            : saved.where((p) => p.category == filter))
        .toList(growable: false)
      ..sort((a, b) {
        if (user != null) {
          final da = distanceMeters(user.lat, user.lng, a.lat, a.lng);
          final db = distanceMeters(user.lat, user.lng, b.lat, b.lng);
          return da.compareTo(db);
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              HmpSpacing.screenH,
              18,
              HmpSpacing.screenH,
              4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tabSaved,
                  style: const TextStyle(
                    fontFamily: HmpFonts.display,
                    fontWeight: FontWeight.w500,
                    fontSize: HmpType.homeH1,
                    height: 1.1,
                    color: HmpColors.cocoa900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.mapPlacesCount(saved.length),
                  style: const TextStyle(
                    fontFamily: HmpFonts.ui,
                    fontSize: 13,
                    color: HmpColors.cocoa700,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: HmpSpacing.screenH,
                vertical: 6,
              ),
              children: [
                _FilterChip(
                  label: l10n.chipAll,
                  count: saved.length,
                  active: filter == null,
                  onTap: () => onFilter(null),
                ),
                for (final entry in counts.entries) ...[
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: entry.key.label(l10n),
                    count: entry.value,
                    active: filter == entry.key,
                    color: entry.key.color,
                    onTap: () =>
                        onFilter(filter == entry.key ? null : entry.key),
                  ),
                ],
              ],
            ),
          ),
        ),
        SliverList.separated(
          itemCount: visible.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            thickness: 1,
            indent: HmpSpacing.screenH,
            endIndent: HmpSpacing.screenH,
            color: Color(0x14261713),
          ),
          itemBuilder: (context, i) => _SavedRow(place: visible[i]),
        ),
        const SliverPadding(
          padding: EdgeInsets.only(bottom: HmpSpacing.tabBarH + 12),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
    this.color,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      semanticLabel: '$label ($count)',
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? HmpColors.cocoa800 : HmpColors.cream100,
          borderRadius: BorderRadius.circular(HmpRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: HmpFonts.ui,
                fontWeight: FontWeight.w600,
                fontSize: HmpType.chip,
                color: active ? HmpColors.cream50 : HmpColors.cocoa800,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: TextStyle(
                fontFamily: HmpFonts.mono,
                fontSize: 11,
                color: active ? HmpColors.sand300 : HmpColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedRow extends ConsumerWidget {
  const _SavedRow({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(userLatLngProvider);
    final distance = user == null
        ? null
        : formatDistance(
            distanceMeters(user.lat, user.lng, place.lat, place.lng),
            Localizations.localeOf(context).toString(),
          );

    final meta = [
      place.category.label(l10n),
      if (place.comment != null && place.comment!.isNotEmpty) place.comment!,
    ].join(' · ');

    return PressableScale(
      semanticLabel: place.name,
      onTap: () => context.push(placeDetailLocation(place.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HmpSpacing.screenH,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [place.category.color, HmpColors.cocoa800],
                ),
              ),
              child: Text(
                place.category.glyph,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: HmpFonts.ui,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: HmpColors.cocoa900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: HmpFonts.ui,
                      fontSize: 11.5,
                      color: HmpColors.cocoa700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (distance != null)
              Text(
                distance,
                style: const TextStyle(
                  fontFamily: HmpFonts.display,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: HmpColors.cocoa800,
                ),
              ),
            const SizedBox(width: 6),
            _UnsaveButton(placeId: place.id),
          ],
        ),
      ),
    );
  }
}

class _UnsaveButton extends ConsumerWidget {
  const _UnsaveButton({required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.bookmarkRemove,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(bookmarksProvider.notifier).toggle(placeId);
        },
        child: const SizedBox(
          width: HmpSpacing.minTapTarget,
          height: HmpSpacing.minTapTarget,
          child: Icon(Icons.bookmark, size: 20, color: HmpColors.cocoa800),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GeometricMotif(
          color: HmpColors.cocoa900.withValues(alpha: 0.04),
          cell: 96,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: HmpColors.cream100,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.bookmark_border,
                  size: 28,
                  color: HmpColors.umber600,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.savedEmptyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: HmpFonts.display,
                  fontWeight: FontWeight.w500,
                  fontSize: 22,
                  color: HmpColors.cocoa900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.savedEmptySub,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: HmpFonts.ui,
                  fontSize: 14,
                  height: 1.45,
                  color: HmpColors.muted,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () => context.go('/map'),
                style: FilledButton.styleFrom(
                  backgroundColor: HmpColors.cocoa800,
                  foregroundColor: HmpColors.cream50,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: HmpSpacing.buttonV,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(HmpRadii.button),
                  ),
                ),
                child: Text(
                  l10n.miniMapOpen,
                  style: const TextStyle(
                    fontFamily: HmpFonts.ui,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
