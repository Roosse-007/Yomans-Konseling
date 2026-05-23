import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/dokter_provider.dart';
import 'providers/user_provider.dart'; //ni baru

import 'screens/auth/login.dart';
import 'screens/home/home.dart';
import 'screens/admin/dashboard.dart';

void main() {

  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {

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

      ],

      child: MaterialApp(

        debugShowCheckedModeBanner: false,

        title: 'Konseling App',

        // ================= AUTO LOGIN =================
        home: AuthWrapper(),

        routes: {

          '/login': (_) => LoginPage(),

          '/home': (_) => HomePage(),

          '/admin': (_) => AdminDashboard(),

        },
      ),
    );
  }
}

// ================= AUTH WRAPPER =================
class AuthWrapper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final auth =
        Provider.of<AuthProvider>(context);

    // ================= BELUM LOGIN =================
    if (!auth.isLogin) {

      return LoginPage();
    }

    // ================= JIKA ADMIN =================
    if (auth.isAdmin) {

      return AdminDashboard();
    }

    // ================= USER BIASA =================
    return HomePage();
  }
}