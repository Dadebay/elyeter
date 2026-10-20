import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final indicatorColor =
        color ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.white
            : AppColors.primary);

    return SizedBox.square(
      dimension: size,
      child: FittedBox(
        fit: BoxFit.contain,
        child: CupertinoActivityIndicator(radius: 12, color: indicatorColor),
      ),
    );
  }
}
