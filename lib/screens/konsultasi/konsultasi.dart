import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'hasil.dart';

class KonsultasiPage extends StatefulWidget {
  @override
  _KonsultasiPageState createState() => _KonsultasiPageState();
}

class _KonsultasiPageState extends State<KonsultasiPage> {
  bool isLoading = false;

  // ================= DATA GEJALA UTAMA BAWAAN (DIKURANGI HANYA YANG DOUBLE) =================
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
    
    // "sulit_tidur" dihapus karena double dengan gangguan_tidur
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
    "bunuh_diri": false, 
  };

  // ================= URUTAN KOLOM KIRI (DATA BAWAAN - SULIT_TIDUR DIHAPUS) =================
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
    "badan_gemetar",
    "keringat_berlebih",
  ];

  // ================= URUTAN KOLOM KANAN (DATA BAWAAN) =================
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
    
  ];

  // ================= LABEL DISPLAY FRONTEND =================
  final Map<String, String> labels = {
    "gangguan_tidur": "Gangguan tidur",
    "lelah": "Lelah",
    "sakit_kepala": "Sakit kepala",
    "sakit_perut": "Sakit perut",
    "nyeri_dada": "Nyeri dada",
    "otot_tegang": "Nyeri atau tegang pada otot",
    "penurunan_gairah_seksual": "Penurunan gairah seksual",
    "obesitas": "Obesitas",
    "hipertensi": "Hipertensi",
    "diabetes": "Diabetes",
    "gangguan_jantung": "Gangguan jantung",
    // "sulit_tidur" dihapus dari label display
    "badan_gemetar": "Badan gemetar",
    "keringat_berlebih": "Mengeluarkan keringat secara berlebihan",
    "jantung_berdebar": "Jantung berdebar",
    "sesak_nafas": "Sesak nafas",
    "pusing": "Pusing",
    "mulut_kering": "Mulut terasa kering",
    "kesemutan": "Kesemutan",
    "kehilangan_minat": "Kehilangan ketertarikan atau motivasi",
    "sedih_terus": "Terus menerus merasa sedih",
    "merasa_bersalah": "Merasa sangat bersalah dan khawatir berlebihan",
    "tidak_percaya_diri": "Tidak dapat menikmati hidup",
    "mudah_tersinggung": "Sulit mengubah keputusan dan mudah tersinggung",
    "tidak_acuh": "Otot leher dan pundak terasa tegang atau kaku",
    "mudah_menangis": "Mudah menangis",
   
  };

  @override
  void initState() {
    super.initState();
    sinkronkanDataDariAdmin();
  }

  // 🔹 LOGIKA UTAMA SINKRONISASI
// 🔹 LOGIKA UTAMA SINKRONISASI (DIPERBARUI AGAR PASTI MASUK PALING BAWAH)
  void sinkronkanDataDariAdmin() async {
    try {
      final List<dynamic> dataAdmin = await ApiService.getGejala(); 
      
      setState(() {
        for (var item in dataAdmin) {
          String labelBaru = item['nama_gejala'];
          String keyBaru = item['key_gejala'] ?? labelBaru.toLowerCase().trim().replaceAll(' ', '_');

          // Jika data dari admin belum terdaftar di map bawaan, masukkan ke baris akhir
          if (!gejala.containsKey(keyBaru)) {
            gejala[keyBaru] = false;
            labels[keyBaru] = labelBaru;

            // Memasukkan ke kolom yang paling pendek saat itu agar seimbang di paling bawah
            if (urutanGejalaKiri.length <= urutanGejalaKanan.length) {
              urutanGejalaKiri.add(keyBaru);
            } else {
              urutanGejalaKanan.add(keyBaru);
            }
          }
        }
      });
    } catch (e) {
      print("Gagal menyinkronkan data tambahan dari admin: $e");
    }
  }

  // Fungsi untuk membersihkan / mengosongkan semua pilihan centang
  void resetCentangGejala() {
    gejala.updateAll((key, value) => false);
  }

  // ================= PERBAIKAN FUNGSI PROSES (ANTI GAJAL / 0%) =================
  void proses() async {
    setState(() => isLoading = true);

    List<String> gejalaTerpilih = [];

    // 1. Ambil data asli dari admin yang sudah disinkronkan lewat API
    try {
      final List<dynamic> dataAdmin = await ApiService.getGejala();

      gejala.forEach((key, value) {
        if (value == true) {
          // Cari data yang cocok di database berdasarkan key atau kecocokan teks label
          var dataCocok = dataAdmin.firstWhere(
            (element) {
              String keyDb = element['key_gejala'] ?? element['nama_gejala'].toString().toLowerCase().trim().replaceAll(' ', '_');
              return keyDb == key || element['nama_gejala'].toString().toLowerCase().trim() == labels[key]?.toLowerCase().trim();
            },
            orElse: () => null,
          );

          if (dataCocok != null) {
            // Jika ketemu di database, kirim teks asli dari database murni!
            gejalaTerpilih.add(dataCocok['nama_gejala'].toString());
          } else {
            // Jika tidak ketemu (data bawaan lokal), kirim label lokal bawaan
            gejalaTerpilih.add(labels[key] ?? key);
          }
        }
      });
    } catch (e) {
      print("Gagal mengambil data pembanding dari database, menggunakan fallback lokal: $e");
      // Fallback jika API gagal saat proses
      gejala.forEach((key, value) {
        if (value == true) {
          gejalaTerpilih.add(labels[key] ?? key);
        }
      });
    }

    // Cetak di debug console untuk memastikan data yang dikirim sudah berupa teks bersih
    print("DATA YANG DIKIRIM KE FLASK: $gejalaTerpilih");

    Map<String, dynamic> requestBody = {"gejala": gejalaTerpilih};
    final res = await ApiService.konsultasi(requestBody);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (res.isNotEmpty && !res.containsKey('error')) { 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HasilPage(result: res)),
      ).then((_) {
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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 25),
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
                                    : const SizedBox(), 
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

  // Widget Kotak Centang (Bisa diklik via teks label & box)
  Widget _buildCheckboxItem(String key) {
    bool isChecked = gejala[key] ?? false;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          gejala[key] = !isChecked;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, 
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
      ),
    );
  }
}

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