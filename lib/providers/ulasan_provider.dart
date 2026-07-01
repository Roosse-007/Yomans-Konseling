import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:yomans_konseling/models/ulasan_model.dart';

class UlasanProvider extends ChangeNotifier {
  static const String baseUrl = "http://127.0.0.1:5000/api";

  List<UlasanModel> _listUlasan = [];
  List<UlasanModel> get listUlasan => _listUlasan;

  bool _loading = false;
  bool get loading => _loading;

  double _rating = 0;
  double get rating => _rating;

  int _totalUlasan = 0;
  int get totalUlasan => _totalUlasan;

  // ======================================
  // AMBIL ULASAN DOKTER
  // ======================================

  Future<void> getUlasanDokter(int dokterId) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/dokter/$dokterId/ulasan"),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        debugPrint("DATA ULASAN = ${json["data"]}");

        _listUlasan = (json["data"] as List)
            .map((e) => UlasanModel.fromJson(e))
            .toList();
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint("ERROR ULASAN : $e");
    }

    _loading = false;
    notifyListeners();
  }

  // ======================================
  // AMBIL RATING
  // ======================================

  Future<void> getRatingDokter(int dokterId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/dokter/$dokterId/rating"),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        _rating =
            double.tryParse(json["data"]["rating"].toString()) ?? 0;

        _totalUlasan =
            int.tryParse(json["data"]["total"].toString()) ?? 0;

        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ======================================
  // TAMBAH ULASAN
  // ======================================

  Future<bool> tambahUlasan({
    required int bookingId,
    required int dokterId,
    required int userId,
    required int rating,
    required String komentar,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/ulasan"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "booking_id": bookingId,
          "dokter_id": dokterId,
          "user_id": userId,
          "rating": rating,
          "komentar": komentar,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // ======================================
  // EDIT ULASAN
  // ======================================

  Future<bool> editUlasan({
    required int id,
    required int rating,
    required String komentar,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/ulasan/$id"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "rating": rating,
          "komentar": komentar,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // ======================================
  // HAPUS ULASAN
  // ======================================

  Future<bool> hapusUlasan(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/ulasan/$id"),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // ======================================
  // REFRESH
  // ======================================

  Future<void> refresh(int dokterId) async {
    await getRatingDokter(dokterId);
    await getUlasanDokter(dokterId);
  }

  // ======================================
  // CLEAR
  // ======================================

  void clear() {
    _listUlasan.clear();
    _rating = 0;
    _totalUlasan = 0;
    notifyListeners();
  }
}