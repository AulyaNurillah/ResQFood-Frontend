import 'package:flutter/material.dart';
import 'maps_screen.dart';
import 'order_list_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart' show HomeTab;

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  int _currentIndex = 0;
  final bool _isLoading = false;

  List<Widget> _getScreens() {
    return [
      const HomeTab(),
      const MapsScreen(),
      OrderListScreen(),
      const ChatScreen(),
      const ProfileScreen(),
    ];
  }

  List<BottomNavigationBarItem> _getNavBarItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: "Explore"),
      BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "Orders"),
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
