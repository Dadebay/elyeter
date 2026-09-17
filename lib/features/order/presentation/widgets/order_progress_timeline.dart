import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../model/order_detail_data.dart';

/// The stages of the order down a rail: reached ones in the brand colour,
/// the rest greyed out as what is still to come.
class OrderProgressTimeline extends StatelessWidget {
  const OrderProgressTimeline({super.key, required this.stages});

  /// Width of the rail column — the ring plus the room around it.
  static const _railWidth = 28.0;

  /// The stage markers are rings, not filled dots: an outline reads as a
  /// stop on a route, a filled disc as a bullet point.
  static const _ringSize = 18.0;
  static const _ringStroke = 2.5;

  /// Halo around the stage the order has just reached.
  static const _haloSize = 28.0;

  static const _connectorWidth = 3.0;

  /// Leaves the rail long enough for the connector to read as a line rather
  /// than as a gap between two dots.
  static const _rowGap = AppSpacing.xl;

  final List<OrderStageEntry> stages;

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex();

    return Column(
      children: [
        for (var i = 0; i < stages.length; i++)
          _Row(
            entry: stages[i],
            isCurrent: i == current,
            isLast: i == stages.length - 1,
            // The connector belongs to the gap below a dot, so the last row
            // ends the rail instead of trailing a line into nothing.
            hasConnector: i < stages.length - 1,
            // A connector is only lit when the stage after it has also been
            // reached; otherwise the rail visibly stops at the current step.
            connectorDone: i < stages.length - 1 && stages[i + 1].done,
          ),
      ],
    );
  }

  /// The last stage the order has reached.
  int _currentIndex() {
    var current = -1;
    for (var i = 0; i < stages.length; i++) {
      if (stages[i].done) current = i;
    }
    return current;
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.entry,
    required this.isCurrent,
    required this.isLast,
    required this.hasConnector,
    required this.connectorDone,
  });

  final OrderStageEntry entry;
  final bool isCurrent;

  /// The end of the route carries a dot inside its ring — the destination
  /// rather than one more stop on the way.
  final bool isLast;

  final bool hasConnector;
  final bool connectorDone;

  @override
  Widget build(BuildContext context) {
    final done = entry.done;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: OrderProgressTimeline._railWidth,
            child: Column(
              children: [
                _Ring(done: done, isCurrent: isCurrent, isLast: isLast),
                if (hasConnector)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: OrderProgressTimeline._connectorWidth,
                        // Stretches to whatever the row beside it needs, so
                        // a two-line label does not break the rail.
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: connectorDone
                              ? AppColors.primary
                              : AppColors.grey300,
                          borderRadius: BorderRadius.circular(
                            OrderProgressTimeline._connectorWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: hasConnector ? OrderProgressTimeline._rowGap : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat(
                      'MMMM d, HH:mm',
                      Localizations.localeOf(context).toString(),
                    ).format(entry.at),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _label(context, entry.stage),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: done ? AppColors.black : AppColors.grey500,
                      fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // The badge marks where the order stands right now. It centres on
          // the label block, not on the whole row — the row also carries the
          // gap that holds the connector, which would pull it downwards.
          if (isCurrent)
            Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.sm,
                bottom: hasConnector ? OrderProgressTimeline._rowGap : 0,
              ),
              child: const Center(
                widthFactor: 1,
                child: _CurrentBadge(),
              ),
            ),
        ],
      ),
    );
  }

  static String _label(BuildContext context, OrderStage stage) {
    final l10n = context.l10n;
    return switch (stage) {
      OrderStage.placed => l10n.orderStepPlaced,
      OrderStage.chinaWarehouse => l10n.orderStepWarehouse,
      OrderStage.shipped => l10n.orderStepShipped,
      OrderStage.arrived => l10n.orderStepArrived,
      OrderStage.delivered => l10n.orderStepDelivered,
    };
  }
}

/// A hollow ring on the rail: brand-coloured once the stage is reached,
/// grey while it is still ahead.
class _Ring extends StatelessWidget {
  const _Ring({required this.done, required this.isCurrent, required this.isLast});

  final bool done;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.primary : AppColors.grey300;

    final ring = Container(
      width: OrderProgressTimeline._ringSize,
      height: OrderProgressTimeline._ringSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: OrderProgressTimeline._ringStroke),
      ),
      child: isLast
          ? DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const SizedBox.square(dimension: 6),
            )
          : null,
    );

    return Container(
      // The halo keeps the rail's spacing whether or not it is drawn, so the
      // rings stay on one vertical line.
      width: OrderProgressTimeline._haloSize,
      height: OrderProgressTimeline._haloSize,
      alignment: Alignment.center,
      decoration: isCurrent
          ? const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle)
          : null,
      child: ring,
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    decoration: const BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.check_rounded, size: 14, color: AppColors.white),
  );
}
