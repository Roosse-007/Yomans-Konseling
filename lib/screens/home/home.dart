import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yomans_konseling/screens/dokter/PilihPsikologPage.dart';
import 'package:yomans_konseling/screens/dokter/detail_booking.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dokter_provider.dart'; 

import '../konsultasi/konsultasi.dart';
import '../berita/informasi.dart';
import '../admin/dashboard.dart';
import 'package:yomans_konseling/screens/history_boking/history_boking.dart';
import 'package:yomans_konseling/screens/halaman_akun/profile_screen.dart'; 

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Mengatur Navigasi Bawah Aktif
  bool _isPressedOffline = false;
  bool _isPressedOnline = false;

  @override
  Widget build(BuildContext context) {
    // 1. Ambil status admin dari AuthProvider
    final isAdmin = Provider.of<AuthProvider>(context).isAdmin;
    
    // 2. Ambil data nama langsung menggunakan getter '.nama' dari AuthProvider milikmu
    final username = Provider.of<AuthProvider>(context).nama;
    // Jika data nama ternyata kosong di database, tampilkan 'User' sebagai cadangan
    final namaTampilan = username.isNotEmpty ? username : "User";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= BARIS SALAM & NAMA USER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hallo, $namaTampilan",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (isAdmin)
                    IconButton(
                      icon: const Icon(Icons.admin_panel_settings, color: Colors.red),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminDashboard()),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 25),

              // ================= MENU UTAMA: OFFLINE & ONLINE KONSELING =================
              Row(
                children: [
                  Expanded(
                    child: _buildMenuUtamaCard(
                      imagePath: 'lib/assets/offline.png',
                      title: "Offline\nkonseling",
                      isPressed: _isPressedOffline,
                      onTapDown: () {
                        setState(() {
                          _isPressedOffline = true;
                        });
                      },
                      onTapUp: () {
                        setState(() {
                          _isPressedOffline = false;
                        });
                        // Secara default mengarah ke ID dokter 1 (Misal Ira) jika klik menu utama
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PilihPsikologPage(),
                          ),
                        );
                      },
                      onTapCancel: () {
                        setState(() {
                          _isPressedOffline = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildMenuUtamaCard(
                      imagePath: 'lib/assets/online.png',
                      title: "Online\nkonseling",
                      isPressed: _isPressedOnline,
                      onTapDown: () {
                        setState(() {
                          _isPressedOnline = true;
                        });
                      },
                      onTapUp: () {
                        setState(() {
                          _isPressedOnline = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KonsultasiPage(),
                          ),
                        );
                      },
                      onTapCancel: () {
                        setState(() {
                          _isPressedOnline = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // ================= SUB-JUDUL: PSIKOLOG ANDALAN KAMI =================
              const Text(
                "Psikolog andalan kami",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),

              // ================= HORIZONTAL SLIDER DOKTER =================
              Consumer<DokterProvider>(
                builder: (context, dokterProv, child) {
                  if (dokterProv.listDokter.isEmpty) {
                    dokterProv.fetchDokter();
                    return const SizedBox(
                      height: 240,
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF2E6A3F))),
                    );
                  }

                  final paraDokter = dokterProv.listDokter;

                  return SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: paraDokter.length,
                      itemBuilder: (context, index) {
                        final dokter = paraDokter[index];
                        List<String> tags = List<String>.from(dokter['tags'] ?? []);

                        return _buildDokterCard(
                              context,
                              dokter: dokter,
                            );
                      },
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDotIndicator(isActive: true),
                    _buildDotIndicator(isActive: false),
                    _buildDotIndicator(isActive: false),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ================= SUB-JUDUL: KEUNGGULAN KONSULTASI =================
              const Text(
                "keunggulan Yomans konseling",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),

              // ================= HORIZONTAL LIST KEUNGGULAN BANNER =================
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildKeunggulanCard("1", "Cerita Aman,\nTanpa Takut"),
                    _buildKeunggulanCard("2", "Didengar\ndengan\nSepenuh Hati"),
                    _buildKeunggulanCard("3", "Solusi Nyata,\nBukan\nSekadar Kata"),
                    _buildKeunggulanCard("4", "Teman\nBicara\nSetiap\nWaktu"),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ================= BANNER AJAKAN BAWAH =================
              _buildBottomBanner(context),
              const SizedBox(height: 20),
            ],
          ),
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

    if (index == 1) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Informasi(),
        ),
      );

    } else if (index == 2) {

      // NAVIGASI KE HISTORY BOOKING
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const HistoryBookingPage(),
        ),
      );

    } else if (index == 3) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const ProfileScreen(),
        ),
      );
    }
  },

  items: const [

    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      label: "Beranda",
    ),

    BottomNavigationBarItem(
      icon: Icon(Icons.book_outlined),
      label: "Informasi",
    ),

    BottomNavigationBarItem(
      icon: Icon(Icons.receipt_long_rounded),
      label: "Riwayat",
    ),

    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      label: "Profile",
    ),
  ],
),
    );
  }

  // ================= WIDGET BUILDER UNTUK CARD MENU UTAMA =================
  Widget _buildMenuUtamaCard({
    required String imagePath,
    required String title,
    required bool isPressed,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
    required VoidCallback onTapCancel,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.green.withOpacity(0.15),
          highlightColor: Colors.green.withOpacity(0.08),
          onTapDown: (_) => onTapDown(),
          onTapUp: (_) => onTapUp(),
          onTapCancel: onTapCancel,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: isPressed ? 0.96 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isPressed ? 0.08 : 0.14),
                    blurRadius: isPressed ? 6 : 14,
                    spreadRadius: isPressed ? 1 : 2,
                    offset: Offset(0, isPressed ? 2 : 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      imagePath,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          color: const Color(0xFFE8F5E9),
                          child: const Icon(Icons.image, color: Colors.green, size: 40),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1B4326),
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

  // ================= WIDGET BUILDER UNTUK CARD SLIDER PSIKOLOG =================
  // ================= WIDGET BUILDER UNTUK CARD SLIDER PSIKOLOG =================
Widget _buildDokterCard(
  BuildContext context, {
  required Map<String, dynamic> dokter,
}) {
  final int id = dokter['id'] ?? 0;

  final String imagePath =
      dokter['image_url'] ?? '';

  final String name =
      dokter['nama'] ?? '';

  final List<String> tags =
      List<String>.from(
        dokter['tags'] ?? [],
      );

  final String time =
      dokter['jadwal'] ?? '';

  final int hargaAwal =
      dokter['harga_awal'] ?? 0;

  final int hargaDiskon =
      dokter['harga_diskon'] ?? 0;

  final int diskon =
      dokter['diskon'] ?? 0;

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          print("DATA DOKTER HOME:");
          print(dokter);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailBookingPage(
                dataDokter: {
                  'id': id,
                  'nama': name,
                  'jadwal': time,
                  'image': imagePath,
                  'tags': tags,
                  'harga_awal': hargaAwal,
                  'harga_diskon': hargaDiskon,
                  'diskon': diskon,
                },
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 165,
          margin: const EdgeInsets.only(
            right: 15,
            bottom: 8,
            top: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12),
                  child: imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          height: 90,
                          width: 90,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildAvatarError(),
                        )
                      : Image.asset(
                          imagePath,
                          height: 90,
                          width: 90,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildAvatarError(),
                        ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: tags.map((tag) {
                    return Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(),
                const Text(
                  "Jadwal tercepat",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E6A3F),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    time,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
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

  Widget _buildAvatarError() {
    return Container(
      height: 90,
      width: 90,
      color: Colors.grey[200],
      child: const Icon(Icons.person, color: Colors.grey),
    );
  }

  // ================= WIDGET BUILDER BANNER KEUNGGULAN BANNER =================
  Widget _buildKeunggulanCard(String number, String text) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12, bottom: 6),
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 120,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1F522F),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, height: 1.3),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Color(0xFFFFD54F), shape: BoxShape.circle),
              child: Text(
                number,
                style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ================= WIDGET BANNER BAWAH =================
  Widget _buildBottomBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD4E7D7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Apa aku butuh\nkonseling",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4326)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KonsultasiPage())),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F522F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text("Cek disini", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildDotIndicator({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      height: 6,
      width: 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }
}