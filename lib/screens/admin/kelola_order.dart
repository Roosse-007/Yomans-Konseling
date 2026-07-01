import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_order_provider.dart';

class KelolaOrderPage extends StatefulWidget {
  const KelolaOrderPage({super.key});

  @override
  State<KelolaOrderPage> createState() => _KelolaOrderPageState();
}

class _KelolaOrderPageState extends State<KelolaOrderPage> {

  final String baseUrl = "http://127.0.0.1:5000/api";

  bool loading = true;

  List orders = [];

  List filteredOrders = [];

  final TextEditingController searchController =
      TextEditingController();

  String statusFilter = "Semua";

  final Color primaryGreen =
      const Color(0xff2E6B33);

  final Color lightGreen =
      const Color(0xffEEF7EC);

  @override
  void initState() {
    super.initState();

    getOrders();

    searchController.addListener(() {
      filterData();
    });
  }

Future<void> getOrders() async {

  try {

    final response = await http.get(
      Uri.parse("$baseUrl/admin/orders"),
    );

    final json = jsonDecode(response.body);

    if (json["status"] == "success") {

orders = json["data"];

for (var item in orders) {
  print("USER : ${item["user"]["nama"]}");
  print("EMAIL : ${item["user"]["email"]}");
  print("DOKTER : ${item["dokter"]["nama"]}");
}

filterData();

    }

  } catch (e) {

    debugPrint(e.toString());

  } finally {

    if (mounted) {

      setState(() {

        loading = false;

      });

    }

  }

}

  void filterData() {
  final keyword = searchController.text.toLowerCase().trim();

  print("Keyword = $keyword");

  setState(() {
    filteredOrders = orders.where((item) {
final namaUser =
    (item["user"]["nama"] ?? "")
        .toString()
        .toLowerCase();

final namaDokter =
    (item["dokter"]["nama"] ?? "")
        .toString()
        .toLowerCase();

      print("Cek: $namaUser | $namaDokter");

      final status =
          (item["booking_status"] ?? "").toString();

      bool cocokStatus = true;

      if (statusFilter != "Semua") {
        cocokStatus = status == statusFilter;
      }

      bool cocokKeyword =
          keyword.isEmpty ||
          namaUser.contains(keyword) ||
          namaDokter.contains(keyword);

      return cocokStatus && cocokKeyword;
    }).toList();

    print("Jumlah hasil = ${filteredOrders.length}");
  });
}
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF5F7F5),

      appBar: AppBar(

        backgroundColor: primaryGreen,

        elevation: 0,

        centerTitle: true,

        title: const Text(

          "Kelola Order",

          style: TextStyle(

            color: Colors.white,

            fontWeight: FontWeight.bold,

          ),

        ),

      ),

      body: loading

          ? const Center(

              child:

                  CircularProgressIndicator(),

            )

          : Column(

              children: [

                const SizedBox(height: 15),

                Padding(

                  padding:

                      const EdgeInsets.symmetric(

                    horizontal: 18,

                  ),

                  child: TextField(
  controller: searchController,
  decoration: InputDecoration(
    hintText: "Cari User / Psikolog",
    prefixIcon: const Icon(Icons.search),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  ),
),

                ),

                const SizedBox(height: 15),
                                SizedBox(

                  height: 45,

                  child: ListView(

                    scrollDirection:

                        Axis.horizontal,

                    padding:
                        const EdgeInsets.symmetric(
                            horizontal: 15),

                    children: [

                      filterChip("Semua"),

                      filterChip(
                          "Menunggu Pembayaran"),

                      filterChip("Lunas"),

                      filterChip("Selesai"),

                    ],

                  ),

                ),

                const SizedBox(height: 10),

                Expanded(

                  child: filteredOrders.isEmpty

                      ? const Center(

                          child: Text(

                            "Belum ada data order",

                          ),

                        )

                      : ListView.builder(

                          itemCount:
                              filteredOrders.length,

                          padding:
                              const EdgeInsets.only(
                            bottom: 20,
                          ),

                          itemBuilder:

                              (context, index) {

                            final item =
                                filteredOrders[index];
                                                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),

                              child: Padding(
                                padding:
                                    const EdgeInsets.all(16),

                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [
                                    

                                    //------------------------------------------------
                                    // HEADER
                                    //------------------------------------------------

                                    Row(
                                      children: [

                                        Container(
                                          width: 45,
                                          height: 45,

                                          decoration: BoxDecoration(
                                            color: lightGreen,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),

                                          child: const Icon(
                                            Icons.receipt_long,
                                            color: Color(0xff2E6B33),
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                            children: [

                                              Text(
                                                "Booking #${item["booking_id"]}",

                                                style:
                                                    const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),

                                              const SizedBox(height: 3),

                                              Text(
                                                item["tanggal"]
                                                    .toString(),

                                                style:
                                                    const TextStyle(
                                                  color:
                                                      Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        statusBadge(
                                          item["booking_status"],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 18),

                                    const Divider(),

                                    

                                    //------------------------------------------------
                                    // USER
                                    //------------------------------------------------

                                    const Text(
                                      "DATA USER",

                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        color:
                                            Color(0xff2E6B33),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    Row(
                                      children: [

CircleAvatar(
  radius: 25,
  backgroundImage:
(item["user"]["foto"] != null &&
 item["user"]["foto"].toString().isNotEmpty)
    ? NetworkImage(item["user"]["foto"])
    : null,
  child:
(item["user"]["foto"] == null ||
 item["user"]["foto"].toString().isEmpty)
      ? const Icon(Icons.person)
      : null,
),

const SizedBox(width: 12),
                                        Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

Text(
  item["user"]["nama"]?.toString() ??
      "Nama tidak tersedia",
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  ),
),

Text(
  item["user"]["email"]?.toString() ?? "-",
),

    ],
  ),
),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    //------------------------------------------------
                                    // PSIKOLOG
                                    //------------------------------------------------

                                    const Text(
                                      "DATA PSIKOLOG",

                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        color:
                                            Color(0xff2E6B33),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    Row(
                                      children: [

                                    CircleAvatar(
  radius: 25,
  backgroundImage:
(item["dokter"]["foto"] != null &&
 item["dokter"]["foto"].toString().isNotEmpty)
    ? NetworkImage(item["dokter"]["foto"])
    : null,
  child:
(item["dokter"]["foto"] == null ||
 item["dokter"]["foto"].toString().isEmpty)
      ? const Icon(Icons.person)
      : null,
),

const SizedBox(width: 12),

                                        Expanded(
                                          child: Text(
  item["dokter"]["nama"] ??
      "Belum ada psikolog",
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  ),
),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),
                                                              //------------------------------------------
                                    // DETAIL PEMBAYARAN
                                    //------------------------------------------

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(15),

                                      decoration: BoxDecoration(
                                        color: lightGreen,
                                        borderRadius:
                                            BorderRadius.circular(15),
                                      ),

                                      child: Column(
                                        children: [

                                          infoRow(
                                            "Metode",
                                            item["payment"]["metode"],
                                          ),

                                          const SizedBox(height: 8),

                                          infoRow(
                                            "Nominal",
                                            "Rp ${item["payment"]["nominal"]}",
                                          ),

                                          const SizedBox(height: 8),

                                          infoRow(
                                            "Durasi",
                                            item["duration"],
                                          ),

                                          const Divider(height: 25),

                                          infoRow(
                                            "Total Bayar",
                                            "Rp ${item["total_price"]}",
                                            bold: true,
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    //------------------------------------------
                                    // BUKTI TRANSFER
                                    //------------------------------------------

                                    const Text(
                                      "BUKTI TRANSFER",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2E6B33),
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                  ClipRRect(
  borderRadius: BorderRadius.circular(15),
  child: Image.network(
  item["payment"] != null &&
          item["payment"]["bukti"] != null
      ? "http://127.0.0.1:5000/static/uploads/bukti_transfer/${item["payment"]["bukti"]}"
      : "https://via.placeholder.com/180",
  height: 180,
  width: double.infinity,
  fit: BoxFit.cover,
  errorBuilder: (_, __, ___) => Container(
    height: 180,
    color: Colors.grey.shade200,
    child: const Center(
      child: Icon(Icons.image_not_supported, size: 40),
    ),
  ),
),
),
                                    const SizedBox(height: 18),

                                    //------------------------------------------
                                    // BUTTON
                                    //------------------------------------------

                                    Row(
                                      children: [

                                        Expanded(
  child: OutlinedButton.icon(
    onPressed: () {
  print("=== TOMBOL LIHAT BUKTI DIKLIK ===");

  if (item["payment"] == null ||
      item["payment"]["bukti"] == null ||
      item["payment"]["bukti"].toString().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Bukti transfer belum tersedia"),
      ),
    );
    return;
  }

  final imageUrl =
      "http://127.0.0.1:5000/static/uploads/bukti_transfer/${item["payment"]["bukti"]}";

  print(imageUrl);

  lihatBukti(imageUrl);
  },
    icon: const Icon(Icons.image),
    label: const Text("Lihat Bukti"),
  ),
),

                                        const SizedBox(width: 12),

                                        Expanded(

                                          child: ElevatedButton.icon(

                                            style:
                                                ElevatedButton.styleFrom(

                                              backgroundColor:
                                                  primaryGreen,

                                              foregroundColor:
                                                  Colors.white,

                                            ),

                                            onPressed: () {

                                              konfirmasiPembayaran(
                                                item["booking_id"],
                                              );

                                            },

                                            icon: const Icon(
                                              Icons.check,
                                            ),

                                            label: const Text(
                                              "Konfirmasi",
                                            ),

                                          ),

                                        ),

                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    SizedBox(

                                      width: double.infinity,

                                      child: TextButton.icon(

  onPressed: () {

    tolakPembayaran(
      item["booking_id"],
    );

  },

  icon: const Icon(
    Icons.close,
    color: Colors.red,
  ),

  label: const Text(
    "Tolak Pembayaran",
    style: TextStyle(
      color: Colors.red,
    ),
  ),

),

                                    ),
                                                                      ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
  Widget statusBadge(String status) {
  Color bg = Colors.orange.shade100;
  Color fg = Colors.orange.shade800;

  if (status == "Lunas") {
    bg = Colors.green.shade100;
    fg = Colors.green.shade800;
  }
if(status=="Menunggu Pembayaran"){

bg=Colors.orange.shade100;

fg=Colors.orange.shade800;

}

  if (status == "Selesai") {
    bg = Colors.blue.shade100;
    fg = Colors.blue.shade800;
  }

  if (status == "Dibatalkan") {
    bg = Colors.red.shade100;
    fg = Colors.red.shade800;
  }

  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: fg,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}
Widget infoRow(
  String title,
  String value, {
  bool bold = false,
}) {
  return Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight:
              bold ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    ],
  );
}
Widget filterChip(String title) {
  final active = statusFilter == title;

  return Padding(
    padding: const EdgeInsets.only(right: 10),
    child: ChoiceChip(
      selected: active,
      label: Text(title),
      selectedColor: primaryGreen,
      labelStyle: TextStyle(
        color: active
            ? Colors.white
            : Colors.black87,
      ),
      onSelected: (_) {
        setState(() {
          statusFilter = title;
        });

        filterData();
      },
    ),
  );
}



Future<void> tolakPembayaran(
  int bookingId,
) async {

  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(

      title: const Text(
        "Tolak Pembayaran",
      ),

      content: const Text(
        "Yakin ingin menolak pembayaran ini?",
      ),

      actions: [

        TextButton(

          onPressed: () {

            Navigator.pop(context,false);

          },

          child: const Text(
            "Batal",
          ),

        ),

        ElevatedButton(

          style: ElevatedButton.styleFrom(

            backgroundColor: Colors.red,

          ),

          onPressed: () {

            Navigator.pop(context,true);

          },

          child: const Text(

            "Tolak",

            style: TextStyle(
              color: Colors.white,
            ),

          ),

        ),

      ],

    ),

  );

  if(ok != true) return;

  try{

    final response = await http.put(

      Uri.parse(

        "$baseUrl/admin/orders/$bookingId/reject",

      ),

    );

    final json = jsonDecode(
      response.body,
    );

    if(json["status"]=="success"){

      if(!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          backgroundColor: Colors.orange,

          content: Text(
            "Pembayaran ditolak.",
          ),

        ),

      );

      getOrders();

    }

  }catch(e){

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text(
          e.toString(),
        ),

      ),

    );

  }

}

Future<void> konfirmasiPembayaran(int bookingId) async {

  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(

      title: const Text(
        "Konfirmasi Pembayaran",
      ),

      content: const Text(
        "Yakin ingin mengonfirmasi pembayaran ini?",
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
            backgroundColor: primaryGreen,
          ),

          onPressed: () {
            Navigator.pop(context, true);
          },

          child: const Text(
            "Konfirmasi",
            style: TextStyle(
              color: Colors.white,
            ),
          ),

        ),

      ],

    ),
  );

  if (ok != true) return;

  try {

    final response = await http.put(

      Uri.parse(
        "$baseUrl/admin/orders/$bookingId/confirm",
      ),

    );

    final json = jsonDecode(response.body);

    if (json["status"] == "success") {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          backgroundColor: Colors.green,

          content: Text(
            "Pembayaran berhasil dikonfirmasi.",
          ),

        ),

      );

      await getOrders();

      setState(() {});

    } else {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(
            json["message"] ?? "Gagal mengonfirmasi pembayaran",
          ),

        ),

      );

    }

  } catch (e) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(
        content: Text(
          e.toString(),
        ),
      ),

    );

  }

}

  void lihatBukti(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Bukti Transfer",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
  height: MediaQuery.of(context).size.height * 0.6,
  child: InteractiveViewer(
    child: Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return const Center(
          child: Text("Gambar tidak ditemukan"),
        );
      },
    ),
  ),
),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tutup"),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}