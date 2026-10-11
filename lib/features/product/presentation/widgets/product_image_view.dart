import 'package:flutter/material.dart';

import '../../../../core/widgets/app_network_image.dart';

/// Product artwork may be a bundled placeholder or a URL from the API.
class ProductImageView extends StatelessWidget {
  const ProductImageView({
    super.key,
    required this.source,
    this.fit = BoxFit.contain,
    this.wordmarkPlaceholder = false,
  });

  final String source;
  final BoxFit fit;

  /// Shows the sweeping brand wordmark while a remote photo loads.
  final bool wordmarkPlaceholder;

  @override
  Widget build(BuildContext context) => source.startsWith('assets/')
      ? Image.asset(source, fit: fit)
      : AppNetworkImage(
          url: source,
          fit: fit,
          radius: 0,
          wordmarkPlaceholder: wordmarkPlaceholder,
          wordmarkSize: 24,
        );
}
