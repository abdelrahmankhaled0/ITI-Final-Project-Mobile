import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taborq/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:taborq/features/auth/presentation/screens/login.dart';
import 'package:taborq/features/auth/presentation/screens/register.dart';
import 'package:taborq/features/home/widgets/bottom_nav.dart';

import 'package:taborq/features/auth/presentation/screens/verify_email_screen.dart';

class AppRoutes {
  static const String login = "/";
  static const String register = "/register";
  static const String forgetPassword = "/forgetPassword";
  static const String verifyEmail = "/verifyEmail";
  static const String home = "/home";

  static final routes = GoRouter(
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(),
          child: LoginScreen(),
        ),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(),
          child: RegisterScreen(),
        ),
      ),
      GoRoute(
        path: forgetPassword,
        builder: (context, state) => ForgetPasswordScreen(),
      ),
      GoRoute(
        path: verifyEmail,
        builder: (context, state) {
          final authCubit = state.extra as AuthCubit?;
          return BlocProvider.value(
            value: authCubit ?? AuthCubit(),
            child: const VerifyEmailScreen(),
          );
        },
      ),
      GoRoute(path: home, builder: (context, state) => BottomNav()),
    ],
  );
}
