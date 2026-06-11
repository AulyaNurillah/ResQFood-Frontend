import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../buyer/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  final AuthService authService =
      AuthService();

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {

    await Future.delayed(
      const Duration(seconds: 2),
    );

    final token =
        await authService.getToken();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            token != null
                ? const HomeScreen()
                : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          AppColors.secondary,

      body: Center(
        child: Image.asset(
          "assets/images/splash_logo.png",

          width: MediaQuery.of(context)
                  .size
                  .width *
              0.85,

          fit: BoxFit.contain,
        ),
      ),
    );
  }
}