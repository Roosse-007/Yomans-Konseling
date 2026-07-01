import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Base URL Backend Flask
const String baseUrl = "http://127.0.0.1:5000";


class PaymentDetailPage extends StatefulWidget {
  final int bookingId;
  final int jadwalId;

  const PaymentDetailPage({
    super.key,
    required this.bookingId,
    required this.jadwalId,
  });

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {

Color getStatusColor() {

  switch(payment!["status"]){

    case "pending":

      return Colors.orange;

    case "waiting_verification":

      return Colors.blue;

    case "success":

      return Colors.green;

    case "rejected":

      return Colors.red;

    default:

      return Colors.grey;

  }

}

IconData getStatusIcon(){

  switch(payment!["status"]){

    case "pending":

      return Icons.payment;

    case "waiting_verification":

      return Icons.access_time;

    case "success":

      return Icons.check_circle;

    case "rejected":

      return Icons.cancel;

    default:

      return Icons.info;

  }

}

String getStatusTitle(){

  switch(payment!["status"]){

    case "pending":

      return "Menunggu Pembayaran";

    case "waiting_verification":

      return "Menunggu Verifikasi Admin";

    case "success":

      return "Pembayaran Berhasil";

    case "rejected":

      return "Pembayaran Ditolak";

    default:

      return "-";

  }

}

String getStatusDescription(){

  switch(payment!["status"]){

    case "pending":

      return "Silakan upload bukti transfer.";

    case "waiting_verification":

      return "Bukti transfer sudah dikirim. Mohon tunggu admin melakukan verifikasi.";

    case "success":

      return "Pembayaran telah dikonfirmasi oleh admin. Booking sudah aktif.";

    case "rejected":

      return "Bukti transfer ditolak. Silakan upload bukti transfer yang benar.";

    default:

      return "";

  }

}
  bool loading = true;
  bool uploading = false;

  Map<String, dynamic>? payment;

  PlatformFile? selectedFile;

  Uint8List? fileBytes;

  final FilePicker _picker = FilePicker.platform;

      final NumberFormat rupiah = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

  @override
  void initState() {
    super.initState();
    getPayment();
  }

  Future<void> getPayment() async {

  try {

    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/payment/${widget.bookingId}",
      ),
    );

    final result = jsonDecode(response.body);

    if (!mounted) return;

    if (result["status"] == "success") {

      setState(() {

        payment = result["data"];

        loading = false;

      });

    } else {

      setState(() {

        loading = false;

      });

    }

  } catch (e) {

    debugPrint(e.toString());

    if (!mounted) return;

    setState(() {

      loading = false;

    });

  }

}

Future<void> uploadBukti() async {
  if (selectedFile == null || fileBytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Silakan pilih bukti transfer."),
      ),
    );
    return;
  }

  setState(() {
    uploading = true;
  });

  try {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/api/upload_bukti"),
    );

    request.fields["booking_id"] = widget.bookingId.toString();

    request.files.add(
      http.MultipartFile.fromBytes(
        "bukti",
        fileBytes!,
        filename: selectedFile!.name,
      ),
    );

    var response = await request.send();

    var body = await response.stream.bytesToString();

    var result = jsonDecode(body);

    if (!mounted) return;

    if (response.statusCode == 200 &&
        result["status"] == "success") {

          await http.put(
          Uri.parse(
            "$baseUrl/api/jadwal/${widget.jadwalId}/status",
          ),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "status": "booked",
          }),
        );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Text("Upload Berhasil"),
            ],
          ),
          content: const Text(
            "Bukti transfer berhasil dikirim.\n\n"
            "Admin akan melakukan verifikasi pembayaran. "
            "Status booking akan berubah menjadi Lunas setelah pembayaran dikonfirmasi.",
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E6B33),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);

                Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            result["message"] ?? "Upload gagal.",
          ),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Terjadi kesalahan:\n$e",
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        uploading = false;
      });
    }
  }
}

Future<void> pilihBukti() async {
  FilePickerResult? result = await _picker.pickFiles(
    type: FileType.image,
    withData: true,
  );

  if (result == null) return;

  final file = result.files.first;

  if (file.bytes == null) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("File tidak valid."),
      ),
    );
    return;
  }

  setState(() {
    selectedFile = file;
    fileBytes = file.bytes!;
  });
}

@override
Widget build(BuildContext context) {

  if (loading) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  if (payment == null) {
    return const Scaffold(
      body: Center(
        child: Text("Data pembayaran tidak ditemukan"),
      ),
    );
  }

  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF2E6B33),
      centerTitle: true,
      title: const Text(
        "Detail Pembayaran",
        style: TextStyle(color: Colors.white),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    payment!["metode"]
                        .toString()
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E6B33),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Total Pembayaran",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 5),

                   Text(
  rupiah.format(
    double.tryParse(payment!["nominal"].toString()) ?? 0,
  ),
  style: const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.orange,
  ),
),
                  const Divider(height: 35),

                  const Text(
                    "Nomor Rekening",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          payment!["nomor_rekening"],
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      IconButton(

                        icon: const Icon(
                          Icons.copy,
                          color: Color(0xFF2E6B33),
                        ),

                        onPressed: () {

                          Clipboard.setData(

                            ClipboardData(
                              text: payment!["nomor_rekening"],
                            ),

                          );

                          ScaffoldMessenger.of(context)
                              .showSnackBar(

                            const SnackBar(
                              content: Text(
                                "Nomor rekening berhasil disalin",
                              ),
                            ),

                          );

                        },

                      ),

                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Atas Nama",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    payment!["nama_pemilik"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Petunjuk Pembayaran",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text("1. Salin nomor rekening di atas."),
          const SizedBox(height: 5),
          const Text("2. Transfer sesuai nominal pembayaran."),
          const SizedBox(height: 5),
          const Text("3. Simpan bukti transfer."),
          const SizedBox(height: 5),
          const Text("4. Upload bukti transfer di bawah."),
          const SizedBox(height: 30),

          if (selectedFile != null) ...[

  Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: ListTile(
      leading: const Icon(
        Icons.image,
        color: Color(0xFF2E6B33),
        size: 40,
      ),
      title: Text(
        selectedFile!.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "${(selectedFile!.size / 1024).toStringAsFixed(2)} KB",
      ),
      trailing: const Icon(
        Icons.check_circle,
        color: Colors.green,
      ),
    ),
  ),

  const SizedBox(height: 20),

],

if (payment!["status"] == "pending" ||
    payment!["status"] == "rejected") ...[

  SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: pilihBukti,
      icon: const Icon(Icons.file_upload),
      label: const Text("Pilih Bukti Transfer"),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2E6B33),
        side: const BorderSide(
          color: Color(0xFF2E6B33),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ),

  const SizedBox(height: 20),

  SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton.icon(
      onPressed: uploading ? null : uploadBukti,
      icon: uploading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.cloud_upload),
      label: Text(
        uploading
            ? "Mengupload..."
            : "Upload Bukti Transfer",
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E6B33),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ),

  const SizedBox(height: 30),

],

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: getStatusColor().withOpacity(.15),
    borderRadius: BorderRadius.circular(15),
    border: Border.all(
      color: getStatusColor(),
    ),
  ),
  child: Row(
    children: [
      Icon(
        getStatusIcon(),
        color: getStatusColor(),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getStatusTitle(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: getStatusColor(),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              getStatusDescription(),
            ),
          ],
        ),
      ),
    ],
  ),
),

],
),
),
);
}
}