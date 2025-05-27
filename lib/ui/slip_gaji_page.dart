import 'package:flutter/material.dart';
import '../widget/sidebar.dart';
import '../helpers/user_info.dart';

class SlipGajiPage extends StatefulWidget {
  const SlipGajiPage({super.key});

  @override
  State<SlipGajiPage> createState() => _SlipGajiPageState();
}

class _SlipGajiPageState extends State<SlipGajiPage> {
  final List<Map<String, dynamic>> dataKaryawan = [
    {'nama': 'Bahrudin', 'username': 'bahrudin', 'gaji': 5000000.0},
    {'nama': 'Cantika Ayu', 'username': 'cantika', 'gaji': 5200000.0},
    {'nama': 'Aditya S', 'username': 'aditya', 'gaji': 4800000.0},
    {'nama': 'Denis', 'username': 'denis', 'gaji': 5100000.0},
  ];

  List<Map<String, dynamic>> filteredData = [];

  @override
  void initState() {
    super.initState();
    filterData();
  }

  void filterData() {
    final isAdmin = UserInfo.role == 'admin';
final username = UserInfo.username;

print('Logged in as: $username, role: ${UserInfo.role}');

if (isAdmin) {
  filteredData = dataKaryawan;
} else {
  filteredData = dataKaryawan
      .where((k) => k['username'].toString().toLowerCase() == username?.toLowerCase())
      .toList();
}


    setState(() {}); // untuk rebuild UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      backgroundColor: const Color(0xFF1F2C2C),
      appBar: AppBar(
        title: const Text('Slip Gaji PT. Naga Hytam'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F2C2C),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: filteredData.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3 / 2,
          ),
          itemBuilder: (context, index) {
            final karyawan = filteredData[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle,
                      size: 40, color: Colors.white),
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
