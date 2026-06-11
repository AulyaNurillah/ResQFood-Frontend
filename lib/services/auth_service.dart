import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../models/login_response.dart';

class AuthService {

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

      final loginResponse =
          LoginResponse.fromJson(data);

      await saveToken(
        loginResponse.token,
      );

      await saveUserRole(
        loginResponse.user.roles,
      );

      return loginResponse;
    }

    final error =
        jsonDecode(response.body);

    throw Exception(
      error["message"] ??
          "Login gagal",
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {

    final response = await http.post(
      Uri.parse(ApiConstants.register),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "fullName": fullName,
        "email": email,
        "password": password,
        "phone": phone,
      }),
    );

    if (response.statusCode == 201) {
      return;
    }

    final error =
        jsonDecode(response.body);

    throw Exception(
      error["message"] ??
          "Registrasi gagal",
    );
  }

  Future<void> forgotPassword(
    String email,
  ) async {

    final response = await http.post(
      Uri.parse(
        ApiConstants.forgotPassword,
      ),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "email": email,
      }),
    );

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(
      "Gagal mengirim reset password",
    );
  }

  Future<void> saveToken(
    String token,
  ) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      "token",
      token,
    );
  }

  Future<String?> getToken() async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
      "token",
    );
  }

  Future<void> saveUserRole(
    List<String> roles,
  ) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setStringList(
      "roles",
      roles,
    );
  }

  Future<List<String>> getRoles()
  async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getStringList(
            "roles") ??
        [];
  }

  Future<bool> isSeller()
  async {

    final roles =
        await getRoles();

    return roles.contains(
      "penjual",
    );
  }

  Future<Map<String, String>>
      getAuthHeaders() async {

    final token =
        await getToken();

    return {
      "Authorization":
          "Bearer $token",
      "Content-Type":
          "application/json",
    };
  }

  Future<void> logout() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();
  }
}