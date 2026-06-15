import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yomans_konseling/providers/dokter_provider.dart';
import 'package:yomans_konseling/screens/admin/tambahDataPsikolog.dart';

class DaftarPsikologAdminPage extends StatefulWidget {
  const DaftarPsikologAdminPage({Key? key}) : super(key: key);

  @override
  State<DaftarPsikologAdminPage> createState() =>
      _DaftarPsikologAdminPageState();
}

class _DaftarPsikologAdminPageState
    extends State<DaftarPsikologAdminPage> {
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
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_note_rounded,
                              color: Colors.blue,
                              size: 28,
                            ),

                            onPressed: () {
                              print(
                                "Edit data: ${dokter['nama']}",
                              );
                            },
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons
                                  .delete_outline_rounded,
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
                      ),
                    ],
                  ),
                );
              },
            ),

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

  // ================= BUILD IMAGE =================
  Widget _buildImage(Map<String, dynamic> dokter) {
  print("IMAGE URL: ${dokter['image_url']}");

  if (dokter['image_url'] != null &&
      dokter['image_url'].toString().isNotEmpty) {
    return Image.network(
      dokter['image_url'].toString(),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        print("ERROR GAMBAR: $error");

        return const Center(
          child: Icon(
            Icons.person,
            size: 40,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  return const Center(
    child: Icon(
      Icons.person,
      size: 40,
      color: Colors.grey,
    ),
  );
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