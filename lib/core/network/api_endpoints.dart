/// Every backend path in one place — no raw strings inside data sources.
abstract final class ApiEndpoints {
  // Auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const refreshToken = '/auth/refresh';
  static const logout = '/auth/logout';

  // Catalog
  static const banners = '/banners';
  static const categories = '/categories';
  static const products = '/products';
  static String product(String id) => '/products/$id';
  static String productReviews(String id) => '/products/$id/reviews';
  static const search = '/products/search';

  // Cart
  static const cart = '/cart';
  static String cartItem(String id) => '/cart/items/$id';

  // Favorites
  static const favorites = '/favorites';
  static String favorite(String id) => '/favorites/$id';

  // Orders
  static const orders = '/orders';
  static String order(String id) => '/orders/$id';
  static String cancelOrder(String id) => '/orders/$id/cancel';

  // Profile
  static const profile = '/profile';
  static const addresses = '/profile/addresses';
  static const notifications = '/notifications';
}
