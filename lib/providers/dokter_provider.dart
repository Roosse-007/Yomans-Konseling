import 'dart:convert';
import 'dart:typed_data'; // Penting untuk membaca gambar di Web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DokterProvider with ChangeNotifier {

  // ================= BASE URL =================
  // Karena running di Web Chrome, wajib menggunakan localhost / 127.0.0.1
  final String _baseUrl = 'http://127.0.0.1:5000/api';

  // ================= DATA AWAL =================
  List<Map<String, dynamic>> _listDokter = [
    {
      "id": 1,
      "nama": "Ira Febriana M.Psi.,Psikolog",
      "tags": ["Keluarga", "Kecemasan", "Percintaan"],
      "jadwal": "Hari ini, 18.00 WIB",
      "image_url": "lib/assets/ira1.png",
      "harga": 150000
    },
    {
      "id": 2,
      "nama": "Lil Roosse K.Ing.,Petarunkx",
      "tags": ["Keluarga", "Kecemasan", "Perkelahian"],
      "jadwal": "Hari ini, 19.00 WIB",
      "image_url": "lib/assets/gue1.png",
      "harga": 120000
    },
    {
      "id": 3,
      "nama": "Teguh B.K., M.Psi",
      "tags": ["Keluarga", "Kecemasan"],
      "jadwal": "Besok, 10.00 WIB",
      "image_url": "lib/assets/teguh.png",
      "harga": 100000
    },
  ];

  List<Map<String, dynamic>> get listDokter => _listDokter;

  // ================= FETCH DATA =================
  Future<void> fetchDokter() async {
    final String url = '$_baseUrl/dokter';
    try {
      final response = await http.get(Uri.parse(url));

      print("FETCH STATUS: ${response.statusCode}");
      print("FETCH BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List<Map<String, dynamic>> dataDariDatabase =
              List<Map<String, dynamic>>.from(data['data']);

          _listDokter = dataDariDatabase;
          notifyListeners();
        }
      }
    } catch (e) {
      print("Gagal fetch dokter: $e");
    }
  }

  // ================= TAMBAH DOKTER (KHUSUS WEB) =================
  Future<bool> tambahDokter(Map<String, dynamic> dokterBaru) async {
    final String url = '$_baseUrl/admin/dokter';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // ================= FIELD TEKS =================
      request.fields['nama'] = dokterBaru["nama"].toString();
      request.fields['spesialis'] = dokterBaru["spesialis"].toString();
      request.fields['harga'] = dokterBaru["harga"].toString();

      // ================= FOTO KHUSUS WEB =================
      // Di Web, kita menangkap data gambar via bytes memori, bukan via path file lokal.
      if (dokterBaru["imageBytes"] != null && dokterBaru["imageName"] != null) {
        Uint8List bytes = dokterBaru["imageBytes"];

        request.files.add(
          http.MultipartFile.fromBytes(
            'foto', // Harus sama dengan key di Flask kamu
            bytes,
            filename: dokterBaru["imageName"],
          ),
        );
        print("Foto bytes berhasil dimasukkan ke multipart (Web)");
      } else {
        print("Foto tidak ditemukan atau kosong");
      }

      // ================= SEND DATA =================
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("STATUS CODE: ${response.statusCode}");
      print("BODY RESPONSE: ${response.body}");

      // ================= SUCCESS =================
      if (response.statusCode == 201) {
        await fetchDokter(); // Sinkronisasi ulang data setelah berhasil menyimpan
        return true;
      }
      return false;

    } catch (e) {
      print("ERROR TAMBAH DOKTER: $e");
      return false;
    }
  }

  // ================= HAPUS DOKTER =================
  Future<bool> hapusDokter(int id) async {
    final String url = '$_baseUrl/admin/dokter/$id';
    try {
      final response = await http.delete(Uri.parse(url));
      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        _listDokter.removeWhere((dokter) => dokter['id'] == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("ERROR HAPUS DOKTER: $e");
    }
    return false;
  }

  // ================= BOOKING =================
  Future<Map<String, dynamic>> buatBooking({
    required int userId,
    required int dokterId,
    required String tanggal,
    required String keluhan,
    required int duration,
  }) async {
    final String url = '$_baseUrl/booking';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "dokter_id": dokterId,
          "tanggal": tanggal,
          "keluhan": keluhan,
          "duration": duration,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        "status": "error",
        "message": e.toString(),
      };
    }
  }
}