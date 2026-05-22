import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'hasil.dart';

class KonsultasiPage extends StatefulWidget {
  @override
  _KonsultasiPageState createState() => _KonsultasiPageState();
}

class _KonsultasiPageState extends State<KonsultasiPage> {
  bool isLoading = false;

  // ================= DATA GEJALA UTAMA (TOTAL 27 DATA - SESUAI BACKEND ML) =================
  final Map<String, bool> gejala = {
    "gangguan_tidur": false,
    "lelah": false,
    "sakit_kepala": false,
    "sakit_perut": false,
    "nyeri_dada": false,
    "otot_tegang": false,
    "penurunan_gairah_seksual": false,
    "obesitas": false,
    "hipertensi": false,
    "diabetes": false,
    "gangguan_jantung": false,
    
    "sulit_tidur": false,
    "badan_gemetar": false,
    "keringat_berlebih": false,
    "jantung_berdebar": false,
    "sesak_nafas": false,
    "pusing": false,
    "mulut_kering": false,
    "kesemutan": false,
    
    "kehilangan_minat": false,
    "sedih_terus": false,
    "mudah_menangis": false,
    "merasa_bersalah": false,
    "tidak_percaya_diri": false,
    "mudah_tersinggung": false,
    "tidak_acuh": false,
    "bunuh_diri": false, // Tambahan fitur baru sesuai skema backend
  };

  // ================= URUTAN KOLOM KIRI (14 ITEM) =================
  final List<String> urutanGejalaKiri = [
    "gangguan_tidur",
    "lelah",
    "sakit_kepala",
    "sakit_perut",
    "nyeri_dada",
    "otot_tegang",
    "penurunan_gairah_seksual",
    "obesitas",
    "hipertensi",
    "diabetes",
    "gangguan_jantung",
    "sulit_tidur",
    "badan_gemetar",
    "keringat_berlebih",
  ];

  // ================= URUTAN KOLOM KANAN (13 ITEM) =================
  final List<String> urutanGejalaKanan = [
    "jantung_berdebar",
    "sesak_nafas",
    "pusing",
    "mulut_kering",
    "kesemutan",
    "kehilangan_minat",
    "sedih_terus",
    "mudah_menangis",
    "merasa_bersalah",
    "tidak_percaya_diri",
    "mudah_tersinggung",
    "tidak_acuh",
    "bunuh_diri",
  ];

  // ================= LABEL DISPLAY FRONTEND =================
  final Map<String, String> labels = {
    "gangguan_tidur": "Gangguan tidur",
    "lelah": "Lelah",
    "sakit_kepala": "Sakit Kepala",
    "sakit_perut": "Sakit Perut / Kepala",
    "nyeri_dada": "Nyeri Dada",
    "otot_tegang": "Nyeri atau tegang pada otot",
    "penurunan_gairah_seksual": "Penurunan gairah seksual",
    "obesitas": "Obesitas",
    "hipertensi": "Hipertensi",
    "diabetes": "Diabetes",
    "gangguan_jantung": "Gangguan Jantung",
    "sulit_tidur": "Sulit tidur",
    "badan_gemetar": "Badan Gemetar",
    "keringat_berlebih": "Mengeluarkan keringat berlebih",
    "jantung_berdebar": "Jantung Berdebar",
    "sesak_nafas": "Sesak Nafas",
    "pusing": "Pusing",
    "mulut_kering": "Mulut Terasa Kering",
    "kesemutan": "Kesemutan",
    "kehilangan_minat": "Kehilangan Motivasi",
    "sedih_terus": "Merasa Sedih Terus Menerus",
    "mudah_menangis": "Mudah Menangis",
    "merasa_bersalah": "Merasa Bersalah Berlebihan",
    "tidak_percaya_diri": "Tidak Percaya Diri",
    "mudah_tersinggung": "Mudah Tersinggung",
    "tidak_acuh": "Tidak Acuh / Apatis",
    "bunuh_diri": "Ide atau Pikiran Bunuh Diri",
  };

  // Fungsi untuk membersihkan / mengosongkan semua pilihan centang
  void resetCentangGejala() {
    gejala.updateAll((key, value) => false);
  }

  void proses() async {
    setState(() => isLoading = true);

    List<String> gejalaTerpilih = [];
    gejala.forEach((key, value) {
      if (value == true) {
        gejalaTerpilih.add(key);
      }
    });

    Map<String, dynamic> requestBody = {"gejala": gejalaTerpilih};
    final res = await ApiService.konsultasi(requestBody);

    // Jika widget sudah ditutup oleh user saat menunggu data dari server, 
    // hentikan eksekusi kode di bawahnya agar tidak terjadi error BuildContext/setState.
    if (!mounted) return;

    setState(() => isLoading = false);

    // Jika fungsi ApiService.konsultasi Anda mengembalikan map kosong/error saat gagal,
    // kita periksa apakah datanya valid (misal: cek isi map atau status di dalamnya)
    if (res.isNotEmpty && !res.containsKey('error')) { 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HasilPage(result: res)),
      ).then((_) {
        // 🔹 DI SINI PROSES RESET TERJADI
        // Ketika user kembali (pop) dari HasilPage, blok kode ini akan langsung dijalankan
        setState(() {
          resetCentangGejala();
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal terhubung ke server atau data kosong")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ================= CUSTOM APP BAR =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Asesmen Konseling Online",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // ================= SCROLLABLE CONTENT =================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6EAD4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Asesmen awal online merupakan proses otomatis yang dirancang untuk mengumpulkan informasi dasar mengenai kondisi Anda secara cepat. Hasil asesmen ini akan digunakan oleh sistem untuk memberikan rekomendasi awal sebelum melanjutkan ke sesi konsultasi",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF426A44),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tampilan Grid Menggunakan Table (Sangat Stabil & Rapi)
                  CustomPaint(
                    painter: CardBackgroundPainter(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(1),
                        },
                        children: List.generate(urutanGejalaKiri.length, (index) {
                          String keyKiri = urutanGejalaKiri[index];
                          // Proteksi aman jika jumlah array kanan lebih sedikit dibanding array kiri
                          String keyKanan = (index < urutanGejalaKanan.length) ? urutanGejalaKanan[index] : "";

                          return TableRow(
                            children: [
                              // Slot Kolom Kiri
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: _buildCheckboxItem(keyKiri),
                              ),
                              // Slot Kolom Kanan
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: keyKanan.isNotEmpty 
                                    ? _buildCheckboxItem(keyKanan) 
                                    : const SizedBox(), // Kotak kosong agar baris seimbang
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // ================= BUTTON KIRIM =================
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, bottom: 30, top: 10),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : proses,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00642C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Kirim",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget Kotak Centang Putih Bersih (Background & Border Dikunci Putih Saat Kosong)
  Widget _buildCheckboxItem(String key) {
    bool isChecked = gejala[key] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Menimpa warna latar belakang bawaan tema Flutter
                borderRadius: BorderRadius.circular(4),
              ),
              child: Checkbox(
                value: isChecked,
                activeColor: const Color(0xFF00642C), 
                checkColor: Colors.white,            
                side: BorderSide(
                  color: isChecked ? Colors.transparent : Colors.white,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      gejala[key] = value;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                labels[key] ?? key,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF325433),
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= CUSTOM CANVAS BACKGROUND LAYER =================
class CardBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFCBE5C9)
      ..style = PaintingStyle.fill;

    final RRect outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    canvas.drawRRect(outerRect, paint);

    final Paint wavePaint1 = Paint()
      ..color = const Color(0xFFD4EAD2).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final Path path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.6, 0)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.1, 0, size.height * 0.05)
      ..close();
    canvas.drawPath(path1, wavePaint1);

    final Paint wavePaint2 = Paint()
      ..color = const Color(0xFFB9DCB6).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final Path path2 = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width * 0.35, size.height)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.9, size.width, size.height * 0.85)
      ..close();
    canvas.drawPath(path2, wavePaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}