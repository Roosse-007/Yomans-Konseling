import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yomans_konseling/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

// Tambahkan TickerProviderStateMixin agar widget mendukung animasi kontroleler
class _EditProfileScreenState extends State<EditProfileScreen> with TickerProviderStateMixin {
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color backgroundGrey = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF212121);
  static const Color textMuted = Color(0xFF757575);

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  // PERBAIKAN ANIMASI: Inisialisasi controller & objek animasi secara benar
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation; // Mengatasi LateInitializationError

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user ?? {};

    _nameController = TextEditingController(text: user['username'] ?? ''); 
    _usernameController = TextEditingController(text: user['username'] ?? '');
    _emailController = TextEditingController(text: user['email'] ?? '');

    // Inisialisasi pengontrol animasi (durasi 500ms)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Perbaikan Curves.backOut menjadi Curves.easeOutBack
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Menginisialisasi _fadeAnimation agar tidak memicu LateInitializationError
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Jalankan animasi saat halaman dibuka
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _animationController.dispose(); // Wajib di-dispose agar tidak leak memory
    super.dispose();
  }

// Di dalam _EditProfileScreenState pada fungsi _saveProfile():
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String newUsername = _usernameController.text.trim();
      final String newEmail = _emailController.text.trim();

      // Panggil fungsi API yang hanya mengirim username dan email
      bool isBackendSaved = await authProvider.updateProfileApi(
        username: newUsername,
        email: newEmail,
      );

      if (isBackendSaved) {
        // Gabungkan data lama dengan perubahan barunya ke state lokal aplikasi
        final updatedUser = Map<String, dynamic>.from(authProvider.user ?? {});
        updatedUser['username'] = newUsername;
        updatedUser['email'] = newEmail;
        
        await authProvider.updateUser(updatedUser);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception("Gagal menyimpan ke server backend.");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textDark, size: 25),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        // Membungkus area form dengan Fade & Scale Transition yang aman dan legal
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "INFORMASI PRIBADI",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMuted, letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              children: [
                                CustomInputField(
                                  label: 'Username',
                                  controller: _usernameController,
                                  prefixIcon: Icons.alternate_email_rounded,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return 'Username tidak boleh kosong';
                                    if (value.trim().contains(' ')) return 'Username tidak boleh mengandung spasi';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomInputField(
                                  label: 'Alamat Email',
                                  controller: _emailController,
                                  prefixIcon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
                                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                    if (!emailRegex.hasMatch(value.trim())) return 'Masukkan format email yang valid';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // TOMBOL SIMPAN ELEGAN
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4)),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      // Menggunakan ElevatedButton standar tanpa modifikasi objek .withAnimation yang ilegal
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          disabledBackgroundColor: primaryGreen.withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final String? Function(String?)? validator;

  const CustomInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF616161))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Color(0xFF212121), fontWeight: FontWeight.w500),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            fillColor: const Color(0xFFF8F9FA),
            filled: true,
            prefixIcon: Icon(prefixIcon, color: const Color(0xFF757575), size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorStyle: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w500),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200, width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade700, width: 1.5)),
          ),
        ),
      ],
    );
  }
}