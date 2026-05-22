import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {

  Map<String, dynamic>? _user;

  // ================= CONSTRUCTOR =================
  // AUTO LOAD SESSION SAAT REFRESH
  AuthProvider() {
    loadSession();
  }

  // ================= GET USER =================
  Map<String, dynamic>? get user => _user;

  // ================= SET USER =================
  // DIPANGGIL SAAT LOGIN BERHASIL
  Future<void> setUser(
    Map<String, dynamic> data,
  ) async {

    _user = data;

    notifyListeners();

    // SIMPAN SESSION KE LOCAL STORAGE
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'user_session',
      jsonEncode(data),
    );
  }

  // ================= LOAD SESSION =================
  // DIPANGGIL OTOMATIS SAAT APP REFRESH
  Future<void> loadSession() async {

    final prefs =
        await SharedPreferences.getInstance();

    final String? userString =
        prefs.getString('user_session');

    if (userString != null) {

      _user = jsonDecode(userString);

      notifyListeners();
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {

    _user = null;

    notifyListeners();

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('user_session');
  }

  // ================= CEK LOGIN =================
  bool get isLogin =>
      _user != null;

  // ================= GET NAMA USER =================
  String get nama {

    if (_user == null) {
      return '';
    }

    return _user!['nama'] ?? '';
  }

  // ================= GET USER ID =================
  int get userId {

    if (_user == null) {
      return 0;
    }

    return _user!['id'] ?? 0;
  }

  // ================= CEK ADMIN =================
  bool get isAdmin {

    if (_user == null) {
      return false;
    }

    return _user!['role'] == 'admin';
  }

  // ================= GET EMAIL =================
  String get email {

    if (_user == null) {
      return '';
    }

    return _user!['email'] ?? '';
  }

  // ================= GET USERNAME =================
  String get username {

    if (_user == null) {
      return '';
    }

    return _user!['username'] ?? '';
  }
}