import 'package:flutter/material.dart';
import 'package:yomans_konseling/screens/pembayaran/payment.dart';

class DetailBookingPage extends StatefulWidget {
  final Map<String, dynamic> dataDokter;

  const DetailBookingPage({Key? key, required this.dataDokter}) : super(key: key);

  @override
  State<DetailBookingPage> createState() => _DetailBookingPageState();
}

class _DetailBookingPageState extends State<DetailBookingPage> {
  bool _showConfirmation = true; 

  // Mengatur status aktif antar tab (true = Profil Psikolog, false = Jadwal)
  bool _isTabProfilAktif = true; 

  // Menyimpan data filter waktu dan durasi secara real-time
  String _pilihanWaktu = 'Semua';
  String _pilihanDurasi = '1 jam';

  final List<String> _listWaktu = ['Semua', 'Pagi', 'Siang', 'Sore', 'Malam'];
  final List<String> _listDurasi = ['30 Menit', '1 jam', '1.5 jam', '2 jam'];

  // Fungsi bottom sheet untuk memilih item filter waktu/durasi
  void _tampilkanPilihanFilter({
    required String judul,
    required List<String> opsiData,
    required String nilaiSekarang,
    required Function(String) padaSaatDipilih,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(judul, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              ...opsiData.map((opsi) {
                final bool isSelected = opsi == nilaiSekarang;
                return ListTile(
                  title: Text(
                    opsi,
                    style: TextStyle(
                      color: isSelected ? const Color(0xff2d6a4f) : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check, color: Color(0xff2d6a4f)) : null,
                  onTap: () {
                    padaSaatDipilih(opsi);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String imagePath = widget.dataDokter['image'] ?? '';
    final bool isNetworkImage = imagePath.startsWith('http');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isTabProfilAktif ? (widget.dataDokter['name']?.split(' ')[0] ?? 'Profil') : 'Jadwal dan atur temu',
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tautan profil psikolog berhasil disalin!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TAMPILKAN HEADER BERDASARKAN TAB YANG SEDANG AKTIF
            _isTabProfilAktif 
                ? _buildHeaderProfilBesar(imagePath, isNetworkImage) 
                : _buildHeaderJadwalKecil(imagePath, isNetworkImage), 

            // NAVIGASI INTERAKTIF TAB MENU
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
              ),
              child: Row(
                children: [
                  // Tab Profil Psikolog
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isTabProfilAktif = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _isTabProfilAktif ? const Color(0xff2d6a4f) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Profil Psikolog',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isTabProfilAktif ? const Color(0xff2d6a4f) : Colors.grey,
                            fontWeight: _isTabProfilAktif ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Tab Jadwal
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isTabProfilAktif = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: !_isTabProfilAktif ? const Color(0xff2d6a4f) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Jadwal',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isTabProfilAktif ? const Color(0xff2d6a4f) : Colors.grey,
                            fontWeight: !_isTabProfilAktif ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // KONTEN BAWAH BERDASARKAN SELEKSI TAB
            _isTabProfilAktif 
                ? _buildKontenUlasanPsikolog() 
                : _buildKontenAturJadwal(),    

            // Ganjal area kosong di bawah agar layout konten tidak bertubrukan dengan Bottom Sheet
            const SizedBox(height: 380), 
          ],
        ),
      ),
      bottomSheet: _showConfirmation ? _buildBottomSheetKonfirmasi(context) : null,
    );
  }

  // ==================== DAFTAR WIDGET PEMBANTU ====================

  // Header Tampilan Tab Profil 
  Widget _buildHeaderProfilBesar(String imagePath, bool isNetworkImage) {
    return Container(
      width: double.infinity,
      color: const Color(0xfff4f9f4),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff2d6a4f), width: 3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: isNetworkImage
                  ? Image.network(imagePath, height: 160, width: 160, fit: BoxFit.cover)
                  : Image.asset(imagePath, height: 160, width: 160, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.dataDokter['name'] ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: ((widget.dataDokter['tags'] ?? []) as List<String>).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xffe8f5e9), borderRadius: BorderRadius.circular(8)),
                child: Text(tag, style: const TextStyle(color: Color(0xff2d6a4f), fontSize: 10, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  // Header Tampilan Tab Jadwal
  Widget _buildHeaderJadwalKecil(String imagePath, bool isNetworkImage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: const Color(0xffe8f5e9).withOpacity(0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff2d6a4f), width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isNetworkImage
                  ? Image.network(imagePath, height: 100, width: 100, fit: BoxFit.cover)
                  : Image.asset(imagePath, height: 100, width: 100, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(widget.dataDokter['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: ((widget.dataDokter['tags'] ?? []) as List<String>).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(6)),
                      child: Text(tag, style: const TextStyle(color: Color(0xff2d6a4f), fontSize: 9, fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Isi Komponen Profil & Komentar Reviewer (Ulasan)
  Widget _buildKontenUlasanPsikolog() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ulasan Psikolog', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('Lihat Semua', style: TextStyle(color: Colors.green, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 8),
          _buildItemUlasanCard('Udin Jabrix', '07/03/2026', 'Ngobrol nyaman banget, serasa cerita ke temen tapi tetap dapat solusi yang profesional.'),
          const Divider(height: 24),
          _buildItemUlasanCard('Jamal Kopling', '08/03/2026', 'Ngobrol nyaman banget, serasa cerita ke temen tapi tetap dapat solusi yang profesional.'),
        ],
      ),
    );
  }

  Widget _buildItemUlasanCard(String namaUser, String tanggal, String isiKomentar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xff2d6a4f),
              radius: 18,
              child: Text(namaUser[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(namaUser, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      Icon(Icons.star, color: Colors.amber, size: 14),
                    ],
                  )
                ],
              ),
            ),
            Text(tanggal, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 10),
        Text(isiKomentar, style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4)),
      ],
    );
  }

  // Isi Komponen Pemilihan Tanggal & Dropdown Atur Jadwal
  Widget _buildKontenAturJadwal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _tampilkanPilihanFilter(
                      judul: 'Pilih Waktu Konseling',
                      opsiData: _listWaktu,
                      nilaiSekarang: _pilihanWaktu,
                      padaSaatDipilih: (hasil) => setState(() => _pilihanWaktu = hasil),
                    );
                  },
                  child: _buildFilterDropdown(Icons.access_time, 'Waktu:', _pilihanWaktu),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _tampilkanPilihanFilter(
                      judul: 'Pilih Durasi Konseling',
                      opsiData: _listDurasi,
                      nilaiSekarang: _pilihanDurasi,
                      padaSaatDipilih: (hasil) => setState(() => _pilihanDurasi = hasil),
                    );
                  },
                  child: _buildFilterDropdown(Icons.hourglass_empty, 'Durasi:', _pilihanDurasi),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Pilih Tanggal dan Waktu Online', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.black.withOpacity(0.04),
          child: const Center(
            child: Text(
              'Area Input Tanggal Kalender Kelompok', 
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  // Widget Bottom Sheet Ringkasan Data di Layar Terbawah
  Widget _buildBottomSheetKonfirmasi(BuildContext context) {
    final String imagePath = widget.dataDokter['image'] ?? '';
    final bool isNetworkImage = imagePath.startsWith('http');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, spreadRadius: 1)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isTabProfilAktif 
                    ? 'Bagikan Sesi Konseling' 
                    : 'Konseling dengan ${widget.dataDokter['name']?.split(' ')[0]}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() => _showConfirmation = false),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isNetworkImage
                          ? Image.network(imagePath, height: 60, width: 60, fit: BoxFit.cover)
                          : Image.asset(imagePath, height: 60, width: 60, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.dataDokter['name'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            children: ((widget.dataDokter['tags'] ?? []) as List<String>).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xffe8f5e9), borderRadius: BorderRadius.circular(4)),
                                child: Text(tag, style: const TextStyle(color: Color(0xff2d6a4f), fontSize: 8)),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified_user, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
                          children: [
                            TextSpan(text: 'Tenang, pengalaman konselingmu dijamin aman dengan '),
                            TextSpan(text: 'Jaminan Efektivitas Konseling', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(width: 26),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Rp349.000', style: TextStyle(fontSize: 11, color: Colors.grey[400], decoration: TextDecoration.lineThrough)),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              color: Colors.red[50],
                              child: const Text('-29%', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        const Text('Rp249.000', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('Konfirmasi Pertemuan', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Text('Buat janji temu bersama ${widget.dataDokter['name']?.split(' ')[0]} pada sesi $_pilihanWaktu ($_pilihanDurasi)?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                        ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff2d6a4f)),
                        onPressed: () {
                          Navigator.pop(context); // Tutup dialog konfirmasi
                          
                          // NAVIGASI LANGSUNG KE HALAMAN PAYMENT PUNYAMU
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentMethodPage(), // Sudah disesuaikan ke class baru kamu
                            ),
                          );
                        },
                        child: const Text('Ya, Konfirmasi', style: TextStyle(color: Colors.white)),
                      ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006432),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  elevation: 0,
                ),
                child: Text(
                  _isTabProfilAktif ? 'Konseling Dengan Psikolog' : 'Pilih Jadwal', 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

