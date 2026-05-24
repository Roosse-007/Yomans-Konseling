import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  // ================= TEMPLATE COLOR (DISAMAKAN DENGAN LOGIN) =================
  final Color primaryGreen = const Color(0xFF006B24);

  // ================= URL BACKEND =================
  final url = Uri.parse('http://127.0.0.1:5000/api/kirim-otp');

  // ================= KIRIM OTP =================
  Future<void> prosesKirimOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      tampilPesan("Email tidak boleh kosong!", false);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
        }),
      ).timeout(
        const Duration(seconds: 15),
      );

      final data = jsonDecode(response.body);

      // ================= BERHASIL =================
      if (response.statusCode == 200) {
        tampilPesan(data["message"] ?? "OTP berhasil dikirim", true);

        // ================= PINDAH HALAMAN =================
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(email: email),
          ),
        );
      }
      // ================= GAGAL =================
      else {
        tampilPesan(data["message"] ?? "Gagal mengirim OTP", false);
      }
    } catch (e) {
      print("ERROR OTP: $e");
      tampilPesan("Koneksi ke server gagal", false);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ================= SNACKBAR =================
  void tampilPesan(String pesan, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: success ? primaryGreen : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Lupa Password",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ================= 1. WATERMARK BACKGROUND (SAMA DENGAN LOGIN) =================
            Center(
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  'lib/assets/logo_yomans.png', // Menggunakan aset yang sama persis
                  width: MediaQuery.of(context).size.width * 2.2,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // ================= 2. LAYER KONTEN UTAMA =================
            Positioned.fill(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ================= TITLE =================
                      Text(
                        "Pulihkan Akun",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Masukkan email terdaftar Anda. Kami akan mengirimkan kode OTP untuk memverifikasi kepemilikan akun.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ================= FIELD EMAIL =================
                      Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Material(
                        elevation: 2,
                        shadowColor: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "masukkan email anda",
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                            fillColor: const Color(0xFFF9F9F9),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            prefixIcon: Icon(Icons.email_outlined, color: primaryGreen),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),

                      // ================= BUTTON KIRIM OTP =================
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25), // Dibuat kapsul/bulat penuh agar senada dengan login
                            ),
                            elevation: 0,
                          ),
                          onPressed: isLoading ? null : prosesKirimOtp,
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Kirim OTP",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}