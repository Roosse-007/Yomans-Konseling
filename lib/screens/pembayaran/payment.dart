import 'package:flutter/material.dart';
import 'package:yomans_konseling/screens/pembayaran/payment_va.dart';

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
  String? _selectedMethod;
  final Color primaryGreen = const Color(0xFF2E6B33);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF2E6B33),
        title: const Text("Pilih Metode Pembayaran", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'lib/assets/logo_yomans.png',
                width: MediaQuery.of(context).size.width * 0.9,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
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
          Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildCategoryHeader('Transfer Bank', Icons.account_balance),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      id: 'bca',
                      logoPath: 'lib/assets/logo-bca.jpg',
                      labelText: 'BCA',
                    ),
                    const Divider(height: 1, thickness: 1),
                    _buildPaymentOption(
                      id: 'mandiri',
                      logoPath: 'lib/assets/logo-mandiri.png',
                      labelText: 'mandiri',
                    ),
                    const Divider(height: 1, thickness: 1),
                    _buildPaymentOption(
                      id: 'bri',
                      logoPath: 'lib/assets/logo-bri.jpg',
                      labelText: 'BRI',
                    ),
                    const Divider(height: 1, thickness: 1),
                    const SizedBox(height: 32),
                    _buildCategoryHeader('Dompet Digital', Icons.account_balance_wallet),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      id: 'ovo',
                      logoPath: 'lib/assets/logo-ovo.jpg',
                      labelText: 'OVO',
                    ),
                    const Divider(height: 1, thickness: 1),
                    _buildPaymentOption(
                      id: 'gopay',
                      logoPath: 'lib/assets/logo-gopay.png',
                      labelText: 'gopay',
                    ),
                    const Divider(height: 1, thickness: 1),
                    _buildPaymentOption(
                      id: 'dana',
                      logoPath: 'lib/assets/logo-dana.png',
                      labelText: 'DANA',
                    ),
                    const Divider(height: 1, thickness: 1),
                  ],
                ),
              ),
              Padding(
  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
  child: SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      // Logika tombol: null jika belum ada metode yang dipilih, 
      // melakukan navigasi jika sudah ada metode yang dipilih.
      onPressed: _selectedMethod == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentPage(metode: _selectedMethod!),
                ),
              );
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E6B33),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Bayar',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildPaymentOption({
    required String id,
    required String logoPath,
    required String labelText,
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
            Container(
              height: 32,
              width: 100,
              alignment: Alignment.centerLeft,
              child: Image.asset(
                logoPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    labelText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  );
                },
              ),
            ),
            Theme(
              data: ThemeData(unselectedWidgetColor: Colors.black54),
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
