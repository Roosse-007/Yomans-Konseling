import 'package:flutter/material.dart';
import 'package:yomans_konseling/screens/dokter/detail_booking.dart';
// NOTE: Jika api_service.dart milik tim kamu sudah siap dengan fungsi fetch, tinggal aktifkan baris ini
// import '../../services/api_service.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // Metode simulasi lokal untuk data psikolog agar UI bisa langsung tampil tanpa error API
  Future<List<Map<String, dynamic>>> _fetchDokterSimulasi() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Efek loading buatan
    return [
      {
        'id': 1,
        'name': 'Ira Febriana M.Psi., Psikolog',
        'tags': ['Keluarga', 'Kecemasan', 'Percintaan'],
        'image': "lib/assets/ira1.png",
        'time': 'Hari ini, 18.00 WIB',
      },
      {
        'id': 2,
        'name': 'Teguh B.K., Bos Kecil',
        'tags': ['Keluarga', 'Kecemasan', 'Percintaan'],
        'image':"lib/assets/teguh.png",
        'time': 'Hari ini, 18.00 WIB',
      },
      {
        'id': 3,
        'name': 'Lil Roosse K.ing., Petarunkx',
        'tags': ['Keluarga', 'Kecemasan', 'Perkelahian'],
        'image': "lib/assets/gue1.png",
        'time': 'Hari ini, 18.00 WIB',
      },
     
    ];
  }

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
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Pilih Psikolog Anda',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      // FutureBuilder disiapkan untuk menerima data dari Laravel secara asynchronous
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDokterSimulasi(), 
        // JIKA API SUDAH SIAP: Ganti baris future di atas dengan fungsi milik temanmu, misalnya:
        // future: ApiService.getDokter(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xff2d6a4f)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Tidak ada data psikolog tersedia.'),
            );
          }

          final List<Map<String, dynamic>> dataPsikolog = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GridView.builder(
              itemCount: dataPsikolog.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,          // Menampilkan 2 kolom miring kanan-kiri
                crossAxisSpacing: 10,       // Jarak mendatar antar kartu
                mainAxisSpacing: 10,        // Jarak tegak antar kartu
                childAspectRatio: 1,     // Rasio tinggi-lebar kartu agar rapi
              ),
              itemBuilder: (context, index) {
                final item = dataPsikolog[index];
                return _buildPsychologistCard(context, item);
              },
            ),
          );
        },
      ),
    );
  }

  // Komponen Kartu Item Psikolog sesuai mockup gambar
 Widget _buildPsychologistCard(BuildContext context, Map<String, dynamic> data) {
    final String imagePath = data['image'] ?? '';
    final bool isNetworkImage = imagePath.startsWith('http');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 4), // Efek bayangan halus & premium
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. FOTO PROFIL (Melengkung Sempurna & Presisi)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isNetworkImage
                  ? Image.network(
                      imagePath,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      imagePath,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey[100],
                          child: Icon(Icons.person, size: 45, color: Colors.grey[400]),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 4),

            // 2. NAMA PSIKOLOG
            Text(
              data['name'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87, // Warna hitam pekat profesional yang aman
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // 3. CHIPS/TAGS KATEGORI (Rapi & Tidak Kebesaran)
            Wrap(
              spacing: 2,
              runSpacing: 2,
              alignment: WrapAlignment.center,
              children: ((data['tags'] ?? []) as List<String>).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xffe8f5e9), // Latar belakang hijau muda soft
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Color(0xff2d6a4f), // Hijau tua tema Yomans
                      fontSize: 8, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                );
              }).toList(),
            ),

            const Spacer(), // Mendorong otomatis teks jadwal ke dasar kartu agar sejajar rata kanan-kiri

            // 4. TEKS JADWAL TERCEPAT
            const Text(
              'Jadwal tercepat',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 9,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),

            // 5. TOMBOL BOOKING HIJAU (Simetris & Pas Ukurannya)
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
               // Ganti properti onPressed tombol hijau di booking.dart kamu dengan ini:
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailBookingPage(dataDokter: data),
                  ),
                );
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2d6a4f), // Hijau tua khas Yomans
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  data['time'] ?? '',
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
      ),
    );
  }
}