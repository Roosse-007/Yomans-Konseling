import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class AdminDashboard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final isAdmin =
        Provider.of<AuthProvider>(context).isAdmin;

    // ================= CEK ROLE =================
    if (!isAdmin) {

      return Scaffold(
        body: Center(
          child: Text(
            "Akses ditolak",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      );
    }

    // ================= DASHBOARD ADMIN =================
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Admin"),
      ),

      body: Center(
        child: Text("Selamat datang Admin"),
      ),
    );
  }
}