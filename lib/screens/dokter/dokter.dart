import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yomans_konseling/providers/dokter_provider.dart'; // Jangan lupa import provider
// import 'path_ke_provider_kamu/dokter_provider.dart'; 

class PsikologPage extends StatelessWidget {
  final int dokterId; // Terima ID dokter yang dipilih dari halaman sebelumnya

  const PsikologPage({super.key, required this.dokterId});

  @override
  Widget build(BuildContext context) {
    // Ambil data provider
    final dokterProvider = Provider.of<DokterProvider>(context);
    
    // Cari data dokter yang spesifik berdasarkan ID yang dikirim
    final dokter = dokterProvider.listDokter.firstWhere(
      (d) => d['id'] == dokterId,
      orElse: () => {},
    );

    // Proteksi jika data dokter tidak ditemukan
    if (dokter.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Data dokter tidak ditemukan")),
      );
    }

    // Ambil data dari map agar kode di bawah lebih bersih
    final String namaDokter = dokter['nama'] ?? '';
    final List<String> tags = List<String>.from(dokter['tags'] ?? []);
    final String imageUrl = dokter['image_url'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 25),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // DINAMIS: Nama di AppBar mengikuti dokter yang dipilih
        title: Text(
          namaDokter.split(' ').first, // Mengambil kata pertama saja (misal: "Ira")
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                
                // --- Header Foto & Background ---
                Center(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Container(
                        width: 140,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF1B5E20),
                            width: 4,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            // DINAMIS: Menggunakan AssetImage karena datamu berupa path lokal
                            image: AssetImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Nama & Gelar Dokter ---
                Center(
                  child: Text(
                    namaDokter, // DINAMIS
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // --- Tag Keahlian / Kategori ---
                // DINAMIS: Menampilkan berapapun jumlah tag dari Provider menggunakan Wrap
                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: tags.map((tag) => _buildTag(tag)).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Tab Menu (Profil & Jadwal) ---
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Profil Psikolog',
                            style: TextStyle(
                              color: Color(0xFF1B5E20),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 3,
                            color: const Color(0xFF1B5E20),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Jadwal',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 3,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Bagian Ulasan ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ulasan Psikolog',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                _buildReviewItem(
                  initial: 'U',
                  name: 'Udin Jabrix',
                  date: '07/03/2026',
                  avatarColor: Colors.green[800]!,
                ),
                const Divider(height: 1, thickness: 1),
                _buildReviewItem(
                  initial: 'JK',
                  name: 'Jamal Kopling',
                  date: '08/03/2026',
                  avatarColor: Colors.teal[800]!,
                ),
                const Divider(height: 1, thickness: 1),
              ],
            ),
          ),

          // --- Tombol Konseling ---
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Aksi tombol konseling
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006622),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Konseling Dengan Psikolog',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF2E7D32),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildReviewItem({
    required String initial,
    required String name,
    required String date,
    required Color avatarColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: avatarColor,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ngobrol nyaman banget, serasa cerita ke temen tapi tetap dapat solusi yang profesional.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}