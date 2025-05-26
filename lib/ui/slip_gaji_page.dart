import 'package:flutter/material.dart';
import '../widget/sidebar.dart';

class SlipGajiPage extends StatelessWidget {
  const SlipGajiPage({super.key});

  final List<Map<String, dynamic>> dataKaryawan = const [
    {'nama': 'Bahrudin', 'gaji': 5000000.0},
    {'nama': 'Cantika Ayu', 'gaji': 5200000.0},
    {'nama': 'Aditya S', 'gaji': 4800000.0},
    {'nama': 'Denis', 'gaji': 5100000.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      backgroundColor: const Color(0xFF1F2C2C), // Warna dasar gelap sesuai gambar
      appBar: AppBar(
        title: const Text('Slip Gaji PT. Naga Hytam'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F2C2C),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: dataKaryawan.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3 / 2,
          ),
          itemBuilder: (context, index) {
            final karyawan = dataKaryawan[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1), // transparan seperti kartu di gambar
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle, size: 40, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Slip Gaji',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    karyawan['nama'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${karyawan['gaji'].toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
