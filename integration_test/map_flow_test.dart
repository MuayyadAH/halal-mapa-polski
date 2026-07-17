import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// End-to-end Map flow on a real device/emulator with the real MapLibre engine.
///
/// Run with the tiles key:
///   flutter test integration_test/map_flow_test.dart \
///     --dart-define-from-file=dart_define.local.json
///
/// US1 scaffold — skipped headless (needs a device + tiles). Expanded across
/// US2–US7 to cover: location → select pin↔card → search-fly → toggle Lista
/// (stagger) → filter + sort → Navigate hand-off (spec TC-1…TC-23).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Map tab renders the warm basemap and category pins',
    (tester) async {
      // TODO(003-map-screen US1+): pump the app, navigate to the Mapa tab,
      // and assert the MapLibre surface + pins render; then extend per story.
    },
    skip: true,
  );
}
