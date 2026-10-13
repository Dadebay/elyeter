import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;

/// Foreground-only lookup for the address picker. A short precise attempt is
/// followed by a network-based fix so indoor users are not stuck waiting for
/// satellites. Call only after the user taps the locate button.
class DeviceLocationService {
  DeviceLocationService({loc.Location? platform})
    : _platform = platform ?? loc.Location();

  final loc.Location _platform;
  LatLng? _recentPoint;
  DateTime? _recentAt;
  bool lastFixWasApproximate = false;

  Future<LatLng> locate() async {
    var enabled = await _platform.serviceEnabled();
    if (!enabled) enabled = await _platform.requestService();
    if (!enabled) throw const LocationLookupException('Konum servisi kapalı.');

    var permission = await _platform.hasPermission();
    if (permission == loc.PermissionStatus.denied) {
      permission = await _platform.requestPermission();
    }
    if (permission != loc.PermissionStatus.granted &&
        permission != loc.PermissionStatus.grantedLimited) {
      throw const LocationLookupException('Konum izni verilmedi.');
    }

    loc.LocationData? reading;
    try {
      await _platform.changeSettings(accuracy: loc.LocationAccuracy.high);
      reading = await _platform.getLocation().timeout(
        const Duration(seconds: 6),
      );
    } on Object {
      // A satellite fix often times out indoors; use Wi-Fi/cell positioning.
    }
    if (reading?.latitude == null || reading?.longitude == null) {
      try {
        await _platform.changeSettings(accuracy: loc.LocationAccuracy.balanced);
        reading = await _platform.getLocation().timeout(
          const Duration(seconds: 8),
        );
      } on Object {
        // A recent in-memory fix is still useful as a starting point.
      }
    }
    final lat = reading?.latitude;
    final lon = reading?.longitude;
    if (lat != null && lon != null && lat.abs() <= 90 && lon.abs() <= 180) {
      _recentPoint = LatLng(lat, lon);
      _recentAt = DateTime.now();
      lastFixWasApproximate = (reading?.accuracy ?? 0) > 100;
      return _recentPoint!;
    }
    if (_recentPoint != null &&
        _recentAt != null &&
        DateTime.now().difference(_recentAt!) < const Duration(minutes: 10)) {
      lastFixWasApproximate = true;
      return _recentPoint!;
    }
    throw const LocationLookupException(
      'Konum bulunamadı. Haritadan adresi seçebilirsiniz.',
    );
  }
}

class LocationLookupException implements Exception {
  const LocationLookupException(this.message);
  final String message;
  @override
  String toString() => message;
}
