import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EdukasiPage extends StatefulWidget {
  @override
  _EdukasiPageState createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  List data = [];

  @override
  void initState() {
    super.initState();
    loadData(); // 🔥 dipanggil di sini
  }

  // 🔥 DI SINI LETAK KODENYA
  void loadData() async {
    final res = await ApiService.getEdukasi();
    setState(() {
      data = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edukasi")),
      body: data.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) {
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(data[i]['judul']),
                    subtitle: Text(data[i]['isi']),
                  ),
                );
              },
            ),
    );
  }
}