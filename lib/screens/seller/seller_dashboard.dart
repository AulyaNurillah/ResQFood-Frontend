import 'package:flutter/material.dart';
import '../buyer/chat_screen.dart';
import '../buyer/profile_screen.dart';
import '../buyer/home_screen.dart' show SellerDashboardTab;
import 'add_product_screen.dart';
import 'scan_screen.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  int _currentIndex = 0;
  bool _isLoading = false;

  List<Widget> _getScreens() {
    return [
      const SellerDashboardTab(),
      const AddProductScreen(),
      const SellerScanScreen(),
      const ChatScreen(),
      const ProfileScreen(),
    ];
  }

  List<BottomNavigationBarItem> _getNavBarItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
      BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Add Product"),
      BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "Scan QR"),
      BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _getScreens(),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() { _currentIndex = index; }),
            selectedItemColor: const Color(0xFF234A3E),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            items: _getNavBarItems(),
            showUnselectedLabels: true,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
