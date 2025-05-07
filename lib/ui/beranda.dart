import 'package:flutter/material.dart';
import '../widget/sidebar.dart';

class Beranda extends StatelessWidget {
  const Beranda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Beranda")),
      drawer: const Sidebar(), // Tambahkan drawer jika Sidebar digunakan
      body: const Center(
        child: Text("Selamat Datang"),
      ),
    );
  }
}
