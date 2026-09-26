/// Every backend path in one place — no raw strings inside data sources.
///
/// Mirrors `elyeter-mobile-api.md`; paths are relative to
/// [AppEnvironment.apiBaseUrl].
abstract final class ApiEndpoints {
  // ------------------------------------------------------------- auth --
  static const sendCode = '/auth/send-code';
  static const verifyCode = '/auth/verify-code';
  static const me = '/auth/me';
  static const fcmToken = '/auth/fcm-token';

  // ---------------------------------------------------------- catalog --
  static const categoriesTree = '/categories/tree';
  static String category(String slug) => '/categories/$slug';

  static const products = '/products';
  static String product(String slug) => '/products/$slug';
  static String productVariants(int id) => '/products/$id/variants';

  static const searchSuggest = '/search/suggest';

  // ----------------------------------------------------------- brands --
  static const brands = '/brands';
  static String brand(String slug) => '/brands/$slug';

  // ------------------------------------------------------- pre-orders --
  static const preOrders = '/pre-orders';
  static const preOrderCheck = '/pre-orders/check';
  static String preOrder(int id) => '/pre-orders/$id';
  static String cancelPreOrder(int id) => '/pre-orders/$id/cancel';
}
