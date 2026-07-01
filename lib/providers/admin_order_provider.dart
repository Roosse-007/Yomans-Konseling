import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminOrderProvider with ChangeNotifier {

  final String _baseUrl = "http://127.0.0.1:5000/api";

  bool _loading = false;

  bool get loading => _loading;

  List<dynamic> _orders = [];

  List<dynamic> get orders => _orders;

  // ===========================
  // GET ALL ORDER
  // ===========================
  Future<void> getOrders() async {

    _loading = true;
    notifyListeners();

    try {

      final response = await http.get(
        Uri.parse("$_baseUrl/admin/orders"),
      );

      final json = jsonDecode(response.body);

      if (json["status"] == "success") {

        _orders = json["data"];

      }

    } catch (e) {

      debugPrint(e.toString());

    }

    _loading = false;

    notifyListeners();

  }

  // ===========================
  // CONFIRM
  // ===========================
  Future<Map<String,dynamic>> confirmOrder(
      int bookingId) async {

    try {

      final response = await http.put(

        Uri.parse(
          "$_baseUrl/admin/orders/$bookingId/confirm",
        ),

      );

      return jsonDecode(response.body);

    } catch (e) {

      return {

        "status":"error",

        "message":e.toString(),

      };

    }

  }

  // ===========================
  // REJECT
  // ===========================
  Future<Map<String,dynamic>> rejectOrder(
      int bookingId) async {

    try {

      final response = await http.put(

        Uri.parse(
          "$_baseUrl/admin/orders/$bookingId/reject",
        ),

      );

      return jsonDecode(response.body);

    } catch (e) {

      return {

        "status":"error",

        "message":e.toString(),

      };

    }

  }

}