import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yomans_konseling/providers/dokter_provider.dart';
import 'package:yomans_konseling/screens/berita/informasi.dart';
import 'package:yomans_konseling/screens/dokter/detail_booking.dart';
import 'package:yomans_konseling/screens/halaman_akun/profile_screen.dart';
import 'package:yomans_konseling/screens/home/home.dart';

class PilihPsikologPage extends StatefulWidget {
  const PilihPsikologPage({super.key});

  @override
  State<PilihPsikologPage> createState() => _PilihPsikologPageState();
}

class _PilihPsikologPageState extends State<PilihPsikologPage> {
  int _currentIndex = 0; 

@override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await Provider.of<DokterProvider>(
        context,
        listen: false,
      ).fetchDokter();

      print("Jumlah dokter:");
      print(
        Provider.of<DokterProvider>(
          context,
          listen: false,
        ).listDokter.length,
      );
    });
  }
  

  @override
  Widget build(BuildContext context) {
    final dokterProvider = Provider.of<DokterProvider>(context);
    final listDokter = dokterProvider.listDokter;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 25,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pilih Psikolog Anda",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: listDokter.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1B5E20),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: listDokter.length,
              itemBuilder: (context, index) {
                final dokter = listDokter[index];

                // Pengaman tipe data ID (mengantisipasi jika dari DB berupa int atau string)
                final int id = dokter['id'] is int 
                    ? dokter['id'] 
                    : int.tryParse(dokter['id'].toString()) ?? 0;
                    
                final String nama = dokter['nama'] ?? 'Nama Psikolog';
                final String imageUrl = dokter['image_url'] ?? '';
                final String jadwal = dokter['jadwal'] ?? 'Belum ada jadwal';

                // ================= LOGIKA PENGAMAN TAGS (FIX DATA HAN SO-HEE) =================
                List<String> tags = [];
                if (dokter['tags'] != null && dokter['tags'].toString() != 'null') {
                  if (dokter['tags'] is List) {
                    tags = List<String>.from(dokter['tags']);
                  } else if (dokter['tags'] is String) {
                    String tagsRaw = dokter['tags'].toString().trim();
                    
                    if (tagsRaw.startsWith('[')) {
                      tagsRaw = tagsRaw.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').replaceAll("'", "");
                      tags = tagsRaw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                    } else {
                      tags = tagsRaw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                    }
                  }
                }
                
                if (tags.isEmpty) {
                  tags = ['Umum'];
                }
                // =============================================================================

                return _DokterCard(
                id: id,
                nama: nama,
                imageUrl: imageUrl,
                tags: tags,
                jadwal: jadwal,

                hargaAwal: dokter['harga_awal'],
                hargaDiskon: dokter['harga_diskon'],
                diskon: dokter['diskon'],
              );
              },
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
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
            }
          } else if (index == 1) {
             Navigator.push(context, MaterialPageRoute(builder: (_) => Informasi()));
          } else if (index == 2) {
             // Sediakan navigasi halaman Riwayat di sini jika sudah ada
          } else if (index == 3) {
             Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
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
            label: "Akun",
          ),
        ],
      ),
    );
  }
}

class _DokterCard extends StatefulWidget {
  final int id;
  final String nama;
  final String imageUrl;
  final List<String> tags;
  final String jadwal;

  final dynamic hargaAwal;
  final dynamic hargaDiskon;
  final dynamic diskon;

  const _DokterCard({
    required this.id,
    required this.nama,
    required this.imageUrl,
    required this.tags,
    required this.jadwal,

    required this.hargaAwal,
    required this.hargaDiskon,
    required this.diskon,
  });

  @override
  State<_DokterCard> createState() => _DokterCardState();
}

class _DokterCardState extends State<_DokterCard> {
  bool isPressed = false;
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapCancel: () => setState(() => isPressed = false),
        onTapUp: (_) {
          setState(() => isPressed = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailBookingPage(
            dataDokter: {
              'id': widget.id,
              'nama': widget.nama,
              'jadwal': widget.jadwal,
              'image': widget.imageUrl,
              'tags': widget.tags,

              'harga_awal': widget.hargaAwal,
              'harga_diskon': widget.hargaDiskon,
              'diskon': widget.diskon,
                },
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 12),
          transform: Matrix4.identity()..scale(isPressed ? 0.99 : 1.0),
          decoration: BoxDecoration(
            color: isPressed ? const Color(0xFF1B5E20).withOpacity(0.02) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHover ? const Color(0xFF1B5E20).withOpacity(0.5) : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FOTO (SISI KIRI)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 85,
                  height: 95,
                  child: widget.imageUrl.startsWith('http')
                      ? Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : Image.asset(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // INFO KONTEN (SISI KANAN)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // TAGS KEAHLIAN (MAX 3)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: widget.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF1B5E20),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // DETAIL JADWAL TERCEPAT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            "Jadwal tercepat",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // ================= NAVIGASI TOMBOL JADWAL =================
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailBookingPage(
                                  dataDokter: {
                                    'id': widget.id, 
                                    'nama': widget.nama,
                                    'jadwal': widget.jadwal,
                                    'image': widget.imageUrl,
                                    'tags': widget.tags,
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B5E20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.jadwal,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.person,
        color: Colors.grey,
        size: 30,
      ),
    );
  }
}