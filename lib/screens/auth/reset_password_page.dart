import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // ================= CONTROLLER =================
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // ================= STATE VISIBILITY & LOADING =================
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // ================= TEMPLATE COLOR (SAMA DENGAN LOGIN) =================
  final Color primaryGreen = const Color(0xFF006B24);

  // ================= URL BACKEND =================
  final url = Uri.parse('http://127.0.0.1:5000/api/reset-password');

  // ================= RESET PASSWORD =================
  Future<void> resetPassword() async {
    final otp = otpController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // ================= VALIDASI =================
    if (otp.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      tampilPesan("Semua field wajib diisi", false);
      return;
    }

    if (password.length < 6) {
      tampilPesan("Password minimal 6 karakter", false);
      return;
    }

    if (password != confirmPassword) {
      tampilPesan("Konfirmasi password tidak cocok", false);
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
          "email": widget.email,
          "otp": otp,
          "password": password,
        }),
      ).timeout(
        const Duration(seconds: 15),
      );

      final data = jsonDecode(response.body);

      // ================= BERHASIL =================
      if (response.statusCode == 200) {
        tampilPesan(data["message"] ?? "Password berhasil direset", true);

        // ================= DELAY =================
        await Future.delayed(const Duration(seconds: 1));

        // ================= KEMBALI KE LOGIN =================
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
      // ================= GAGAL =================
      else {
        tampilPesan(data["message"] ?? "Reset password gagal", false);
      }
    } catch (e) {
      print("RESET PASSWORD ERROR: $e");
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
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
          "Ubah Password",
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
                  'lib/assets/logo_yomans.png',
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
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Kode verifikasi telah dikirim ke akun email ${widget.email}",
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 30),

                      // ================= FIELD OTP =================
                      Text(
                        "Kode OTP",
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
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "masukkan kode otp",
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                            fillColor: const Color(0xFFF9F9F9),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            prefixIcon: Icon(Icons.lock_clock_outlined, color: primaryGreen),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ================= FIELD PASSWORD BARU =================
                      Text(
                        "Password Baru",
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
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            hintText: "masukkan password baru",
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                            fillColor: const Color(0xFFF9F9F9),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            prefixIcon: Icon(Icons.lock_outlined, color: primaryGreen),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: primaryGreen,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ================= FIELD KONFIRMASI PASSWORD =================
                      Text(
                        "Konfirmasi Password",
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
                          controller: confirmPasswordController,
                          obscureText: obscureConfirmPassword,
                          decoration: InputDecoration(
                            hintText: "ulangi password baru",
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                            fillColor: const Color(0xFFF9F9F9),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            prefixIcon: Icon(Icons.lock_reset_outlined, color: primaryGreen),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureConfirmPassword = !obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: primaryGreen,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),

                      // ================= BUTTON RESET PASSWORD =================
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25), // Kelengkungan elips/kapsul identik login
                            ),
                            elevation: 0,
                          ),
                          onPressed: isLoading ? null : resetPassword,
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
                                  "Reset Password",
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