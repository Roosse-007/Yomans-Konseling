import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {

  // ================= SECURE STORAGE =================
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  // ================= PRIVATE STATE =================
  Map<String, dynamic>? _user;

  String? _token;

  bool _isLoading = true;

  // ================= CONSTRUCTOR =================
  AuthProvider() {
    loadSession();
  }

  // ================= GETTERS =================

  Map<String, dynamic>? get user =>
      _user;

  String? get token =>
      _token;

  bool get isLoading =>
      _isLoading;

  bool get isLogin =>
      _token != null &&
      _user != null;

  // ================= USER DATA =================

  int get userId {

    if (_user == null) {
      return 0;
    }

    return _user!['id'] ?? 0;
  }

  String get nama {

    if (_user == null) {
      return '';
    }

    return _user!['nama'] ?? '';
  }

  String get email {

    if (_user == null) {
      return '';
    }

    return _user!['email'] ?? '';
  }

  String get username {

    if (_user == null) {
      return '';
    }

    return _user!['username'] ?? '';
  }

  bool get isAdmin {

    if (_user == null) {
      return false;
    }

    return _user!['role'] == 'admin';
  }

  // ================= SAVE LOGIN =================
  Future<void> setLogin({

    required String token,

    required Map<String, dynamic> userData,

  }) async {

    try {

      // SET STATE
      _token = token;

      _user = userData;

      // SAVE TOKEN
      await _storage.write(
        key: 'token',
        value: token,
      );

      // SAVE USER
      await _storage.write(
        key: 'user',
        value: jsonEncode(userData),
      );

      notifyListeners();

    } catch (e) {

      debugPrint(
        'SET LOGIN ERROR: $e',
      );
    }
  }

  // ================= LOAD SESSION =================
  Future<void> loadSession() async {

    try {

      _isLoading = true;

      notifyListeners();

      // GET TOKEN
      final savedToken =
          await _storage.read(
        key: 'token',
      );

      // GET USER
      final savedUser =
          await _storage.read(
        key: 'user',
      );

      // CHECK SESSION
      if (
          savedToken != null &&
          savedUser != null
      ) {

        _token = savedToken;

        _user = jsonDecode(savedUser);
      }

    } catch (e) {

      debugPrint(
        'LOAD SESSION ERROR: $e',
      );

      _token = null;

      _user = null;

    } finally {

      _isLoading = false;

      notifyListeners();
    }
  }

  // ================= UPDATE USER =================
  Future<void> updateUser(
    Map<String, dynamic> newUser,
  ) async {

    try {

      _user = newUser;

      await _storage.write(
        key: 'user',
        value: jsonEncode(newUser),
      );

      notifyListeners();

    } catch (e) {

      debugPrint(
        'UPDATE USER ERROR: $e',
      );
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {

    try {

      _user = null;

      _token = null;

      // DELETE STORAGE
      await _storage.delete(
        key: 'token',
      );

      await _storage.delete(
        key: 'user',
      );

      notifyListeners();

    } catch (e) {

      debugPrint(
        'LOGOUT ERROR: $e',
      );
    }
  }

  // ================= CHECK TOKEN =================
  // OPTIONAL:
  // DIGUNAKAN UNTUK CEK TOKEN EXPIRED
  bool get hasToken =>
      _token != null &&
      _token!.isNotEmpty;
}