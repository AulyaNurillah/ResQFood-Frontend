import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:resqfood_app/screens/seller/edit_product_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/dashboard_router.dart';
import 'screens/buyer/chat_room_screen.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF234A3E)),
        scaffoldBackgroundColor: const Color(0xFFCBDED3),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFCBDED3), foregroundColor: Color(0xFF133B1F), elevation: 0),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF234A3E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardRouter(),
        '/upgrade-seller': (context) => UpgradeSellerScreen(),
        '/edit-profile': (context) => EditProfileScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/order-list': (context) => OrderListScreen(),
        '/chat-room': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          String orderId = '';
          String storeName = '';
          if (args is String) {
            orderId = args;
          } else if (args is Map) {
            orderId = (args['orderId'] ?? args['id'] ?? '').toString();
            storeName = (args['storeName'] ?? args['store_name'] ?? '').toString();
          }
          return ChatRoomScreen(orderId: orderId, storeName: storeName);
        },
        '/edit-product': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          Map? product;
          if (args is Map) product = args['product'] as Map?;
          return EditProductScreen();
        },
      },
    );
  }
}