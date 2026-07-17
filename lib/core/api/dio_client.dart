import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/env.dart';

/// Scaffold placeholder — not consumed by any feature yet. The first
/// backend-touching feature (likely Map for places, or Auth for sign-in)
/// will be its first reader.
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'accept': 'application/json'},
    ),
  );
});
