import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'buyer/buyer_dashboard.dart';
import 'seller/seller_dashboard.dart';

class DashboardRouter extends StatefulWidget {
  const DashboardRouter({super.key});

  @override
  State<DashboardRouter> createState() => _DashboardRouterState();
}

class _DashboardRouterState extends State<DashboardRouter> {
  bool _loading = true;
  Widget? _child;

  @override
  void initState() {
    super.initState();
    _determineRole();
  }

  Future<void> _determineRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRole = prefs.getString('current_role');
      if (savedRole != null) {
        setState(() {
          _child = savedRole == 'penjual' ? const SellerDashboard() : const BuyerDashboard();
          _loading = false;
        });
        return;
      }

      final auth = AuthService();
      final seller = await auth.isSeller();
      setState(() {
        _child = seller ? const SellerDashboard() : const BuyerDashboard();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _child = const BuyerDashboard();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return _child!;
  }
}
