import 'package:flutter/material.dart';
import 'package:yomans_konseling/screens/dokter/PilihPsikologPage.dart';

class HasilPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const HasilPage({
    Key? key,
    required this.result,
  }) : super(key: key);

  // ================= DATA MAPPING DESKRIPSI & SARAN INDONESIA =================
  final Map<String, Map<String, String>> hasilData = const {
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
          "Tetap pertahankan pola hidup sehat, kelola pikiran positif Anda, luangkan waktu untuk hobi, dan jaga komunikasi yang baik dengan orang-orang terdekat."
    }
  };

  @override
  Widget build(BuildContext context) {
    // 1. Parsing Nilai Diagnosis Utama
    final String hasilRaw = result['hasil'] ?? 
                            (result['data'] is Map ? result['data']['hasil'] : null) ?? 
                            "normal";
    final String hasilKey = hasilRaw.toLowerCase().trim();
    final dataLokal = hasilData[hasilKey];

    // 2. Parsing Tingkat Keparahan (Level) - Dipaksa ke String dengan aman (.toString())
    final String levelTampilan = (result['level'] ?? 
                                 (result['data'] is Map ? result['data']['level'] : null) ?? 
                                 "Normal").toString();

    // 3. Parsing Persentase Dinamis - FIX ANTI ERROR TYPE CASTING (int ke String)
    final String stressPct = result['stress_percentage'] != null 
        ? "${result['stress_percentage']}%" 
        : "0%";
        
    final String depresiPct = result['depresi_percentage'] != null 
        ? "${result['depresi_percentage']}%" 
        : "0%";
        
    final String kecemasanPct = result['kecemasan_percentage'] != null 
        ? "${result['kecemasan_percentage']}%" 
        : "0%";

    // 4. Sinkronisasi Konten Teks
    final String deskripsiTampilan = dataLokal?['deskripsi'] ?? "Sistem mendeteksi adanya indikasi kondisi psikologis.";
    final String saranTampilan = result['saran'] ?? 
                                 (result['data'] is Map ? result['data']['saran'] : null) ?? 
                                 dataLokal?['saran'] ?? 
                                 "Tidak ada edukasi tambahan.";

    // 5. Format Judul Hasil Tampilan
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

            // ================= SCROLLABLE CONTENT =================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  // CARD 1: BLOK DIAGNOSIS EMERALD GREEN
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
                        const SizedBox(height: 6),
                        
                        // Menampilkan Label Tingkat/Level Dinamis dengan Operator Ternary Valid
                        Text(
                          "Tingkat : $levelTampilan",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: levelTampilan.toLowerCase() == 'berat' 
                                ? Colors.redAccent[100] 
                                : (levelTampilan.toLowerCase() == 'sedang' 
                                    ? Colors.orangeAccent[100] 
                                    : Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 12),
                        
                        // Nilai Persentase Riil Hasil Sinkronisasi
                        Text("Stress : $stressPct", style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                        Text("Depresi : $depresiPct", style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                        Text("Gangguan Kecemasan : $kecemasanPct", style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                        
                        const SizedBox(height: 20),
                        Text(
                          deskripsiTampilan,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Anda disarankan berkonsultasi langsung ke Psikolog, agar Anda dapat mengetahui kondisi kesehatan mental secara lebih detail.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ACTION BUTTONS
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
                                  onPressed: () => Navigator.pop(context),
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

                  // CARD 2: BOX EDUKASI PASTEL
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