import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  String? _selectedCategory = 'Restoran';
  DateTime? _expiredDate;
  File? _imageFile;
  bool _isLoading = false;
  String? _productId;

  final List<String> _categories = ["Restoran", "Hotel", "Cafe", "Bakery", "UMKM"];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['product'] != null) {
      final p = args['product'] as Map;
      _productId = p['id']?.toString();
      _nameController.text = p['name'] ?? '';
      _descriptionController.text = p['description'] ?? '';
      _priceController.text = (p['price'] ?? '').toString();
      _stockController.text = (p['stock'] ?? '').toString();
      _selectedCategory = p['category'] ?? _selectedCategory;
      try {
        if (p['expiredDate'] != null && p['expiredDate'].toString().isNotEmpty) {
          _expiredDate = DateTime.parse(p['expiredDate']);
        }
      } catch (_) {}
    }
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
      debugPrint('Gagal mengambil gambar: $e');
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiredDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _expiredDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await ApiService.uploadProductImage(_imageFile!.path);
      }

      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': int.tryParse(_priceController.text) ?? 0,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'category': _selectedCategory,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (_expiredDate != null) 'expiredDate': _expiredDate!.toIso8601String(),
      };

      if (_productId != null) {
        final res = await ApiService.updateProduct(_productId!, data);
        if (res['id'] != null) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil diperbarui'), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['error'] ?? 'Gagal memperbarui produk')));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk'),
        backgroundColor: const Color(0xFFCBDED3),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Ambil Foto'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Pilih Galeri'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255,255,255,0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_imageFile!, fit: BoxFit.cover))
                      : const Center(child: Icon(Icons.add_a_photo, size: 48)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Produk', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(labelText: 'Kategori', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _priceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _stockController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Stock', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_expiredDate == null ? 'Tanggal Kadaluwarsa' : DateFormat('dd MMM yyyy').format(_expiredDate!)),
                      const Icon(Icons.calendar_today)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Update Produk'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
