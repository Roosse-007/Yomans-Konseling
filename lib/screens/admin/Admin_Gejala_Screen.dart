import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:yomans_konseling/services/api_service.dart';

class AdminGejalaScreen extends StatefulWidget {
  const AdminGejalaScreen({Key? key}) : super(key: key);

  @override
  State<AdminGejalaScreen> createState() => _AdminGejalaScreenState();
}

class _AdminGejalaScreenState extends State<AdminGejalaScreen> {
  List<dynamic> _listGejala = [];
  bool _isLoading = true;

  // Controller Input Form
  final _namaController = TextEditingController();
  final _bobotController = TextEditingController();
  String _selectedKategori = 'stres'; // Nilai default kategori

  @override
  void initState() {
    super.initState();
    fetchGejala();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _bobotController.dispose();
    super.dispose();
  }

  // ================= 1. GET DATA =================
  Future<void> fetchGejala() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getGejala();
      setState(() {
        _listGejala = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal terhubung ke server: $e');
    }
  }

  // ================= 2. POST DATA =================
  Future<void> tambahGejala() async {
    if (_namaController.text.isEmpty || _bobotController.text.isEmpty) {
      _showSnackBar('Semua field wajib diisi!');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/gejala'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          'nama_gejala': _namaController.text.trim(),
          'kategori': _selectedKategori,
          'bobot': int.parse(_bobotController.text.trim()),
        }),
      );

      final Map<String, dynamic> resData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar(resData['message'] ?? 'Gejala berhasil disimpan!');
        _clearForm();
        Navigator.pop(context);
        fetchGejala();
      } else {
        _showSnackBar('Gagal: ${resData['message'] ?? response.body}');
      }
    } catch (e) {
      _showSnackBar('Kendala koneksi atau format data salah: $e');
    }
  }

  // ================= 3. PUT DATA (EDIT) =================
  Future<void> editGejala(dynamic id) async {
    if (_namaController.text.isEmpty || _bobotController.text.isEmpty) {
      _showSnackBar('Semua field wajib diisi!');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/gejala/$id'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          'nama_gejala': _namaController.text.trim(),
          'kategori': _selectedKategori,
          'bobot': int.parse(_bobotController.text.trim()),
        }),
      );

      final Map<String, dynamic> resData = json.decode(response.body);

      if (response.statusCode == 200) {
        _showSnackBar(resData['message'] ?? 'Gejala berhasil diperbarui!');
        _clearForm();
        Navigator.pop(context);
        fetchGejala();
      } else {
        _showSnackBar('Gagal: ${resData['message'] ?? response.body}');
      }
    } catch (e) {
      _showSnackBar('Kendala koneksi atau format data salah: $e');
    }
  }

// ================= 4. DELETE DATA =================
  Future<void> hapusGejala(dynamic id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/gejala/$id'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      // JIKA BACKEND MERESPON DENGAN SUKSES (JSON)
      if (response.statusCode == 200) {
        final Map<String, dynamic> resData = json.decode(response.body);
        _showSnackBar(resData['message'] ?? 'Gejala berhasil dihapus!');
        fetchGejala();
      } else {
        // JIKA ERROR (BISA JADI HTML ATAU JSON ERROR)
        try {
          final Map<String, dynamic> resData = json.decode(response.body);
          _showSnackBar('Gagal [${response.statusCode}]: ${resData['message']}');
        } catch (_) {
          // Jika gagal didecode sebagai JSON (berarti dapet HTML), tampilkan status kodenya saja
          _showSnackBar('Server Error [${response.statusCode}]: Gagal memproses request hapus.');
        }
      }
    } catch (e) {
      _showSnackBar('Kendala koneksi: $e');
    }
  }

  // Helper Clear Form
  void _clearForm() {
    _namaController.clear();
    _bobotController.clear();
    _selectedKategori = 'stres';
  }

  // ================= DIALOG KONFIRMASI HAPUS =================
  void _showDeleteConfirmation(dynamic id, String namaGejala) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Gejala', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Apakah Anda yakin ingin menghapus gejala "$namaGejala"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              hapusGejala(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ================= FORM DIALOG INPUT (TAMBAH & EDIT) =================
  void _showFormDialog({Map<String, dynamic>? gejala}) {
    final bool isEditMode = gejala != null;

    if (isEditMode) {
      _namaController.text = gejala['nama_gejala'] ?? '';
      
      if (gejala['bobot'] != null) {
        _bobotController.text = gejala['bobot'].toString();
      } else {
        _bobotController.text = '2'; 
      }
      
      String katRaw = (gejala['kategori'] ?? 'stres').toString().toLowerCase().trim();
      if (katRaw == 'stress') katRaw = 'stres';
      if (['stres', 'kecemasan', 'depresi'].contains(katRaw)) {
        _selectedKategori = katRaw;
      } else {
        _selectedKategori = 'stres';
      }
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEditMode ? 'Edit Data Gejala' : 'Tambah Gejala Baru',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _namaController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Gejala *',
                    hintText: 'Contoh: Jantung berdebar',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.assignment_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedKategori,
                  decoration: const InputDecoration(
                    labelText: 'Kategori Gangguan *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.psychology_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'stres', child: Text('Stres / Stress')),
                    DropdownMenuItem(value: 'kecemasan', child: Text('Kecemasan / Anxiety')),
                    DropdownMenuItem(value: 'depresi', child: Text('Depresi')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => _selectedKategori = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bobotController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nilai Bobot Skor (1 - 5) *',
                    hintText: 'Masukkan nilai bobot angka',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.star_border_rounded),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearForm();
                Navigator.pop(context);
              },
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (isEditMode) {
                  editGejala(gejala['id']);
                } else {
                  tambahGejala();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isEditMode ? 'Update' : 'Simpan',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Color _getBadgeColor(String kategori) {
    switch (kategori.toLowerCase().trim()) {
      case 'stres':
      case 'stress':
        return Colors.blue;
      case 'kecemasan':
        return Colors.orange;
      case 'depresi':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      appBar: AppBar(
        title: const Text(
          'Kelola Data Gejala',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green[700]))
          : _listGejala.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada data gejala di database.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchGejala,
                  color: Colors.green[700],
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _listGejala.length,
                    itemBuilder: (context, index) {
                      final gejala = _listGejala[index];
                      final String kategori = (gejala['kategori'] ?? 'stres').toString();
                      final int bobot = gejala['bobot'] ?? 2;

                      return Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[50],
                              child: Text(
                                "${gejala['id']}",
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                gejala['nama_gejala'] ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _getBadgeColor(kategori).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    kategori.toUpperCase(),
                                    style: TextStyle(
                                      color: _getBadgeColor(kategori),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "Bobot: $bobot",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_note_rounded, color: Colors.orange, size: 28),
                                  onPressed: () => _showFormDialog(
                                    gejala: Map<String, dynamic>.from(gejala),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
                                  onPressed: () {
                                    final int idGejala = int.parse(gejala['id'].toString());
                                    final String namaGejala = gejala['nama_gejala'] ?? '-';
                                    _showDeleteConfirmation(idGejala, namaGejala);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}