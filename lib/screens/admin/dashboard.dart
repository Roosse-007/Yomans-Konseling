import 'package:flutter/material.dart';
import 'package:yomans_konseling/screens/admin/daftarPsikolog.dart';
import 'package:yomans_konseling/screens/berita/admin_berita_screen.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF4F6F4), // Latar belakang abu-abu terang kehijauan samar
      ),
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  // Definisi palet warna sesuai desain
  final Color primaryGreen = const Color(0xFF2E6B33);       // Hijau tua header & teks utama
  final Color accentGreen = const Color(0xFF3B7A40);        // Hijau tombol utama
  final Color lightGreenBg = const Color(0xFFE4EFE3);       // Hijau muda tombol bawah
  final Color actionGreen = const Color(0xFF4CAF50);        // Hijau tombol tambah (+)
  final Color actionOrange = const Color(0xFFFF9800);       // Oranye tombol edit
  final Color actionRed = const Color(0xFFE53935);          // Merah tombol hapus

  // --- KLIK EDIT POP-UP DIALOG ---
  void _showEditDialog(BuildContext context, String currentName) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: currentName);
    String? _selectedSpecialization = 'Anxiety & Stress';
    final List<String> _specializations = [
      'Anxiety & Stress',
      'Hubungan / Pernikahan',
      'Pengembangan Diri',
      'Anak & Remaja',
      'Depresi & Trauma',
    ];

    showDialog(
      context: context,
      barrierDismissible: false, // Mengharuskan admin memilih Batal atau Simpan
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Data Psikolog',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        )
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    
                    // Input Nama
                    const Text('Nama Lengkap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: primaryGreen, size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryGreen),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Nama lengkap wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input Spesialisasi
                    const Text('Spesialisasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedSpecialization,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.psychology, color: primaryGreen, size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryGreen),
                        ),
                      ),
                      items: _specializations.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        _selectedSpecialization = newValue;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Tombol Aksi di dalam Dialog
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Perubahan data ${_nameController.text} berhasil disimpan!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND HIJAU ATAS
          Container(
            height: 220,
            color: primaryGreen,
          ),

          // 2. WATERMARK BACKGROUND DI TENGAH LAYAR
          Center(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'lib/assets/logo-yomans.png',
                width: MediaQuery.of(context).size.width * 0.85,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(); // Fallback kosong jika aset gambar belum ada
                },
              ),
            ),
          ),

          // 3. KONTEN UTAMA (Sistem Lapisan Atas)
          SafeArea(
            child: Column(
              children: [
                // --- HEADER PANEL ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Panel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white24,
                                child: ClipOval(
                                  child: Image.asset(
                                    'lib/assets/logo-yomans.png',
                                    errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Yomans Counseling',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    'Yomans Counseling',
                                    style: TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Tombol Logout
                      Container(
                        margin: const EdgeInsets.only(top: 28),
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Berhasil keluar dari Admin Panel'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(context); 
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBDD9BB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Text('Logout', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 6),
                                Icon(Icons.logout, color: primaryGreen, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- CONTAINER DASHBOARD UTAMA (Lengkung Putih) ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                              children: [
                                // Judul Besar Dashboard
                                Text(
                                  'Admin Dashboard:\nKelola Konten & Data',
                                  style: TextStyle(
                                    color: primaryGreen,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // ==========================================
                                // SECTION 1: KELOLA PSIKOLOG
                                // ==========================================
                                _buildMainSectionHeader(
                                  title: 'Kelola Psikolog',
                                  subtitle: 'Psikolog yang Terdaftar',
                                  buttonText: 'Buka Daftar Psikolog',
                                  iconData: Icons.psychology_outlined,
                                  onHeaderButtonTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const DaftarPsikologAdminPage()),
                                    );
                                  },
                                ),
                                
                                
                                const SizedBox(height: 16),

                                // ==========================================
                                // SECTION 2: KELOLA BERITA & EDUKASI
                                // ==========================================
                             _buildMainSectionHeader(
                                title: 'Kelola Berita & Edukasi',
                                subtitle: 'Artikel-Artikel',
                                buttonText: 'Buka Daftar Berita',
                                iconData: Icons.menu_book,
                                onHeaderButtonTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AdminBeritaScreen()),
                                  );
                                },
                              ),
                                

                                // ==========================================
                                // SECTION 3: KELOLA GEJALA
                                // ==========================================
                                _buildMainSectionHeader(
                                  title: 'Kelola Gejala',
                                  subtitle: 'Gejala-Gejala',
                                  buttonText: 'Buka Daftar Gejala',
                                  iconData: Icons.add_moderator_outlined,
                                  onHeaderButtonTap: () {},
                                ),
                               
                              ],
                            ),
                          ),

                          // --- TOMBOL BAWAH ---
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                            child: Column(
                              children: [
                                shadowContainer(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: lightGreenBg,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Kembali ke Dashboard Utama',
                                      style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Powered by System Core',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Wrapper untuk pembantu ukuran boks elevasi tombol bawah
  Widget shadowContainer({required double width, required double height, required Widget child}) {
    return SizedBox(width: width, height: height, child: child);
  }

  // --- WIDGET HELPER BUILDER UNTUK MATRIKS DASHBOARD ---

  // Header Utama Section
  Widget _buildMainSectionHeader({
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData iconData,
    required VoidCallback onHeaderButtonTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(iconData, size: 44, color: const Color(0xFF7CA979)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                    InkWell(
                      onTap: onHeaderButtonTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Baris Data Sub-Item: USER / PSIKOLOG (Ditambahkan parameter onEditPressed)
  Widget _buildSubItemUser({
    required String name, 
    required String role, 
    required BuildContext context,
    VoidCallback? onEditPressed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(role, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          _buildActionButtons(
            hasAddText: true,
            onAddPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPsikologPage()),
              );
            },
            onEditPressed: onEditPressed, // Menyalurkan fungsi edit ke tombol
          ),
        ],
      ),
    );
  }

  // Baris Data Sub-Item: BERITA / ARTIKEL
  Widget _buildSubItemArticle({required String title, required String date}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.image, size: 18, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          _buildActionButtons(hasAddText: false),
        ],
      ),
    );
  }

  // Baris Data Sub-Item: LIST GEJALA / SYMPTOM SEDERHANA
  Widget _buildSubItemSimpleRow({required String title}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          _buildActionButtons(hasAddText: false, isMinimal: true),
        ],
      ),
    );
  }

  // Komponen Kelompok Tombol Aksi (Ditambahkan InkWell onTap pada bagian Edit)
  Widget _buildActionButtons({
    required bool hasAddText, 
    bool isMinimal = false, 
    VoidCallback? onAddPressed,
    VoidCallback? onEditPressed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tombol Tambah (+)
        InkWell(
          onTap: onAddPressed,
          borderRadius: BorderRadius.circular(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: actionGreen, borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.add, color: Colors.white, size: 14),
              ),
              if (hasAddText && !isMinimal) ...[
                const SizedBox(height: 2),
                Text('Tambah Data', style: TextStyle(color: Colors.grey.shade600, fontSize: 7, fontWeight: FontWeight.bold)),
              ] else if (!hasAddText && !isMinimal) ...[
                const SizedBox(height: 2),
                Text('Tambah', style: TextStyle(color: Colors.grey.shade600, fontSize: 7, fontWeight: FontWeight.bold)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 6),
        // Tombol Edit (Pensil) -> Sekarang dibungkus dengan InkWell untuk mendengarkan klik
        InkWell(
          onTap: onEditPressed,
          borderRadius: BorderRadius.circular(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: actionOrange, borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
              if (!isMinimal) ...[
                const SizedBox(height: 2),
                Text('Edit', style: TextStyle(color: Colors.grey.shade600, fontSize: 7, fontWeight: FontWeight.bold)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 6),
        // Tombol Hapus (Tong Sampah)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: actionRed, borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.delete, color: Colors.white, size: 14),
            ),
            if (!isMinimal) ...[
              const SizedBox(height: 2),
              Text('Hapus', style: TextStyle(color: Colors.grey.shade600, fontSize: 7, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ],
    );
  }
}

// =========================================================================
// HALAMAN FORM TAMBAH DATA PSIKOLOG (AddPsikologPage)
// =========================================================================
class AddPsikologPage extends StatefulWidget {
  const AddPsikologPage({Key? key}) : super(key: key);

  @override
  State<AddPsikologPage> createState() => _AddPsikologPageState();
}

class _AddPsikologPageState extends State<AddPsikologPage> {
  final _formKey = GlobalKey<FormState>();

  final Color primaryGreen = const Color(0xFF2E6B33); 
  final Color accentGreen = const Color(0xFF3B7A40);  
  final Color hintIconGreen = const Color(0xFF2E6B33); 

  String? _selectedSpecialization;
  final List<String> _specializations = [
    'Anxiety & Stress',
    'Hubungan / Pernikahan',
    'Pengembangan Diri',
    'Anak & Remaja',
    'Depresi & Trauma',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4), 
      appBar: AppBar(
        title: const Text(
          'Tambah Data Psikolog',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 0.06, 
              child: Image.asset(
                'lib/assets/logo_yomans.png',
                width: MediaQuery.of(context).size.width * 0.85,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(); 
                },
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB0B0B0),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  child: const Icon(Icons.person, size: 75, color: Colors.white),
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: accentGreen,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel('Nama Lengkap'),
                                TextFormField(
                                  decoration: _buildInputDecoration(Icons.person),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Nama lengkap wajib diisi';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildInputLabel('Nomor Lisensi / SIPP'),
                                TextFormField(
                                  decoration: _buildInputDecoration(Icons.description),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Nomor lisensi wajib diisi';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildInputLabel('Spesialisasi'),
                                DropdownButtonFormField<String>(
                                  value: _selectedSpecialization,
                                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                  decoration: _buildInputDecoration(Icons.psychology),
                                  items: _specializations.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value, style: const TextStyle(fontSize: 14)),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedSpecialization = newValue;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) return 'Silakan pilih spesialisasi';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildInputLabel('Pengalaman (Tahun)'),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration(Icons.badge),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Lama pengalaman wajib diisi';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildInputLabel('Bio Singkat'),
                                TextFormField(
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(bottom: 50), 
                                      child: Icon(Icons.edit, color: hintIconGreen, size: 20),
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: primaryGreen, width: 1),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.red, width: 1),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.red, width: 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Data Psikolog Berhasil Disimpan'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.pop(context); 
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B663E), 
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Simpan Data Psikolog', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  InputDecoration _buildInputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: hintIconGreen, size: 20),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryGreen, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }
}