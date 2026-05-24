import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // ================= CONTROLLER =================
  final email = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();

  // ================= STATE =================
  bool isLoading = false;
  bool obscurePassword = true;

  // ================= TEMPLATE COLOR =================
  final Color primaryGreen = const Color(0xFF006B24);

  // ================= REGISTER FUNCTION =================
  void daftar() async {
    if (email.text.trim().isEmpty ||
        username.text.trim().isEmpty ||
        password.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field wajib diisi")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await ApiService.register(
        email.text.trim(),
        username.text.trim(),
        password.text.trim(),
      );

      setState(() => isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Terjadi kesalahan")),
      );

      if (res['status'] == "success") {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    email.dispose();
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // ================= 1. WATERMARK BACKGROUND (BACKGROUND LOGO BESAR NYATA) =================
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

            // ================= 2. TOMBOL BACK STYLE IOS POJOK KIRI ATAS =================
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 26),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // ================= 3. LAYER KONTEN UTAMA =================
            Positioned.fill(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40), 

                      // ================= TITLE (SESUAI GAMBAR) =================
                      Text(
                        "Yuk, Lengkapi Profilmu",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 35),

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
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "masukkan nama lengkapmu", // Hint teks disamakan dengan gambar bawanmu
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
                          controller: username,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "masukkan email kamu", // Hint teks disamakan dengan gambar bawaanmu
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
                          controller: password,
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
                      const SizedBox(height: 45),

                      // ================= SIMPAN BUTTON (SESUAI GAMBAR) =================
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
                          onPressed: isLoading ? null : daftar,
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
                                  "Simpan",
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