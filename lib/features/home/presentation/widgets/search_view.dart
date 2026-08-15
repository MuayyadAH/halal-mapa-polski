import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/places/presentation/category_style.dart';
import 'package:halal_map_polskie/core/routing/app_router.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/fade_rise_in.dart';
import 'package:halal_map_polskie/shared/widgets/pressable_scale.dart';

import '../state/home_notifier.dart';
import '../state/search_notifier.dart';
import 'home_header.dart';

/// Search-active overlay (handoff Screen A, adapted to guest v1 + real data):
/// a dimmed header peek, a focused field with native caret, and a suggestions
/// panel with three groups — Ostatnie (recent), Podpowiedzi (live place
/// matches), Kategorie (category shortcuts). Dock stays mounted (this renders
/// inside the Home tab body). Reduced motion disables the entrance animation.
class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView>
    with TickerProviderStateMixin, EntranceController<SearchView> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  Duration get entranceDuration => const Duration(milliseconds: 520);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _close() {
    _focusNode.unfocus();
    ref.read(searchActiveProvider.notifier).close();
  }

  void _refill(String query) {
    _controller
      ..text = query
      ..selection = TextSelection.collapsed(offset: query.length);
    ref.read(searchQueryProvider.notifier).set(query);
    _focusNode.requestFocus();
  }

  void _openPlace(Place place) {
    ref.read(recentSearchesProvider.notifier).add(_controller.text);
    context.push(placeDetailLocation(place.id));
    _close();
  }

  void _selectCategory(Category category) {
    ref.read(selectedCategoryProvider.notifier).select(category);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recents = ref.watch(recentSearchesProvider);
    final suggestions = ref.watch(searchSuggestionsProvider);
    final categories = ref.watch(availableCategoriesProvider);
    final query = ref.watch(searchQueryProvider);

    // Build the ordered list of animated rows for the stagger.
    var rowIndex = 0;
    Widget staggered(Widget child) {
      final i = rowIndex++;
      final start = (i * 0.06).clamp(0.0, 0.6);
      return FadeRiseIn(
        controller: entrance,
        start: start,
        end: (start + 0.4).clamp(0.0, 1.0),
        child: child,
      );
    }

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header peek — dimmed, non-interactive.
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 44, 0, 12),
            child: IgnorePointer(
              child: Opacity(opacity: 0.4, child: HomeHeader()),
            ),
          ),
          // 2. Active search field.
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: HmpSpacing.screenH,
              vertical: 8,
            ),
            child: _ActiveField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (v) => ref.read(searchQueryProvider.notifier).set(v),
              onSubmitted: (v) =>
                  ref.read(recentSearchesProvider.notifier).add(v),
              onCancel: _close,
            ),
          ),
          // 3. Suggestions panel.
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xF7FBF8EF),
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 6, 20, 24),
                children: [
                  if (recents.isNotEmpty) ...[
                    staggered(_GroupLabel(l10n.searchGroupRecent)),
                    for (final q in recents)
                      staggered(
                        _RecentRow(
                          query: q,
                          refillLabel: l10n.searchRefill,
                          onTap: () => _refill(q),
                        ),
                      ),
                  ],
                  staggered(_GroupLabel(l10n.searchGroupSuggestions)),
                  if (query.trim().isNotEmpty && suggestions.isEmpty)
                    staggered(_EmptyResults(l10n.searchNoResults))
                  else
                    for (var i = 0; i < suggestions.length; i++)
                      staggered(
                        _SuggestionRow(
                          place: suggestions[i],
                          showDivider: i > 0,
                          onTap: () => _openPlace(suggestions[i]),
                        ),
                      ),
                  staggered(_GroupLabel(l10n.searchGroupCategories)),
                  staggered(
                    _CategoryWrap(
                      categories: categories,
                      onSelected: _selectCategory,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveField extends StatelessWidget {
  const _ActiveField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onCancel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HmpRadii.search),
        border: Border.all(color: HmpColors.cocoa800, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x38261713),
            blurRadius: 28,
            offset: Offset(0, 12),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: HmpColors.cocoa800),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              cursorColor: HmpColors.cocoa800,
              cursorWidth: 2,
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontSize: 15,
                color: HmpColors.cocoa900,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: l10n.homeSearchHint,
                hintStyle: const TextStyle(
                  fontFamily: HmpFonts.ui,
                  fontSize: 15,
                  color: HmpColors.muted,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: onCancel,
            child: Text(
              l10n.searchCancel,
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: HmpColors.cocoa800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: HmpFonts.ui,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.4,
          color: HmpColors.umber600,
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({
    required this.query,
    required this.refillLabel,
    required this.onTap,
  });

  final String query;
  final String refillLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0x0F261713),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.history, size: 16, color: HmpColors.muted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                query,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: HmpFonts.ui,
                  fontSize: 14,
                  color: HmpColors.cocoa900,
                ),
              ),
            ),
            Semantics(
              label: refillLabel,
              child: Transform.rotate(
                angle: -math.pi / 4,
                child: const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: HmpColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    required this.place,
    required this.showDivider,
    required this.onTap,
  });

  final Place place;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0x0D261713)),
        PressableScale(
          onTap: onTap,
          semanticLabel: place.name,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: place.category.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    place.category.glyph,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
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
                      const SizedBox(height: 2),
                      Text(
                        place.category.label(l10n),
                        style: const TextStyle(
                          fontFamily: HmpFonts.ui,
                          fontSize: 11,
                          color: HmpColors.cocoa700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryWrap extends StatelessWidget {
  const _CategoryWrap({required this.categories, required this.onSelected});

  final List<Category> categories;
  final ValueChanged<Category> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in categories)
            PressableScale(
              onTap: () => onSelected(c),
              semanticLabel: c.label(l10n),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x0D261713),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(c.glyph, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      c.label(l10n),
                      style: const TextStyle(
                        fontFamily: HmpFonts.ui,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: HmpColors.cocoa900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: HmpFonts.ui,
          fontSize: 14,
          color: HmpColors.muted,
        ),
      ),
    );
  }
}
