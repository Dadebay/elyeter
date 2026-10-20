import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

/// Turns a map coordinate into a readable address after a user action.
abstract class AddressLookupService {
  Future<String?> reverse(LatLng point, Locale locale);
}

class DeviceAddressLookupService implements AddressLookupService {
  DeviceAddressLookupService({Geocoding? geocoding})
    : _geocoding = geocoding ?? Geocoding();

  final Geocoding _geocoding;

  @override
  Future<String?> reverse(LatLng point, Locale locale) async {
    if (!await _geocoding.isPresent()) return null;
    final places = await _geocoding.placemarkFromCoordinates(
      point.latitude,
      point.longitude,
      locale: locale,
    );
    if (places.isEmpty) return null;
    return formatPlacemark(places.first);
  }

  static String? formatPlacemark(Placemark place) {
    String clean(String? value) {
      final text = value?.trim() ?? '';
      return text.toLowerCase() == 'null' ? '' : text;
    }

    final street = clean(place.street);
    final thoroughfare = clean(place.thoroughfare);
    final number = clean(place.subThoroughfare);
    final road = [
      thoroughfare,
      number,
    ].where((part) => part.isNotEmpty).join(' ');
    final firstLine = street.isNotEmpty
        ? street
        : (road.isNotEmpty ? road : clean(place.name));
    final locality = [
      place.locality,
      place.subLocality,
      place.subAdministrativeArea,
      place.administrativeArea,
    ].map(clean).firstWhere((part) => part.isNotEmpty, orElse: () => '');
    final country = clean(place.country);
    if (firstLine.isEmpty && locality.isEmpty) return null;

    final parts = <String>[];
    for (final part in [firstLine, locality, country]) {
      if (part.isEmpty) continue;
      if (parts.any(
        (existing) => existing.toLowerCase() == part.toLowerCase(),
      )) {
        continue;
      }
      parts.add(part);
    }
    return parts.isEmpty ? null : parts.join(', ');
  }
}
