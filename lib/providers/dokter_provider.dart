import 'dart:convert';
import 'dart:typed_data'; // Penting untuk membaca gambar di Web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DokterProvider with ChangeNotifier {

  // ================= BASE URL =================
  // Karena running di Web Chrome, wajib menggunakan localhost / 127.0.0.1
  final String _baseUrl = 'http://127.0.0.1:5000/api';

  // ================= DATA AWAL =================
 // ================= DATA AWAL =================
List<Map<String, dynamic>> _listDokter = [];

List<Map<String, dynamic>> get listDokter => _listDokter;

// ================= FETCH DATA (FIXED TOTAL) =================
  Future<void> fetchDokter() async {
    final String url = '$_baseUrl/dokter';
    try {
      final response = await http.get(Uri.parse(url));

      print("--- DEBUG AMBIL DATA ---");
      print("BODY RESPONS SERVER: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        List<dynamic> rawData = [];

        // 1. Jika respons langsung berbentuk List []
        if (decodedData is List) {
          rawData = decodedData;
        } 
        // 2. Jika respons berbentuk Map {} dan memiliki key 'data'
        else if (decodedData is Map && decodedData.containsKey('data')) {
          rawData = decodedData['data'] ?? [];
        } 
        // 3. JIKA TERNYATA MEREK RELEASING REPSONS SEPERTI LOG ANDA (Hanya info sukses, bukan data)
        else if (decodedData is Map && decodedData['status'] == 'success' && !decodedData.containsKey('data')) {
          print("⚠️ PERINGATAN: Endpoint API Anda mengembalikan status sukses, tapi TIDAK ada data array dokternya!");
          return; // Hentikan di sini agar tidak crash mengecek data kosong
        }

        List<Map<String, dynamic>> dataDariDatabase = rawData.map((dokterRaw) {
          Map<String, dynamic> dokter = Map<String, dynamic>.from(dokterRaw);

          String imgUrl = dokter['image_url'] ?? '';
          dokter['is_local_asset'] = !imgUrl.startsWith('http');
          dokter['image_url'] = imgUrl;

          // --- Normalisasi Tags ---
          List<String> parsedTags = [];
          if (dokter['tags'] != null && dokter['tags'].toString() != 'null') {
            var rawTags = dokter['tags'];
            if (rawTags is List) {
              parsedTags = List<String>.from(rawTags);
            } else if (rawTags is String) {
              String tagsString = rawTags.trim();
              if (tagsString.startsWith('[') && tagsString.endsWith(']')) {
                tagsString = tagsString.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').replaceAll("'", "");
              }
              parsedTags = tagsString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            }
          }
          
          dokter['tags'] = parsedTags.isEmpty ? ['Umum'] : parsedTags;
          dokter['jadwal'] = dokter['jadwal'] ?? 'Belum ada jadwal';

// =====================
// NORMALISASI HARGA
// =====================
          final int hargaAwal = double.tryParse(dokter['harga_awal'].toString())?.toInt() ?? 0;
          final int hargaDiskon = double.tryParse(dokter['harga_diskon'].toString())?.toInt() ?? 0;

// Simpan kembali ke map
dokter['harga_awal'] = hargaAwal;
dokter['harga_diskon'] = hargaDiskon;

// =====================
// HITUNG DISKON OTOMATIS
// =====================

int diskon = 0;

if (hargaAwal > 0 && hargaDiskon > 0) {
            diskon = (((hargaAwal - hargaDiskon) / hargaAwal) * 100).round();
}

dokter['diskon'] = diskon;

print("DEBUG DOKTER:");
print(dokter);

          return dokter;
        }).toList();

        _listDokter = dataDariDatabase;
        notifyListeners();
        print("BERHASIL: ${_listDokter.length} dokter dimuat.");
      } else {
        print("Server error dengan kode status: ${response.statusCode}");
      }
    } catch (e) {
      print("Gagal fetch dokter karena format salah: $e");
    }
  }

  // ================= TAMBAH DOKTER (KHUSUS WEB) =================
  Future<bool> tambahDokter(Map<String, dynamic> dokterBaru) async {
    final String url = '$_baseUrl/admin/dokter';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['nama'] = dokterBaru["nama"].toString();
      request.fields['tags'] = dokterBaru["tags"].toString(); 
      request.fields['harga_awal'] =
    dokterBaru["harga_awal"].toString();

request.fields['harga_diskon'] =
    dokterBaru["harga_diskon"].toString();
      request.fields['jadwal'] = dokterBaru["jadwal"].toString();
      request.fields['harga_awal'] = dokterBaru["harga_awal"].toString();
      request.fields['harga_diskon'] = dokterBaru["harga_diskon"].toString();
      request.fields['jadwal'] = dokterBaru["jadwal"].toString();
      request.fields['durasi'] = dokterBaru["durasi"].toString();

      // ================= FOTO KHUSUS WEB =================
      if (dokterBaru["imageBytes"] != null && dokterBaru["imageName"] != null) {
        Uint8List bytes = dokterBaru["imageBytes"];

        request.files.add(
          http.MultipartFile.fromBytes(
            'foto', 
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
        await fetchDokter(); 
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

  // ================= EDIT DOKTER (SUDAH DIPERBAIKI DI DALAM CLASS) =================
  Future<bool> editDokter(Map<String, dynamic> data) async {
  try {
    final id = data['id'];
    final url = Uri.parse("http://localhost:5000/api/admin/dokter/$id/update");
    
    // Gunakan MultipartRequest untuk mengirim teks DAN file sekaligus
    var request = http.MultipartRequest("POST", url);

    // 1. Tambahkan semua field teks
    request.fields['nama'] = data['nama'].toString();
    request.fields['tags'] = data['tags'].toString();
    request.fields['jadwal'] = data['jadwal'].toString();
    request.fields['harga_awal'] = data['harga_awal'].toString();
    request.fields['harga_diskon'] = data['harga_diskon'].toString();
    request.fields['durasi'] = data['durasi'].toString();

    // 2. Tambahkan file hanya jika ada perubahan gambar
    if (data['imageBytes'] != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'foto',
        data['imageBytes'] as List<int>,
        filename: "dokter_$id.png", // Nama fix untuk menghindari karakter aneh
      ));
    }

    // 3. Kirim request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print("Update Berhasil: ${response.body}");
      return true;
    } else {
      print("Update Gagal: ${response.statusCode} - ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error saat update: $e");
    return false;
    }
  }
}