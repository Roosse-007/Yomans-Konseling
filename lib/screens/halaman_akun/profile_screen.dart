import 'dart:io'; // Diperlukan untuk membaca berkas gambar lokal di platform mobile
import 'package:flutter/foundation.dart'; // Diperlukan untuk mendeteksi kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import package pengambil gambar
import 'package:provider/provider.dart';
import 'package:yomans_konseling/providers/auth_provider.dart';
import 'package:yomans_konseling/screens/berita/informasi.dart';
import 'package:yomans_konseling/screens/halaman_akun/edit_profile.dart';
import 'package:yomans_konseling/screens/halaman_akun/ganti_password.dart';
import 'package:yomans_konseling/screens/history_boking/history_boking.dart';
import 'package:yomans_konseling/screens/home/home.dart';
import 'package:yomans_konseling/screens/auth/login.dart';

// 💡 PASTIKAN PATH IMPORT DI BAWAH INI SUDAH SESUAI DENGAN PROYEKMU
// import 'package:yomans_konseling/screens/home_page.dart'; 
// import 'package:yomans_konseling/screens/informasi.dart';
import 'notification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  // MENGUBAH TEMA WARNA UTAMA MENJADI HIJAU SESUAI HALAMAN BOOKING
  static const Color primaryGreen = Color(0xFF1B5E20);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  
  // Set default ke 3 karena halaman ini adalah indeks "Profile"
  int _currentIndex = 3; 

  // FUNGSI UNTUK MEMILIH GAMBAR YANG MENDUKUNG MOBILE DAN WEB
  Future<void> _pickImage(AuthProvider authProvider) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompres kualitas gambar agar tidak terlalu berat
      );

      if (pickedFile != null) {
        // Ambil data map user lama
        Map<String, dynamic> updatedData = {
          ...authProvider.user ?? {},
        };

        // Simpan path gambar (di web ini akan berupa Blob URL, di mobile berupa local path)
        updatedData['image_url'] = pickedFile.path;

        // Perbarui data local state & Secure Storage
        await authProvider.updateUser(updatedData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui')),
          );
        }
      }
    } catch (e) {
      debugPrint("Gagal mengambil gambar: $e");
    }
  }

  void _showSignOutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Tutup dialog
              Navigator.pop(context);

              // Logout dari provider
              await Provider.of<AuthProvider>(
                context,
                listen: false,
              ).logout();

              // Pindah ke halaman login
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
  // LOGIKA PINTAR UNTUK MENAMPILKAN GAMBAR (Mencegah crash 'js_allow_interop' di Web)
  ImageProvider _getProfileImage(String path) {
    if (path.startsWith('http') || path.startsWith('https')) {
      return NetworkImage(path);
    } else if (kIsWeb || path.startsWith('blob:')) {
      // Di Web, path berupa 'blob:http...' harus dibaca sebagai NetworkImage
      return NetworkImage(path);
    } else {
      // Di Android / iOS asli, baru kita panggil FileImage
      return FileImage(File(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    final String namaUser = authProvider.nama.isNotEmpty ? authProvider.nama : 'Nama Pengguna';
    final String peranUser = authProvider.user?['role'] ?? 'Client';
    final String fotoUser = authProvider.user?['image_url'] ?? 'https://via.placeholder.com/150';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- FOTO PROFIL USER (SUDAH DIPERBAIKI) ---
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 3),
                      image: DecorationImage(
                        image: _getProfileImage(fotoUser), // Menggunakan penangan gambar dinamis aman
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 2,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click, // <-- MERUBAH KURSOR MENJADI TELUNJUK SAAT DIATAS ICON EDIT
                      child: GestureDetector(
                        onTap: () => _pickImage(authProvider),
                        child: const CircleAvatar(
                          radius: 15,
                          backgroundColor: ProfileScreen.primaryGreen,
                          child: Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              namaUser,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 4),
            Text(
              peranUser,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 32),
            
            // --- MENU NAVIGASI ---
            ProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profil',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.notifications_none_outlined,
              title: 'Notifikasi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.lock_open_outlined,
              title: 'Ganti Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // --- TOMBOL SIGN OUT ---
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () => _showSignOutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.white, size: 16),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ProfileScreen.primaryGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
          ],
        ),
      ),
      
      // ================= NAVIGATION BAR BAWAH =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E6A3F), 
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            // Tambahkan navigasi balik ke Beranda jika diperlukan
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
          } else if (index == 1) {
            // Hindari error pemanggilan dengan memastikan widget Informasi() sudah diimport
            Navigator.push(context, MaterialPageRoute(builder: (_) => Informasi()));
          } else if (index == 2) {
            // Hindari error pemanggilan dengan memastikan widget HomePage() sudah diimport
            // 
            Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryBookingPage())); 
          } else if (index == 3) {
            // Karena ini sudah di halaman ProfileScreen, tidak perlu push kembali ke diri sendiri
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: "Informasi"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}

// Komponen Reusable Widget khusus ListTile Menu
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: const Color(0xFFE8F5E9),
        child: Icon(icon, color: ProfileScreen.primaryGreen, size: 16),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }
}