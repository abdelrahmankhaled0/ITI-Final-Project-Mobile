import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/services/local/cash_helper.dart';
import 'package:taborq/core/services/remote/notification_service.dart';
import 'package:taborq/core/utils/app_theme.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taborq/features/home/presentation/cubit/home_cubit.dart';
import 'package:taborq/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:taborq/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:taborq/features/profile/presentation/cubit/theme-cubit.dart';
import 'package:taborq/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🌟 1. عمل initialization للـ CashHelper أولاً
  await CashHelper.init();

  await NotificationService().initNotification();
  await FirebaseMessaging.instance.requestPermission();

  // 🌟 2. قراءة المود باستخدام الـ CashHelper الخاص بكِ (لو فاضي هيعتبره light)
  String savedTheme = CashHelper.getData('theme_mode') ?? 'light';

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => HomeCubit()..getClinics()),
        BlocProvider<NotificationCubit>(create: (context) => NotificationCubit()),
        BlocProvider<BookingCubit>(
          create: (context) => BookingCubit(
            notificationCubit: context.read<NotificationCubit>(),
          ),
        ),
        // 🌟 3. تمرير الثيم المحفوظ للـ Cubit عند إنشائه
        BlocProvider(create: (context) => ThemeCubit(savedTheme)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: AppRoutes.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
