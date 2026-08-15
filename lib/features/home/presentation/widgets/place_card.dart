import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/places/presentation/category_style.dart';
import 'package:halal_map_polskie/core/routing/app_router.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/pressable_scale.dart';

import '../state/bookmarks_notifier.dart';

/// Featured place card (handoff §4.5, adapted to v1 data). Shows a category-
/// tinted gradient placeholder, a category badge, a bookmark toggle, and the
/// name. No city / open-status / rating / distance (FR-012/FR-023). Tapping the
/// body opens the in-app place detail; tapping the bookmark toggles
/// the saved state (FR-014).
class PlaceCard extends ConsumerWidget {
  const PlaceCard({super.key, required this.place});

  final Place place;

  static const double width = 230;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bookmarked = ref.watch(
      bookmarksProvider.select((s) => s.contains(place.id)),
    );

    return PressableScale(
      semanticLabel: place.name,
      onTap: () => context.push(placeDetailLocation(place.id)),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(HmpRadii.cardCompact),
          boxShadow: HmpShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageArea(l10n, bookmarked, () {
              ref.read(bookmarksProvider.notifier).toggle(place.id);
            }),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                place.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: HmpFonts.ui,
                  fontWeight: FontWeight.w700,
                  fontSize: HmpType.cardTitle,
                  color: HmpColors.cocoa900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageArea(
    AppLocalizations l10n,
    bool bookmarked,
    VoidCallback onToggleBookmark,
  ) {
    return SizedBox(
      height: 116,
      width: double.infinity,
      child: Stack(
        children: [
          // Gradient placeholder for the eventual photo (per-card accent).
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [place.category.color, HmpColors.cocoa800],
                ),
              ),
            ),
          ),
          // Category badge (glass pill) — top-start.
          PositionedDirectional(
            top: 10,
            start: 10,
            child: _CategoryBadge(
              text: '${place.category.glyph} ${place.category.label(l10n)}',
            ),
          ),
          // Bookmark toggle — top-end. Its own gesture wins over the card tap.
          PositionedDirectional(
            top: 8,
            end: 8,
            child: _BookmarkButton(
              bookmarked: bookmarked,
              onTap: onToggleBookmark,
              addLabel: l10n.bookmarkAdd,
              removeLabel: l10n.bookmarkRemove,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x8C1C201D),
        borderRadius: BorderRadius.circular(HmpRadii.iconSm),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: HmpFonts.ui,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          color: HmpColors.cream50,
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({
    required this.bookmarked,
    required this.onTap,
    required this.addLabel,
    required this.removeLabel,
  });

  final bool bookmarked;
  final VoidCallback onTap;
  final String addLabel;
  final String removeLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: bookmarked,
      label: bookmarked ? removeLabel : addLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // 44px hit area around a 28px visual circle (WCAG 2.1 AA).
        child: SizedBox(
          width: HmpSpacing.minTapTarget,
          height: HmpSpacing.minTapTarget,
          child: Center(
            child: AnimatedScale(
              scale: bookmarked ? 1.0 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 16,
                  color: HmpColors.cocoa800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
