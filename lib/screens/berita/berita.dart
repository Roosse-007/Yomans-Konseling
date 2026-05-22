import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BeritaPage extends StatefulWidget {
  @override
  _BeritaPageState createState() => _BeritaPageState();
}

class _BeritaPageState extends State<BeritaPage> {
  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final res = await ApiService.getBerita();

    setState(() {
      data = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Berita")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? Center(child: Text("Belum ada berita"))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data[i]['judul'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(data[i]['isi']),
                            SizedBox(height: 5),
                            Text(
                              data[i]['tanggal'] ?? '',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}