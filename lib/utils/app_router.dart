import 'package:flutter/material.dart';
import '../features/splash/view/splash_screen.dart';
import '../features/auth/view/login_screen.dart';
import '../core/navigation/main_navigation.dart';
import '../features/address/view/address_list_screen.dart';
import '../features/orders/view/order_history_screen.dart';
import '../features/cart/view/cart_screen.dart';

class AppRouter {
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String addressListRoute = '/addresses';
  static const String addAddressRoute = '/addresses/add';
  static const String orderHistoryRoute = '/orders';
  static const String cartRoute = '/cart';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      case addressListRoute:
        return MaterialPageRoute(builder: (_) => const AddressListScreen());
      case orderHistoryRoute:
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());
      case cartRoute:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
