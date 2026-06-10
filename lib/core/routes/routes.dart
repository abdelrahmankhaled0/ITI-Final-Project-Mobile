import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taborq/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:taborq/features/auth/presentation/screens/login.dart';
import 'package:taborq/features/auth/presentation/screens/register.dart';
import 'package:taborq/features/auth/presentation/screens/change_password_screen.dart';
import 'package:taborq/features/auth/presentation/screens/terms_and_conditions_screen.dart';
import 'package:taborq/features/booking/presentation/screens/subServices_screen.dart';
import 'package:taborq/features/booking/presentation/cubit/booking_cubit.dart'; // الـ Import الجديد
import 'package:taborq/features/booking_view/presentation/cubit/booking_view_cubit.dart';
import 'package:taborq/features/booking_view/presentation/screens/booking_view_screen.dart';
import 'package:taborq/features/business_datails/cubit/business_details_cubit.dart';
import 'package:taborq/features/business_datails/screens/business_details_screen.dart';
import 'package:taborq/features/home/presentation/widgets/bottom_nav.dart';
import 'package:taborq/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:taborq/features/home/presentation/screens/home_screen.dart';
import 'package:taborq/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:taborq/features/profile/presentation/screens/profile_screen.dart';
import 'package:taborq/features/welcome/presentation/cubit/welcome_cubit.dart';
import 'package:taborq/features/welcome/presentation/screens/onboarding_screen.dart';
import 'package:taborq/features/welcome/presentation/screens/splach_screen.dart';

class AppRoutes {
  static const String splash = "/";
  static const String onboarding = "/onboarding";
  static const String login = "/login";
  static const String register = "/register";
  static const String forgetPassword = "/forgetPassword";
  static const String changePassword = "/changePassword";
  static const String terms = "/terms";
  static const String verifyEmail = "/verifyEmail";
  static const String home = "/home";
  static const String businessDetails = "/home/details";
  static const String subServices = "sub-services";
  static const String profile = "/profile";
  static const String bookings = '/bookings';

  static final routes = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: '/__/auth/action',
        builder: (context, state) {
          final code = state.uri.queryParameters['oobCode'];
          return ChangePasswordScreen(actionCode: code!);
        },
      ),
      GoRoute(path: splash, builder: (context, state) => SplachScreen()),
      GoRoute(
        path: onboarding,
        builder: (context, state) => BlocProvider(
          create: (context) => WelcomeCubit(),
          child: OnboardingScreen(),
        ),
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
                  if (state.extra == null) {
                    return const Scaffold(
                      body: Center(child: Text("Error: No Data")),
                    );
                  }
                  return BusinessDetailsScreen(
                    business: state.extra as Map<String, dynamic>,
                  );
                },
                routes: [
                  GoRoute(
                    path: subServices,
                    builder: (context, state) {
                      if (state.extra == null) {
                        return const Scaffold(
                          body: Center(child: Text("Error: No Data")),
                        );
                      }
                      final data = state.extra as Map<String, dynamic>;

                      // هنا التعديل الجوهري باستخدام MultiBlocProvider لتوفير الـ 2 Cubits معاً
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider<BusinessDetailsCubit>(
                            create: (context) => BusinessDetailsCubit(),
                          ),
                          BlocProvider<BookingCubit>(
                            create: (context) => BookingCubit(),
                          ),
                        ],
                        child: SubServicesScreen(
                          businessId: data['businessId'],
                          serviceId: data['serviceId'],
                          serviceName: data['serviceName'],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => BlocProvider(
              create: (context) => BookingViewCubit(),
              child: BookingViewScreen(),
            ),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => BlocProvider(
              create: (_) => BookingViewCubit()..getTicketsByUserId(),
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
