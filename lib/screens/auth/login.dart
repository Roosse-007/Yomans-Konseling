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
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  // ================= CONTROLLER =================
  final TextEditingController user =
      TextEditingController();

  final TextEditingController pass =
      TextEditingController();

  // ================= STATE =================
  bool isLoading = false;

  bool obscurePassword = true;

  // ================= LOGIN FUNCTION =================
  Future<void> doLogin() async {

    // VALIDASI INPUT
    if (
        user.text.trim().isEmpty ||
        pass.text.trim().isEmpty
    ) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Username & Password wajib diisi",
          ),
        ),
      );

      return;
    }

    // START LOADING
    setState(() {

      isLoading = true;
    });

    try {

      // ================= HIT API =================
      final res =
          await ApiService.login(

        user.text.trim(),

        pass.text.trim(),
      );

      // DEBUG RESPONSE
      debugPrint(
        "===== RESPONSE LOGIN =====",
      );

      debugPrint(
        res.toString(),
      );

      // ================= LOGIN SUCCESS =================
      if (
          res != null &&
          res['status'] == 'success'
      ) {

        // ================= USER DATA =================
        final Map<String, dynamic>
            userData =
            Map<String, dynamic>.from(
          res['data'],
        );

        // FALLBACK NAMA
        if (
            !userData.containsKey(
              'nama',
            ) &&
            userData.containsKey(
              'username',
            )
        ) {

          userData['nama'] =
              userData['username'];
        }

        // ================= TOKEN =================
        final String token =
            res['token'] ?? '';

        // VALIDASI TOKEN
        if (token.isEmpty) {

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(

            const SnackBar(

              content: Text(
                "Token login tidak ditemukan",
              ),
            ),
          );

          return;
        }

        // ================= SIMPAN SESSION =================
        await Provider.of<AuthProvider>(

          context,

          listen: false,

        ).setLogin(

          token: token,

          userData: userData,
        );

        // ================= AMBIL ROLE =================
        final String role =
            userData['role'] ?? 'user';

        // ================= CEK MOUNTED =================
        if (!mounted) return;

        // ================= PINDAH HALAMAN =================
        if (role == 'admin') {

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder: (context) =>
                  AdminDashboard(),
            ),
          );

        } else {

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder: (context) =>
                  HomePage(),
            ),
          );
        }

      } else {

        // ================= LOGIN GAGAL =================
        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content: Text(

              res != null

                  ? (
                      res['message'] ??
                      "Login gagal"
                    )

                  : "Server tidak merespon",
            ),
          ),
        );
      }

    } catch (e) {

      // ================= ERROR =================
      debugPrint(
        "===== LOGIN ERROR =====",
      );

      debugPrint(
        e.toString(),
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            "Terjadi kesalahan: $e",
          ),
        ),
      );

    } finally {

      // STOP LOADING
      if (mounted) {

        setState(() {

          isLoading = false;
        });
      }
    }
  }

  // ================= DISPOSE =================
  @override
  void dispose() {

    user.dispose();

    pass.dispose();

    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding:
                const EdgeInsets.all(24),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [

                // ================= ICON =================
                Container(

                  width: 120,

                  height: 120,

                  decoration: BoxDecoration(

                    color: Colors.blue
                        .withOpacity(0.1),

                    shape: BoxShape.circle,
                  ),

                  child: const Icon(

                    Icons.health_and_safety,

                    size: 70,

                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 25),

                // ================= TITLE =================
                const Text(

                  "Konseling App",

                  textAlign: TextAlign.center,

                  style: TextStyle(

                    fontSize: 30,

                    fontWeight:
                        FontWeight.bold,

                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(

                  "Silakan login untuk melanjutkan",

                  textAlign: TextAlign.center,

                  style: TextStyle(

                    fontSize: 15,

                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                // ================= USERNAME =================
                TextField(

                  controller: user,

                  keyboardType:
                      TextInputType.text,

                  decoration:
                      InputDecoration(

                    labelText: "Username",

                    hintText:
                        "Masukkan username",

                    prefixIcon:
                        const Icon(
                      Icons.person,
                    ),

                    border:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),

                    enabledBorder:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),

                      borderSide:
                          const BorderSide(
                        color: Colors.grey,
                      ),
                    ),

                    focusedBorder:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),

                      borderSide:
                          const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ================= PASSWORD =================
                TextField(

                  controller: pass,

                  obscureText:
                      obscurePassword,

                  decoration:
                      InputDecoration(

                    labelText: "Password",

                    hintText:
                        "Masukkan password",

                    prefixIcon:
                        const Icon(
                      Icons.lock,
                    ),

                    suffixIcon:
                        IconButton(

                      onPressed: () {

                        setState(() {

                          obscurePassword =
                              !obscurePassword;
                        });
                      },

                      icon: Icon(

                        obscurePassword

                            ? Icons.visibility

                            : Icons.visibility_off,
                      ),
                    ),

                    border:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),

                    enabledBorder:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),

                      borderSide:
                          const BorderSide(
                        color: Colors.grey,
                      ),
                    ),

                    focusedBorder:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),

                      borderSide:
                          const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // ================= LUPA PASSWORD =================
                Align(

                  alignment:
                      Alignment.centerRight,

                  child: TextButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (context) =>
                              const ForgotPasswordPage(),
                        ),
                      );
                    },

                    child: const Text(
                      "Lupa Password?",
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ================= LOGIN BUTTON =================
                SizedBox(

                  height: 55,

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(

                      backgroundColor:
                          Colors.blue,

                      foregroundColor:
                          Colors.white,

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),

                    onPressed:
                        isLoading
                            ? null
                            : doLogin,

                    child:
                        isLoading

                            ? const SizedBox(

                                width: 24,

                                height: 24,

                                child:
                                    CircularProgressIndicator(

                                  color:
                                      Colors.white,

                                  strokeWidth: 2,
                                ),
                              )

                            : const Text(

                                "LOGIN",

                                style: TextStyle(

                                  fontSize: 16,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= REGISTER =================
                Row(

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    const Text(
                      "Belum punya akun?",
                    ),

                    TextButton(

                      onPressed: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (context) =>
                                RegisterPage(),
                          ),
                        );
                      },

                      child: const Text(
                        "Daftar",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}