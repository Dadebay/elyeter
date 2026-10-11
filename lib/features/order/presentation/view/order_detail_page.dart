import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/pre_order.dart';
import '../../domain/repositories/pre_order_repository.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});
  final int orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<Result<PreOrder>> _future;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() => setState(
    () => _future = getIt<PreOrderRepository>().byId(widget.orderId),
  );

  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _cancelling = true);
    final result = await getIt<PreOrderRepository>().cancel(widget.orderId);
    if (!mounted) return;
    setState(() => _cancelling = false);
    if (result.isSuccess) {
      _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failureOrNull?.message ?? 'Could not cancel'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Order'),
      actions: [
        IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
      ],
    ),
    body: FutureBuilder<Result<PreOrder>>(
      future: _future,
      builder: (context, snapshot) {
        final order = snapshot.data?.dataOrNull;
        if (order == null) {
          return Center(
            child: snapshot.connectionState != ConnectionState.done
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: _refresh,
                    child: Text(
                      snapshot.data?.failureOrNull?.message ?? 'Retry',
                    ),
                  ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              order.number,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              order.status.value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.pushNamed(
                AppRoutes.orderTrack.name,
                pathParameters: {'id': order.id.toString()},
              ),
              icon: const Icon(Icons.map_outlined),
              label: const Text('Siparişi haritada takip et'),
            ),
            const SizedBox(height: 16),
            for (final item in order.items)
              ListTile(
                leading: item.image == null
                    ? const Icon(Icons.shopping_bag_outlined)
                    : Image.network(
                        item.image!,
                        width: 50,
                        height: 50,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.shopping_bag_outlined),
                      ),
                title: Text(item.name),
                subtitle: Text(
                  '${item.variant ?? ''} · ${item.quantity} × ${item.price.toStringAsFixed(2)} TMT',
                ),
                trailing: Text('${item.lineTotal.toStringAsFixed(2)} TMT'),
                onTap: item.productSlug == null
                    ? null
                    : () => context.pushNamed(
                        AppRoutes.productDetail.name,
                        pathParameters: {'id': item.productSlug!},
                      ),
              ),
            const Divider(),
            ListTile(
              title: const Text('Total'),
              trailing: Text(
                '${order.totalPrice.toStringAsFixed(2)} ${order.currency}',
              ),
            ),
            if (order.customerName != null)
              ListTile(
                title: const Text('Name'),
                subtitle: Text(order.customerName!),
              ),
            if (order.phone != null)
              ListTile(
                title: const Text('Phone'),
                subtitle: Text(order.phone!),
              ),
            if (order.address != null)
              ListTile(
                title: const Text('Address'),
                subtitle: Text(order.address!),
              ),
            if (order.comment != null)
              ListTile(
                title: const Text('Comment'),
                subtitle: Text(order.comment!),
              ),
            if (order.canCancel)
              FilledButton.tonal(
                onPressed: _cancelling ? null : _cancel,
                child: Text(_cancelling ? '…' : 'Cancel order'),
              ),
          ],
        );
      },
    ),
  );
}
