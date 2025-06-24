import 'package:flutter/material.dart';
import 'ui/login.dart';
import '/ui/tambah_karyawan_page.dart'; // import halaman tambah karyawan
import 'ui/daftar_karyawan_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PT Naga Hytam Sejahtera Abadi',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),

      // 👇 ROUTES disiapkan di sini
      routes: {
        '/tambah-karyawan': (context) => const TambahKaryawanPage(),
         '/data-karyawan': (context) => const DaftarKaryawanPage(),
        // Tambahkan route lain di sini jika diperlukan
      },
    );
  }
}
