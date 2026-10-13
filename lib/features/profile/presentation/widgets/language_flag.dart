import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';

/// The flag for a supported app language, cropped to a circle.
class LanguageFlag extends StatelessWidget {
  const LanguageFlag({
    super.key,
    required this.languageCode,
    required this.semanticsLabel,
  });

  final String languageCode;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final flagCode = switch (languageCode) {
      'tk' => 'tm',
      'ru' => 'ru',
      _ => 'gb',
    };

    return Container(
      width: 34,
      height: 34,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.grey300),
      ),
      child: ClipOval(
        child: SvgPicture.asset(
          'assets/images/flags/$flagCode.svg',
          fit: BoxFit.cover,
          semanticsLabel: semanticsLabel,
        ),
      ),
    );
  }
}
