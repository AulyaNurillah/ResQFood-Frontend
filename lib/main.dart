import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const ResQFoodApp());
}

class ResQFoodApp extends StatelessWidget {
  const ResQFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ResQFood',

      theme: ThemeData(
        useMaterial3: true,
      ),

      home: const SplashScreen(),
    );
  }
}