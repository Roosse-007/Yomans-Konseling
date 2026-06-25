import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yomans_konseling/providers/dokter_provider.dart';

class EditPsikologPage extends StatefulWidget {
  final Map<String, dynamic> dokter;
  const EditPsikologPage({Key? key, required this.dokter}) : super(key: key);

  @override
  State<EditPsikologPage> createState() => _EditPsikologPageState();
}

class _EditPsikologPageState extends State<EditPsikologPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk input
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jadwalController = TextEditingController();
  final TextEditingController _hargaAwalController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _durasiController = TextEditingController();
  
  final String _cacheKey = DateTime.now().millisecondsSinceEpoch.toString();
  List<String> _selectedTags = [];
  final List<String> _availableTags = ['Keluarga', 'Kecemasan', 'Percintaan', 'Perkelahian', 'Umum', 'Karir'];
  
  Uint8List? _imageBytes;
  String? _imageName;
  String? _oldImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.dokter['nama']?.toString() ?? '';
    _jadwalController.text = widget.dokter['jadwal']?.toString() ?? '';
    _hargaAwalController.text = widget.dokter['harga_awal']?.toString() ?? '';
    _hargaController.text = widget.dokter['harga_diskon']?.toString() ?? '';
    _durasiController.text = widget.dokter['durasi']?.toString() ?? '';
    _oldImageUrl = widget.dokter['image_url']?.toString();

    String rawTags = widget.dokter['tags']?.toString() ?? '';
    rawTags = rawTags.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
    if (rawTags.isNotEmpty) {
      _selectedTags = rawTags.split(',').map((tag) => tag.trim()).toList();
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = pickedFile.name;
      });
    }
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    );
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
      filled: true,
      fillColor: Colors.white,
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dokterProvider = Provider.of<DokterProvider>(context, listen: false);

    // 💡 DEFINISIKAN BASE URL BACKEND ANDA DI SINI
    const String baseUrl = "http://127.0.0.1:5000"; 

    // Logika pengaman penataan URL Gambar agar terhindar dari error 404
    String finalImageUrl = "";
    if (_oldImageUrl != null && _oldImageUrl!.isNotEmpty) {
      if (_oldImageUrl!.startsWith('http')) {
        finalImageUrl = _oldImageUrl!; // Jika dari DB sudah berupa full URL link
      } else {
        finalImageUrl = "$baseUrl/$_oldImageUrl"; // Jika berupa rute relatif "uploads/..."
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Edit Data Psikolog', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ), 
        backgroundColor: Colors.white, 
        centerTitle: true, 
        elevation: 0,
        scrolledUnderElevation: 0,
        // 🔥 FIX: Mengubah tombol back menjadi gaya panah iOS (iOS style back arrow)
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 25,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // FOTO LINGKARAN DENGAN INDIKATOR EDIT
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 2)),
                      child: ClipOval(
                        child: _imageBytes != null 
                          ? Image.memory(_imageBytes!, fit: BoxFit.cover) 
                          : (finalImageUrl.isNotEmpty 
                              // 🔥 FIX: Memuat gambar menggunakan rute aman yang telah difilter
                              ? Image.network(
                                  "$finalImageUrl?v=$_cacheKey", 
                                  fit: BoxFit.cover, 
                                  errorBuilder: (c, o, s) => const Icon(Icons.person, size: 60, color: Colors.grey),
                                )
                              : const Icon(Icons.person, size: 60, color: Colors.grey)),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFF1B5E20), shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextFormField(controller: _namaController, decoration: _buildInputDecoration("Nama", Icons.person)),
            const SizedBox(height: 20),
            TextFormField(controller: _jadwalController, decoration: _buildInputDecoration("Jadwal", Icons.calendar_month)),
            const SizedBox(height: 20),
            TextFormField(controller: _hargaAwalController, decoration: _buildInputDecoration("Harga Awal", Icons.money)),
            const SizedBox(height: 20),
            TextFormField(controller: _hargaController, decoration: _buildInputDecoration("Harga Diskon", Icons.payments)),
            const SizedBox(height: 20),
            TextFormField(controller: _durasiController, decoration: _buildInputDecoration("Durasi", Icons.hourglass_bottom)),
            const SizedBox(height: 25),
            const Text("Spesialisasi / Tags", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  selected: isSelected,
                  selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF2E7D32),
                  label: Text(tag, style: TextStyle(color: isSelected ? const Color(0xFF1B5E20) : Colors.black87)),
                  onSelected: (bool selected) => setState(() => selected ? _selectedTags.add(tag) : _selectedTags.remove(tag)),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20), 
                  padding: const EdgeInsets.symmetric(vertical: 16), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    bool success = await dokterProvider.editDokter({
                      "id": widget.dokter['id'],
                      "nama": _namaController.text,
                      "tags": _selectedTags.join(", "),
                      "harga_awal": int.tryParse(_hargaAwalController.text) ?? 0,
                      "harga_diskon": int.tryParse(_hargaController.text) ?? 0,
                      "jadwal": _jadwalController.text,
                      "durasi": _durasiController.text,
                      "imageBytes": _imageBytes,
                      "imageName": _imageName,
                    });
                    if (success && mounted) Navigator.pop(context, true);
                  }
                },
                child: const Text("Perbarui Data Psikolog", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}