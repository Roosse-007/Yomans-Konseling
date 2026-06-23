import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yomans_konseling/screens/pembayaran/payment.dart';
import 'package:yomans_konseling/utils/currency_helper.dart';

class DetailBookingPage extends StatefulWidget {
  final Map<String, dynamic> dataDokter;

  const DetailBookingPage({Key? key, required this.dataDokter}) : super(key: key);

  @override
  State<DetailBookingPage> createState() => _DetailBookingPageState();
}

class _DetailBookingPageState extends State<DetailBookingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  PersistentBottomSheetController? _sheetController;
  bool _isSheetOpen = false; 
  bool _isTabProfilAktif = true; 
   
  String _pilihanWaktu = 'Semua';
  String _filterWaktu = "Semua";
  String _pilihanDurasi = '1 jam';
List<dynamic> _jadwalDokter = [];


@override
void initState() {
  super.initState();

  fetchJadwal();
}
Future<void> fetchJadwal() async {

  setState(() {
    _loadingJadwal = true;
  });

  try {

    final int dokterId =
        widget.dataDokter['id'];

    print("DOKTER ID = $dokterId");

    final response =
        await http.get(
      Uri.parse(
        'http://127.0.0.1:5000/api/dokter/$dokterId/jadwal',
      ),
    );

    print("STATUS CODE = ${response.statusCode}");
    print("BODY = ${response.body}");

    final data =
        jsonDecode(
      response.body,
    );

    setState(() {
      _jadwalDokter =
          data['data'] ?? [];
    });

    print("DATA JADWAL = $_jadwalDokter");

  } catch (e) {

    print("ERROR FETCH JADWAL = $e");

  }

  setState(() {
    _loadingJadwal = false;
  });
}

bool _loadingJadwal = false;
  final List<String> _listWaktu = ['Semua', 'Pagi', 'Siang', 'Sore', 'Malam'];
  final List<String> _listDurasi = ['30 Menit', '1 jam', '1.5 jam', '2 jam'];

  // 1. TAMBAHKAN VARIABEL INI UNTUK REMOTING STATE DARI LUAR
  StateSetter? _updateHargaBottomSheet;

  String _getNamaDepan(String fullName) {
    if (fullName.isEmpty) return '';
    String cleanName = fullName.replaceAll(RegExp(r',.*'), ''); 
    return cleanName.split(' ')[0];
  }

  List<String> _ambilTagsAman() {
    try {
      if (widget.dataDokter['tags'] != null) {
        return List<String>.from(widget.dataDokter['tags']);
      }
    } catch (e) {
      debugPrint("Error parsing tags: $e");
    }
    return []; 
  }

  void _bukaBottomSheetKonfirmasi() {
    if (_isSheetOpen) return; 

    setState(() {
      _isSheetOpen = true;
    });

    _sheetController = _scaffoldKey.currentState?.showBottomSheet(
      (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            // 2. SIMPAN STATE SETTER KE VARIABEL GLOBAL AGAR BISA DIAKSES DI LUAR
            _updateHargaBottomSheet = setSheetState;

final String imagePath = widget.dataDokter['image'] ?? '';
final bool isNetworkImage = imagePath.startsWith('http');
final String namaLengkap = widget.dataDokter['nama'] ?? '';
final String namaDepan = _getNamaDepan(namaLengkap);
final List<String> tags = _ambilTagsAman();

// ===============================
// DEBUG
// ===============================
print(widget.dataDokter);
print("Harga Awal   : ${widget.dataDokter['harga_awal']}");
print("Harga Diskon : ${widget.dataDokter['harga_diskon']}");
print("Diskon       : ${widget.dataDokter['diskon']}");

// ===============================
// AMBIL HARGA DARI DATABASE
// ===============================
// ===============================
// HARGA BERDASARKAN DATABASE
// ===============================

double hargaAwal =
    double.tryParse(
      widget.dataDokter['harga_awal'].toString(),
    ) ??
    0;

double hargaDiskon =
    double.tryParse(
      widget.dataDokter['harga_diskon'].toString(),
    ) ??
    0;

// ===============================
// SESUAIKAN DENGAN DURASI
// ===============================

double faktor = 1;

switch (_pilihanDurasi) {
  case '30 Menit':
    faktor = 0.5;
    break;

  case '1 jam':
    faktor = 1;
    break;

  case '1.5 jam':
    faktor = 1.5;
    break;

  case '2 jam':
    faktor = 2;
    break;
}

// Harga setelah dikalikan durasi
final int hargaAwalFinal =
    (hargaAwal * faktor).round();

final int hargaDiskonFinal =
    (hargaDiskon * faktor).round();

// Format rupiah
String hargaCoret =
    rupiah(hargaAwalFinal);

String hargaFix =
    rupiah(hargaDiskonFinal);

// Hitung persen diskon otomatis
String diskonPersen = '';

if (hargaAwalFinal > 0 &&
    hargaDiskonFinal > 0) {
  final int diskon =
      (((hargaAwalFinal - hargaDiskonFinal) /
                  hargaAwalFinal) *
              100)
          .round();

  diskonPersen = '-$diskon%';
}
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10, 
                    spreadRadius: 1
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isTabProfilAktif 
                              ? 'Bagikan Sesi Konseling' 
                              : 'Konseling dengan Psikolog $namaDepan', 
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            _sheetController?.close();
                          },
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xff2d6a4f), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: isNetworkImage
                                    ? Image.network(imagePath, height: 75, width: 75, fit: BoxFit.cover)
                                    : Image.asset(imagePath, height: 75, width: 75, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    namaLengkap, 
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: tags.map((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: const Color(0xffe8f5e9), borderRadius: BorderRadius.circular(6)),
                                        child: Text(tag, style: const TextStyle(color: Color(0xff2d6a4f), fontSize: 9, fontWeight: FontWeight.w600)),
                                      );
                                    }).toList(),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
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
                                    Text(hargaCoret, style: TextStyle(fontSize: 11, color: Colors.grey[400], decoration: TextDecoration.lineThrough)),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      color: Colors.red[50],
                                      child: Text(diskonPersen, style: const TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                                Text(hargaFix, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff006432),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('Konfirmasi Pertemuan', style: TextStyle(fontWeight: FontWeight.bold)),
                              content: Text('Buat janji temu bersama Psikolog $namaDepan pada sesi $_pilihanWaktu ($_pilihanDurasi)?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context), 
                                  child: const Text('Batal', style: TextStyle(color: Colors.grey))
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff2d6a4f)),
                                  onPressed: () async {
                                    Navigator.pop(context); 

                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(
                                        child: CircularProgressIndicator(color: Colors.green),
                                      ),
                                    );

                                    try {
                                      final rawId = widget.dataDokter['id'];
                                      final int dokterIdAnak = rawId is int 
                                          ? rawId 
                                          : (int.tryParse(rawId.toString()) ?? 1);

                                      final dynamic provider = Provider.of<dynamic>(context, listen: false); 
                                      
                                      var res = await provider.buatBooking(
                                        userId: 1, 
                                        dokterId: dokterIdAnak, 
                                        tanggal: "2026-05-25 18:00:00", 
                                        keluhan: "Sering cemas di malam hari", 
                                        duration: _pilihanDurasi, 
                                      );

                                      Navigator.pop(context); 

                                      if (res != null && res['status'] == 'success') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const PaymentMethodPage(),
                                          ),
                                        );
                                      } else {
                                        String pesanError = res != null ? res['message'] : 'Terjadi kesalahan respon';
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Gagal booking: $pesanError')),
                                        );
                                      }
                                    } catch (e) {
                                      Navigator.pop(context); 
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PaymentMethodPage(),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Ya, Konfirmasi', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
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
          },
        );
      },
      backgroundColor: Colors.transparent,
      elevation: 10,
    );

    _sheetController?.closed.then((_) {
      setState(() {
        _isSheetOpen = false;
        _updateHargaBottomSheet = null; // Reset saat ditutup
      });
    });
  }

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
    final String namaLengkap = widget.dataDokter['nama'] ?? '';
    final String namaDepan = _getNamaDepan(namaLengkap);

    return Scaffold(
      key: _scaffoldKey, 
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 25),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isTabProfilAktif ? 'Psikolog $namaDepan' : 'Jadwal dan atur temu', 
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
          children: [
            _isTabProfilAktif 
                ? _buildHeaderProfilBesar(imagePath, isNetworkImage, namaLengkap) 
                : _buildHeaderJadwalKecil(imagePath, isNetworkImage, namaLengkap), 

            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
              ),
              child: Row(
                children: [
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

            _isTabProfilAktif 
                ? _buildKontenUlasanPsikolog() 
                : _buildKontenAturJadwal(),    

            const SizedBox(height: 120), 
          ],
        ),
      ),
      
      bottomNavigationBar: !_isSheetOpen 
          ? Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06), 
                    blurRadius: 10, 
                    offset: const Offset(0, -4)
                  )
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006432),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  onPressed: _bukaBottomSheetKonfirmasi, 
                  child: const Text(
                    'Lihat Ringkasan Sesi & Harga', 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            )
          : null, 
    );
  }

  Widget _buildHeaderProfilBesar(String imagePath, bool isNetworkImage, String namaLengkap) {
    final List<String> tags = _ambilTagsAman();

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 130,
                margin: const EdgeInsets.only(bottom: 70),
                decoration: const BoxDecoration(
                  color: Color(0xffdfebd6),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              Positioned(
                top: 25,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xff2d6a4f), width: 4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: isNetworkImage
                        ? Image.network(imagePath, height: 145, width: 145, fit: BoxFit.cover)
                        : Image.asset(imagePath, height: 145, width: 145, fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            namaLengkap,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xffe8f5e9), 
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag, 
                    style: const TextStyle(color: Color(0xff2d6a4f), fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeaderJadwalKecil(String imagePath, bool isNetworkImage, String namaLengkap) {
    final List<String> tags = _ambilTagsAman();

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
                Text(namaLengkap, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: tags.map((tag) {
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
                     nilaiSekarang: _filterWaktu,

                      padaSaatDipilih: (hasil) {

                        setState(() {

                          _filterWaktu = hasil;

                        });

                        print(
                          "FILTER = $_filterWaktu",
                        );
                      },
                    );
                  },
                  child: _buildFilterDropdown(
                      Icons.access_time,
                      'Waktu:',
                      _filterWaktu,
                    ),
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
                      padaSaatDipilih: (hasil) {
                        setState(() {
                          _pilihanDurasi = hasil;
                        });
                        
                        // 3. JIKA DROPDOWN DIUBAH, MAKA PAKSA STATE DI DALAM BOTTOMSHEET IKUT DI-UPDATE
                        if (_isSheetOpen && _updateHargaBottomSheet != null) {
                          _updateHargaBottomSheet!(() {});
                        }
                      },
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
  child: Text(
    'Pilih Tanggal dan Waktu',
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
  ),
),

_loadingJadwal
    ? const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      )
    : Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Column(
          children: (_filterWaktu == "Semua"
                  ? _jadwalDokter
                  : _jadwalDokter.where((jadwal) {

                      return jadwal['sesi']
                              .toString()
                              .toLowerCase() ==
                          _filterWaktu
                              .toLowerCase();

                    }).toList())
             .map((jadwal) {

  print(
    "TAMPIL = ${jadwal['jam']} | ${jadwal['sesi']}"
  );

           return Card(
  elevation: 3,
  color: _pilihanWaktu ==
          jadwal['jam'].toString()
      ? Colors.green.shade50
      : Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius:
        BorderRadius.circular(16),
    side: BorderSide(
      color: _pilihanWaktu ==
              jadwal['jam']
                  .toString()
          ? const Color(0xff2d6a4f)
          : Colors.grey.shade300,
      width: 1.5,
    ),
  ),
  child: ListTile(
    contentPadding:
        const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    leading: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xff2d6a4f)
            .withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.access_time,
        color: Color(0xff2d6a4f),
      ),
    ),
    title: Text(
      jadwal['tanggal'].toString(),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(
        top: 6,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            "Jam : ${jadwal['jam']}",
          ),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.green
                  .withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Text(
              jadwal['sesi']
                  .toString(),
              style: const TextStyle(
                color: Color(0xff2d6a4f),
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
    trailing: _pilihanWaktu ==
            jadwal['jam']
                .toString()
        ? Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration:
                BoxDecoration(
              color: const Color(
                  0xff2d6a4f),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: const Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  "Dipilih",
                  style: TextStyle(
                    color:
                        Colors.white,
                  ),
                ),
              ],
            ),
          )
        : ElevatedButton(
            onPressed: () {
              setState(() {
                _pilihanWaktu =
                    jadwal['jam']
                        .toString();
              });

              print(
                "JAM DIPILIH = $_pilihanWaktu",
              );
            },
            style: ElevatedButton
                .styleFrom(
              backgroundColor:
                  const Color(
                0xff2d6a4f,
              ),
            ),
            child: const Text(
              "Pilih",
              style: TextStyle(
                color:
                    Colors.white,
              ),
            ),
          ),
  ),
);
          }).toList(),
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
}