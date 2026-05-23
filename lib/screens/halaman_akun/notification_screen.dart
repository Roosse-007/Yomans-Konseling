import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // SINKRONISASI TEMA WARNA UTAMA MENJADI HIJAU
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color inputBg = Color(0xFFF5F6F8);

  // State untuk menyimpan kondisi tombol toggle ON/OFF
  bool _appNotification = true;
  bool _emailNotification = false;
  bool _promoNotification = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  // MENGAMBIL DATA SETTING YANG TERSIMPAN DI PENYIMPANAN LOKAL HP
  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _appNotification = prefs.getBool('push_notifications') ?? true;
        _emailNotification = prefs.getBool('email_notifications') ?? false;
        _promoNotification = prefs.getBool('promo_notifications') ?? true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal memuat pengaturan notifikasi: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // MENYIMPAN PERUBAHAN SETTING SECARA REAL-TIME KE LOKAL HP
  Future<void> _updateSetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint("Gagal menyimpan pengaturan $key: $e");
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 25,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              children: [
                _buildSwitchTile(
                  title: 'Push Notifications',
                  subtitle: 'Dapatkan pemberitahuan langsung di perangkat Anda.',
                  value: _appNotification,
                  onChanged: (val) {
                    setState(() => _appNotification = val);
                    _updateSetting('push_notifications', val);
                  },
                ),
                _buildSwitchTile(
                  title: 'Email Notifications',
                  subtitle: 'Terima laporan transaksi dan info akun via email.',
                  value: _emailNotification,
                  onChanged: (val) {
                    setState(() => _emailNotification = val);
                    _updateSetting('email_notifications', val);
                  },
                ),
                _buildSwitchTile(
                  title: 'Promotions & Updates',
                  subtitle: 'Info diskon menarik dan info fitur konseling terbaru.',
                  value: _promoNotification,
                  onChanged: (val) {
                    setState(() => _promoNotification = val);
                    _updateSetting('promo_notifications', val);
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
        borderRadius: BorderRadius.circular(12), // Mengikuti radius form input edit profile
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