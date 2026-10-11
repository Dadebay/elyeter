import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../domain/entities/pre_order_check.dart';
import '../../domain/entities/pre_order_line.dart';
import '../../domain/repositories/pre_order_repository.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _comment = TextEditingController();
  List<PreOrderLine> _lines = [];
  PreOrderCheck? _check;
  List<SavedLocation> _savedLocations = [];
  int? _selectedLocationId;
  String? _error;
  bool _working = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final cart = context.read<CartCubit>().state;
    final selectedSlugs = cart.selectedIds.toList();
    final lines = <PreOrderLine>[];
    for (final slug in selectedSlugs) {
      final detail = (await getIt<ProductRepository>().bySlug(slug)).dataOrNull;
      if (detail == null) continue;
      lines.add(
        PreOrderLine(
          productId: detail.product.id,
          quantity: cart.quantityOf(slug),
          variantId: cart.variants[slug],
        ),
      );
    }
    if (!mounted) return;
    if (context.read<AuthCubit>().state.isAuthenticated) {
      try {
        final locations = await getIt<ShopApi>().locations();
        if (mounted && locations.isNotEmpty) {
          setState(() {
            _savedLocations = locations;
            _selectedLocationId = locations.first.id;
            _address.text = locations.first.address ?? '';
          });
        }
      } on Object {
        /* Address can be entered manually. */
      }
    }
    if (!mounted) return;
    setState(() {
      _lines = lines;
      _ready = true;
      if (lines.length != selectedSlugs.length) {
        _error =
            'A product is no longer available. Remove it from the cart before ordering.';
      }
    });
    if (lines.length == selectedSlugs.length && lines.isNotEmpty) {
      await _verify();
    }
  }

  Future<void> _verify() async {
    if (_working ||
        _lines.isEmpty ||
        _error?.startsWith('A product is no longer') == true) {
      return;
    }
    if (!context.read<AuthCubit>().state.isAuthenticated) {
      if (!await promptSignIn(context) || !mounted) return;
    }
    setState(() {
      _working = true;
      _check = null;
      _error = null;
    });
    final result = await getIt<PreOrderRepository>().check(_lines);
    if (mounted) {
      setState(() {
        _check = result.dataOrNull;
        _error = result.failureOrNull?.message;
        _working = false;
      });
    }
  }

  Future<void> _place() async {
    final check = _check;
    if (check == null || !check.available || _working) return;
    setState(() {
      _working = true;
      _error = null;
    });
    final result = await getIt<PreOrderRepository>().create(
      lines: _lines,
      customerName: _name.text.trim().isEmpty ? null : _name.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
      expectedTotal: check.totalPrice,
    );
    if (!mounted) return;
    final order = result.dataOrNull;
    if (order != null) {
      final cart = context.read<CartCubit>();
      for (final slug in cart.state.selectedIds.toList()) {
        cart.remove(slug);
      }
      context.goNamed(
        AppRoutes.orderDetail.name,
        pathParameters: {'id': order.id.toString()},
      );
      return;
    }
    setState(() {
      _check = result.failureOrNull?.details.asPreOrderCheck;
      _error = result.failureOrNull?.message;
      _working = false;
    });
  }

  void _selectLocation(int? id) {
    final matches = _savedLocations.where((location) => location.id == id);
    if (matches.isEmpty) return;
    setState(() {
      _selectedLocationId = id;
      _address.text = matches.first.address ?? '';
    });
  }

  Future<void> _openSavedLocations() async {
    await context.pushNamed(AppRoutes.addresses.name);
    if (!mounted) return;
    try {
      final locations = await getIt<ShopApi>().locations();
      if (!mounted) return;
      setState(() {
        _savedLocations = locations;
        if (locations.isNotEmpty) {
          _selectedLocationId = locations.first.id;
          _address.text = locations.first.address ?? '';
        } else {
          _selectedLocationId = null;
        }
      });
    } on Object {
      // Manual address entry remains available.
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.commonCheckout)),
    body: !_ready
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_savedLocations.isNotEmpty)
                DropdownButtonFormField<int>(
                  key: ValueKey(_selectedLocationId),
                  initialValue: _selectedLocationId,
                  decoration: const InputDecoration(labelText: 'Kayıtlı adres'),
                  items: [
                    for (final location in _savedLocations)
                      DropdownMenuItem(
                        value: location.id,
                        child: Text(location.name),
                      ),
                  ],
                  onChanged: _selectLocation,
                ),
              TextButton.icon(
                onPressed: _openSavedLocations,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Haritadan adres ekle veya düzenle'),
              ),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: _comment,
                decoration: const InputDecoration(labelText: 'Comment'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              if (_working) const Center(child: CircularProgressIndicator()),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_check case final check?) ...[
                for (final item in check.items)
                  ListTile(
                    title: Text(item.name ?? '#${item.productId}'),
                    subtitle: Text(
                      [
                        if (item.variant != null) item.variant!,
                        if (item.message != null) item.message!,
                      ].join(' · '),
                    ),
                    trailing: Text(
                      item.lineTotal == null
                          ? item.status.name
                          : '${item.lineTotal} TMT',
                    ),
                  ),
                const Divider(),
                ListTile(
                  title: Text(context.l10n.commonTotal),
                  trailing: Text('${check.totalPrice} TMT'),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _working || _lines.isEmpty ? null : _verify,
                child: const Text('Check availability'),
              ),
              FilledButton(
                onPressed: _working || _check?.available != true
                    ? null
                    : _place,
                child: const Text('Place order'),
              ),
            ],
          ),
  );
}
