import 'package:flutter/material.dart';
import 'package:resqfood_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpgradeSellerScreen extends StatefulWidget {
  @override
  _UpgradeSellerScreenState createState() => _UpgradeSellerScreenState();
}

class _UpgradeSellerScreenState extends State<UpgradeSellerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _storeDescController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _storePhoneController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankAccountNameController = TextEditingController();
  final _idCardNumberController = TextEditingController();
  bool _isLoading = false;
  String? _idCardImageUrl; // nanti bisa tambah upload gambar KTP
  bool _isUploading = false;

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeDescController.dispose();
    _storeAddressController.dispose();
    _storePhoneController.dispose();
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankAccountNameController.dispose();
    _idCardNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.registerSeller({
        'storeName': _storeNameController.text.trim(),
        'storeDescription': _storeDescController.text.trim(),
        'storeAddress': _storeAddressController.text.trim(),
        'storePhone': _storePhoneController.text.trim(),
        'bankName': _bankNameController.text.trim(),
        'bankAccountNumber': _bankAccountNumberController.text.trim(),
        'bankAccountName': _bankAccountNameController.text.trim(),
        'idCardNumber': _idCardNumberController.text.trim(),
        'idCardImageUrl': _idCardImageUrl ?? '',
      });
      if (response.containsKey('profile')) {
        // Update role di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final userResponse = await ApiService.getProfile(); // ambil ulang user
        final newRoles = List<String>.from(userResponse['roles'] ?? ['pembeli']);
        await prefs.setStringList('roles', newRoles);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pendaftaran penjual berhasil!')),
        );
        Navigator.pushReplacementNamed(context, '/dashboard'); // kembali ke dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Gagal mendaftar')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(203, 222, 211, 1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromRGBO(203, 222, 211, 1),
        title: Text('Daftar Menjadi Penjual', style: TextStyle(color: Color.fromRGBO(19, 59, 31, 1))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromRGBO(19, 59, 31, 1)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  labelText: 'Nama Toko *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _storeDescController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Toko (opsional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _storeAddressController,
                decoration: InputDecoration(
                  labelText: 'Alamat Toko *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _storePhoneController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon Toko',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _bankNameController,
                decoration: InputDecoration(
                  labelText: 'Nama Bank',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _bankAccountNumberController,
                decoration: InputDecoration(
                  labelText: 'Nomor Rekening',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _bankAccountNameController,
                decoration: InputDecoration(
                  labelText: 'Nama Pemilik Rekening',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _idCardNumberController,
                decoration: InputDecoration(
                  labelText: 'Nomor KTP (NIK) *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 24),
              // Upload KTP bisa ditambahkan nanti
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(59, 98, 85, 1),
                    foregroundColor: Color.fromRGBO(240, 226, 186, 1),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isLoading ? CircularProgressIndicator() : Text('Daftar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}