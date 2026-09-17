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
  search('/search', 'search'),
  orders('orders', 'orders'),
  notifications('notifications', 'notifications'),
  addresses('addresses', 'addresses'),
  settings('settings', 'settings'),
  login('/login', 'login');

  const AppRoutes(this.path, this.name);

  final String path;
  final String name;
}
