import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/buyer/home_screen.dart';
import 'screens/seller/upgrade_seller_screen.dart';
import 'screens/buyer/edit_profile_screen.dart';
import 'screens/buyer/notification_screen.dart';
import 'screens/buyer/order_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wcsmgqlsruqbetgvjetn.supabase.co',
    publishableKey: 'sb_publishable_rp6ZB9WMmvsiB9bBo_5L4Q_rz-AbYFt',
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const ResQFoodApp(),
    ),
  );
}

class ResQFoodApp extends StatelessWidget {
  const ResQFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'ResQFood',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const HomeScreen(),
        '/upgrade-seller': (context) => UpgradeSellerScreen(),
        '/edit-profile': (context) => EditProfileScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/order-list': (context) => OrderListScreen(),
      },
    );
  }
}