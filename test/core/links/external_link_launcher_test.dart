import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/env/env.dart';
import 'package:halal_map_polskie/core/links/external_link_launcher.dart';

import '../../support/fake_external_link_launcher.dart';

void main() {
  group('Env external destinations', () {
    test('all profile link URLs are non-empty and parseable', () {
      for (final url in [
        Env.suggestFormUrl,
        Env.websiteUrl,
        Env.privacyUrl,
        Env.termsUrl,
      ]) {
        expect(url, isNotEmpty);
        final uri = Uri.parse(url);
        expect(uri.hasScheme, isTrue, reason: '$url should have a scheme');
        expect(uri.scheme, anyOf('http', 'https'));
      }
    });

    test('AppInfo.version is the launch version string', () {
      expect(AppInfo.version, '1.0.0');
    });
  });

  group('FakeExternalLinkLauncher', () {
    test('records opened URIs in order and returns the programmed result',
        () async {
      final fake = FakeExternalLinkLauncher();
      final a = Uri.parse(Env.suggestFormUrl);
      final b = Uri.parse(Env.websiteUrl);

      expect(await fake.open(a), isTrue);
      expect(await fake.open(b), isTrue);

      expect(fake.opened, [a, b]);
      expect(fake.lastOpened, b);
    });

    test('returns false when configured to simulate a launch failure',
        () async {
      final fake = FakeExternalLinkLauncher(result: false);
      expect(await fake.open(Uri.parse(Env.suggestFormUrl)), isFalse);
      expect(fake.opened, hasLength(1));
    });
  });
}
