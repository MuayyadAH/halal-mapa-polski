import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionsServiceProvider =
    Provider<PermissionsService>((_) => const PermissionsService());

/// Privacy defaults are encoded in `constitution.md` §1.7:
/// location is only-while-using; precise location only when user opts in.
class PermissionsService {
  const PermissionsService();

  Future<bool> requestLocationWhenInUse() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted || status.isLimited;
  }

  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestPhotos() async {
    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }

  Future<bool> requestNotifications() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}
