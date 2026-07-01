import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:yomans_konseling/providers/ulasan_provider.dart';

class TambahUlasanPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const TambahUlasanPage({
    super.key,
    required this.booking,
  });

  @override
  State<TambahUlasanPage> createState() =>
      _TambahUlasanPageState();
}

class _TambahUlasanPageState
    extends State<TambahUlasanPage> {

  final TextEditingController komentarC =
      TextEditingController();

  int rating = 5;

  bool loading = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color(0xff2D6A4F),
        foregroundColor: Colors.white,
        title: const Text("Beri Ulasan"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 10),

            const Center(
              child: Icon(
                Icons.rate_review,
                size: 80,
                color: Color(0xff2D6A4F),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                widget.booking["nama_dokter"] ?? "",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 5),

Center(
  child: Text(
    widget.booking["tags"]?.toString() ?? "",
    style: const TextStyle(
      color: Colors.grey,
    ),
  ),
),

            const SizedBox(height: 35),

            const Text(
              "Berikan Rating",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: Row(

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: List.generate(
                  5,
                  (index) {

                    return IconButton(

                      iconSize: 42,

                      onPressed: () {

                        setState(() {
                          rating = index + 1;
                        });

                      },

                      icon: Icon(

                        index < rating
                            ? Icons.star
                            : Icons.star_border,

                        color: Colors.amber,

                      ),

                    );

                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Komentar",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 12),

            TextField(

              controller: komentarC,

              maxLines: 6,

              decoration: InputDecoration(

                hintText:
                    "Tuliskan pengalaman konsultasi Anda...",

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),

              ),

            ),

            const SizedBox(height: 35),
                        SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2D6A4F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),

                onPressed: loading
                    ? null
                    : () async {

                        if (komentarC.text.trim().isEmpty) {

                          ScaffoldMessenger.of(context)
                              .showSnackBar(

                            const SnackBar(
                              content: Text(
                                "Komentar tidak boleh kosong.",
                              ),
                            ),

                          );

                          return;
                        }

                        setState(() {
                          loading = true;
                        });

                        final provider =
                            Provider.of<UlasanProvider>(
                          context,
                          listen: false,
                        );

                        print("=========== DATA BOOKING ===========");
print(widget.booking);
print("booking id   = ${widget.booking["id"]}");
print("user id      = ${widget.booking["user_id"]}");
print("dokter id    = ${widget.booking["dokter_id"]}");
print("rating       = $rating");
print("komentar     = ${komentarC.text}");

                        final berhasil =
                            await provider.tambahUlasan(

                          bookingId:
                              widget.booking["id"],

                          dokterId:
                              widget.booking["dokter_id"],

                          userId:
                              widget.booking["user_id"],

                          rating: rating,

                          komentar:
                              komentarC.text.trim(),

                        );

                        setState(() {
                          loading = false;
                        });

                        if (!mounted) return;

                        if (berhasil) {

                          showDialog(

                            context: context,

                            barrierDismissible: false,

                            builder: (_) {

                              return AlertDialog(

                                title: const Text(
                                  "Berhasil",
                                ),

                                content: const Text(
                                  "Terima kasih telah memberikan ulasan.",
                                ),

                                actions: [

                                  ElevatedButton(

                                    onPressed: () {

                                      Navigator.pop(context);

                                      Navigator.pop(
                                        context,
                                        true,
                                      );

                                    },

                                    child: const Text(
                                      "OK",
                                    ),

                                  )

                                ],

                              );

                            },

                          );

                        } else {

                          ScaffoldMessenger.of(context)
                              .showSnackBar(

                            const SnackBar(

                              backgroundColor:
                                  Colors.red,

                              content: Text(
                                "Gagal mengirim ulasan.",
                              ),

                            ),

                          );

                        }

                      },

                icon: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),

                label: Text(

                  loading
                      ? "Mengirim..."
                      : "Kirim Ulasan",

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),

                ),

              ),
            ),

            const SizedBox(height: 30),
                      ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    komentarC.dispose();
    super.dispose();
  }
}