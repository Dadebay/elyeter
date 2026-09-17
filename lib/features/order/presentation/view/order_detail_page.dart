import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../model/order_detail_data.dart';
import '../widgets/order_card.dart';
import '../widgets/order_info_row.dart';
import '../widgets/order_products_strip.dart';
import '../widgets/order_progress_timeline.dart';
import '../widgets/order_total_card.dart';
import 'order_placeholder_data.dart';

/// One order, end to end: where it has got to, what is in it, where it is
/// going and what it cost.
class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, this.orderId});

  /// Null opens the order the customer has just placed.
  final String? orderId;

  @override
  Widget build(BuildContext context) {
    final order = OrderPlaceholderData.active;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: AppBackButton.leadingWidth,
        leading: const AppBackButton.appBarLeading(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          AppSpacing.xxxl,
        ),
        children: [
          _Header(order: order),
          const SizedBox(height: AppSpacing.md),
          _Progress(order: order),
          const SizedBox(height: AppSpacing.md),
          _Products(order: order),
          const SizedBox(height: AppSpacing.md),
          _Details(order: order),
          const SizedBox(height: AppSpacing.md),
          OrderTotalCard(order: order),
        ],
      ),
    );
  }
}

/// Title, order number and the three things that can be done about it.
class _Header extends StatelessWidget {
  const _Header({required this.order});

  final OrderDetailData order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return OrderCard(
      child: Column(
        children: [
          Text(
            l10n.orderActiveTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.orderNumber(order.number),
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _Action(
                  icon: AppAssets.iconRepeatOrder,
                  label: l10n.orderRepeat,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Action(
                  icon: AppAssets.iconBubbleQuestion,
                  label: l10n.orderQuestions,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Action(
                  icon: AppAssets.iconCircleX,
                  label: l10n.orderCancel,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One of the header's three buttons.
class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, this.onTap});

  /// Path to an SVG in `assets/icons`; see [OrderInfoRow.icon].
  final String icon;

  final String label;

  /// Repeat, support and cancellation do not exist yet, so the three are
  /// drawn as the design has them and handed an empty callback — pressed
  /// they acknowledge the touch and do nothing. Wire them at the call site.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.grey100,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            children: [
              SvgPicture.asset(icon, width: 22, height: 22),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.textTheme.labelMedium?.copyWith(
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.order});

  final OrderDetailData order;

  @override
  Widget build(BuildContext context) {
    return OrderCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderCardHeader(title: context.l10n.orderProgress),
          const SizedBox(height: AppSpacing.lg),
          OrderProgressTimeline(stages: order.stages),
        ],
      ),
    );
  }
}

class _Products extends StatelessWidget {
  const _Products({required this.order});

  final OrderDetailData order;

  @override
  Widget build(BuildContext context) {
    return OrderCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderCardHeader(title: context.l10n.orderProducts, onTap: () {}),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            context.l10n.orderItemSummary(
              order.itemCount,
              CurrencyFormatter.format(order.productsTotal, decimals: 0),
            ),
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OrderProductsStrip(
            products: order.products,
            itemCount: order.itemCount,
          ),
        ],
      ),
    );
  }
}

/// Where it is going, who is collecting it, when it was placed and how it
/// was paid for.
class _Details extends StatelessWidget {
  const _Details({required this.order});

  final OrderDetailData order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();

    return OrderCard(
      child: Column(
        children: [
          OrderInfoRow(
            icon: AppAssets.iconPinLocation,
            label: l10n.orderPickupPoint,
            value: order.pickupPoint,
            onEdit: () {},
          ),
          const _Gap(),
          OrderInfoRow(
            icon: AppAssets.iconUser,
            label: l10n.orderRecipient,
            value: order.recipientName,
            secondary: order.recipientPhone,
            onEdit: () {},
          ),
          const _Gap(),
          OrderInfoRow(
            icon: AppAssets.iconCalendar,
            label: l10n.orderTime,
            value: DateFormat(
              "MMMM d, y 'at' HH:mm",
              locale,
            ).format(order.placedAt),
          ),
          const _Gap(),
          OrderInfoRow(
            icon: AppAssets.iconWallet,
            label: l10n.orderPayment,
            value: l10n.orderPaymentCard,
          ),
        ],
      ),
    );
  }
}

/// The hairline between two facts.
class _Gap extends StatelessWidget {
  const _Gap();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Divider(height: 1, color: AppColors.grey100),
  );
}
