import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yomans_konseling/models/ulasan_model.dart';
import 'package:yomans_konseling/screens/pembayaran/payment.dart';
import 'package:yomans_konseling/utils/currency_helper.dart';
import 'package:yomans_konseling/providers/ulasan_provider.dart';
import 'package:yomans_konseling/providers/favorit_provider.dart';
import 'package:yomans_konseling/providers/auth_provider.dart';

List<dynamic> _jadwalDokter = [];

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
  String _pilihanDurasi = '1 jam';

late UlasanProvider ulasanProvider;


@override
void initState() {
  super.initState();

  ulasanProvider = Provider.of<UlasanProvider>(
    context,
    listen: false,
  );


  fetchJadwal();
}
Future<void> fetchJadwal() async {
  setState(() {
    _loadingJadwal = true;
  });

  try {
    final int dokterId = widget.dataDokter["id"];

    print("DOKTER ID = $dokterId");

    final response = await http.get(
      Uri.parse(
        "http://127.0.0.1:5000/api/dokter/$dokterId/jadwal",
      ),
    );

    print("STATUS CODE = ${response.statusCode}");
    print("BODY = ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        _jadwalDokter = data["data"] ?? [];
      });

      // Refresh ulasan juga
      await ulasanProvider.refresh(dokterId);
    }

    print("DATA JADWAL = $_jadwalDokter");
  } catch (e) {
    print("ERROR FETCH JADWAL = $e");
  }

  if (mounted) {
    setState(() {
      _loadingJadwal = false;
    });
  }
}

Future<void> updateStatusJadwal(
  int id,
  String status,
) async {

  final response = await http.put(
    Uri.parse(
      "http://127.0.0.1:5000/api/jadwal/$id/status",
    ),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "status": status,
    }),
  );

  print("UPDATE STATUS CODE = ${response.statusCode}");
  print("UPDATE BODY = ${response.body}");

  if (response.statusCode != 200) {
    throw Exception("Gagal update status jadwal");
  }
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
int diskon = 0;
String diskonPersen = '';

if (hargaAwalFinal > 0 &&
    hargaDiskonFinal > 0) {

  diskon = (((hargaAwalFinal - hargaDiskonFinal) /
          hargaAwalFinal) *
      100)
      .round();

  diskonPersen = '-$diskon%';
}

final bool adaDiskon = diskon > 0;

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
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    const SizedBox(width: 26),

    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        if (adaDiskon)
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
    icon: const Icon(
      Icons.arrow_back_ios_new_rounded,
      color: Colors.black,
      size: 25,
    ),
    onPressed: () {
      Navigator.pop(context);
    },
        ),
        title: Text(
    namaLengkap.split(' ').first,
    style: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
        ),
        centerTitle: true,
        actions: [

    Consumer<FavoritProvider>(
      builder: (
        context,
        favoritProvider,
        child,
      ) {

        final auth =
            Provider.of<AuthProvider>(
          context,
          listen: false,
        );

        final bool isFavorit =
            favoritProvider
                .favoritDokter
                .contains(
                  widget.dataDokter['id'],
                );

        return IconButton(

          icon: Icon(

            isFavorit
                ? Icons.favorite
                : Icons.favorite_border,

            color: Colors.red,
            size: 28,
          ),

          onPressed: () async {

            if (isFavorit) {

              await favoritProvider
                  .hapusFavorit(

                userId:
                    auth.userId,

                dokterId:
                    widget.dataDokter['id'],
              );

            } else {

              await favoritProvider
                  .tambahFavorit(

                userId:
                    auth.userId,

                dokterId:
                    widget.dataDokter['id'],
              );
            }
          },
              );
            },
          ),

    const SizedBox(width: 10),
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

  Widget _buildHeaderProfilBesar(
    String imagePath,
    bool isNetworkImage,
    String namaLengkap,
) {
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
                  border: Border.all(
                    color: const Color(0xff2d6a4f),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: isNetworkImage
                      ? Image.network(
                          imagePath,
                          height: 145,
                          width: 145,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          imagePath,
                          height: 145,
                          width: 145,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        Text(
          namaLengkap,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffe8f5e9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Color(0xff2d6a4f),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        Consumer<UlasanProvider>(
          builder: (context, provider, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 18,
                ),

                const SizedBox(width: 5),

                Text(
                  provider.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 5),

                Text(
                  "(${provider.totalUlasan} ulasan)",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 18),
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
  return Consumer<UlasanProvider>(
    builder: (context, provider, child) {
      if (provider.loading) {
        return const Padding(
          padding: EdgeInsets.all(30),
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xff2d6a4f),
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            const Text(
              "Ulasan Pengguna",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "${provider.totalUlasan} ulasan • Rating ${provider.rating.toStringAsFixed(1)}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 18),

            if (provider.listUlasan.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  children: [

                    Icon(
                      Icons.rate_review_outlined,
                      size: 45,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 12),

                    Text(
                      "Belum ada ulasan",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      "Jadilah pengguna pertama yang memberikan ulasan.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: List.generate(
                  provider.listUlasan.length > 3
                      ? 3
                      : provider.listUlasan.length,
                  (index) {
                    return Column(
                      children: [

                        _buildItemUlasanCard(
                          provider.listUlasan[index],
                        ),

                        const SizedBox(height: 12),

                      ],
                    );
                  },
                ),
              ),

            if (provider.listUlasan.length > 3)
              Center(
                child: TextButton.icon(
                  onPressed: () {

                    // TODO:
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => SemuaUlasanScreen(
                    //       dokterId: widget.dataDokter["id"],
                    //     ),
                    //   ),
                    // );

                  },
                  icon: const Icon(
                    Icons.visibility,
                    color: Color(0xff2d6a4f),
                  ),
                  label: const Text(
                    "Lihat Semua Ulasan",
                    style: TextStyle(
                      color: Color(0xff2d6a4f),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      );
    },
  );
}

  Widget _buildItemUlasanCard(UlasanModel ulasan) {
  return Container(
    margin: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.grey.shade300,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xff2d6a4f),
              child: Text(
                ulasan.nama.isNotEmpty
                    ? ulasan.nama[0].toUpperCase()
                    : "?",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    ulasan.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: index < ulasan.rating
                            ? Colors.amber
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text(
              ulasan.createdAt,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Text(
          ulasan.komentar,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    ),
  );
}
Widget _buildKontenAturJadwal() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [

            Expanded(
              child: GestureDetector(
                onTap: () {
                  _tampilkanPilihanFilter(
                    judul: 'Pilih Waktu Konseling',
                    opsiData: _listWaktu,
                    nilaiSekarang: _pilihanWaktu,
                    padaSaatDipilih: (hasil) {
                      setState(() {
                        _pilihanWaktu = hasil;
                      });
                    },
                  );
                },
                child: _buildFilterDropdown(
                  Icons.access_time,
                  'Waktu:',
                  _pilihanWaktu,
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

                      if (_isSheetOpen &&
                          _updateHargaBottomSheet != null) {
                        _updateHargaBottomSheet!(() {});
                      }
                    },
                  );
                },
                child: _buildFilterDropdown(
                  Icons.hourglass_empty,
                  'Durasi:',
                  _pilihanDurasi,
                ),
              ),
            ),

          ],
        ),
      ),

      const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Pilih Tanggal dan Waktu',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Area Input Tanggal Kalender Kelompok',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
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
}