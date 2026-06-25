import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yomans_konseling/providers/auth_provider.dart';
import 'package:yomans_konseling/screens/berita/informasi.dart';
import 'package:yomans_konseling/screens/halaman_akun/edit_profile.dart';
import 'package:yomans_konseling/screens/halaman_akun/ganti_password.dart';
import 'package:yomans_konseling/screens/history_boking/history_boking.dart';
import 'package:yomans_konseling/screens/home/home.dart';
import 'package:yomans_konseling/screens/auth/login.dart';
import 'notification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const Color primaryGreen = Color(0xFF1B5E20);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final int _currentIndex = 3;

  Uint8List? _webImageBytes;

  Future<void> _pickImage(AuthProvider authProvider) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    final Uint8List imageBytes = await pickedFile.readAsBytes();

    setState(() {
      _webImageBytes = imageBytes;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengupload foto...')),
    );

    bool success = await authProvider.uploadProfilePicture(pickedFile);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto berhasil diperbarui')),
      );

      setState(() {
        _webImageBytes = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal upload foto')),
      );
      setState(() {
        _webImageBytes = null;
      });
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Yakin ingin keluar dari akun Anda?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Provider.of<AuthProvider>(context, listen: false).logout();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final user = authProvider.user ?? {};
    final namaUser = user['username'] ?? 'User';
    final peranUser = user['role'] ?? 'user';
    final fotoUser = user['foto_profil'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Ubah background ke light grey agar card lebih pop-out
      appBar: AppBar(
  title: const Text("Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
  centerTitle: true,
  backgroundColor: Colors.white,
  elevation: 0.5,
  leading: IconButton( // 🔥 Tambahkan properti leading secara eksplisit
    icon: const Icon(Icons.arrow_back_ios_new, size: 25, color: Colors.black), // Menggunakan panah style iOS
    onPressed: () => Navigator.maybePop(context), // Fungsi kembali yang aman
  ),
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // ================= PROFILE IMAGE WITH MOUSE CURSOR =================
            Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click, // 🔥 Mengubah kursor menjadi telunjuk (Pointer)
                child: GestureDetector(
                  onTap: () => _pickImage(authProvider),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _webImageBytes != null
                              ? MemoryImage(_webImageBytes!)
                              : (fotoUser.startsWith('http')
                                  ? NetworkImage("$fotoUser?cache=${DateTime.now().millisecondsSinceEpoch}")
                                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: ProfileScreen.primaryGreen,
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white), // Mengganti ke icon kamera agar lebih intuitif
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= USER INFO =================
            Text(
              namaUser,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF212121)),
            ),

            const SizedBox(height: 32),

            // ================= MENU LIST (GROUPED IN A CARD) =================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.person_outline,
                    title: "Edit Profile",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildMenuTile(
                    icon: Icons.notifications_none_outlined,
                    title: "Notifikasi",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildMenuTile(
                    icon: Icons.lock_outline,
                    title: "Kelola keamanan",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

// ================= LOGOUT BUTTON =================
SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton( // 🔥 Cukup gunakan ElevatedButton biasa di sini
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.red,
      elevation: 0,
      side: const BorderSide(color: Colors.red, width: 1.5), // Gaya outline border merah tetap aman
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    onPressed: () => _showSignOutDialog(context),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.logout, size: 18),
        SizedBox(width: 8),
        Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    ),
  ),
),
          ],
        ),
      ),

      // ================= BOTTOM NAVIGATION BAR =================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: ProfileScreen.primaryGreen,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == _currentIndex) return;

            if (index == 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
            } else if (index == 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Informasi()));
            } else if (index == 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HistoryBookingPage()));
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Beranda"),
            BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: "Informasi"),
            BottomNavigationBarItem(icon: Icon(Icons.history), activeIcon: Icon(Icons.history), label: "Riwayat"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat menu item agar kode lebih bersih dan konsisten
  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: ProfileScreen.primaryGreen, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF212121))),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}