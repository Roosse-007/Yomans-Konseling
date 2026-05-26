import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentPage extends StatelessWidget {
  final String metode;

  const PaymentPage({Key? key, required this.metode,}) : super(key: key);

  // Fungsi untuk mendapatkan path logo berdasarkan ID metode
  // Update fungsi ini di dalam class PaymentPage agar bisa membaca semua jenis file
  String _getLogoPath() {
    // Daftar mapping jika ada perbedaan ekstensi file
    Map<String, String> logoMap = {
      'bca': 'lib/assets/logo-bca.jpg',
      'mandiri': 'lib/assets/logo-mandiri.png',
      'bri': 'lib/assets/logo-bri.jpg',
      'ovo': 'lib/assets/logo-ovo.jpg',
      'gopay': 'lib/assets/logo-gopay.png',
      'dana': 'lib/assets/logo-dana.png',
    };
    
    // Mengambil path berdasarkan id metode, default ke teks jika tidak ada
    return logoMap[metode] ?? '';
  }


  @override
  Widget build(BuildContext context) {
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: _getLogoPath().isNotEmpty 
      ? Image.asset(_getLogoPath(), height: 50) 
      : Text(metode.toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
  );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E6B33),
        title: const Text("Ringkasan Pesanan", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Logo Bank
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset(_getLogoPath(), height: 50, errorBuilder: (c, o, s) => Text(metode.toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            ),

            // Card Detail
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Virtual Account Number", style: TextStyle(color: Colors.grey)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("7000701501999576408", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Color(0xFF2E6B33)),
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: "7000701501999576408"));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nomor disalin!")));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text("Nama Akun", style: TextStyle(color: Colors.grey)),
                    const Text("Yomansid", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),
                    const Text("Amount to Pay", style: TextStyle(color: Colors.grey)),
                    const Text("IDR 249.000", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  ],
                ),
              ),
            ),

            // Box Peringatan dengan Inner Layer
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield, color: Colors.green.shade900),
                      const SizedBox(width: 8),
                      Text("Lindungi Diri Anda dari Penipuan", style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Inner Layer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Rekening Yomans Konseling Hanya Atas Nama Yomansid", style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold)),
                        const Divider(color: Colors.green, thickness: 1),
                        const Text("Waspada penipuan atas nama Yomans."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}