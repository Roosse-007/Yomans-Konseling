import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

import '../admin/dashboard.dart';
import '../home/home.dart';
import '../auth/register.dart';
import '../auth/forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ================= CONTROLLER =================
  final TextEditingController user = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final FocusNode passFocus = FocusNode();

  // ================= STATE =================
  bool isLoading = false;
  bool obscurePassword = true;

  // ================= TEMPLATE COLOR =================
  final Color primaryGreen = const Color(0xFF006B24);

  // ================= LOGIN FUNCTION =================
  Future<void> doLogin() async {
    if (user.text.trim().isEmpty || pass.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username & Password wajib diisi"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final res = await ApiService.login(
        user.text.trim(),
        pass.text.trim(),
      );

      debugPrint("===== RESPONSE LOGIN =====");
      debugPrint(res.toString());

      if (res != null && res['status'] == 'success') {
        final Map<String, dynamic> userData =
            Map<String, dynamic>.from(res['data']);

        if (!userData.containsKey('nama') && userData.containsKey('username')) {
          userData['nama'] = userData['username'];
        }

        final String token = res['token'] ?? '';

        if (token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Token login tidak ditemukan"),
            ),
          );
          return;
        }

        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).setLogin(
          token: token,
          userData: userData,
        );

        final String role = userData['role'] ?? 'user';

        if (!mounted) return;

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDashboard(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }
      }else {
  pass.clear();
  passFocus.requestFocus();// reset password

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        res != null
            ? (res['message'] ?? "Login gagal")
            : "Server tidak merespon",
      ),
    ),
  );
}
    } catch (e) {
  debugPrint("===== LOGIN ERROR =====");
  debugPrint(e.toString());

  pass.clear(); // reset password

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Terjadi kesalahan: $e"),
    ),
  );
} finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    user.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // ================= 1. WATERMARK BACKGROUND (SUPER BESAR) =================
              Center(
                child: Opacity(
                  opacity: 0.12, 
                  child: Image.asset(
                    'lib/assets/logo_yomans.png',
                    // Mengubah multiplier dari 1.6 menjadi 2.2 agar ukuran logo jauh lebih raksasa
                    width: MediaQuery.of(context).size.width * 2.2,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

            // --- Tombol Back dan Logo Kecil Pojok Atas Sudah Dihapus ---

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
                        "Login",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ================= REGISTER LINK =================
                      Row(
                        children: [
                          const Text(
                            "Belum punya akun? ",
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          // Menambahkan MouseRegion agar kursor berubah menjadi telunjuk (pointer)
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Buat akun",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // ================= FIELD USERNAME =================
                      Text(
                        "Username",
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
                          controller: user,
                          keyboardType: TextInputType.text, // Diubah menjadi input teks biasa
                          decoration: InputDecoration(
                            hintText: "masukkan username",
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                            fillColor: const Color(0xFFF9F9F9),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ================= FIELD PASSWORD =================
                      Text(
                        "Password",
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
                          controller: pass,
                          focusNode: passFocus,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            hintText: "masukkan password",
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                            fillColor: const Color(0xFFF9F9F9),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

                      // ================= LUPA PASSWORD =================
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Lupa password?",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ================= PRIVACY POLICY TEXT =================
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87, fontSize: 12, height: 1.4),
                          children: [
                            const TextSpan(text: "Dengan menggunakan layanan Yoman Konseling kamu menyetujui "),
                            TextSpan(
                              text: "kebijakan privasi",
                              style: TextStyle(
                                color: primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " dari layanan kami"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ================= LOGIN BUTTON =================
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isLoading ? null : doLogin,
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
                                  "Login",
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