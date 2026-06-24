import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  // Properti privat yang disesuaikan dengan kolom database
  int? _id;
  String _email = '';
  String _username = '';
  String _role = 'user'; // Default sesuai DB: 'user'
  String? _fotoProfil; // Menggunakan String? karena di DB "Allow Null" bernilai true

  // Getter untuk mengambil data
  int? get id => _id;
  String get email => _email;
  String get username => _username;
  String get role => _role;
  String? get fotoProfil => _fotoProfil;

  // Fungsi untuk mengisi data setelah berhasil login atau mengambil data dari API/DB
  void setUser({
    required int id,
    required String email,
    required String username,
    required String role,
    String? fotoProfil,
  }) {
    _id = id;
    _email = email;
    _username = username;
    _role = role;
    _fotoProfil = fotoProfil;
    
    notifyListeners();
  }

  // Fungsi untuk mengupdate data profil (misal setelah panggil API update)
  void updateProfile({required String usernameBaru, String? fotoProfilBaru}) {
    _username = usernameBaru;
    _fotoProfil = fotoProfilBaru;
    
    // Memberitahu seluruh UI yang menggunakan data ini agar otomatis ter-update
    notifyListeners(); 
  }
  
  // Fungsi untuk membersihkan data saat user logout
  void logout() {
    _id = null;
    _email = '';
    _username = '';
    _role = 'user';
    _fotoProfil = null;
    notifyListeners();
  }
}