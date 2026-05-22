import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Setup Warna Sesuai Desain Tema
  static const Color primaryTeal = Color(0xFF318F95);
  static const Color inputBg = Color(0xFFF5F6F8);

  // 1. Controller untuk menampung teks yang bisa diketik
  final TextEditingController _nameController = TextEditingController(text: 'Albert Florest');
  final TextEditingController _usernameController = TextEditingController(text: 'albertflorest_');
  final TextEditingController _emailController = TextEditingController(text: 'albertflorest@email.com');
  
  // 2. Variabel untuk menampung pilihan Gender
  String _selectedGender = 'Male';

  @override
  void dispose() {
    // Membersihkan controller saat halaman ditutup agar menghemat memori
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // Tombol Kembali Kustom Kotak Toska
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: primaryTeal,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
            ),
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Konten Form Menggunakan ScrollView agar tidak overflow jika keyboard muncul
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input Nama
                    CustomInputField(
                      label: 'Name', 
                      controller: _nameController,
                    ),
                    
                    // Input Username
                    CustomInputField(
                      label: 'Username', 
                      controller: _usernameController,
                    ),
                    
                    // Input Gender (Menggunakan Dropdown agar bisa dipilih)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gender',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            dropdownColor: Colors.white,
                            decoration: InputDecoration(
                              fillColor: inputBg,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                            items: const [
                              DropdownMenuItem(value: 'Male', child: Text('Male', style: TextStyle(fontSize: 14, color: Colors.black))),
                              DropdownMenuItem(value: 'Female', child: Text('Female', style: TextStyle(fontSize: 14, color: Colors.black))),
                            ],
                            onChanged: (newValue) {
                              setState(() {
                                _selectedGender = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Input Email
                    CustomInputField(
                      label: 'Email', 
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
            ),
            
            // Tombol Save Berada Statis di Bagian Bawah
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Aksi saat data disimpan (bisa dikirim ke database/API nantinya)
                    debugPrint("Nama baru: ${_nameController.text}");
                    debugPrint("Username baru: ${_usernameController.text}");
                    debugPrint("Gender terpilih: $_selectedGender");
                    debugPrint("Email baru: ${_emailController.text}");
                    
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Komponen Reusable Widget khusus Input Form (Bisa Diketik)
class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const CustomInputField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              fillColor: const Color(0xFFF5F6F8),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              // Membuat input box tanpa border garis (flat style) sesuai mockup figma
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}