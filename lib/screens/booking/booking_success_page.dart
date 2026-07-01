import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yomans_konseling/providers/booking_provider.dart';
import 'package:yomans_konseling/screens/booking/tambah_ulasan_page.dart';
import 'package:yomans_konseling/screens/home/home.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingSuccessPage extends StatefulWidget {
  final int bookingId;

  const BookingSuccessPage({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingSuccessPage> createState() =>
      _BookingSuccessPageState();
}

class _BookingSuccessPageState

    extends State<BookingSuccessPage> {

  late BookingProvider provider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      provider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );

      await provider.getDetailBooking(widget.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color(0xff2D6A4F),
        title: const Text(
          "Detail Booking",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {

          if (provider.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.booking == null) {
            return const Center(
              child: Text("Data booking tidak ditemukan"),
            );
          }

          final booking = provider.booking!;
          debugPrint("STATUS = ${booking["status"]}");
debugPrint("REVIEWED = ${booking["reviewed"]}");

        return SingleChildScrollView(
  padding: const EdgeInsets.all(18),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      // =========================
      // STATUS
      // =========================
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: booking["status"] == "Lunas"
              ? const Color(0xffEAF8EC)
              : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Icon(
              booking["status"] == "Lunas"
                  ? Icons.check_circle
                  : Icons.schedule,
              color: booking["status"] == "Lunas"
                  ? Colors.green
                  : Colors.orange,
              size: 40,
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    booking["status"] == "Lunas"
                        ? "Booking Anda Telah Dijadwalkan"
                        : "Booking Sedang Diproses",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(

                    booking["status"] == "Lunas"

                        ? "Silakan hadir sesuai jadwal konsultasi."

                        : booking["status"] == "waiting_verification"

                            ? "Pembayaran sedang diverifikasi Admin."

                            : "Silakan selesaikan pembayaran.",

                  ),

                ],
              ),
            )

          ],
        ),
      ),

      const SizedBox(height: 25),

      const Text(
        "Psikolog",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),

      const SizedBox(height: 12),

      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [

              CircleAvatar(
                radius: 35,
              backgroundImage: booking["image_url"] == null
    ? null
    : NetworkImage(
        booking["image_url"],
      ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      booking["nama_dokter"]?? "-",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      booking["email"]?? "-",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                  ],
                ),
              )

            ],
          ),
        ),
      ),

      const SizedBox(height: 25),

      
      // ===========================
      // DETAIL BOOKING
      // ===========================
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [

  _buildItem(
    Icons.calendar_today,
    "Tanggal",
    booking["tanggal"] ?? "-",
  ),

  const Divider(),

  _buildItem(
    Icons.access_time,
    "Jam",
    booking["jam"] ?? "-",
  ),

  const Divider(),

  _buildItem(
    Icons.timer,
    "Durasi",
    booking["duration"] ?? "-",
  ),

  const Divider(),

  _buildItem(
    Icons.payments,
    "Total Pembayaran",
    "Rp ${booking["total_price"]}",
  ),

  const Divider(),

  _buildItem(
    Icons.account_balance,
    "Metode",
    booking["metode"]?.toUpperCase() ?? "-",
  ),

],
          ),
        ),
      ),

      const SizedBox(height: 30),

     SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton.icon(
    onPressed: booking["status"] != "Lunas"
        ? null
        : () async {

            final konfirmasi = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Selesaikan Konseling"),
                content: const Text(
                  "Apakah sesi konseling telah selesai?",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text("Batal"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2D6A4F),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text(
                      "Selesai",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );

            if (konfirmasi != true) return;

            try {

              final response = await http.put(
                Uri.parse(
                  "http://127.0.0.1:5000/api/booking/${widget.bookingId}/finish",
                ),
              );

              final result = jsonDecode(response.body);

              if (response.statusCode == 200 &&
                  result["status"] == "success") {

                await provider.getDetailBooking(
                  widget.bookingId,
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      "Konseling berhasil diselesaikan.",
                    ),
                  ),
                );

              } else {

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      result["message"] ?? "Terjadi kesalahan",
                    ),
                  ),
                );

              }

            } catch (e) {

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(e.toString()),
                ),
              );

            }

          },
    icon: const Icon(Icons.check_circle),
    label: Text(
      booking["status"] == "Selesai"
          ? "Konseling Selesai"
          : "Selesaikan Konseling",
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff2D6A4F),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  ),
),

      const SizedBox(height: 15),

SizedBox(
  width: double.infinity,
  height: 50,
  child: OutlinedButton.icon(

    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xff2D6A4F),
      side: const BorderSide(
        color: Color(0xff2D6A4F),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),

    onPressed: booking["status"] != "Selesai"
        ? null
        : booking["reviewed"] == 1
            ? null
            : () async {

                final hasil =
                    await Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        TambahUlasanPage(
                      booking: booking,
                    ),

                  ),

                );

                if (hasil == true) {

                  await provider.getDetailBooking(
                    widget.bookingId,
                  );

                }

              },

    icon: Icon(

      booking["reviewed"] == 1
          ? Icons.check_circle
          : Icons.star,

    ),

    label: Text(

      booking["reviewed"] == 1

          ? "Sudah Memberikan Ulasan"

          : "Beri Ulasan",

    ),

  ),
),
const SizedBox(height: 25),
const SizedBox(height: 15),

SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2E6A3F),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    onPressed: () {

      Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (_) => HomePage(),
  ),
  (route) => false,
);

    },
    icon: const Icon(Icons.home),
    label: const Text(
      "Kembali ke Beranda",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
const Text(
  "Detail Pembayaran",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
  ),
  child: Padding(
    padding: const EdgeInsets.all(18),
    child: Column(
      children: [

        _buildItem(
          Icons.account_balance_wallet,
          "Metode",
          booking["metode"] ?? "-",
        ),

        const Divider(),

        _buildItem(
          Icons.payments,
          "Nominal",
          "Rp ${booking["nominal"] ?? booking["total_price"]}",
        ),

        const Divider(),

        _buildItem(
          Icons.verified,
          "Status Pembayaran",
          booking["pembayaran_status"] ?? "-",
        ),

      ],
    ),
  ),
),

const SizedBox(height: 25),
    ],
  ),
);

        },
      ),
    );
  }
  Widget _buildItem(
  IconData icon,
  String title,
  String value,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [

        Icon(
          icon,
          color: const Color(0xff2D6A4F),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

      ],
    ),
  );
}
}