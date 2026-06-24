

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yomans_konseling/providers/dokter_provider.dart';
import 'package:yomans_konseling/screens/admin/kelola_jadwal.dart';
import 'package:yomans_konseling/screens/admin/tambahDataPsikolog.dart';
import 'package:yomans_konseling/screens/admin/editDataPsikolog.dart'; // <--- Sesuaikan dengan path file Anda
import 'package:http/http.dart' as http; 
import 'dart:convert'; // <--- WAJIB DITAMBAHKAN UNTUK DECODE JSON MESSAGES

class DaftarPsikologAdminPage extends StatefulWidget {
  const DaftarPsikologAdminPage({Key? key}) : super(key: key);

  @override
  State<DaftarPsikologAdminPage> createState() =>
      _DaftarPsikologAdminPageState();
}

class _DaftarPsikologAdminPageState
    extends State<DaftarPsikologAdminPage> {
      int _cacheBuster = 0;
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<DokterProvider>(
        context,
        listen: false,
      ).fetchDokter();
    });
  }

  // ================= FUNGSI TOGGLE DENGAN NOTIFIKASI DINAMIS =================
 Future<void> _prosesToggleAndalan(
  int id,
  DokterProvider provider,
) async {

  try {

    final response = await http.post(
      Uri.parse(
        "http://127.0.0.1:5000/api/admin/dokter/$id/toggle-andalan",
      ),
    );

    print(
      "STATUS TOGGLE = ${response.statusCode}",
    );

    print(
      "BODY TOGGLE = ${response.body}",
    );

    if (response.statusCode != 200) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Server Error ${response.statusCode}",
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final data =
        jsonDecode(response.body);

    await provider.fetchDokter();

    if (mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            data['message'] ??
                "Status andalan diperbarui",
          ),
          backgroundColor:
              const Color(
            0xFF2E7D32,
          ),
        ),
      );
    }

  } catch (e) {

    print(
      "TOGGLE ERROR = $e",
    );

  }
  }

  @override
  Widget build(BuildContext context) {
    final dokterProvider =
        Provider.of<DokterProvider>(context);

    final listDokter = dokterProvider.listDokter;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      // ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          'Daftar Psikolog',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        centerTitle: true,
      ),

      // ================= BODY =================
      body: listDokter.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                24,
              ),

              itemCount: listDokter.length,

              itemBuilder: (context, index) {
                final dokter = listDokter[index];

                /// ================= AMBIL TAG =================
List<String> tags = [];

if (dokter['tags'] != null &&
    dokter['tags'].toString().isNotEmpty &&
    dokter['tags'].toString().toLowerCase() != "null") {
  tags = dokter['tags']
      .toString()
      .split(',')
      .map((e) => e.trim())
      .toList();
}

                // Cek status andalan (jika bernilai 1 berarti termasuk psikolog andalan)
                final bool isAndalan = dokter['is_andalan'] == 1 || dokter['is_andalan'] == '1';

                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 14,
                  ),

                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(14),

                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.02,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,

                    children: [
                      // ================= FOTO =================
                      Container(
                        width: 75,
                        height: 75,

                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFEDF2F7),

                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),

                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                          child: _buildImage(
                            dokter,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // ================= DATA =================
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            Text(
                              dokter['nama'] ?? '',

                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 15,
                                color:
                                    Color(0xFF1A202C),
                              ),

                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 8),

                            Wrap(
                              spacing: 6,
                              runSpacing: 4,

                              children:
                                  tags.map((tag) {
                                return Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xFFE8F5E9,
                                    ),

                                    borderRadius:
                                        BorderRadius.circular(
                                      6,
                                    ),
                                  ),

                                  child: Text(
                                    tag.toString(),

                                    style:
                                        const TextStyle(
                                      color:
                                          Color(
                                        0xFF2E7D32,
                                      ),

                                      fontSize: 10,

                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

// ================= ACTION =================
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          // --- TOMBOL IKON BINTANG (TOGGLE ANDALAN) ---
                              IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isAndalan ? Icons.star_rounded : Icons.star_border_rounded,
                              color: isAndalan ? Colors.amber : const Color(0xFFA0AEC0),
                                  size: 28,
                                ),
                                onPressed: () {
                              _prosesToggleAndalan(dokter['id'], dokterProvider);
                            },
                          ),
                          const SizedBox(width: 6),

                          // --- TOMBOL EDIT ---
                       IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.edit_note_rounded, color: Colors.blue, size: 28),
                          onPressed: () async {
                            // 1. Awal dari fungsi async
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EditPsikologPage(dokter: dokter)),
                            );

                            // 2. Logika IF diletakkan di DALAM onPressed
                            if (result == true) {
                              setState(() {
                                _cacheBuster = DateTime.now().millisecondsSinceEpoch;
                              });
                              dokterProvider.fetchDokter();
                            }
                          }, // <--- Pastikan ada tanda koma setelah kurung kurawal penutup onPressed
                        ),
                          // --- TOMBOL JADWAL ---
                              IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.green,
                              size: 24,
                                ),
                               onPressed: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => KelolaJadwalPage(
                                    dokterId: dokter['id'],
                                    namaDokter: dokter['nama'],
                                  ),
                                ),
                              );

                            },
                              ),
                          const SizedBox(width: 6),

                          // --- TOMBOL HAPUS ---
                              IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                  size: 24,
                                ),
                                onPressed: () {
                                  _tampilkanDialogHapus(
                                    context,
                                    dokter,
                                    dokterProvider,
                                  );
                                },
                              ),
                            ],
                          ), // Penutup Row Action
                        ],
                      ), // Penutup Row Utama di dalam Container
                    ); // Penutup Container item
                  }, // Penutup itemBuilder
                ), // Penutup ListView.builder

      // ================= BUTTON BAWAH =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),

        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const TambahPsikologPage(),
              ),
            );
          },

          icon: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 22,
          ),

          label: const Text(
            "Tambah Data Psikolog",

            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF2E7D32),

            padding:
                const EdgeInsets.symmetric(
              vertical: 14,
            ),

            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // ================= BUILD IMAGE (VERSI TERBAIK & BERSIH) =================
  Widget _buildImage(Map<String, dynamic> dokter) {
    final String? fotoPath = dokter['image_url']?.toString();

    if (fotoPath == null || fotoPath.isEmpty) {
      return const Icon(
        Icons.person,
        size: 40,
        color: Color(0xFFA0AEC0),
      );
    }

    if (fotoPath.startsWith('http')) {
      final String webSafeUrl = fotoPath.replaceAll('http://127.0.0.1:', 'http://localhost:');

      return SizedBox(
  width: 75,
  height: 75,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      // TAMBAHKAN INI: Menambahkan parameter unik (?t=...)
      // Jika url sudah memiliki query, ganti '&' menjadi '?'
      "$webSafeUrl${webSafeUrl.contains('?') ? '&' : '?'}v=$_cacheBuster",
  fit: BoxFit.cover,
      // Penting: agar cache tidak terus menerus digunakan oleh Image widget
      cacheWidth: 300, 
      errorBuilder: (context, error, stackTrace) {
        print("Gagal memuat gambar: $error");
        return const Icon(Icons.person, size: 40, color: Color(0xFFA0AEC0));
      },
    ),
  ),
);
    }
    
    else if (fotoPath.startsWith('lib/')) {
      return Image.asset(
        fotoPath,
        fit: BoxFit.cover,
        width: 75,
        height: 75,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image_rounded, size: 35, color: Colors.redAccent);
      },
    );
  }

    else {
      return const Icon(
      Icons.person,
      size: 40,
        color: Color(0xFFA0AEC0),
  );
}
  }

  // ================= DIALOG HAPUS =================
  void _tampilkanDialogHapus(
    BuildContext context,
    Map<String, dynamic> dokter,
    DokterProvider provider,
  ) {
    showDialog(
      context: context,

      builder: (ctx) => AlertDialog(
        title: const Text(
          "Hapus Dokter",
        ),

        content: Text(
          "Apakah Anda yakin ingin menghapus ${dokter['nama']} dari database?",
        ),

        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx),

            child: const Text("Batal"),
          ),

          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);

              await provider.hapusDokter(
                dokter['id'],
              );
            },

            child: const Text(
              "Hapus",

              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildImage(Map<String, dynamic> dokter) {
  final String? fotoPath = dokter['image_url']?.toString();

  // 1. KONDISI JIKA FOTO KOSONG
  if (fotoPath == null || fotoPath.isEmpty) {
    return const Icon(
      Icons.person,
      size: 40,
      color: Color(0xFFA0AEC0),
    );
  }

  // 2. KONDISI JIKA BERUPA URL INTERNET (Hasil upload dari Flask)
  if (fotoPath.startsWith('http')) {
    final String webSafeUrl = fotoPath.replaceAll('http://127.0.0.1:', 'http://localhost:');

    // Menggunakan HtmlElementView agar browser Chrome merender gambar secara native (Abaikan proteksi CanvasKit)
    // ignore: undefined_patched_instance
    return SizedBox(
      width: 75,
      height: 75,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          webSafeUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Gagal memuat gambar: $error");
            return const Icon(Icons.person, size: 40, color: Color(0xFFA0AEC0));
          },
        ),
      ),
    );
  }
  
  // 3. KONDISI JIKA BERUPA ASET LOKAL (lib/assets/...)
  else if (fotoPath.startsWith('lib/')) {
    return Image.asset(
      fotoPath,
      fit: BoxFit.cover,
      width: 75,
      height: 75,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image_rounded, size: 35, color: Colors.redAccent);
      },
    );
  } 
  
  // 4. KONDISI CADANGAN JIKA EROR / PLATFORM WEB LOKAL
  else {
    return const Icon(
      Icons.person,
      size: 40,
      color: Color(0xFFA0AEC0),
    );
  }
}