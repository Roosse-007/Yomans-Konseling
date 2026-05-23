import 'package:flutter/material.dart';

class HistoryBookingPage extends StatefulWidget {
  const HistoryBookingPage({super.key});

  @override
  State<HistoryBookingPage> createState() =>
      _HistoryBookingPageState();
}

class _HistoryBookingPageState
    extends State<HistoryBookingPage> {

 final List<Map<String, dynamic>> bookingHistory = [

  {
    "doctor": "Ira Febriana M.Psi",
    "category": "percintaan",
    "date": "20 Mei 2026",
    "time": "13:00 WIB",
    "status": "Sesi Berakhir",
    "reviewed": false,
    "rating": 0,
    "comment": "",
    "image": "lib/assets/ira1.png",
  },

  {
    "doctor": "Lil Roosse K.",
    "category": "Kecemasan",
    "date": "25 Mei 2026",
    "time": "15:00 WIB",
    "status": "Menunggu Jadwal",
    "reviewed": false,
    "rating": 0,
    "comment": "",
    "image": "lib/assets/gue1.png",
  },

  {
    "doctor": "Teguh B.K, M.Psi",
    "category": "keluarga",
    "date": "23 Mei 2026",
    "time": "09:00 WIB",
    "status": "Sedang Berlangsung",
    "reviewed": false,
    "rating": 0,
    "comment": "",
    "image": "lib/assets/teguh.png",
  },
  ];

  Color statusColor(String status) {
    switch (status) {
      case "Sesi Berakhir":
        return Colors.green;

      case "Menunggu Jadwal":
        return Colors.orange;

      case "Sedang Berlangsung":
        return Colors.blue;

      case "Dibatalkan":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  void showReviewDialog(int index) {

    int selectedStar = 5;

    TextEditingController commentController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20),
              ),

              title: const Text(
                "Beri Ulasan Dokter",
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Text(
                    bookingHistory[index]["doctor"],
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (starIndex) {
                        return IconButton(
                          onPressed: () {
                            setDialogState(() {
                              selectedStar =
                                  starIndex + 1;
                            });
                          },

                          icon: Icon(
                            Icons.star,
                            color: starIndex <
                                    selectedStar
                                ? Colors.amber
                                : Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller:
                        commentController,
                    maxLines: 3,
                    decoration:
                        InputDecoration(
                      hintText:
                          "Tulis ulasan...",
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                15),
                      ),
                    ),
                  ),
                ],
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Batal",
                  ),
                ),

                ElevatedButton(
                  onPressed: () {

                    setState(() {

                      bookingHistory[index]
                          ["reviewed"] = true;

                      bookingHistory[index]
                          ["rating"] =
                          selectedStar;

                      bookingHistory[index]
                          ["comment"] =
                          commentController.text;
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Ulasan berhasil dikirim",
                        ),
                      ),
                    );
                  },

                  child: const Text(
                    "Kirim",
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  void cancelBooking(int index) {

    showDialog(
      context: context,
      builder: (_) {

        return AlertDialog(
          title: const Text(
            "Batalkan Booking",
          ),

          content: const Text(
            "Apakah kamu yakin ingin membatalkan booking ini?",
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Tidak",
              ),
            ),

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),

              onPressed: () {

                setState(() {
                  bookingHistory[index]
                      ["status"] =
                      "Dibatalkan";
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(
                        context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Booking berhasil dibatalkan",
                    ),
                  ),
                );
              },

              child: const Text(
                "Ya, Batalkan",
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xffF5F5F5),

      appBar: AppBar(
  backgroundColor: const Color(0xFF1F5F33), // hijau seperti foto
  elevation: 0,
  centerTitle: true,

  title: const Text(
    "History Booking",
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w900, // tebal seperti foto
      color: Colors.white,
      letterSpacing: 0.3,
    ),
  ),
),

      body: ListView.builder(
        padding:
            const EdgeInsets.all(16),
        itemCount:
            bookingHistory.length,

        itemBuilder: (context, index) {

          final item =
              bookingHistory[index];

          return Container(
            margin:
                const EdgeInsets.only(
                    bottom: 18),

            padding:
                const EdgeInsets.all(
                    16),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(
                      20),

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),

            child: Column(
              children: [

                Row(
                  children: [

                   CircleAvatar(
                   radius: 35,
                   backgroundImage: AssetImage(
                   item["image"],
                    ),
                    ),

                    const SizedBox(
                        width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Text(
                            item["doctor"],
                            style:
                                const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                              height: 4),

                          Text(
                            item["category"],
                            style:
                                const TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),

                          const SizedBox(
                              height: 8),

                          Text(
                            "Tanggal: ${item["date"]}",
                          ),

                          Text(
                            "Jam: ${item["time"]}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 16),

                Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets
                          .all(12),

                  decoration:
                      BoxDecoration(
                    color: statusColor(
                            item[
                                "status"])
                        .withOpacity(
                            0.1),

                    borderRadius:
                        BorderRadius
                            .circular(15),
                  ),

                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [

                          Text(
                            item["status"],
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color:
                                  statusColor(
                                item[
                                    "status"],
                              ),
                            ),
                          ),

                          Row(
                            children: [

                              if (item["status"] ==
                                      "Sesi Berakhir" &&
                                  item[
                                          "reviewed"] ==
                                      false)

                                ElevatedButton(
                                  onPressed: () {
                                    showReviewDialog(
                                        index);
                                  },

                                  child:
                                      const Text(
                                    "Beri Ulasan",
                                  ),
                                ),

                              if (item["status"] ==
                                  "Menunggu Jadwal")

                                ElevatedButton(
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.red,
                                  ),

                                  onPressed:
                                      () {
                                    cancelBooking(
                                        index);
                                  },

                                  child:
                                      const Text(
                                    "Batalkan",
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      if (item[
                              "reviewed"] ==
                          true) ...[

                        const Divider(),

                        Row(
                          children:
                              List.generate(
                            item["rating"],
                            (index) =>
                                const Icon(
                              Icons.star,
                              color: Colors
                                  .amber,
                              size: 20,
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 8),

                        Align(
                          alignment:
                              Alignment
                                  .centerLeft,

                          child: Text(
                            item["comment"],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}