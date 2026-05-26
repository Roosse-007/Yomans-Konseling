import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DokterProvider with ChangeNotifier {
  List<Map<String, dynamic>> _listDokter = [
    {
      "id": 1,
      "nama": "Ira Febriana M.Psi.,Psikolog",
      "tags": ["Keluarga", "Kecemasan", "Percintaan"],
      "jadwal": "Hari ini, 18.00 WIB",
      "image_url": "lib/assets/ira1.png"
    },
    {
      "id": 2,
      "nama": "Lil Roosse K.Ing.,Petarunkx",
      "tags": ["Keluarga", "Kecemasan", "Perkelahian"],
      "jadwal": "Hari ini, 19.00 WIB",
      "image_url": "lib/assets/gue1.png"
    },
    {
      "id": 3,
      "nama": "Teguh B.K., M.Psi",
      "tags": ["Keluarga", "Kecemasan"],
      "jadwal": "Besok, 10.00 WIB",
      "image_url": "lib/assets/teguh.png"
    },
  ];

  List<Map<String, dynamic>> get listDokter => _listDokter;

  Future<void> fetchDokter() async {
    // Dipanggil di home, biarkan kosong dulu karena menggunakan data awal di atas
  }

  Future<bool> tambahDokter(Map<String, dynamic> dokterBaru) async {
    dokterBaru['id'] = _listDokter.length + 1; 
    _listDokter.add(dokterBaru);
    notifyListeners();
    return true;
  }

  Future<bool> hapusDokter(int id) async {
    _listDokter.removeWhere((dokter) => dokter['id'] == id);
    notifyListeners();
    return true;
  }
}
// Method baru untuk menembak API Flask Booking
  Future<Map<String, dynamic>> buatBooking({
    required int userId,
    required int dokterId,
    required String tanggal,
    required String keluhan,
    required int duration,
  }) async {
    final String url = 'http://10.0.2.2:5000/api/booking'; // Gunakan 10.0.2.2 jika testing via Emulator Android

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "dokter_id": dokterId,
          "tanggal": tanggal,
          "keluhan": keluhan,
          "duration": duration, // <-- Mengirim durasi dinamis yang dipilih user dari UI
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }