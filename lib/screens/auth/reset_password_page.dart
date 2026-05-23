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
  State<ResetPasswordPage> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState
    extends State<ResetPasswordPage> {

  // ================= CONTROLLER =================
  final TextEditingController otpController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  // ================= LOADING =================
  bool isLoading = false;

  // ================= URL BACKEND =================
  final url = Uri.parse(
    'http://127.0.0.1:5000/api/reset-password',
  );

  // ================= RESET PASSWORD =================
  Future<void> resetPassword() async {

    final otp =
        otpController.text.trim();

    final password =
        passwordController.text.trim();

    final confirmPassword =
        confirmPasswordController.text.trim();

    // ================= VALIDASI =================
    if (
        otp.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty
    ) {

      tampilPesan(
        "Semua field wajib diisi",
        false,
      );

      return;
    }

    if (password.length < 6) {

      tampilPesan(
        "Password minimal 6 karakter",
        false,
      );

      return;
    }

    if (password != confirmPassword) {

      tampilPesan(
        "Konfirmasi password tidak cocok",
        false,
      );

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

      final data =
          jsonDecode(response.body);

      // ================= BERHASIL =================
      if (response.statusCode == 200) {

        tampilPesan(
          data["message"] ??
              "Password berhasil direset",
          true,
        );

        // ================= DELAY =================
        await Future.delayed(
          const Duration(seconds: 1),
        );

        // ================= KEMBALI KE LOGIN =================
        Navigator.pushAndRemoveUntil(

          context,

          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),

          (route) => false,
        );
      }

      // ================= GAGAL =================
      else {

        tampilPesan(
          data["message"] ??
              "Reset password gagal",
          false,
        );
      }

    }

    catch (e) {

      print("RESET PASSWORD ERROR: $e");

      tampilPesan(
        "Koneksi ke server gagal",
        false,
      );
    }

    finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  // ================= SNACKBAR =================
  void tampilPesan(
      String pesan,
      bool success,
      ) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        content: Text(pesan),

        backgroundColor:
            success
                ? Colors.green
                : Colors.red,
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

      appBar: AppBar(
        title:
            const Text("Reset Password"),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            const SizedBox(height: 40),

            // ================= EMAIL =================
            TextField(

              enabled: false,

              decoration: InputDecoration(

                labelText: widget.email,

                border:
                    const OutlineInputBorder(),

                prefixIcon:
                    const Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 20),

            // ================= OTP =================
            TextField(

              controller:
                  otpController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(

                labelText: "Kode OTP",

                hintText:
                    "Masukkan kode OTP",

                border:
                    OutlineInputBorder(),

                prefixIcon:
                    Icon(Icons.lock_clock),
              ),
            ),

            const SizedBox(height: 20),

            // ================= PASSWORD =================
            TextField(

              controller:
                  passwordController,

              obscureText: true,

              decoration:
                  const InputDecoration(

                labelText:
                    "Password Baru",

                hintText:
                    "Masukkan password baru",

                border:
                    OutlineInputBorder(),

                prefixIcon:
                    Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 20),

            // ================= KONFIRMASI PASSWORD =================
            TextField(

              controller:
                  confirmPasswordController,

              obscureText: true,

              decoration:
                  const InputDecoration(

                labelText:
                    "Konfirmasi Password",

                hintText:
                    "Ulangi password baru",

                border:
                    OutlineInputBorder(),

                prefixIcon:
                    Icon(Icons.lock_outline),
              ),
            ),

            const SizedBox(height: 30),

            // ================= BUTTON =================
            SizedBox(

              width: double.infinity,

              height: 50,

              child: ElevatedButton(

                onPressed:
                    isLoading
                        ? null
                        : resetPassword,

                child:

                    isLoading

                        ? const SizedBox(

                            width: 24,
                            height: 24,

                            child:
                                CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )

                        : const Text(
                            "Reset Password",
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}