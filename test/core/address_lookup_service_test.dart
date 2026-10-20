import 'package:elyeter/core/services/address_lookup_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  test('formats street, city and country without duplicates', () {
    expect(
      DeviceAddressLookupService.formatPlacemark(
        const Placemark(
          street: 'Ahal street',
          locality: 'Annau',
          country: 'Turkmenistan',
        ),
      ),
      'Ahal street, Annau, Turkmenistan',
    );
    expect(
      DeviceAddressLookupService.formatPlacemark(
        const Placemark(street: 'Annau', locality: 'Annau'),
      ),
      'Annau',
    );
  });

  test('does not present country alone as a street address', () {
    expect(
      DeviceAddressLookupService.formatPlacemark(
        const Placemark(country: 'Turkmenistan'),
      ),
      isNull,
    );
  });
}
