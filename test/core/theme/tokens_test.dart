import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';

void main() {
  group('HmpColors', () {
    test('cocoa-950 matches design handoff hex', () {
      expect(HmpColors.cocoa950, const Color(0xFF1A100E));
    });

    test('functional verify token matches design', () {
      expect(HmpColors.verify, const Color(0xFF5A7A55));
    });

    test('category restaurant tint matches design', () {
      expect(HmpColors.catRest, const Color(0xFF8A4A36));
    });
  });

  group('HmpRadii', () {
    test('card radius matches design system', () {
      expect(HmpRadii.card, 22.0);
    });

    test('pill radius matches design system', () {
      expect(HmpRadii.pill, 999.0);
    });
  });
}
