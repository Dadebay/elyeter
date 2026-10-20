/// Public product routes accept numeric IDs only; legacy slugs are ignored.
abstract final class ProductId {
  static int? tryParse(String? value) {
    if (value == null || !RegExp(r'^[0-9]+$').hasMatch(value)) return null;
    final id = int.tryParse(value);
    return id != null && id > 0 ? id : null;
  }
}
