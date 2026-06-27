import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:yomans_konseling/screens/pembayaran/payment_detail.dart';

// ==========================================
// 1. HALAMAN PILIH METODE PEMBAYARAN
// ==========================================
class PaymentPage extends StatefulWidget {
  final int bookingId;
  final int jadwalId;

  const PaymentPage({
    super.key,
    required this.bookingId,
    required this.jadwalId,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _selectedMethod;


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
          // Background Watermark Logo
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
          
          // List Pilihan Metode Pembayaran
          Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildCategoryHeader('Transfer Bank', Icons.account_balance),
                    const SizedBox(height: 8),
                    _buildPaymentOption(id: 'BCA', logoPath: 'lib/assets/logo-bca.jpg', labelText: 'BCA'),
                    const Divider(height: 1, thickness: 1),
                    _buildPaymentOption(id: 'Mandiri', logoPath: 'lib/assets/logo-mandiri.png', labelText: 'Mandiri'),
                    const Divider(height: 1, thickness: 1),
                    _buildPaymentOption(id: 'BRI', logoPath: 'lib/assets/logo-bri.jpg', labelText: 'BRI'),
                    const Divider(height: 1, thickness: 1),
                    const SizedBox(height: 32),
                    _buildCategoryHeader('Dompet Digital', Icons.account_balance_wallet),
                    const SizedBox(height: 8),
                    _buildPaymentOption(id: 'OVO', logoPath: 'lib/assets/logo-ovo.jpg', labelText: 'OVO'),
                    const Divider(height: 1, thickness: 1),
                    _buildPaymentOption(id: 'GoPay', logoPath: 'lib/assets/logo-gopay.png', labelText: 'GoPay'),
                    const Divider(height: 1, thickness: 1),
                    _buildPaymentOption(id: 'DANA', logoPath: 'lib/assets/logo-dana.png', labelText: 'DANA'),
                    const Divider(height: 1, thickness: 1),
                  ],
                ),
              ),
              
              // Tombol Utama "Lanjutkan"
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E6B33),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _selectedMethod == null
                        ? null
      : () async {
          try {
            final response = await http.post(
              Uri.parse("http://127.0.0.1:5000/api/create_payment"),
              headers: {
                "Content-Type": "application/json",
              },
              body: jsonEncode({
                "booking_id": widget.bookingId,
                "metode": _selectedMethod!.toLowerCase(),
              }),
            );

            final result = jsonDecode(response.body);

            if (!mounted) return;

            if (result["status"] == "success") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                  builder: (_) => PaymentDetailPage(
                  bookingId: widget.bookingId,
                  jadwalId: widget.jadwalId,
                )
                              ),
                            );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result["message"]),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Terjadi kesalahan: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
                          },
                    child: const Text(
    "Lanjutkan Pembayaran",
    style: TextStyle(
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

  Widget _buildCategoryHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E6B33)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({required String id, required String logoPath, required String labelText}) {
    return RadioListTile<String>(
      activeColor: const Color(0xFF2E6B33),
      value: id,
      groupValue: _selectedMethod,
      onChanged: (value) {
        setState(() {
          _selectedMethod = value;
        });
      },
      title: Row(
        children: [
          Image.asset(
            logoPath,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.payment, size: 30, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Text(labelText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ==========================================
// 2. HALAMAN DETAIL INSTRUKSI & KONFIRMASI (PRO)
// ==========================================
