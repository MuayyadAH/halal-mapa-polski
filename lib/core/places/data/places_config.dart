/// Configuration for the launch place data source (a public Google Sheet).
///
/// The sheet id is **not** a secret (the sheet is published read-only). It can
/// be overridden at build time with `--dart-define=PLACES_SHEET_ID=...`.
const String kPlacesSheetId = String.fromEnvironment(
  'PLACES_SHEET_ID',
  defaultValue: '1z2UpkDUv7VoDsCbzsBm1fXq7UODZe3iHXj2988G_dms',
);

/// CSV export endpoint for the published sheet (307-redirects to a signed URL;
/// `dio` follows redirects).
String placesCsvUrl([String sheetId = kPlacesSheetId]) =>
    'https://docs.google.com/spreadsheets/d/$sheetId/export?format=csv';
