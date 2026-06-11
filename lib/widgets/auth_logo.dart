import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/splash_logo.png",
      height: 150,
      fit: BoxFit.contain,
    );
  }
}