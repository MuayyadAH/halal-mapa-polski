import 'package:halal_map_polskie/core/links/external_link_launcher.dart';

/// Test double for [ExternalLinkLauncher]: records every opened URI and returns
/// a programmable result so widget tests can assert which links were launched
/// and exercise the graceful-failure path (004-profile-screen).
class FakeExternalLinkLauncher implements ExternalLinkLauncher {
  FakeExternalLinkLauncher({this.result = true});

  /// The value [open] returns (set false to simulate a launch failure).
  bool result;

  /// URIs passed to [open], in call order.
  final List<Uri> opened = <Uri>[];

  Uri? get lastOpened => opened.isEmpty ? null : opened.last;

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return result;
  }
}
