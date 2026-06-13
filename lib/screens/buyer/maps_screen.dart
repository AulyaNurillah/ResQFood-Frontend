import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/api_service.dart';
import '../../constants/app_colors.dart';
import 'product_detail_screen.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(-8.1689, 113.7022); // Default Jember
  List<dynamic> _sellers = [];
  bool _isLoading = true;
  dynamic _selectedSeller;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          Position position = await Geolocator.getCurrentPosition();
          if (mounted) {
            setState(() {
              _currentPosition = LatLng(position.latitude, position.longitude);
            });
            _mapController.move(_currentPosition, 14);
          }
        }
      }
    } catch (e) {
      debugPrint("Gagal mengambil lokasi GPS: $e");
    }

    await _fetchSellers();
  }

  Future<void> _fetchSellers() async {
    try {
      final sellersData = await ApiService.getNearbySellers(
        _currentPosition.latitude,
        _currentPosition.longitude,
      );
      if (mounted) {
        setState(() {
          _sellers = sellersData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching sellers: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lokasi Penjual Terdekat', style: TextStyle(color: Color(0xFF133B1F), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFCBDED3),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // MAPS VIEW
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.resqfood.app',
              ),
              MarkerLayer(
                markers: [
                  // Current Position Marker
                  Marker(
                    point: _currentPosition,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  // Seller Markers
                  ..._sellers.map((seller) {
                    final lat = double.tryParse(seller['latitude']?.toString() ?? '') ?? _currentPosition.latitude + 0.005;
                    final lng = double.tryParse(seller['longitude']?.toString() ?? '') ?? _currentPosition.longitude + 0.005;
                    return Marker(
                      point: LatLng(lat, lng),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSeller = seller;
                          });
                        },
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 38,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_sellers.isEmpty)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.white.withOpacity(0.9),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Tidak ditemukan penjual di sekitar lokasi Anda saat ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF234A3E), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          // Seller Details Bottom Sheet/Panel
          if (_selectedSeller != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B6255),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedSeller['store_name'] ?? _selectedSeller['full_name'] ?? 'Penjual ResQFood',
                            style: const TextStyle(
                              color: Color(0xFFF0E2BA),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () {
                            setState(() {
                              _selectedSeller = null;
                            });
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFF0E2BA), size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _selectedSeller['store_address'] ?? _selectedSeller['address'] ?? 'Alamat toko tidak tersedia',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF234A3E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon: const Icon(Icons.directions),
                            label: const Text('Get Directions'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Membuka rute ke penjual...')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          backgroundColor: const Color(0xFF234A3E),
                          child: IconButton(
                            icon: const Icon(Icons.phone, color: Colors.white),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Menghubungi ${_selectedSeller['store_phone'] ?? 'penjual'}...')),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
