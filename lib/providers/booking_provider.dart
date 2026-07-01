import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = "http://127.0.0.1:5000/api";

class BookingProvider extends ChangeNotifier {
  bool loading = false;

  Map<String, dynamic>? booking;

  Future<bool> getDetailBooking(int bookingId) async {
    loading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/booking/$bookingId/detail"),
      );

      final result = jsonDecode(response.body);

      if (result["status"] == "success") {
        booking = result["data"];
      }

      loading = false;
      notifyListeners();

      return result["status"] == "success";
    } catch (e) {
      debugPrint(e.toString());

      loading = false;
      notifyListeners();

      return false;
    }
  }
  List<Map<String, dynamic>> bookingHistory = [];

Future<bool> getHistoryBooking(int userId) async {
  loading = true;
  notifyListeners();

  try {
    final response = await http.get(
      Uri.parse("$baseUrl/history-booking/$userId"),
    );

    final result = jsonDecode(response.body);

    if (result["status"] == "success") {
      bookingHistory =
          List<Map<String, dynamic>>.from(result["data"]);
    }

    loading = false;
    notifyListeners();

    return result["status"] == "success";
  } catch (e) {
    debugPrint(e.toString());

    loading = false;
    notifyListeners();

    return false;
  }
}
}