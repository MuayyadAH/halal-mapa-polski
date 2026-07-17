/// Compile-time environment values. Pass via `--dart-define` on `flutter run`/`build`.
/// See README → "Environment variables" for the canonical key list.
abstract final class Env {
  static const mapStyleUrlLight = String.fromEnvironment(
    'MAP_STYLE_URL_LIGHT',
    defaultValue: 'asset://assets/map_styles/halalmap-light.json',
  );
  static const mapStyleUrlDark = String.fromEnvironment(
    'MAP_STYLE_URL_DARK',
    defaultValue: 'asset://assets/map_styles/halalmap-dark.json',
  );

  /// MapTiler tiles key — injected at runtime via
  /// `--dart-define=MAP_TILES_KEY=...`. NEVER committed (constitution §2).
  /// Substituted into the `{key}` placeholder of the custom warm style JSON.
  static const mapTilesKey = String.fromEnvironment('MAP_TILES_KEY');

  static bool get hasMapTilesKey => mapTilesKey.isNotEmpty;

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static bool get crashReportingEnabled => sentryDsn.isNotEmpty;

  // Profile external destinations (004-profile-screen). Placeholder values for
  // v1 — overridable via `--dart-define` once real URLs exist (no screen change).
  // The notify button and both "Suggest a place" controls share [suggestFormUrl].
  static const suggestFormUrl = String.fromEnvironment(
    'SUGGEST_FORM_URL',
    defaultValue: 'https://forms.gle/REPLACE-suggest-place',
  );
  static const websiteUrl = String.fromEnvironment(
    'WEBSITE_URL',
    defaultValue: 'https://example.pl',
  );
  static const privacyUrl = String.fromEnvironment(
    'PRIVACY_URL',
    defaultValue: 'https://example.pl/privacy',
  );
  static const termsUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue: 'https://example.pl/terms',
  );

  const Env._();
}
