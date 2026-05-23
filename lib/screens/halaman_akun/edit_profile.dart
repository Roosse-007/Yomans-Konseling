import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yomans_konseling/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // SINKRONISASI TEMA WARNA UTAMA
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color inputBg = Color(0xFFF5F6F8);

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    // Mengambil data user saat ini secara langsung dari AuthProvider tanpa listen
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Isi nilai teks controller secara dinamis dari database/auth state
    _nameController = TextEditingController(text: authProvider.nama);
    _usernameController = TextEditingController(text: authProvider.username);
    _emailController = TextEditingController(text: authProvider.email);
  }

  @override
  void dispose() {
    // Membersihkan controller saat halaman ditutup agar menghemat memori
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Jalankan validasi client-side terlebih dahulu
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final String newName = _nameController.text.trim();
      final String newUsername = _usernameController.text.trim();
      final String newEmail = _emailController.text.trim();

      // ====================================================================
      // 💡 CATATAN BACKEND INTEGRASI:
      // Jika kamu sudah memiliki fungsi kirim data ke Server API di AuthProvider-mu,
      // buka komentar baris di bawah ini dan sesuaikan nama fungsinya:
      //
      // await authProvider.updateProfileToApi(
      //   name: newName,
      //   username: newUsername,
      //   email: newEmail,
      // );
      // ====================================================================

      // Siapkan Map data baru untuk memperbarui state lokal aplikasi
      Map<String, dynamic> updatedData = {
        ...(authProvider.user ?? {}),
        'nama': newName,
        'username': newUsername,
        'email': newEmail,
      };

      // Memanggil fungsi update local storage & state di AuthProvider kamu
      await authProvider.updateUser(updatedData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Kembali ke halaman ProfileScreen
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 25,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.bold, 
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input Nama
                      CustomInputField(
                        label: 'Name',
                        controller: _nameController,
                        backgroundColor: inputBg,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      // Input Username
                      CustomInputField(
                        label: 'Username',
                        controller: _usernameController,
                        backgroundColor: inputBg,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          if (value.trim().contains(' ')) {
                            return 'Username tidak boleh mengandung spasi';
                          }
                          return null;
                        },
                      ),

                      // Input Email
                      CustomInputField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        backgroundColor: inputBg,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          // Regex validasi standar struktur email
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Masukkan format email yang valid';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol Save Statis Berada di Bagian Bawah
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      disabledBackgroundColor: primaryGreen.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 16, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Komponen Reusable Widget khusus Input Form dengan Dukungan Validasi
class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Color backgroundColor;
  final String? Function(String?)? validator;

  const CustomInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.backgroundColor,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.bold, 
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            autovalidateMode: AutovalidateMode.onUserInteraction, // Validasi otomatis saat user mengetik
            decoration: InputDecoration(
              fillColor: backgroundColor,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              errorStyle: TextStyle(color: Colors.red.shade700, fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red.shade700, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}