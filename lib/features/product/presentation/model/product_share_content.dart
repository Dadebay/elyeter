import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';

/// A product summary with an app link using the public numeric product ID.
ShareParams productShareContent({
  required Product product,
  required AppLocalizations l10n,
  ProductVariant? variant,
  String? imageUrl,
  Rect? origin,
}) {
  String clean(String value) => value.replaceAll(RegExp(r'\s+'), ' ').trim();
  String money(num value) => CurrencyFormatter.format(
    value,
    locale: l10n.localeName.startsWith('ru') ? 'ru' : 'en',
    decimals: value % 1 == 0 ? 0 : 2,
  );

  final name = clean(product.name);
  final photo = (imageUrl ?? product.mainImage)?.trim();
  final price = variant?.price ?? product.price;
  final oldPrice = variant == null ? product.oldPrice : variant.oldPrice;
  final sku = clean(variant?.sku ?? '').isNotEmpty
      ? clean(variant!.sku)
      : clean(product.sku);
  final link = Uri(
    scheme: 'elyeter',
    host: 'app',
    path: '/product/${product.id}',
    queryParameters: variant == null ? null : {'variant': '${variant.id}'},
  );
  final text = [
    '🛍️ Elýeter',
    '',
    name,
    '',
    '${l10n.productSharePrice}: ${money(price)}',
    if (oldPrice != null && oldPrice > price)
      '${l10n.productRegularPrice}: ${money(oldPrice)} · '
          '${l10n.productDiscountPercent(((oldPrice - price) / oldPrice * 100).round())}',
    if (variant != null)
      for (final option in variant.attributes)
        if (clean(option.name).isNotEmpty && clean(option.value).isNotEmpty)
          '${clean(option.name)}: ${clean(option.value)}',
    if (sku.isNotEmpty) '${l10n.productArticle} $sku',
    if (photo != null && photo.isNotEmpty) ...[
      '',
      '${l10n.productSharePhoto}:',
      photo,
    ],
    '',
    '${l10n.productShareOpen}:',
    link.toString(),
  ].join('\n');

  return ShareParams(
    title: 'Elýeter · $name',
    subject: 'Elýeter · $name',
    text: text,
    sharePositionOrigin: origin,
  );
}
