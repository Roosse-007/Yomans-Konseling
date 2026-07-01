import 'package:yomans_konseling/providers/admin_order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yomans_konseling/providers/booking_provider.dart';
import 'package:yomans_konseling/providers/ulasan_provider.dart';
import 'package:yomans_konseling/providers/favorit_provider.dart';

import 'providers/auth_provider.dart';
import 'providers/dokter_provider.dart';
import 'providers/user_provider.dart';
import 'providers/pembayaran_provider.dart';

import 'screens/auth/login.dart';
import 'screens/auth/splash_screen.dart'; // Pastikan path impor splash screen ini benar
import 'screens/home/home.dart';
import 'screens/admin/dashboard.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Menambahkan constructor const untuk performa lebih baik

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
  ChangeNotifierProvider(
    create: (_) => AuthProvider(),
  ),

  ChangeNotifierProvider(
    create: (_) => DokterProvider(),
  ),

  ChangeNotifierProvider(
    create: (_) => UserProvider(),
  ),

  ChangeNotifierProvider(
    create: (_) => PembayaranProvider(),
  ),


  ChangeNotifierProvider(
    create: (_) => UlasanProvider(),
  ),

  ChangeNotifierProvider(
    create: (_) => FavoritProvider(),
  ),
  ChangeNotifierProvider(
  create: (_) => AdminOrderProvider(),
),
ChangeNotifierProvider(
  create: (_) => BookingProvider(),
),
],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Yomans Konseling',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.white,
        ),
        
        // 🔥 Aplikasi pertama kali membuka SplashScreen
        home: const SplashScreen(), 

        routes: {
          '/login': (_) => LoginPage(),
          '/wrapper': (_) => AuthWrapper(), // Ditambahkan route ke wrapper setelah splash selesai
          '/home': (_) =>  HomePage(),
          '/admin': (_) => AdminDashboard(),
        },
      ),
    );
  }
}

// ================= AUTH WRAPPER =================
// Mengubah ke StatefulWidget agar bisa memicu validasi token saat pertama kali dibuka
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Opsional: Jika AuthProvider Anda memiliki fungsi cek login lokal (SharedPreferences/SecureStorage)
    // Anda bisa memanggilnya di sini secara asynchronous, contoh:
    // Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // ================= BELUM LOGIN =================
    if (!auth.isLogin) {
      return const LoginPage();
    }

    // ================= JIKA ADMIN =================
    if (auth.isAdmin) {
      return const AdminDashboard();
    }

    // ================= USER BIASA =================
    return  HomePage();
  }
}