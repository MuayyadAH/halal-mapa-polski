import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/places/presentation/category_style.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

const Map<String, String> _plFolds = {
  'ą': 'a',
  'ć': 'c',
  'ę': 'e',
  'ł': 'l',
  'ń': 'n',
  'ó': 'o',
  'ś': 's',
  'ż': 'z',
  'ź': 'z',
};

/// Lowercase + strip Polish diacritics, for accent- AND case-insensitive
/// matching (003-map-screen FR-017). "Łazienki" → "lazienki".
String foldPl(String input) {
  final lower = input.toLowerCase();
  final sb = StringBuffer();
  for (final ch in lower.split('')) {
    sb.write(_plFolds[ch] ?? ch);
  }
  return sb.toString();
}

/// True when [query] (folded) is a substring of the place's folded name,
/// category label, or comment. Empty query → false. Used by the Map search
/// overlay (full dataset) and the Lista inline filter (FR-017/FR-019).
bool matchesQuery(Place place, String query, AppLocalizations l10n) {
  final q = foldPl(query.trim());
  if (q.isEmpty) return false;
  final hay = StringBuffer()
    ..write(foldPl(place.name))
    ..write(' ')
    ..write(foldPl(place.category.label(l10n)));
  final comment = place.comment;
  if (comment != null && comment.isNotEmpty) {
    hay
      ..write(' ')
      ..write(foldPl(comment));
  }
  return hay.toString().contains(q);
}
