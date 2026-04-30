import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/catalog/presentation/screens/home_screen.dart';
import '../../features/catalog/presentation/screens/product_detail_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/orders/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/payment_screen.dart';
import '../../features/orders/presentation/screens/order_list_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      
      final isLoggedIn = authState.user != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/verify-email';

      final protectedRoutes = [
        '/profile',
        '/checkout',
        '/orders',
        '/payment',
      ];

      final isProtectedRoute =
          protectedRoutes.any((route) => state.matchedLocation.startsWith(route));

      if (!isLoggedIn && isProtectedRoute) {
        return '/login?message=Silakan login terlebih dahulu untuk mengakses fitur ini';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/payment/:publicId',
        name: 'payment',
        builder: (context, state) {
          final publicId = state.pathParameters['publicId']!;
          return PaymentScreen(publicId: publicId);
        },
      ),
      GoRoute(
        path: '/orders',
        name: 'order_list',
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: '/orders/:publicId',
        name: 'order_detail',
        builder: (context, state) {
          final publicId = state.pathParameters['publicId']!;
          return OrderDetailScreen(publicId: publicId);
        },
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product_detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify_email',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyEmailScreen(email: email);
        },
      ),
    ],
  );
});