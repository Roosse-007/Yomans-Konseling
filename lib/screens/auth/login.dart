import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../admin/dashboard.dart';
import '../home/home.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final user = TextEditingController();
  final pass = TextEditingController();

  bool isLoading = false;

  Future<void> doLogin() async {

    // VALIDASI INPUT
    if (user.text.isEmpty || pass.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Username & Password wajib diisi",
          ),
        ),
      );

      return;
    }

    setState(() => isLoading = true);

    try {

      final res = await ApiService.login(
        user.text,
        pass.text,
      );

      // DEBUG RESPONSE
      print("===== DEBUG RESPONSE LOGIN =====");
      print("Isi respons: $res");
      print("================================");

      // LOGIN SUCCESS
      if (res != null && res['status'] == 'success') {

        // AMBIL DATA USER
        final Map<String, dynamic> userData =
            Map<String, dynamic>.from(
          res['data'],
        );

        // FALLBACK NAMA
        if (!userData.containsKey('nama') &&
            userData.containsKey('username')) {

          userData['nama'] = userData['username'];
        }

        // SIMPAN KE PROVIDER
        Provider.of<AuthProvider>(
          context,
          listen: false,
        ).setUser(userData);

        // CEK ROLE ADMIN
        final role = userData['role'];

        // JIKA ADMIN
        if (role == 'admin') {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDashboard(),
            ),
          );

        } else {

          // USER BIASA
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(),
            ),
          );
        }

      } else {

        // LOGIN GAGAL
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res != null
                  ? (res['message'] ?? "Login gagal")
                  : "Tidak ada response dari server",
            ),
          ),
        );
      }

    } catch (e) {

      // DEBUG ERROR
      print("===== EROR SISTEM LOGIN =====");
      print("Pesan Eror: $e");
      print("=============================");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Terjadi kesalahan koneksi",
          ),
        ),
      );

    } finally {

      setState(() => isLoading = false);
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

      body: Center(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Column(

            children: [

              // TITLE
              const Text(
                "Konseling App",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // USERNAME
              TextField(
                controller: user,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // PASSWORD
              TextField(
                controller: pass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // BUTTON LOGIN
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(

                  onPressed: isLoading
                      ? null
                      : doLogin,

                  child: isLoading

                      ? const SizedBox(
                          width: 20,
                          height: 20,

                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )

                      : const Text("Login"),
                ),
              ),

              const SizedBox(height: 10),

              // KE REGISTER
              TextButton(

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterPage(),
                    ),
                  );
                },

                child: const Text(
                  "Belum punya akun? Daftar",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}