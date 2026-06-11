import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title: const Text(
          "ResQFood",
        ),
        centerTitle: true,
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,
      ),

      body: const Center(
        child: Text(
          "Dashboard Buyer",
          style: TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}