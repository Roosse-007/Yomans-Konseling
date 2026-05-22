import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailArtikel extends StatelessWidget {

  final Map data;

  const DetailArtikel({
    super.key,
    required this.data,
  });

  Color getColor(String kategori) {

    if (kategori == "Artikel Mental") {
      return Colors.blue;
    }

    return Colors.green;
  }

  Future bukaLink(String url) async {

    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {

      throw Exception(
        "Tidak bisa membuka link",
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF4F7FC),

      appBar: AppBar(

        elevation: 0,
        backgroundColor: Colors.white,

        iconTheme: const IconThemeData(
          color: Colors.black,
        ),

        title: Text(

          data['kategori'],

          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ================= KATEGORI =================
            Container(

              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),

              decoration: BoxDecoration(

                color: getColor(
                  data['kategori'],
                ),

                borderRadius:
                    BorderRadius.circular(30),
              ),

              child: Text(

                data['kategori'],

                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= JUDUL =================
            Text(

              data['judul'],

              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 30),

            // ================= ISI =================
            Text(

              data['isi'],

              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
                height: 1.9,
              ),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 35),

            // ================= SUMBER =================
            Container(

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(22),

                boxShadow: [

                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Row(

                    children: [

                      Icon(
                        Icons.verified,
                        color: Colors.blue,
                      ),

                      SizedBox(width: 10),

                      Text(

                        "Sumber Referensi",

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Text(

                    data['sumber'] ??
                        "Sumber tidak tersedia",

                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(

                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton.icon(

                      style: ElevatedButton.styleFrom(

                        backgroundColor:
                            getColor(
                          data['kategori'],
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),

                      onPressed: () async {

                        if (data['link_sumber'] !=
                                null &&
                            data['link_sumber']
                                .toString()
                                .isNotEmpty) {

                          await bukaLink(
                            data['link_sumber'],
                          );
                        }
                      },

                      icon: const Icon(
                        Icons.open_in_new,
                        color: Colors.white,
                      ),

                      label: const Text(

                        "Buka Sumber Asli",

                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}