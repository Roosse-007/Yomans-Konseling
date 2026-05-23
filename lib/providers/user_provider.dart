import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  // Data dummy awal user
  String _nama = 'Albert Florest';
  String _peran = 'Client';
  String _imageUrl = 'https://via.placeholder.com/150';

  // Getter untuk mengambil data
  String get nama => _nama;
  String get peran => _peran;
  String get imageUrl => _imageUrl;

  // Fungsi untuk mengupdate data profil dari halaman edit profile
  void updateProfile({required String namaBaru, required String imageUrlBaru}) {
    _nama = namaBaru;
    _imageUrl = imageUrlBaru;
    
    // Memberitahu seluruh UI yang menggunakan data ini agar otomatis ter-update
    notifyListeners(); 
  }
}