import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {

  final TextEditingController emailController =
      TextEditingController();

  bool isLoading = false;

  // ================= URL BACKEND =================
  final url = Uri.parse(
    'http://127.0.0.1:5000/api/kirim-otp',
  );

  // ================= KIRIM OTP =================
  Future<void> prosesKirimOtp() async {

    final email =
        emailController.text.trim();

    if (email.isEmpty) {

      tampilPesan(
        "Email tidak boleh kosong!",
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
          "email": email,
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
              "OTP berhasil dikirim",
          true,
        );

        // ================= PINDAH HALAMAN =================
        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) =>
                ResetPasswordPage(
              email: email,
            ),
          ),
        );

      }

      // ================= GAGAL =================
      else {

        tampilPesan(
          data["message"] ??
              "Gagal mengirim OTP",
          false,
        );
      }

    }

    catch (e) {

      print("ERROR OTP: $e");

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

    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text("Lupa Password"),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            // ================= INPUT EMAIL =================
            TextField(

              controller:
                  emailController,

              keyboardType:
                  TextInputType.emailAddress,

              decoration:
                  const InputDecoration(

                labelText: "Email",

                hintText:
                    "Masukkan email anda",

                border:
                    OutlineInputBorder(),

                prefixIcon:
                    Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 20),

            // ================= BUTTON =================
            SizedBox(

              width: double.infinity,

              height: 50,

              child: ElevatedButton(

                onPressed:
                    isLoading
                        ? null
                        : prosesKirimOtp,

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
                            "Kirim OTP",
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}