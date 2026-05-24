import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yomans_konseling/screens/halaman_akun/profile_screen.dart';
import 'package:yomans_konseling/screens/history_boking/history_boking.dart';
import 'package:yomans_konseling/screens/home/home.dart';
import 'detail_artikel.dart';

class Informasi extends StatefulWidget {
  @override
  State<Informasi> createState() => _InformasiState();
}

class _InformasiState extends State<Informasi> {
  List artikel = [];
  bool loading = true;
  
  // Inisialisasi indeks aktif ke 1 karena halaman ini adalah tab Informasi
  int _currentIndex = 1; 

  @override
  void initState() {
    super.initState();
    getArtikel();
  }

  Future getArtikel() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://127.0.0.1:5000/api/artikel",
        ),
      );

      final data = jsonDecode(response.body);

      setState(() {
        artikel = data['data'];
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  Color getColor(String kategori) {
    if (kategori == "Artikel Mental") {
      return const Color.fromARGB(255, 3, 92, 24);
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // ================= TOMBOL BACK IOS (DITAMBAHKAN) =================
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 22, // Ukuran disesuaikan agar proporsional di AppBar
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Informasi Tentang Kesehatan Mental",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : artikel.isEmpty
              ? const Center(
                  child: Text("Artikel tidak tersedia"),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: artikel.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final item = artikel[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailArtikel(
                              data: item,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: getColor(
                                  item['kategori'],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                item['kategori'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              item['judul'],
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: Text(
                                item['isi'],
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  height: 1.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  "Baca Artikel",
                                  style: TextStyle(
                                    color: getColor(
                                      item['kategori'],
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: getColor(
                                    item['kategori'],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E6A3F),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == _currentIndex) return; 

          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (_) => HomePage()), 
            );
          } else if (index == 1) {
            // Sudah berada di halaman Informasi
          } else if (index == 2) {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HistoryBookingPage())); 
          } else if (index == 3) {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen())); 
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: "Informasi"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}