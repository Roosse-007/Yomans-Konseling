import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = "http://127.0.0.1:5000";

class PembayaranProvider extends ChangeNotifier {
  bool loading = false;

  List pembayaran = [];

  Future<void> getPembayaran() async {
    loading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/admin/pembayaran"),
      );

      final result = jsonDecode(response.body);

      if (result["status"] == "success") {
        pembayaran = result["data"];
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> konfirmasiPembayaran(int pembayaranId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/admin/konfirmasi_pembayaran"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "pembayaran_id": pembayaranId,
        }),
      );

      final result = jsonDecode(response.body);

      if (result["status"] == "success") {
        await getPembayaran();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}