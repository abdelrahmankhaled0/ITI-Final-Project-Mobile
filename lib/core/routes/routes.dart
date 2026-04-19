import 'package:go_router/go_router.dart';
import 'package:taborq/features/auth/presentation/screens/login.dart';
import 'package:taborq/features/auth/presentation/screens/register.dart';
import 'package:taborq/features/widgets/bottom_nav.dart';

class AppRoutes {
  // static const String login = "/";
  // static const String register = "/register";
  static const String home = "/";

  static final routes = GoRouter(
    routes: [
      // GoRoute(path: login, builder: (context, state) => LoginScreen()),
      // GoRoute(path: register, builder: (context, state) => RegisterScreen()),
      GoRoute(path: home, builder: (context, state) => BottomNav()),

    ],
  );
}
