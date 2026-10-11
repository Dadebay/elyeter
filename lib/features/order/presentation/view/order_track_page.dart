import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/widgets/elyeter_map.dart';
import '../../domain/entities/pre_order.dart';
import '../../domain/repositories/pre_order_repository.dart';

/// An order-status map. The API has the saved delivery point and status, but
/// no courier position, route, or ETA. Do not invent those on this screen.
class OrderTrackPage extends StatefulWidget {
  const OrderTrackPage({super.key, required this.orderId});
  final int orderId;

  @override
  State<OrderTrackPage> createState() => _OrderTrackPageState();
}

class _OrderTrackPageState extends State<OrderTrackPage>
    with WidgetsBindingObserver {
  Timer? _refreshTimer;
  PreOrder? _order;
  String? _error;
  bool _loading = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _startPolling();
  }

  void _startPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _load(silent: true),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load(silent: true);
      _startPolling();
    } else {
      _refreshTimer?.cancel();
    }
  }

  Future<void> _load({bool silent = false}) async {
    if (_refreshing) return;
    _refreshing = true;
    if (!silent && mounted) setState(() => _loading = true);
    final result = await getIt<PreOrderRepository>().byId(widget.orderId);
    _refreshing = false;
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.dataOrNull case final order?) {
        _order = order;
        _error = null;
        if (order.status.isTerminal) _refreshTimer?.cancel();
      } else {
        _error = result.failureOrNull?.message ?? 'Sipariş alınamadı.';
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  static String _statusText(PreOrderStatus status) => switch (status) {
    PreOrderStatus.newOrder => 'Onay bekliyor',
    PreOrderStatus.confirmed => 'Sipariş onaylandı',
    PreOrderStatus.ordered => 'Tedarikçiden sipariş edildi',
    PreOrderStatus.completed => 'Teslim edildi',
    PreOrderStatus.cancelled => 'Sipariş iptal edildi',
  };

  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (order == null && _loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sipariş takibi')),
        body: Center(
          child: TextButton(
            onPressed: _load,
            child: Text(_error ?? 'Yeniden dene'),
          ),
        ),
      );
    }
    final hasPoint = order.latitude != null && order.longitude != null;
    final point = hasPoint
        ? LatLng(order.latitude!, order.longitude!)
        : ElyeterMap.defaultCenter;
    final steps = [
      PreOrderStatus.newOrder,
      PreOrderStatus.confirmed,
      PreOrderStatus.ordered,
      PreOrderStatus.completed,
    ];
    final progress = order.status == PreOrderStatus.cancelled
        ? -1
        : steps.indexOf(order.status);
    const green = Color(0xFF138E45);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ElyeterMap(
              center: point,
              zoom: hasPoint ? 15 : 12,
              attributionTopInset: 64,
              markers: hasPoint
                  ? [
                      Marker(
                        point: point,
                        width: 54,
                        height: 54,
                        child: Container(
                          decoration: BoxDecoration(
                            color: green.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircleAvatar(
                              backgroundColor: green,
                              child: Icon(
                                Icons.home_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                  : const [],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: MediaQuery.paddingOf(context).top + 12,
            child: Row(
              children: [
                _RoundMapButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(color: Color(0x18000000), blurRadius: 12),
                      ],
                    ),
                    child: Text(
                      'Sipariş ${order.number}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _RoundMapButton(icon: Icons.refresh, onPressed: () => _load()),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 22,
                    offset: Offset(0, -7),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statusText(order.status),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.status == PreOrderStatus.cancelled
                          ? 'Bu sipariş iptal edildi.'
                          : 'Durum her 15 saniyede güncellenir.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        for (var index = 0; index < steps.length; index++) ...[
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: progress >= index
                                ? green
                                : const Color(0xFFE9ECEF),
                            child: Icon(
                              switch (index) {
                                0 => Icons.receipt_long_outlined,
                                1 => Icons.check,
                                2 => Icons.local_shipping_outlined,
                                _ => Icons.done_all,
                              },
                              size: 17,
                              color: progress >= index
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                          if (index < steps.length - 1)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: progress > index
                                    ? green
                                    : const Color(0xFFDFE2E4),
                              ),
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, color: green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            order.address?.isNotEmpty == true
                                ? order.address!
                                : hasPoint
                                ? 'Haritadaki teslimat noktası'
                                : 'Teslimat noktası belirtilmedi',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Güncelleme yapılamadı: $_error',
                        style: const TextStyle(color: Colors.deepOrange),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      'Canlı kurye konumu ve varış saati şu an mevcut değil.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundMapButton extends StatelessWidget {
  const _RoundMapButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 3,
    shape: const CircleBorder(),
    child: IconButton(icon: Icon(icon), onPressed: onPressed),
  );
}
