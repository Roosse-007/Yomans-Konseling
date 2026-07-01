import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = "http://127.0.0.1:5000/api";

class BookingProvider extends ChangeNotifier {
  bool loading = false;
  Map<String, dynamic>? booking;
  List<Map<String, dynamic>> bookingHistory = [];

  Future<bool> getDetailBooking(int bookingId) async {
    loading = true;
    booking = null; // Reset data lama agar tidak muncul data cross-booking
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/booking/$bookingId/detail"),
      );

      // PASTIKAN SERVER MERESPON DENGAN 200 OK
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result["status"] == "success") {
          booking = result["data"];
          loading = false;
          notifyListeners();
          return true;
        }
      }
      
      // Jika status code bukan 200 atau status json bukan success
      debugPrint("Gagal memuat detail booking: ${response.body}");
      loading = false;
      notifyListeners();
      return false;

    } catch (e) {
      debugPrint("Error getDetailBooking: ${e.toString()}");
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> getHistoryBooking(int userId) async {
    loading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/history-booking/$userId"),
      );

      // PASTIKAN SERVER MERESPON DENGAN 200 OK
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result["status"] == "success") {
          bookingHistory = List<Map<String, dynamic>>.from(result["data"]);
          loading = false;
          notifyListeners();
          return true;
        }
      }

      debugPrint("Gagal memuat history booking: ${response.body}");
      loading = false;
      notifyListeners();
      return false;

    } catch (e) {
      debugPrint("Error getHistoryBooking: ${e.toString()}");
      loading = false;
      notifyListeners();
      return false;
    }
  }
}