import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yomans_konseling/providers/dokter_provider.dart';

class TambahPsikologPage extends StatefulWidget {
  const TambahPsikologPage({Key? key}) : super(key: key);

  @override
  State<TambahPsikologPage> createState() =>
      _TambahPsikologPageState();
}

class _TambahPsikologPageState
    extends State<TambahPsikologPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController =
      TextEditingController();

  final TextEditingController _hargaController =
      TextEditingController();

  // ================= TAG =================
  List<String> _selectedTags = [];

  final List<String> _availableTags = [
    'Keluarga',
    'Kecemasan',
    'Percintaan',
    'Perkelahian',
    'Umum',
    'Karir',
  ];

  // ================= FOTO WEB =================
  Uint8List? _imageBytes;
  String? _imageName;

  final ImagePicker _picker = ImagePicker();

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        Uint8List bytes =
            await pickedFile.readAsBytes();

        setState(() {
          _imageBytes = bytes;
          _imageName = pickedFile.name;
        });
      }
    } catch (e) {
      print("Gagal ambil gambar: $e");
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dokterProvider =
        Provider.of<DokterProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 22,
          ),

          onPressed: () =>
              Navigator.pop(context),
        ),

        title: const Text(
          'Tambah Psikolog Baru',

          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ================= FOTO =================
              Center(
                child: GestureDetector(
                  onTap: _pickImage,

                  child: Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 130,

                        decoration:
                            BoxDecoration(
                          color: const Color(
                            0xFFE8F5E9,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            24,
                          ),

                          border: Border.all(
                            color: const Color(
                              0xFF2E7D32,
                            ).withOpacity(0.3),

                            width: 2,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(
                                0xFF2E7D32,
                              ).withOpacity(
                                0.06,
                              ),

                              blurRadius: 15,

                              offset:
                                  const Offset(
                                0,
                                5,
                              ),
                            )
                          ],
                        ),

                        child: _imageBytes !=
                                null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  24,
                                ),

                                child: FittedBox(
  fit: BoxFit.contain,
  child: Image.memory(
    _imageBytes!,
  ),
),
                              )
                            : Column(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,

                                children: const [
                                  Icon(
                                    Icons
                                        .camera_enhance_rounded,

                                    color: Color(
                                      0xFF2E7D32,
                                    ),

                                    size: 36,
                                  ),

                                  SizedBox(
                                    height: 6,
                                  ),

                                  Text(
                                    "Upload Foto",

                                    style:
                                        TextStyle(
                                      color:
                                          Color(
                                        0xFF2E7D32,
                                      ),

                                      fontSize:
                                          12,

                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      if (_imageBytes != null)
                        Positioned(
                          bottom: 0,
                          right: 0,

                          child: CircleAvatar(
                            backgroundColor:
                                const Color(
                              0xFF2E7D32,
                            ),

                            radius: 18,

                            child: const Icon(
                              Icons.edit,
                              color:
                                  Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ================= NAMA =================
              const Text(
                "Nama Lengkap",

                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _namaController,

                decoration:
                    _buildInputDecoration(
                  "Masukkan nama...",
                  Icons.person,
                ),

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return "Nama wajib diisi";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ================= HARGA =================
              const Text(
                "Tarif Konseling (Rp)",

                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller:
                    _hargaController,

                keyboardType:
                    TextInputType.number,

                decoration:
                    _buildInputDecoration(
                  "Contoh: 150000",
                  Icons.payments_outlined,
                ),

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return "Harga wajib diisi";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ================= TAG =================
              const Text(
                "Spesialisasi / Tags",

                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,

                children:
                    _availableTags.map((tag) {
                  final isSelected =
                      _selectedTags
                          .contains(tag);

                  return FilterChip(
                    label: Text(tag),

                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(
                              0xFF2E7D32,
                            ),

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 12,
                    ),

                    selected: isSelected,

                    selectedColor:
                        const Color(
                      0xFF2E7D32,
                    ),

                    backgroundColor:
                        const Color(
                      0xFFE8F5E9,
                    ),

                    checkmarkColor:
                        Colors.white,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        8,
                      ),
                    ),

                    onSelected:
                        (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags
                              .add(tag);
                        } else {
                          _selectedTags
                              .remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // ================= BUTTON =================
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey
                        .currentState!
                        .validate()) {
                      if (_selectedTags
                          .isEmpty) {
                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Pilih minimal satu spesialisasi!",
                            ),
                          ),
                        );

                        return;
                      }

                      // ================= DATA =================
                      Map<String, dynamic>
                          dataBaru = {
                        "nama":
                            _namaController
                                .text,

                        "spesialis":
                            _selectedTags
                                .join(", "),

                        "harga":
                            int.tryParse(
                                  _hargaController
                                      .text,
                                ) ??
                                100000,

                        "imageBytes":
                            _imageBytes,

                        "imageName":
                            _imageName,
                      };

                      bool success =
                          await dokterProvider
                              .tambahDokter(
                        dataBaru,
                      );

                      if (success) {
                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Data psikolog berhasil ditambahkan!",
                            ),
                          ),
                        );

                        Navigator.pop(
                          context,
                        );
                      } else {
                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Gagal menyimpan data!",
                            ),
                          ),
                        );
                      }
                    }
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF2E7D32,
                    ),

                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 16,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),

                  child: const Text(
                    "Simpan Data Psikolog",

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= INPUT DECORATION =================
  InputDecoration _buildInputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        color: Color(0xFFA0AEC0),
        fontSize: 14,
      ),

      prefixIcon: Icon(
        icon,
        color: const Color(
          0xFF2E7D32,
        ),
      ),

      filled: true,

      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),

        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),

        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),

        borderSide: const BorderSide(
          color: Color(0xFF2E7D32),
          width: 1.5,
        ),
      ),
    );
  }
}