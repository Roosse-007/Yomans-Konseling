import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // --- TEMA WARNA SESUAI GAMBAR YOMAN KONSELING ---
  static const Color primaryGreen = Color(0xFF006622); // Hijau gelap khas Yoman
  static const Color inputBg = Color(0xFFF5F6F8);      // Abu-abu muda dasar input

  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulasi proses pengiriman data ke server
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password Berhasil Diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Tombol Back tanda panah kiri minimalis berwarna hitam
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- JUDUL HALAMAN ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Ubah Password',
                    style: TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- CURRENT PASSWORD ---
                        _buildPasswordField(
                          label: 'Current Password',
                          hintText: 'masukkan password lama',
                          controller: _oldPasswordController,
                          obscureText: _obscureOld,
                          onToggle: () => setState(() => _obscureOld = !_obscureOld),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Masukkan password saat ini';
                            }
                            return null;
                          },
                        ),

                        // --- NEW PASSWORD ---
                        _buildPasswordField(
                          label: 'New Password',
                          hintText: 'masukkan password baru',
                          controller: _newPasswordController,
                          obscureText: _obscureNew,
                          onToggle: () => setState(() => _obscureNew = !_obscureNew),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Masukkan password baru';
                            }
                            if (value.trim().length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),

                        // --- CONFIRM NEW PASSWORD ---
                        _buildPasswordField(
                          label: 'Confirm New Password',
                          hintText: 'konfirmasi password baru',
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Konfirmasi password tidak boleh kosong';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Konfirmasi password tidak cocok';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // --- TOMBOL SAVE & FOOTER DI PALING BAWAH ---
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: const StadiumBorder(), // Berbentuk kapsul/elips bulat penuh sesuai tombol Login
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Teks persetujuan layanan di bawah tombol sesuai gambar mockup
                      Center(
                        child: Text(
                          'Dengan menggunakan layanan Yoman Konseling kamu menyetujui kebijakan privasi dari layanan kami',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label teks berwarna hijau gelap tebal
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          // Penambahan kontainer dekoratif untuk efek shadow soft timbul (soft elevation)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              validator: validator,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              decoration: InputDecoration(
                fillColor: inputBg,
                filled: true,
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: primaryGreen, // Warna ikon mata disesuaikan menjadi hijau
                    size: 22,
                  ),
                  onPressed: onToggle,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}