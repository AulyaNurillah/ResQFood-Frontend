// lib/screens/buyer/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resqfood_app/services/api_service.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Map<String, dynamic> _profile = {};
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUpgrading = false;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _avatarUrl;
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
      setState(() {
        _profile = data;
        _nameController.text = data['full_name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _avatarUrl = data['avatar_url'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat profil: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      if (_avatarFile != null) {
        final result = await ApiService.uploadProfilePicture(_avatarFile!.path);
        if (result['avatarUrl'] != null) {
          _avatarUrl = result['avatarUrl'];
        }
      }
      final response = await ApiService.updateProfile({
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });
      if (response['id'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil berhasil diupdate')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Gagal update')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
        _avatarUrl = null;
      });
    }
  }

  Future<void> _upgradeToSeller() async {
    setState(() => _isUpgrading = true);
    try {
      final response = await ApiService.upgradeToSeller();
      if (response['id'] != null) {
        // Update role di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final newRoles = List<String>.from(response['roles']);
        await prefs.setStringList('roles', newRoles);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anda sekarang menjadi penjual!')),
        );
        Navigator.pop(context); // kembali ke profil
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

  @override
  Widget build(BuildContext context) {
    final roles = _profile['roles'] as List? ?? [];
    final isSeller = roles.contains('penjual');

    return Scaffold(
      backgroundColor: Color.fromRGBO(203, 222, 211, 1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromRGBO(203, 222, 211, 1),
        title: Text(
          'Edit Profil',
          style: TextStyle(color: Color.fromRGBO(19, 59, 31, 1), fontSize: 24),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromRGBO(19, 59, 31, 1)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Color.fromRGBO(78, 102, 93, 0.4),
                        backgroundImage: _avatarFile != null
                            ? FileImage(_avatarFile!)
                            : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null),
                        child: (_avatarFile == null && _avatarUrl == null)
                            ? Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Tap untuk ganti foto',
                      style: TextStyle(color: Color.fromRGBO(35, 74, 62, 1), fontSize: 12),
                    ),
                    SizedBox(height: 24),
                    // Nama
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        labelStyle: TextStyle(color: Color.fromRGBO(35, 74, 62, 1)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color.fromRGBO(35, 74, 62, 1)),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                    ),
                    SizedBox(height: 16),
                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Nomor HP',
                        labelStyle: TextStyle(color: Color.fromRGBO(35, 74, 62, 1)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color.fromRGBO(35, 74, 62, 1)),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Alamat
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Alamat',
                        labelStyle: TextStyle(color: Color.fromRGBO(35, 74, 62, 1)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color.fromRGBO(35, 74, 62, 1)),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Tombol Upgrade (jika belum penjual)
                    if (!isSeller)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isUpgrading ? null : _upgradeToSeller,
                          icon: Icon(Icons.store),
                          label: Text(_isUpgrading ? 'Memproses...' : 'Daftar Jadi Penjual'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    if (!isSeller) SizedBox(height: 16),
                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(59, 98, 85, 1),
                          foregroundColor: Color.fromRGBO(240, 226, 186, 1),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: _isSaving
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Simpan Perubahan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}