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
  final int _currentIndex = 3; // Jadikan final karena ini halaman profile tetap (index 3)

  Uint8List? _webImageBytes; // Preview lokal langsung sebelum/selama upload

Future<void> _pickImage(AuthProvider authProvider) async {
  final XFile? pickedFile = await _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );

  if (pickedFile == null) return;

  // 🔥 Baca file sebagai bytes agar aman di Web & Mobile
  final Uint8List imageBytes = await pickedFile.readAsBytes();

  setState(() {
    _webImageBytes = imageBytes; // Set preview langsung menggunakan bytes
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
      _webImageBytes = null; // Reset preview setelah server sukses diperbarui
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
        title: const Text("Sign Out"),
        content: const Text("Yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal"),
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
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  ImageProvider _imageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.isNotEmpty) {
      return FileImage(File(path));
    } else {
      return const AssetImage('assets/images/default_avatar.png'); // Sediakan avatar default jika kosong
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final user = authProvider.user ?? {};
    final namaUser = user['username'] ?? 'User';
    final peranUser = user['role'] ?? 'user';
    final fotoUser = user['foto_profil'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ================= PROFILE IMAGE WORKMANSHIP =================
            Center(
              child: Stack(
                children: [
                 CircleAvatar(
  radius: 55,
  backgroundColor: Colors.grey.shade200,
  // 🔥 PRIORITAS: bytes lokal -> network URL -> fallback default
  backgroundImage: _webImageBytes != null
      ? MemoryImage(_webImageBytes!) // Aman digunakan di Web maupun Mobile
      : (fotoUser.startsWith('http')
          ? NetworkImage("$fotoUser?cache=${DateTime.now().millisecondsSinceEpoch}")
          : const AssetImage('assets/images/default_avatar.png') as ImageProvider),
),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickImage(authProvider),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: ProfileScreen.primaryGreen,
                        child: Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Text(
              namaUser,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              peranUser.toUpperCase(), 
              style: const TextStyle(color: Colors.grey, letterSpacing: 1.1, fontSize: 12),
            ),

            const SizedBox(height: 30),

            // ================= MENU LIST =================
            ListTile(
              leading: const Icon(Icons.person, color: ProfileScreen.primaryGreen),
              title: const Text("Edit Profile"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.notifications, color: ProfileScreen.primaryGreen),
              title: const Text("Notifikasi"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.lock, color: ProfileScreen.primaryGreen),
              title: const Text("Ganti Password"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                );
              },
            ),

            const SizedBox(height: 40),

            // ================= LOGOUT BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ProfileScreen.primaryGreen,
                  foregroundColor: Colors.white, // Warna teks jadi putih
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _showSignOutDialog(context),
                child: const Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      
      // ================= BOTTOM NAVIGATION BAR =================
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ProfileScreen.primaryGreen,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return; // Jika klik menu yang sama, abaikan.

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => Informasi()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HistoryBookingPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Informasi"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}