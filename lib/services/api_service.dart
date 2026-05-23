import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  // ================= BASE URL =================
  static const String baseUrl =
      "http://127.0.0.1:5000/api";

  // ================= LOGIN =================
  static Future<Map<String, dynamic>?> login(

    String username,

    String password,

  ) async {

    try {

      final res = await http.post(

        Uri.parse(
          "$baseUrl/login",
        ),

        headers: {

          "Content-Type":
              "application/json"
        },

        body: jsonEncode({

          "username": username,

          "password": password,
        }),
      );

      final data =
          jsonDecode(res.body);

      if (
          res.statusCode == 200 &&
          data['status'] == 'success'
      ) {

        return data;
      }

      return data;

    } catch (e) {

      print("LOGIN ERROR: $e");

      return {

        "status": "error",

        "message":
            "Koneksi ke server gagal"
      };
    }
  }

  // ================= REGISTER =================
  static Future<Map<String, dynamic>>
      register(

    String email,

    String username,

    String password,

  ) async {

    try {

      final res = await http.post(

        Uri.parse(
          "$baseUrl/register",
        ),

        headers: {

          "Content-Type":
              "application/json"
        },

        body: jsonEncode({

          "email": email,

          "username": username,

          "password": password,
        }),
      );

      return jsonDecode(
        res.body,
      );

    } catch (e) {

      print("REGISTER ERROR: $e");

      return {

        "status": "error",

        "message":
            "Koneksi ke server gagal"
      };
    }
  }

  // ================= KIRIM OTP =================
  static Future<Map<String, dynamic>>
      kirimOtp(

    String email,

  ) async {

    try {

      final response =
          await http.post(

        Uri.parse(
          "$baseUrl/kirim-otp",
        ),

        headers: {

          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "email": email,
        }),
      );

      return jsonDecode(
        response.body,
      );

    } catch (e) {

      print("OTP ERROR: $e");

      return {

        "status": "error",

        "message":
            "Gagal mengirim OTP"
      };
    }
  }

  // ================= RESET PASSWORD =================
  static Future<Map<String, dynamic>>
      resetPassword({

    required String email,

    required String otp,

    required String password,

  }) async {

    try {

      final response =
          await http.post(

        Uri.parse(
          "$baseUrl/reset-password",
        ),

        headers: {

          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "email": email,

          "otp": otp,

          "password": password,
        }),
      );

      return jsonDecode(
        response.body,
      );

    } catch (e) {

      print(
        "RESET PASSWORD ERROR: $e",
      );

      return {

        "status": "error",

        "message":
            "Reset password gagal"
      };
    }
  }

  // ================= GEJALA =================
  static Future<List> getGejala() async {

    try {

      final res = await http.get(

        Uri.parse(
          "$baseUrl/gejala",
        ),
      );

      final data =
          jsonDecode(res.body);

      if (res.statusCode == 200) {

        return data['data'] ?? [];
      }

      return [];

    } catch (e) {

      print(
        "GET GEJALA ERROR: $e",
      );

      return [];
    }
  }

  // ================= KONSULTASI =================
  static Future<Map<String, dynamic>>
      konsultasi(

    Map<String, dynamic> data,

  ) async {

    try {

      final res = await http.post(

        Uri.parse(
          "$baseUrl/konsultasi",
        ),

        headers: {

          "Content-Type":
              "application/json"
        },

        body: jsonEncode(data),
      );

      return jsonDecode(
        res.body,
      );

    } catch (e) {

      print(
        "KONSULTASI ERROR: $e",
      );

      return {

        "status": "error",

        "message":
            "Koneksi ke server gagal"
      };
    }
  }

  // ================= EDUKASI =================
  static Future<List>
      getEdukasi() async {

    try {

      final res = await http.get(

        Uri.parse(
          "$baseUrl/edukasi",
        ),
      );

      final data =
          jsonDecode(res.body);

      if (res.statusCode == 200) {

        return data['data'] ?? [];
      }

      return [];

    } catch (e) {

      print(
        "EDUKASI ERROR: $e",
      );

      return [];
    }
  }

  // ================= BERITA =================
  static Future<List>
      getBerita() async {

    try {

      final res = await http.get(

        Uri.parse(
          "$baseUrl/berita",
        ),
      );

      final data =
          jsonDecode(res.body);

      if (res.statusCode == 200) {

        return data['data'] ?? [];
      }

      return [];

    } catch (e) {

      print(
        "BERITA ERROR: $e",
      );

      return [];
    }
  }

  // ================= DOKTER =================
  static Future<List>
      getDokter() async {

    try {

      final res = await http.get(

        Uri.parse(
          "$baseUrl/dokter",
        ),
      );

      final data =
          jsonDecode(res.body);

      if (res.statusCode == 200) {

        return data['data'] ?? [];
      }

      return [];

    } catch (e) {

      print(
        "DOKTER ERROR: $e",
      );

      return [];
    }
  }

  // ================= BOOKING =================
  static Future<Map<String, dynamic>>
      booking(

    Map<String, dynamic> data,

  ) async {

    try {

      final res = await http.post(

        Uri.parse(
          "$baseUrl/booking",
        ),

        headers: {

          "Content-Type":
              "application/json"
        },

        body: jsonEncode(data),
      );

      return jsonDecode(
        res.body,
      );

    } catch (e) {

      print(
        "BOOKING ERROR: $e",
      );

      return {

        "status": "error",

        "message":
            "Koneksi ke server gagal"
      };
    }
  }
}