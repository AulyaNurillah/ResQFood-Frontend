import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  // Helper header dengan token
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _parseResponse(http.Response response) {
    final status = response.statusCode;
    try {
      final data = jsonDecode(response.body);
      if (status >= 200 && status < 300) return data;
      // Jika status error, lempar Exception dengan pesan yang cocok
      throw Exception(data is Map && (data['message'] ?? data['error']) != null
          ? (data['message'] ?? data['error'])
          : response.body);
    } catch (e) {
      if (status >= 200 && status < 300) return response.body;
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // Auth
  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/api/auth/forgotpassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<Map<String, dynamic>> resetPassword(String accessToken, String newPassword) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/api/auth/resetpassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'access_token': accessToken, 'new_password': newPassword}),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  // Products
  static Future<List<dynamic>> getProducts({String? category, String? search}) async {
  final Map<String, String> queryParams = {};
  if (category != null) queryParams['category'] = category;
  if (search != null && search.isNotEmpty) queryParams['search'] = search;
  final uri = Uri.parse('${Constants.baseUrl}/api/products').replace(queryParameters: queryParams);
  final response = await http.get(uri);
  final data = _parseResponse(response);
  if (data is List) return data;
  if (data is Map && data['products'] != null) return List<dynamic>.from(data['products']);
  return [];
  }

  static Future<Map<String, dynamic>> getProductById(String id) async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/api/products/$id'));
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/api/products'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  // Orders
  static Future<Map<String, dynamic>> createOrder(String productId, int quantity) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/api/orders'),
      headers: await _getHeaders(),
      body: jsonEncode({'productId': productId, 'quantity': quantity}),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('${Constants.baseUrl}/api/orders/$orderId/accept'),
      headers: await _getHeaders(),
      body: jsonEncode({}),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<Map<String, dynamic>> cancelOrder(String orderId) async {
  final response = await http.put(
    Uri.parse('${Constants.baseUrl}/api/orders/$orderId/cancel'),
    headers: await _getHeaders(),
    body: jsonEncode({}),
  );
  return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<Map<String, dynamic>> scanQr(String qrToken) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/api/orders/scan'),
      headers: await _getHeaders(),
      body: jsonEncode({'qrToken': qrToken}),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<List<dynamic>> getMyOrders() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/orders/myorders'),
      headers: await _getHeaders(),
    );
    debugPrint(
      "MY ORDERS => ${response.body}",
    );
  final data = _parseResponse(response);
  if (data is List) return data;
  if (data is Map && data['orders'] != null) return List<dynamic>.from(data['orders']);
  return [];
}

  static Future<List<dynamic>> getMySales() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/orders/mysales'),
      headers: await _getHeaders(),
    );
    debugPrint(
      "MY SALES => ${response.body}",
    );
  final data = _parseResponse(response);
  if (data is List) return data;
  if (data is Map && data['sales'] != null) return List<dynamic>.from(data['sales']);
  if (data is Map && data['orders'] != null) return List<dynamic>.from(data['orders']);
  return [];
}

  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/orders/$orderId'),
      headers: await _getHeaders(),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  // Chat
  static Future<Map<String, dynamic>> sendMessage(String orderId, String message) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/api/chat/send'),
      headers: await _getHeaders(),
      body: jsonEncode({'orderId': orderId, 'message': message}),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<List<dynamic>> getMessages(String orderId) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/chat/order/$orderId'),
      headers: await _getHeaders(),
    );
    debugPrint(
      "GET MESSAGES => ${response.body}",
    );
  final data = _parseResponse(response);
  if (data is List) return data;
  if (data is Map && data['messages'] != null) return List<dynamic>.from(data['messages']);
  return [];
}

  // Notifications
  static Future<List<dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/notifications'),
      headers: await _getHeaders(),
    );
    final data = _parseResponse(response);
    if (data is List) return data;
    if (data is Map && data['notifications'] != null) return List<dynamic>.from(data['notifications']);
    return [];
  }

  static Future<void> markNotificationRead(String id) async {
    final response = await http.put(
      Uri.parse('${Constants.baseUrl}/api/notifications/$id/read'),
      headers: await _getHeaders(),
    );
    _parseResponse(response);
  }

  // User Profile
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/users/profile'),
      headers: await _getHeaders(),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${Constants.baseUrl}/api/users/profile'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<Map<String, dynamic>> upgradeToSeller() async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/api/users/upgradetoseller'),
      headers: await _getHeaders(),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<Map<String, dynamic>> registerSeller(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/api/users/registerseller'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<Map<String, dynamic>> getSellerStatus() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/users/sellerstatus'),
      headers: await _getHeaders(),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  // Additional helpers
  static Future<void> deleteMessage(String messageId) async {
    final response = await http.delete(
      Uri.parse('${Constants.baseUrl}/api/chat/messages/$messageId'),
      headers: await _getHeaders(),
    );
    _parseResponse(response);
  }

  static Future<void> markMessageRead(String messageId) async {
    final response = await http.put(
      Uri.parse('${Constants.baseUrl}/api/chat/messages/$messageId/read'),
      headers: await _getHeaders(),
    );
    _parseResponse(response);
  }

  static Future<Map<String, dynamic>> updateProduct(String productId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${Constants.baseUrl}/api/products/$productId'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<void> deleteProduct(String productId) async {
    final response = await http.delete(
      Uri.parse('${Constants.baseUrl}/api/products/$productId'),
      headers: await _getHeaders(),
    );
    _parseResponse(response);
  }

  static Future<void> deleteUser() async {
    final response = await http.delete(
      Uri.parse('${Constants.baseUrl}/api/users'),
      headers: await _getHeaders(),
    );
    _parseResponse(response);
  }

  static Future<Map<String, dynamic>> uploadProfilePicture(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Constants.baseUrl}/api/users/profilepicture'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('avatar', filePath));
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    final parsed = jsonDecode(responseData);
    if (parsed is Map) return Map<String, dynamic>.from(parsed);
    return {'result': responseData};
  }

  // Upload product image
  static Future<String> uploadProductImage(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Constants.baseUrl}/api/upload/productimage'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('image', filePath));
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseData);
    if (jsonResponse is Map && jsonResponse['url'] != null) return jsonResponse['url'];
    throw Exception('Failed to upload image');
  }

  // Stats
  static Future<Map<String, dynamic>> getBuyerStats() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/stats/buyer'),
      headers: await _getHeaders(),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<Map<String, dynamic>> getSellerStats() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/stats/seller'),
      headers: await _getHeaders(),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<List<dynamic>> getMyProducts() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/products/mine'),
      headers: await _getHeaders(),
    );
    final data = _parseResponse(response);
    if (data is List) return data;
    if (data is Map && data['products'] != null) return List<dynamic>.from(data['products']);
    return [];
  }

  // Sellers (maps)
  static Future<Map<String, dynamic>> getSellerDetail(String sellerId) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/sellers/$sellerId'),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<List<dynamic>> getNearbySellers(double lat, double lng, {int radius = 10}) async {
    final uri = Uri.parse('${Constants.baseUrl}/api/sellers/nearby').replace(queryParameters: {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'radius': radius.toString(),
    });
    final response = await http.get(uri);
    final data = _parseResponse(response);
    if (data is List) return data;
    if (data is Map && data['sellers'] != null) return List<dynamic>.from(data['sellers']);
    return [];
  }

  // Ratings
  static Future<Map<String, dynamic>> createRating(String orderId, int rating, {String? review}) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/api/ratings'),
      headers: await _getHeaders(),
      body: jsonEncode({'orderId': orderId, 'rating': rating, 'review': review}),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }

  static Future<Map<String, dynamic>> getRatingsForSeller(String sellerId) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/ratings/seller/$sellerId'),
      headers: await _getHeaders(),
    );
    return Map<String, dynamic>.from(_parseResponse(response));
  }
}