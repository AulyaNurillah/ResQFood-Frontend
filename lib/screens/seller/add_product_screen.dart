import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  
  String? _selectedCategory = "Restoran";
  DateTime? _expiredDate;
  File? _imageFile;
  bool _isLoading = false;

  final List<String> _categories = ["Restoran", "Hotel", "Cafe", "Bakery", "UMKM"];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil gambar: $e");
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF234A3E)),
              title: const Text('Ambil Foto Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF234A3E)),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF234A3E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF234A3E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _expiredDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih foto produk terlebih dahulu')),
        );
      }
      return;
    }
    if (_expiredDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan tentukan tanggal kadaluwarsa')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload Gambar
      final imageUrl = await ApiService.uploadProductImage(_imageFile!.path);

      // 2. Simpan Produk
      final response = await ApiService.createProduct({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': int.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'imageUrl': imageUrl,
        'category': _selectedCategory,
        'expiredDate': _expiredDate!.toIso8601String(),
        'status': 'tersedia',
      });

      if (response['id'] != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil dipublish!'), backgroundColor: Colors.green),
          );
        }
        // Clear form
        _nameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _stockController.clear();
        setState(() {
          _imageFile = null;
          _expiredDate = null;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? 'Gagal mempublish produk')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBDED3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCBDED3),
        elevation: 0,
        title: const Text('Tambah Produk', style: TextStyle(color: Color(0xFF133B1F), fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Yuk, bantu kurangi limbah makanan dengan berbagi produk berkualitas hari ini.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF234A3E), fontSize: 14),
              ),
              const SizedBox(height: 24),

              // UPLOAD BOX
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF9BB0A5), width: 1.5),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 50, color: Color(0xFF234A3E)),
                            SizedBox(height: 8),
                            Text(
                              "Klik untuk foto\nJPG, PNG, atau WEBP (Max 5MB)",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF234A3E), fontSize: 13),
                            )
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // NAMA PRODUK
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Produk',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // KATEGORI DROPDOWN
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // EXPIRED DATE
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _expiredDate == null
                            ? 'Tanggal Kadaluwarsa'
                            : DateFormat('dd MMMM yyyy').format(_expiredDate!),
                        style: TextStyle(color: _expiredDate == null ? Colors.grey.shade600 : Colors.black, fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, color: Color(0xFF234A3E)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // JUMLAH STOCK
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah Stock',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null) return 'Harus angka';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // HARGA
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga (Rp)',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null) return 'Harus angka';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CATATAN & DESKRIPSI
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Catatan & Deskripsi',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF234A3E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Publish Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
