import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens external URLs (suggest/notify form, website, privacy, terms) for the
/// guest Profile (004-profile-screen FR-014/FR-016). Mirrors the shared
/// `MapsLauncher` pattern so URL launching is testable and consistent.
/// See contracts/external_link_launcher.md.
abstract class ExternalLinkLauncher {
  /// Opens [uri] in the external browser/app. Returns true on success, false if
  /// no handler could open it. Never throws to the caller — the tapped control
  /// shows a localized message on a false result (Constitution §1.3).
  Future<bool> open(Uri uri);
}

class UrlExternalLinkLauncher implements ExternalLinkLauncher {
  const UrlExternalLinkLauncher();

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false; // graceful failure — no crash, no dead-end (FR-014)
    }
  }
}

final externalLinkLauncherProvider =
    Provider<ExternalLinkLauncher>((ref) => const UrlExternalLinkLauncher());

/// App identity shown on the Profile screens. v1 uses a single constant (no
/// `package_info_plus` dependency); wiring to package metadata is deferred
/// (spec §5). Shown verbatim per the design ("v 1.0.0").
abstract final class AppInfo {
  static const version = '1.0.0';

  const AppInfo._();
}
