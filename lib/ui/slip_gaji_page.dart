import 'package:flutter/material.dart';

class SlipGajiPage extends StatelessWidget {
  final String namaKaryawan;
  final double gaji;

  const SlipGajiPage({
    super.key,
    this.namaKaryawan = 'John Doe',
    this.gaji = 5000000.0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Warna latar belakang lembut
      appBar: AppBar(
        title: const Text('Slip Gaji PT. Naga Hytam'),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade600,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Slip Gaji Karyawan PT. Naga Hytam',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: const [
                      Icon(Icons.person, color: Colors.indigo),
                      SizedBox(width: 10),
                      Text(
                        'Nama Karyawan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      namaKaryawan,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: const [
                      Icon(Icons.monetization_on, color: Colors.indigo),
                      SizedBox(width: 10),
                      Text(
                        'Gaji Bulanan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rp ${gaji.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
