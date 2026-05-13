import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taborq/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:taborq/features/auth/presentation/screens/login.dart';
import 'package:taborq/features/auth/presentation/screens/register.dart';
<<<<<<< HEAD
import 'package:taborq/features/auth/presentation/screens/change_password_screen.dart';
import 'package:taborq/features/auth/presentation/screens/terms_and_conditions_screen.dart';
=======
import 'package:taborq/features/business_datails/screens/business_derails_screen.dart';
>>>>>>> main
import 'package:taborq/features/home/widgets/bottom_nav.dart';
import 'package:taborq/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:taborq/features/home/screens/home_screen.dart';
import 'package:taborq/features/notifications/presentation/screens/notifications_screen.dart';

class AppRoutes {
  static const String login = "/";
  static const String register = "/register";
  static const String forgetPassword = "/forgetPassword";
  static const String changePassword = "/changePassword";
  static const String terms = "/terms";
  static const String verifyEmail = "/verifyEmail";
  static const String home = "/home";
  static const String businessDetails = "/home/details";

  static final routes = GoRouter(
    initialLocation: login,
    routes: [

      GoRoute(
        path: '/__/auth/action', // ده المسار الافتراضي من فايربيز
        builder: (context, state) {
          // بنسحب الكود السري من اللينك
          final code = state.uri.queryParameters['oobCode'];
          return ChangePasswordScreen(actionCode: code!);
        },
      ),
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
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(),
          child: ForgetPasswordScreen(),
        ),
      ),
      GoRoute(
        path: changePassword,
        builder: (context, state) {
          final actionCode = state.extra as String?;
          return BlocProvider(
            create: (context) => AuthCubit(),
            child: ChangePasswordScreen(actionCode: actionCode),
          );
        },
      ),
      GoRoute(
        path: terms,
        builder: (context, state) {
          final authCubit = state.extra as AuthCubit?;
          return BlocProvider.value(
            value: authCubit ?? AuthCubit(),
            child: const TermsAndConditionsScreen(),
          );
        },
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

      ShellRoute(
        builder: (context, state, child) {
          return BottomNav(child: child);
        },
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'details',
                builder: (context, state) {
                  final businessData = state.extra as Map<String, dynamic>;
                  return BusinessDetailsScreen(business: businessData);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Bookings'))),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Profile'))),
          ),
        ],
      ),
    ],
  );
}