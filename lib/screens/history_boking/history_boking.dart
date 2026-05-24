import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// Pastikan path import ini sesuai dengan struktur folder di proyek Anda
import '../../providers/auth_provider.dart'; 

class HistoryBookingPage extends StatefulWidget {
  const HistoryBookingPage({super.key});

  @override
  State<HistoryBookingPage> createState() => _HistoryBookingPageState();
}

class _HistoryBookingPageState extends State<HistoryBookingPage> {
  List<dynamic> bookingHistory = [];
  bool isLoading = true;

  // Ganti IP ini sesuai dengan environtment Anda (10.0.2.2 adalah localhost untuk Emulator Android)
  final String baseUrl = 'http://localhost:5000';

  @override
  void initState() {
    super.initState();
    // Mengambil data setelah build pertama selesai agar context siap digunakan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBookingHistory();
    });
  }

  // 1. FUNGSI MENGAMBIL DATA DARI SQL (BERDASARKAN USER YANG LOGIN)
  Future<void> fetchBookingHistory() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String clientName = authProvider.nama; 

      if (clientName.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final url = Uri.parse('$baseUrl/history?client_name=$clientName'); 
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          bookingHistory = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat riwayat booking');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error Fetching Data: $e");
    }
  }

  // 2. FUNGSI MENGIRIM ULASAN KE SQL
  Future<void> submitReview(int index, int rating, String comment) async {
    final url = Uri.parse('$baseUrl/submit-review');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "booking_id": bookingHistory[index]["id"], // Mengirim ID Unik dari Tabel SQL
          "rating": rating,
          "comment": comment,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Mengubah state lokal secara instan agar UI terupdate tanpa reload halaman
          bookingHistory[index]["reviewed"] = true;
          bookingHistory[index]["rating"] = rating;
          bookingHistory[index]["comment"] = comment;
          bookingHistory[index]["status"] = "Sesi Berakhir"; 
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ulasan berhasil dikirim")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error Submitting Review: $e");
    }
  }

  // 3. FUNGSI PEMBATALAN BOOKING KE SQL
  Future<void> submitCancelBooking(int index) async {
    final url = Uri.parse('$baseUrl/cancel-booking');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "booking_id": bookingHistory[index]["id"], // Mengirim ID Unik dari Tabel SQL
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Mengubah status di UI menjadi Dibatalkan
          bookingHistory[index]["status"] = "Dibatalkan";
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Booking berhasil dibatalkan")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error Cancelling Booking: $e");
    }
  }

  // Manajemen Warna Label Berdasarkan Status Transaksi di Database
  Color statusColor(String status) {
    switch (status) {
      case "Sesi Berakhir":
        return const Color(0xFF1F5F33); // Hijau Tua
      case "Menunggu Jadwal":
        return Colors.orange;
      case "Sedang Berlangsung":
        return Colors.blue;
      case "Dibatalkan":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Dialog Popup untuk Mengisi Rating dan Ulasan
  void showReviewDialog(int index) {
    int selectedStar = 5;
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Beri Ulasan Dokter",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F5F33)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bookingHistory[index]["doctor_name"] ?? "Nama Dokter",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (starIndex) {
                        return IconButton(
                          onPressed: () {
                            setDialogState(() {
                              selectedStar = starIndex + 1;
                            });
                          },
                          icon: Icon(
                            Icons.star,
                            size: 32,
                            color: starIndex < selectedStar ? Colors.amber : Colors.grey[300],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Tulis ulasan Anda di sini...",
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFF1F5F33)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F5F33),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    submitReview(index, selectedStar, commentController.text);
                  },
                  child: const Text("Kirim", style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }

  // Dialog Konfirmasi Pembatalan
  void cancelBooking(int index) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Batalkan Booking", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Apakah kamu yakin ingin membatalkan booking ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tidak", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                submitCancelBooking(index);
              },
              child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 25,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "History Booking",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: 0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.withOpacity(0.15),
            height: 1.0,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F5F33))))
          : bookingHistory.isEmpty
              ? const Center(child: Text("Belum ada riwayat booking."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookingHistory.length,
                  itemBuilder: (context, index) {
                    final item = bookingHistory[index];

                    // Validasi status review dari database SQL (Bisa berupa int 1/0 atau bool)
                    final bool isReviewed = item["reviewed"] == true || item["reviewed"] == 1;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: item["doctor_image"] != null && item["doctor_image"].startsWith('http')
                                    ? NetworkImage(item["doctor_image"])
                                    : AssetImage(item["doctor_image"] ?? "lib/assets/ira1.png") as ImageProvider,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["doctor_name"] ?? "Nama Dokter",
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item["doctor_category"] ?? "Kategori",
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    Text("Tanggal: ${item["booking_date"] ?? ""}"),
                                    Text("Jam: ${item["booking_time"] ?? ""}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: statusColor(item["status"] ?? "").withOpacity(0.15),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item["status"] ?? "",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: statusColor(item["status"] ?? ""),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        // JIKA SESI BERAKHIR & BELUM DIULAS -> MUNCUL TOMBOL ULASAN
                                        if (item["status"] == "Sesi Berakhir" && !isReviewed)
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1F5F33),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            ),
                                            onPressed: () => showReviewDialog(index),
                                            child: const Text("Beri Ulasan", style: TextStyle(color: Colors.white, fontSize: 12)),
                                          ),
                                        // JIKA MASIH MENUNGGU JADWAL -> MUNCUL TOMBOL BATALKAN
                                        if (item["status"] == "Menunggu Jadwal")
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            ),
                                            onPressed: () => cancelBooking(index),
                                            child: const Text("Batalkan", style: TextStyle(color: Colors.white, fontSize: 12)),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                // JIKA SUDAH BERHASIL DIULAS -> TAMPILKAN BINTANG DAN KOMENTAR
                                if (isReviewed) ...[
                                  const Divider(),
                                  Row(
                                    children: List.generate(
                                      item["rating"] ?? 0,
                                      (starIndex) => const Icon(Icons.star, color: Colors.amber, size: 20),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      item["comment"] ?? "Tidak ada komentar.",
                                      style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}