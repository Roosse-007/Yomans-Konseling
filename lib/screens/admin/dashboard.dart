import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: ListView(
        children: [
          ListTile(title: Text("Kelola Edukasi")),
          ListTile(title: Text("Kelola Berita")),
          ListTile(title: Text("Kelola Dokter")),
        ],
      ),
    );
  }
}