/// Turns the `+99362990344` the API stores into the `+993 62 990344` the
/// designs show. Anything that is not a Turkmen number in the expected
/// shape is handed back untouched rather than grouped wrongly.
abstract final class PhoneFormatter {
  static const _countryCode = '+993';

  /// Digits a Turkmen number carries after the country code.
  static const _nationalLength = 8;

  static String display(String? phone) {
    final value = phone?.trim() ?? '';
    if (!value.startsWith(_countryCode)) return value;

    final national = value.substring(_countryCode.length);
    if (national.length != _nationalLength ||
        !RegExp(r'^\d+$').hasMatch(national)) {
      return value;
    }

    // Operator code, then the subscriber's six figures.
    return '$_countryCode ${national.substring(0, 2)} '
        '${national.substring(2)}';
  }
}
