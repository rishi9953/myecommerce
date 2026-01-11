import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myecommerce/Web/Modules/Categories/category_page.dart';
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
          path: '${Routes.category}/:categoryName',
          builder: (BuildContext context, GoRouterState state) {
            final categoryName = state.pathParameters['categoryName'] ?? '';
            final categoryIcon = state.uri.queryParameters['icon'] ?? '';
            return CategoryPage(
              categoryName: categoryName,
              categoryIcon: categoryIcon,
            );
          },
        ),
        GoRoute(
          path: Routes.product,
          builder: (BuildContext context, GoRouterState state) {
            return ProductPage();
          },
        ),
      ],
    ),
  ],
);
