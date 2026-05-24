import 'package:flutter/material.dart';
import 'package:yomans_konseling/screens/dokter/PilihPsikologPage.dart';


class HasilPage extends StatelessWidget {
  final Map<String, dynamic> result;

  HasilPage({
    required this.result,
  });

  // ================= DATA MAPPING DESKRIPSI & SARAN =================
  final Map<String, Map<String, String>> hasilData = {
    "stres": {
      "deskripsi":
          "Sistem mendeteksi adanya indikasi gangguan psikologis berdasarkan kecocokan gejala yang Anda pilih.",
      "saran":
          "Mengenali kondisi psikologis sejak dini sangat penting untuk mencegah gangguan berkembang menjadi lebih serius. Disarankan untuk menjaga pola tidur, mengelola stres, dan berkonsultasi dengan tenaga profesional apabila keluhan berlanjut."
    },
    "kecemasan": {
      "deskripsi":
          "Sistem mendeteksi adanya indikasi gangguan kecemasan (Anxiety) berdasarkan kecocokan gejala yang Anda pilih.",
      "saran":
          "Mengenali kondisi psikologis sejak dini sangat penting untuk mencegah gangguan berkembang menjadi lebih serius. Disarankan untuk melakukan relaksasi, mengurangi overthinking, dan membatasi konsumsi kafein."
    },
    "depresi": {
      "deskripsi":
          "Sistem mendeteksi adanya indikasi gangguan depresi berdasarkan kecocokan gejala yang Anda pilih.",
      "saran":
          "Mengenali kondisi psikologis sejak dini sangat penting untuk mencegah gangguan berkembang menjadi lebih serius. Sangat disarankan untuk segera menjadwalkan konsultasi dengan psikolog atau psikiater terdekat."
    },
    "normal": {
      "deskripsi":
          "Kondisi kesehatan mental Anda saat ini berada dalam batas normal dan stabil.",
      "saran":
          "Tetap pertahaman pola hidup sehat, kelola pikiran positif Anda, luangkan waktu untuk hobi, dan jaga komunikasi yang baik dengan orang-orang terdekat."
    }
  };

  @override
  Widget build(BuildContext context) {
    // 1. Ambil nilai hasil utama dari backend
    final String hasilRaw = result['hasil'] ?? 
                            (result['data'] is Map ? result['data']['hasil'] : null) ?? 
                            "normal";
    final String hasilKey = hasilRaw.toLowerCase().trim();
    final dataLokal = hasilData[hasilKey];

    // 2. Ambil nilai persentase secara dinamis dari JSON response Flask
    final String stressPct = result['stress_percentage'] ?? "0%";
    final String depresiPct = result['depresi_percentage'] ?? "0%";
    final String kecemasanPct = result['kecemasan_percentage'] ?? "0%";

    // 3. Sinkronisasi teks deskripsi & edukasi saran
    final String deskripsiTampilan = dataLokal?['deskripsi'] ?? "Sistem mendeteksi adanya indikasi kondisi psikologis.";
    final String saranTampilan = result['saran'] ?? 
                                 (result['data'] is Map ? result['data']['saran'] : null) ?? 
                                 dataLokal?['saran'] ?? 
                                 "Tidak ada edukasi.";

    // 4. Format judul teks (stres -> Stress)
    String judulHasil = hasilRaw.isNotEmpty 
        ? "${hasilRaw[0].toUpperCase()}${hasilRaw.substring(1)}" 
        : "Tidak Diketahui";
    if (judulHasil.toLowerCase() == "stres") judulHasil = "Stress";

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
                    "Hasil Konsultasi Awal Psikologi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // ================= MAIN CONTAINER SCROLLABLE =================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  // CARD 1: BLOK DIAGNOSIS UTAMA (HIJAU TUA EMERALD)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B5B37),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hasil : $judulHasil",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Menampilkan data persentase dinamis dari backend
                        Text("Stress : $stressPct", style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                        Text("Depresi : $depresiPct", style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                        Text("Gangguan Kecemasan : $kecemasanPct", style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                        
                        const SizedBox(height: 24),
                        Text(
                          deskripsiTampilan,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Anda disarankan berkonsultasi langsung ke Psikolog, Agar anda dapat menegetahui kondisi kesehatan mental secara lebih detail.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // CONTAINER ACTIONS BUTTON
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => PilihPsikologPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD3EAD0),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    "Konsultasi Langsung",
                                    style: TextStyle(
                                      color: Color(0xFF2B5B37),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD3EAD0),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    "Tes Ulang",
                                    style: TextStyle(
                                      color: Color(0xFF2B5B37),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CARD 2: BOX EDUKASI (HIJAU MUDA PASTEL)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F0E1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Edukasi :",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B5B37),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          saranTampilan,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF3C5E43),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}