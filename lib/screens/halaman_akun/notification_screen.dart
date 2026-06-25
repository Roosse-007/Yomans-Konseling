import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yomans_konseling/providers/auth_provider.dart';
// Sesuaikan dengan lokasi auth_provider Anda

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const Color primaryGreen = Color(0xFF006622); // Disamakan dengan warna hijau edit profile & ubah password
  static const Color inputBg = Color(0xFFF5F6F8);

  bool _appNotification = true;
  bool _emailNotification = false;
  bool _promoNotification = true;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Memuat preferensi awal yang tersimpan dari database user lewat Provider
    if (_isInit) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        setState(() {
          // MySQL mengembalikan int (1 atau 0) atau bool tergantung driver python-nya
          _appNotification = (user?['push_notifications'] == 1 || user?['push_notifications'] == true);
          _emailNotification = (user?['email_notifications'] == 1 || user?['email_notifications'] == true);
          _promoNotification = (user?['promo_notifications'] == 1 || user?['promo_notifications'] == true);
          _isInit = false;
        });
      }
    }
  }

  // MENGIRIM PERUBAHAN SECARA REAL-TIME KE DATABASE LEWAT PROVIDER API
  Future<void> _syncNotification(String type, bool value) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Siapkan nilai yang akan dikirim berdasarkan switch yang diganti
    bool currentPush = type == 'push' ? value : _appNotification;
    bool currentEmail = type == 'email' ? value : _emailNotification;
    bool currentPromo = type == 'promo' ? value : _promoNotification;

    bool isSaved = await authProvider.updateNotificationApi(
      pushNotif: currentPush,
      emailNotif: currentEmail,
      promoNotif: currentPromo,
    );

    if (!isSaved && mounted) {
      // Jika gagal menyimpan ke database server, kembalikan posisi switch awal dan tampilkan pemberitahuan
      setState(() {
        if (type == 'push') _appNotification = !value;
        if (type == 'email') _emailNotification = !value;
        if (type == 'promo') _promoNotification = !value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyinkronkan pengaturan ke server'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        children: [
          _buildSwitchTile(
            title: 'Push Notifications',
            subtitle: 'Dapatkan pemberitahuan langsung di perangkat Anda.',
            value: _appNotification,
            onChanged: (val) {
              setState(() => _appNotification = val);
              _syncNotification('push', val);
            },
          ),
          _buildSwitchTile(
            title: 'Email Notifications',
            subtitle: 'Terima laporan transaksi dan info akun via email.',
            value: _emailNotification,
            onChanged: (val) {
              setState(() => _emailNotification = val);
              _syncNotification('email', val);
            },
          ),
          _buildSwitchTile(
            title: 'Promotions & Updates',
            subtitle: 'Info diskon menarik dan info fitur konseling terbaru.',
            value: _promoNotification,
            onChanged: (val) {
              setState(() => _promoNotification = val);
              _syncNotification('promo', val);
            },
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
        color: inputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        activeColor: primaryGreen,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1A1A)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle, 
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}