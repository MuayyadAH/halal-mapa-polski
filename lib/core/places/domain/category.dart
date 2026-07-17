/// Canonical halal-place taxonomy (Architecture domain model §Place.category).
///
/// Shared across features (Home today, Map next). The launch Google Sheet
/// provides only four of these (masjid, shop, restaurant, cemetery); grocer
/// and butcher exist in the model for forward-compatibility but are not yet
/// present in the data. See specs/002-home-screen.
enum Category {
  restaurant,
  masjid,
  grocer,
  butcher,
  shop,
  cemetery;

  /// Parses the Polish category string used by the Google Sheet.
  /// Returns null for unknown values so a malformed row can be skipped
  /// rather than crashing the whole load.
  static Category? parsePolish(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'meczet':
      case 'meczety':
        return Category.masjid;
      case 'restauracja':
      case 'restauracje':
        return Category.restaurant;
      case 'cmentarz':
      case 'cmentarze':
        return Category.cemetery;
      case 'sklep':
      case 'sklepy':
        return Category.shop;
      case 'sklep spożywczy':
      case 'spożywczy':
        return Category.grocer;
      case 'rzeźnik':
      case 'mięso':
        return Category.butcher;
      default:
        return null;
    }
  }
}
