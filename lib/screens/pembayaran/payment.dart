import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const PaymentMethodPage(),
    );
  }
}

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({Key? key}) : super(key: key);

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  // Variabel untuk menyimpan metode pembayaran yang dipilih
  String? _selectedMethod;

  // Warna tema sesuai gambar
  final Color primaryGreen = const Color(0xFF2E6B33);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Aksi tombol kembali
          },
        ),
        title: const Text(
          'Pilih Metode Pembayaran',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. WATERMARK BACKGROUND (Logo di tengah latar belakang)
          // Catatan: Ganti 'assets/logo_yomans.png' dengan path file logomu di pubspec.yaml
          Center(
            child: Opacity(
              opacity: 0.15, // Mengatur transparansi watermark agar tipis
              child: Image.asset(
                'assets/logo_yomans.png', 
                width: MediaQuery.of(context).size.width * 0.9,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback jika gambar asset belum dimasukkan
                  return const Text(
                    'YOMANS KONSELING\n(Watermark Background)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. KONTEN UTAMA (Scrollable)
          Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    // --- KATEGORI: TRANSFER BANK ---
                    _buildCategoryHeader('Transfer Bank', Icons.account_balance),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      id: 'bca',
                      logoPath: 'assets/logo_bca.png',
                      labelText: 'BCA', 
                    ),
                    const Divider(height: 1, thickness: 1),
                    _buildPaymentOption(
                      id: 'mandiri',
                      logoPath: 'assets/logo_mandiri.png',
                      labelText: 'mandiri',
                    ),
                    const Divider(height: 1, thickness: 1),
                    _buildPaymentOption(
                      id: 'bri',
                      logoPath: 'assets/logo_bri.png',
                      labelText: 'BRI',
                    ),
                    const Divider(height: 1, thickness: 1),

                    const SizedBox(height: 32),

                    // --- KATEGORI: DOMPET DIGITAL ---
                    _buildCategoryHeader('Dompet Digital', Icons.account_balance_wallet),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      id: 'ovo',
                      logoPath: 'assets/logo_ovo.png',
                      labelText: 'OVO',
                    ),
                    const Divider(height: 1, thickness: 1),
                    _buildPaymentOption(
                      id: 'gopay',
                      logoPath: 'assets/logo_gopay.png',
                      labelText: 'gopay',
                    ),
                    const Divider(height: 1, thickness: 1),
                    _buildPaymentOption(
                      id: 'dana',
                      logoPath: 'assets/logo_dana.png',
                      labelText: 'DANA',
                    ),
                    const Divider(height: 1, thickness: 1),
                  ],
                ),
              ),

              // 3. TOMBOL BAYAR (Tetap di posisi bawah)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _selectedMethod == null 
                        ? null 
                        : () {
                            // Aksi ketika tombol bayar ditekan
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      disabledBackgroundColor: primaryGreen.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24), // Sudut melengkung oval
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Bayar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk membuat Header Kategori (Transfer Bank / Dompet Digital)
  Widget _buildCategoryHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, color: primaryGreen, size: 20),
        ],
      ),
    );
  }

  // Widget untuk membuat Baris Opsi Pembayaran lengkap dengan Radio Button
  Widget _buildPaymentOption({
    required String id, 
    required String logoPath, 
    required String labelText
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = id;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sisi Kiri: Logo Bank / E-Wallet
            Container(
              height: 32,
              width: 100,
              alignment: Alignment.centerLeft,
              child: Image.asset(
                logoPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback teks jika file aset gambar belum tersedia
                  return Text(
                    labelText,
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                    ),
                  );
                },
              ),
            ),
            // Sisi Kanan: Radio Button Bulat
            Theme(
              data: ThemeData(
                unselectedWidgetColor: Colors.black54,
              ),
              child: Radio<String>(
                value: id,
                groupValue: _selectedMethod,
                activeColor: primaryGreen,
                onChanged: (String? value) {
                  setState(() {
                    _selectedMethod = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}