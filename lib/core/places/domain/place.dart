import 'category.dart';

/// A halal-relevant location. v1 fields mirror the launch Google Sheet
/// (name, category, coordinates, optional comment/mawaqit). Shared by Home
/// and the future Map feature. See specs/002-home-screen/data-model.md.
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.lat,
    required this.lng,
    this.comment,
    this.mawaqitLink,
  });

  /// Stable id derived from name + coordinates (the sheet has no id column).
  factory Place.fromParts({
    required String name,
    required Category category,
    required double lat,
    required double lng,
    String? comment,
    String? mawaqitLink,
  }) {
    return Place(
      id: '$name|$lat|$lng',
      name: name,
      category: category,
      lat: lat,
      lng: lng,
      comment: comment,
      mawaqitLink: mawaqitLink,
    );
  }

  final String id;
  final String name;
  final Category category;
  final double lat;
  final double lng;
  final String? comment;
  final String? mawaqitLink;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Place && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
