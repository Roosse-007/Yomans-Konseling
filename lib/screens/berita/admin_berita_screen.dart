import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:yomans_konseling/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminBeritaScreen extends StatefulWidget {
  const AdminBeritaScreen({Key? key}) : super(key: key);

  @override
  State<AdminBeritaScreen> createState() => _AdminBeritaScreenState();
}

class _AdminBeritaScreenState extends State<AdminBeritaScreen> {
  List<dynamic> _listBerita = [];
  bool _isLoading = true;

  // Controller Form
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  final _sumberController = TextEditingController();
  final _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBerita();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    _sumberController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // ================= 1. GET DATA =================
  Future<void> fetchBerita() async {
    setState(() => _isLoading = true);
    try {
      // Disinkronkan langsung ke endpoint berita di Flask Anda
      final url = Uri.parse('${ApiService.baseUrl}/berita');
      
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _listBerita = responseData['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('Server Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data: $e');
    }
  }

  // ================= 2. POST DATA =================
  Future<void> tambahBerita() async {
    if (_judulController.text.isEmpty || _isiController.text.isEmpty) {
      _showSnackBar('Judul dan Isi berita tidak boleh kosong!');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/berita'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode({
          'judul': _judulController.text,
          'isi': _isiController.text,
          'sumber': _sumberController.text.isEmpty ? 'Admin' : _sumberController.text,
          'link_sumber': _linkController.text,
        }),
      );

      final Map<String, dynamic> resData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar(resData['message'] ?? 'Berita berhasil ditambahkan!');
        _clearForm();
        Navigator.pop(context); 
        fetchBerita(); 
      } else {
        _showSnackBar('Gagal: ${resData['message'] ?? response.body}');
      }
    } catch (e) {
      _showSnackBar('Gagal terhubung ke server ($e)');
    }
  }

  // ================= 3. PUT DATA =================
  Future<void> editBerita(dynamic id) async {
    if (_judulController.text.isEmpty || _isiController.text.isEmpty) {
      _showSnackBar('Judul dan Isi berita tidak boleh kosong!');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/berita/$id'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode({
          'judul': _judulController.text,
          'isi': _isiController.text,
          'sumber': _sumberController.text.isEmpty ? 'Admin' : _sumberController.text,
          'link_sumber': _linkController.text,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Berita berhasil diperbarui!');
        _clearForm();
        Navigator.pop(context); 
        fetchBerita(); 
      } else {
        _showSnackBar('Gagal memperbarui data.');
      }
    } catch (e) {
      _showSnackBar('Gagal terhubung ke server ($e)');
    }
  }

  // ================= 4. LAUNCH URL =================
  Future<void> _bukaLink(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url.trim());
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _showSnackBar("Tidak bisa membuka link");
      }
    } catch (e) {
      _showSnackBar("Format URL tidak valid");
    }
  }

  // ================= 5. FORM DIALOG =================
  void _showFormDialog({Map<String, dynamic>? berita}) {
    final bool isEditMode = berita != null;

    if (isEditMode) {
      _judulController.text = berita['judul'] ?? '';
      _isiController.text = berita['isi'] ?? '';
      _sumberController.text = berita['sumber'] ?? '';
      _linkController.text = berita['link_sumber'] ?? '';
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEditMode ? 'Edit Berita & Edukasi' : 'Tambah Berita & Edukasi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Berita *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _isiController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Isi Berita / Edukasi *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sumberController,
                decoration: const InputDecoration(
                  labelText: 'Sumber (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Link Sumber URL (Opsional)',
                  border: OutlineInputBorder(),
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
                editBerita(berita['id']); 
              } else {
                tambahBerita();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: Text(isEditMode ? 'Update' : 'Simpan', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _judulController.clear();
    _isiController.clear();
    _sumberController.clear();
    _linkController.clear();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  // ================= 6. UI UTAMA =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      appBar: AppBar(
        title: const Text(
          'Kelola Berita & Edukasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green[700]))
          : _listBerita.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada berita tersedia.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchBerita,
                  color: Colors.green[700],
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _listBerita.length,
                    itemBuilder: (context, index) {
                      final berita = _listBerita[index];
                      String urlLink = berita['link_sumber'] ?? '';

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ExpansionTile(
                          iconColor: Colors.green[700],
                          title: Text(
                            berita['judul'] ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            'Sumber: ${berita['sumber'] ?? 'Admin'}',
                            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    berita['isi'] ?? '-',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
                                    textAlign: TextAlign.justify,
                                  ),
                                  if (urlLink.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () => _bukaLink(urlLink),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Text(
                                          'Link: $urlLink',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 13,
                                            decoration: TextDecoration.underline,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.green[700]!),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          _showFormDialog(berita: Map<String, dynamic>.from(berita));
                                        },
                                        icon: Icon(Icons.edit, color: Colors.green[700], size: 16),
                                        label: Text(
                                          "Edit Data",
                                          style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(), 
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}