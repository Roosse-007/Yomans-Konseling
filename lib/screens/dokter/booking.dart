import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BookingPage extends StatelessWidget {
  final keluhan = TextEditingController();

  void submit() async {
    await ApiService.booking({
      "keluhan": keluhan.text,
      "user_id": 1,
      "dokter_id": 1
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking")),
      body: Column(
        children: [
          TextField(controller: keluhan),
          ElevatedButton(onPressed: submit, child: Text("Kirim"))
        ],
      ),
    );
  }
}