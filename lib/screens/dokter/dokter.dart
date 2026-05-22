import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DokterPage extends StatefulWidget {
  @override
  _DokterPageState createState() => _DokterPageState();
}

class _DokterPageState extends State<DokterPage> {
  List data = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final res = await ApiService.getDokter();
    setState(() => data = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dokter")),
      body: ListView(
        children: data.map((d) => ListTile(
          title: Text(d['nama']),
          subtitle: Text(d['spesialis']),
        )).toList(),
      ),
    );
  }
}