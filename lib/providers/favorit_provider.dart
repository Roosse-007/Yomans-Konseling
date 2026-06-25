import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FavoritProvider with ChangeNotifier {

  final String _baseUrl =
      'http://127.0.0.1:5000/api';

  List<int> _favoritDokter = [];

  List<int> get favoritDokter =>
      _favoritDokter;

  // ================= GET FAVORIT =================
  Future<void> fetchFavorit(
    int userId,
  ) async {

    try {

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/favorit/$userId',
        ),
      );

      final data =
          jsonDecode(response.body);

      if (data['status'] ==
          'success') {

        _favoritDokter =
            List<Map<String, dynamic>>
                .from(
          data['data'],
        ).map(
          (e) =>
              e['dokter_id']
                  as int,
        ).toList();

        print("LIST FAVORIT: $_favoritDokter");

        notifyListeners();
      }

    } catch (e) {

      print(
        "ERROR FAVORIT: $e",
      );
    }
  }

  // ================= TAMBAH FAVORIT =================
  Future<bool> tambahFavorit({
    required int userId,
    required int dokterId,
  }) async {

    try {

      final response =
          await http.post(

        Uri.parse(
          '$_baseUrl/favorit',
        ),

        headers: {
          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "user_id":
              userId,

          "dokter_id":
              dokterId,

        }),
      );
      print("STATUS FAVORIT: ${response.statusCode}");
      print("BODY FAVORIT: ${response.body}");

      if (response.statusCode ==
          200) {

        await fetchFavorit(
          userId,
        );

        return true;
      }

      return false;

    } catch (e) {

      print(
        "ERROR TAMBAH FAVORIT: $e",
      );

      return false;
    }
    
  }
// ================= HAPUS FAVORIT =================
Future<bool> hapusFavorit({
  required int userId,
  required int dokterId,
}) async {

    try {

      final response =
          await http.delete(

        Uri.parse(
          '$_baseUrl/favorit',
        ),

        headers: {
          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "user_id":
              userId,

          "dokter_id":
              dokterId,

        }),
      );

      if (response.statusCode ==
          200) {

        await fetchFavorit(
          userId,
        );

        return true;
      }

      return false;

    } catch (e) {

      print(
        "ERROR HAPUS FAVORIT: $e",
      );

      return false;
    }
  }

  }
  