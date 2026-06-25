import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class KelolaJadwalPage extends StatefulWidget {
  final int dokterId;
  final String namaDokter;

  const KelolaJadwalPage({
    super.key,
    required this.dokterId,
    required this.namaDokter,
  });

  @override
  State<KelolaJadwalPage> createState() => _KelolaJadwalPageState();
}

class _KelolaJadwalPageState extends State<KelolaJadwalPage> {
  List<dynamic> _jadwal = [];
  bool _loading = true;

  // Controller untuk menangkap input data dari Admin
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _jamController = TextEditingController();
  String _sesiTerpilih = 'Pagi'; // Default dropdown sesuai opsi di phpMyAdmin Anda

  @override
  void initState() {
    super.initState();
    fetchJadwal();
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _jamController.dispose();
    super.dispose();
  }

// 1. Ambil Data Jadwal Spesifik Per Dokter
  Future<void> fetchJadwal() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      // Ditambahkan .toString() pada ID untuk memastikan keandalan URL parser
      final response = await http.get(
        Uri.parse("http://127.0.0.1:5000/api/dokter/${widget.dokterId.toString()}/jadwal"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _jadwal = data["data"] ?? [];
            _loading = false;
          });
        }
      } else {
        _showSnackBar("Gagal memuat jadwal [Status: ${response.statusCode}]");
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint("ERROR FETCH JADWAL = $e");
      _showSnackBar("Gagal tersambung ke server.");
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // 2. Tambah Slot Jadwal Baru
  Future<void> tambahJadwal(String tanggal, String jam, String sesi) async {
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/api/admin/jadwal"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "dokter_id": widget.dokterId, // Dikirim sebagai int sesuai kebutuhan DB relasional
          "tanggal": tanggal,
          "jam": jam,
          "sesi": sesi,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _tanggalController.clear();
        _jamController.clear();
        _showSnackBar("Jadwal berhasil disimpan!");
        fetchJadwal(); // Refresh otomatis
      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(data["message"] ?? "Gagal menambah jadwal.");
      }
    } catch (e) {
      debugPrint("ERROR TAMBAH JADWAL = $e");
      _showSnackBar("Terjadi kesalahan jaringan.");
    }
  }

  // 3. Hapus Slot Jadwal Berdasarkan ID
  Future<void> hapusJadwal(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("http://127.0.0.1:5000/api/admin/jadwal/${id.toString()}"),
      );

      if (response.statusCode == 200) {
        _showSnackBar("Jadwal berhasil dihapus");
        fetchJadwal(); // Refresh otomatis
      } else {
        try {
          final data = jsonDecode(response.body);
          _showSnackBar("Gagal: ${data['message']}");
        } catch (_) {
          _showSnackBar("Gagal menghapus jadwal [${response.statusCode}].");
        }
      }
    } catch (e) {
      debugPrint("ERROR HAPUS JADWAL = $e");
      _showSnackBar("Terjadi kesalahan saat menghapus.");
    }
  }

  void _showSnackBar(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  Future<void> generateJadwalOtomatis() async {
  setState(() => _loading = true);
  try {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:5000/api/admin/jadwal/auto-generate"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "dokter_id": widget.dokterId, // Otomatis mengirim ID dokter aktif (misal 11)
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _showSnackBar(data["message"] ?? "Jadwal otomatis berhasil dibuat!");
      fetchJadwal(); // Refresh list otomatis agar jadwal langsung muncul
    } else {
      _showSnackBar(data["message"] ?? "Gagal generate jadwal.");
      setState(() => _loading = false);
    }
  } catch (e) {
    debugPrint("ERROR AUTO GENERATE = $e");
    _showSnackBar("Terjadi kesalahan jaringan.");
    setState(() => _loading = false);
  }
}

  // Dialog Form Tambah Jadwal (Pop-up)
  void _showTambahJadwalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Tambah Slot Jadwal"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _tanggalController,
                      decoration: const InputDecoration(
                        labelText: "Tanggal (YYYY-MM-DD)",
                        hintText: "Contoh: 2026-06-24",
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _jamController,
                      decoration: const InputDecoration(
                        labelText: "Jam Kehadiran",
                        hintText: "Contoh: 09:00:00 atau 09:00",
                        prefixIcon: Icon(Icons.access_time),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _sesiTerpilih,
                      decoration: const InputDecoration(
                        labelText: "Pilih Sesi",
                        prefixIcon: Icon(Icons.layers),
                      ),
                      items: ['Pagi', 'Siang', 'Sore', 'Malam']
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          _sesiTerpilih = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2d6a4f),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_tanggalController.text.isNotEmpty &&
                        _jamController.text.isNotEmpty) {
                      tambahJadwal(
                        _tanggalController.text,
                        _jamController.text,
                        _sesiTerpilih,
                      );
                      Navigator.pop(context);
                    } else {
                      _showSnackBar("Harap isi semua form!");
                    }
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jadwal ${widget.namaDokter}"),
        backgroundColor: const Color(0xff2d6a4f),
        foregroundColor: Colors.white,
        actions: [
          // ========================================================
          // TOMBOL GENERATE OTOMATIS (AUTO-SLOT)
          // ========================================================
          TextButton.icon(
            onPressed: generateJadwalOtomatis, // Memanggil fungsi auto-generate ke Flask
            icon: const Icon(Icons.flash_on, color: Colors.amber, size: 20),
            label: const Text(
              "Auto-Slot",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _jadwal.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada jadwal",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _jadwal.length,
                  itemBuilder: (context, index) {
                    final item = _jadwal[index];
                    
                    // Mengambil nilai 'id' murni dari DB
                    final int? idJadwal = item["id"];
                    final String status = item["status"]?.toString().toLowerCase() ?? "tersedia";
                    final bool isBooked = status == "booked";

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isBooked ? Colors.grey : const Color(0xff2d6a4f),
                          child: const Icon(Icons.schedule, color: Colors.white),
                        ),
                        title: Text(
                          item["tanggal"]?.toString() ?? "-",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text("${item['jam'] ?? '-'} (${item['sesi'] ?? '-'})"),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Badge Status Dinamis (Tersedia = Hijau, Booked = Merah)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isBooked ? Colors.red.shade100 : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: isBooked ? Colors.red.shade800 : const Color(0xff2d6a4f),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Tombol Hapus Aksi (Disabled jika status 'booked')
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: isBooked ? Colors.grey.shade400 : Colors.red.shade400,
                              ),
                              onPressed: isBooked
                                  ? null 
                                  : () {
                                      if (idJadwal == null) return;
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text("Hapus Jadwal?"),
                                          content: const Text("Apakah Anda yakin ingin menghapus slot jadwal ini?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: const Text("Batal"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                hapusJadwal(idJadwal);
                                              },
                                              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTambahJadwalDialog,
        backgroundColor: const Color(0xff2d6a4f),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}