import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_icons.dart';

/// Shared tile configuration and map attribution for the two maps.
class ElyeterMap extends StatefulWidget {
  const ElyeterMap({
    super.key,
    required this.center,
    this.controller,
    this.onPositionChanged,
    this.markers = const [],
    this.zoom = 15,
    this.attributionTopInset = 0,
    this.showAttributionButton = true,
  });

  static const defaultCenter = LatLng(37.960077, 58.326063);
  static const tileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://a7-tagam.com.tm/tile/{z}/{x}/{y}.png',
  );

  final LatLng center;
  final MapController? controller;
  final PositionCallback? onPositionChanged;
  final List<Marker> markers;
  final double zoom;
  final double attributionTopInset;
  final bool showAttributionButton;

  @override
  State<ElyeterMap> createState() => _ElyeterMapState();
}

class _ElyeterMapState extends State<ElyeterMap> {
  bool _showCredit = true;
  late final Timer _creditTimer;

  @override
  void initState() {
    super.initState();
    _creditTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showCredit = false);
    });
  }

  @override
  void dispose() {
    _creditTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FlutterMap(
    mapController: widget.controller,
    options: MapOptions(
      initialCenter: widget.center,
      initialZoom: widget.zoom,
      minZoom: 3,
      maxZoom: 19,
      onPositionChanged: widget.onPositionChanged,
    ),
    children: [
      TileLayer(
        urlTemplate: ElyeterMap.tileUrl,
        userAgentPackageName: 'com.gurbanov.elyeter',
      ),
      if (widget.markers.isNotEmpty) MarkerLayer(markers: widget.markers),
      SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              8,
              8 + widget.attributionTopInset,
              8,
              8,
            ),
            child: !widget.showAttributionButton
                ? Text(
                    '© OpenStreetMap',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurface,
                      shadows: const [
                        Shadow(color: Colors.white, blurRadius: 3),
                      ],
                    ),
                  )
                : Semantics(
                    button: true,
                    label: 'OpenStreetMap map data and licence',
                    child: Material(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                      child: InkWell(
                        onTap: () => launchUrl(
                          Uri.parse('https://www.openstreetmap.org/copyright'),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 3,
                          ),
                          child: _showCredit
                              ? const Text(
                                  '© OpenStreetMap',
                                  style: TextStyle(fontSize: 10),
                                )
                              : HugeIcon(
                                  icon: AppIcons.information,
                                  size: 18,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    ],
  );
}
