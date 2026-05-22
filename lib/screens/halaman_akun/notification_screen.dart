import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const Color primaryTeal = Color(0xFF318F95);

  // State untuk menyimpan kondisi tombol toggle ON/OFF
  bool _appNotification = true;
  bool _emailNotification = false;
  bool _promoNotification = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: primaryTeal,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
            ),
          ),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        children: [
          _buildSwitchTile(
            title: 'Push Notifications',
            subtitle: 'Dapatkan pemberitahuan langsung di perangkat Anda.',
            value: _appNotification,
            onChanged: (val) => setState(() => _appNotification = val),
          ),
          _buildSwitchTile(
            title: 'Email Notifications',
            subtitle: 'Terima laporan transaksi dan info akun via email.',
            value: _emailNotification,
            onChanged: (val) => setState(() => _emailNotification = val),
          ),
          _buildSwitchTile(
            title: 'Promotions & Updates',
            subtitle: 'Info diskon menarik dan info fitur konseling terbaru.',
            value: _promoNotification,
            onChanged: (val) => setState(() => _promoNotification = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SwitchListTile(
        activeColor: primaryTeal,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}