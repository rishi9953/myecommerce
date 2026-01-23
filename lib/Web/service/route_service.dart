import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myecommerce/Web/Modules/Cart/cart_page.dart';
import 'package:myecommerce/Web/Modules/Categories/category_page.dart';
import 'package:myecommerce/Web/Modules/Checkout/checkout_page.dart';
import 'package:myecommerce/Web/Modules/Home/home_screen.dart';
import 'package:myecommerce/Web/Modules/Login/login_screen.dart';
import 'package:myecommerce/Web/Modules/Product/product_page.dart';
import 'package:myecommerce/Web/Modules/Signup/signup_screen.dart';

class Routes {
  static String home = '/';
  static String login = '/login';
  static String signUp = '/signUp';
  static String category = '/category';
  static String product = '/product';
  static String productDetails = '/product/:productId';
  static String cart = '/cart';
  static String checkout = '/checkout';
}

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: Routes.home,
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: Routes.login,
          builder: (BuildContext context, GoRouterState state) {
            return SignInScreen();
          },
        ),
        GoRoute(
          path: Routes.signUp,
          builder: (BuildContext context, GoRouterState state) {
            return SignUpScreen();
          },
        ),
        GoRoute(
          path: '${Routes.category}/:categoryId',
          builder: (BuildContext context, GoRouterState state) {
            final categoryId = state.pathParameters['categoryId'] ?? '';
            final categoryName = state.uri.queryParameters['name'] ?? '';
            final categoryIcon = state.uri.queryParameters['icon'] ?? '';
            return CategoryPage(
              categoryId: categoryId,
              categoryName: categoryName,
              categoryIcon: categoryIcon,
            );
          },
        ),
        GoRoute(
          path: Routes.productDetails,
          builder: (BuildContext context, GoRouterState state) {
            final productId = state.pathParameters['productId'] ?? '';
            return ProductPage(productId: productId);
          },
        ),
        GoRoute(
          path: Routes.cart,
          builder: (BuildContext context, GoRouterState state) {
            return const CartPage();
          },
        ),
        GoRoute(
          path: Routes.checkout,
          builder: (BuildContext context, GoRouterState state) {
            return const CheckoutPage();
          },
        ),
      ],
    ),
  ],
);
