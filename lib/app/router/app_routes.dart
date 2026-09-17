/// Route names and paths. Navigate with `context.goNamed(AppRoutes.cart.name)`
/// so a path change never breaks call sites.
enum AppRoutes {
  home('/', 'home'),
  category('/category', 'category'),
  cart('/cart', 'cart'),
  favorite('/favorite', 'favorite'),
  profile('/profile', 'profile'),

  // Pushed on top of the shell
  productDetail('product/:id', 'product-detail'),
  productReviews('product/:id/reviews', 'product-reviews'),
  marketplace('marketplace/:id', 'marketplace'),
  categoryDetail('category/:id', 'category-detail'),
  brand('brand/:id', 'brand'),
  search('/search', 'search'),
  orders('orders', 'orders'),
  orderDetail('order', 'order-detail'),
  activeOrders('active-orders', 'active-orders'),
  announcements('announcements', 'announcements'),
  editProfile('edit', 'edit-profile'),
  notifications('notifications', 'notifications'),
  addresses('addresses', 'addresses'),
  settings('settings', 'settings'),
  faq('faq', 'faq'),
  terms('terms', 'terms'),
  privacy('privacy', 'privacy'),
  login('/login', 'login');

  const AppRoutes(this.path, this.name);

  final String path;
  final String name;
}
