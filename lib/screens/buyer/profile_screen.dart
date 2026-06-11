import 'package:flutter/material.dart';
import 'package:resqfood_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _isUpgrading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getProfile();
      setState(() {
        _profile = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat profil: $e')),
      );
    }
  }

  Future<void> _upgradeToSeller() async {
    setState(() => _isUpgrading = true);
    try {
      final response = await ApiService.upgradeToSeller();
      if (response['id'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selamat! Anda sekarang penjual. Silakan lengkapi data toko.')),
        );
        Navigator.pushNamed(context, '/upgrade-seller');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Gagal upgrade')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isUpgrading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_profile == null) {
      return Scaffold(body: Center(child: Text('Gagal memuat profil')));
    }

    final roles = _profile!['roles'] as List? ?? [];
    final isSeller = roles.contains('penjual');
    final fullName = _profile!['full_name'] ?? 'User';
    final email = _profile!['email'] ?? '';
    final avatarUrl = _profile!['avatar_url'];

    return Scaffold(
      backgroundColor: Color.fromRGBO(203, 222, 211, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(203, 222, 211, 1),
        elevation: 0,
        title: Text('Profile', style: TextStyle(color: Color.fromRGBO(19, 59, 31, 1), fontSize: 24)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header profil
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Color.fromRGBO(59, 98, 85, 1),
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null ? Icon(Icons.person, size: 50, color: Colors.white) : null,
                  ),
                  SizedBox(height: 12),
                  Text(
                    fullName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromRGBO(19, 59, 31, 1)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 14, color: Color.fromRGBO(35, 74, 62, 0.8)),
                  ),
                  if (isSeller) ...[
                    SizedBox(height: 8),
                    Chip(
                      label: Text('Penjual', style: TextStyle(color: Colors.white)),
                      backgroundColor: Color.fromRGBO(59, 98, 85, 1),
                    ),
                  ],
                ],
              ),
            ),
            // Menu settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Account',
                    subtitle: 'Manage your profile info',
                    onTap: () {
                      Navigator.pushNamed(context, '/edit-profile');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_none,
                    title: 'Preferences',
                    subtitle: 'Dietary and notifications',
                    onTap: () {
                      // Navigasi ke halaman notifikasi (opsional)
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: 'FAQs and support',
                    onTap: () {},
                  ),
                  if (!isSeller)
                    _buildMenuItem(
                      icon: Icons.store,
                      title: 'Upgrade to Seller',
                      subtitle: 'Jadi mitra penjual ResQFood',
                      onTap: _upgradeToSeller,
                      isLoading: _isUpgrading,
                    ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: '',
                    onTap: _logout,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLoading = false,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color.fromRGBO(240, 226, 186, 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Color.fromRGBO(59, 98, 85, 1)),
        title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : Color.fromRGBO(35, 74, 62, 1))),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)) : null,
        trailing: isLoading
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(Icons.arrow_forward_ios, size: 16, color: Color.fromRGBO(35, 74, 62, 0.5)),
        onTap: onTap,
      ),
    );
  }
}