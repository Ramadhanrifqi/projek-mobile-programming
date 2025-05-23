import 'package:flutter/material.dart';
import '../widget/sidebar.dart';

class Beranda extends StatelessWidget {
  final String username;

  const Beranda({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Beranda")),
      drawer: const Sidebar(),
      body: Center(
        child: Text(
          "Selamat Datang $username",
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
