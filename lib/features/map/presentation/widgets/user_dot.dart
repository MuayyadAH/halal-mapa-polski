import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';

/// The user-location dot (design "User location"): a 20dp blue dot with a white
/// border, sitting inside a soft translucent-blue halo.
class UserDot extends StatelessWidget {
  const UserDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: HmpColors.userDotHalo,
      ),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: HmpColors.userDot,
          border: Border.all(color: Colors.white, width: 3.5),
        ),
      ),
    );
  }
}
