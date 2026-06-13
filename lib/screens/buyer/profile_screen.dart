import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _isUpgrading = false;
  String _currentRole = "pembeli";
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getProfile();
      final prefs = await SharedPreferences.getInstance();
      final savedRole = prefs.getString('current_role') ?? "pembeli";

      setState(() {
        _profile = data;
        _currentRole = savedRole;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat profil: $e')),
      );
    }
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          _avatarFile = File(picked.path);
        });
        
        // Upload ke backend
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        final response = await ApiService.uploadProfilePicture(picked.path);
        
        if (context.mounted) Navigator.pop(context);

        if (response['avatarUrl'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui!'), backgroundColor: Colors.green),
          );
          _loadProfile();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? 'Gagal mengupload foto')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking avatar: $e");
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF234A3E)),
              title: const Text('Ambil Foto via Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF234A3E)),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _upgradeToSeller() async {
    setState(() => _isUpgrading = true);
    try {
      // Direct call upgrade jika toko belum terdaftar, 
      // tapi idealnya mengisi data di upgrade-seller screen
      Navigator.pushNamed(context, '/upgrade-seller');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isUpgrading = false);
    }
  }

  Future<void> _toggleRole() async {
    final prefs = await SharedPreferences.getInstance();
    final nextRole = _currentRole == "pembeli" ? "penjual" : "pembeli";
    await prefs.setString('current_role', nextRole);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Berhasil beralih ke Mode ${nextRole == "penjual" ? "Penjual" : "Pembeli"}')),
    );
    
    // Refresh page / reload dashboard
    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_profile == null) {
      return const Scaffold(body: Center(child: Text('Gagal memuat profil')));
    }

    final roles = _profile!['roles'] as List? ?? [];
    final isSeller = roles.contains('penjual');
    final fullName = _profile!['full_name'] ?? 'User';
    final email = _profile!['email'] ?? '';
    final avatarUrl = _profile!['avatar_url'];

    return Scaffold(
      backgroundColor: const Color(0xFFCBDED3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCBDED3),
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Color(0xFF133B1F), fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF133B1F)),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header profil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showAvatarPicker,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF3B6255),
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap foto untuk mengganti',
                    style: TextStyle(fontSize: 11, color: Color(0xFF234A3E), fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fullName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF133B1F)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF234A3E)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Chip(
                        label: Text('Mode: ${_currentRole == "penjual" ? "Penjual" : "Pembeli"}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: const Color(0xFF234A3E),
                      ),
                      if (isSeller) ...[
                        const SizedBox(width: 8),
                        const Chip(
                          label: Text('Mitra Penjual', style: TextStyle(color: Colors.white, fontSize: 12)),
                          backgroundColor: Colors.orange,
                        ),
                      ]
                    ],
                  ),
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
                  if (isSeller)
                    _buildMenuItem(
                      icon: Icons.swap_horiz,
                      title: 'Beralih Mode',
                      subtitle: _currentRole == "pembeli" ? 'Masuk ke mode penjual' : 'Masuk ke mode pembeli',
                      onTap: _toggleRole,
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
                    icon: Icons.notifications_none,
                    title: 'Notifikasi',
                    subtitle: 'Lihat pemberitahuan Anda',
                    onTap: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Keluar dari akun',
                    onTap: _logout,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E2BA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF3B6255)),
        title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : const Color(0xFF234A3E), fontWeight: FontWeight.bold)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)) : null,
        trailing: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF234A3E)),
        onTap: onTap,
      ),
    );
  }
}