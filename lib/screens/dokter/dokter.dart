import 'package:flutter/material.dart';

class BookingMenuPage extends StatelessWidget {
  const BookingMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () {
            Navigator.pop(context); // Atau sesuaikan dengan navigasi kamu
          },
        ),
        title: const Text(
          'Psikolog Ira',
          style: TextStyle(
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
            padding: const EdgeInsets.only(bottom: 100), // Agar konten tidak tertutup tombol bawah
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                
                // --- Header Foto & Background Hijau Muda ---
                Center(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9).withOpacity(0.5), // Background hijau muda lembut
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Container(
                        width: 140,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF1B5E20), // Border hijau tua
                            width: 4,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=400', // Foto dummy psikolog
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Nama & Gelar Psikolog ---
                const Center(
                  child: Text(
                    'Ira Febriana M.Psi., Psikolog',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // --- Tag Keahlian / Kategori ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTag('Keluarga'),
                    const SizedBox(width: 8),
                    _buildTag('Kecemasan'),
                    const SizedBox(width: 8),
                    _buildTag('Percintaan'),
                  ],
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
                            color: const Color(0xFF1B5E20), // Garis aktif hijau
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
                            color: Colors.grey[300], // Garis tidak aktif grey
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Bagian Ulasan Psikolog ---
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

                // --- List Ulasan ---
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

          // --- Tombol Konseling (Fixed di Bawah Layar) ---
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
                  backgroundColor: const Color(0xFF006622), // Hijau tua pekat
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

  // Widget Helper: Tag / Badge Kategori
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

  // Widget Helper: Item Komentar / Ulasan
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
                  // BENAR
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
            'Ngobrol sama Kak Ira itu nyaman banget, serasa cerita ke temen tapi tetap dapat solusi yang profesional. Bener-bener ngebantu aku memahami diri sendiri lebih baik.',
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