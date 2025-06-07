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
    {'nama': 'Cantika Ayu', 'username': 'Cantika Ayu', 'gaji': 5200000.0},
    {'nama': 'Aditya S', 'username': 'Aditiya S', 'gaji': 4800000.0},
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
          .where((k) =>
              k['username'].toString().toLowerCase() ==
              username?.toLowerCase())
          .toList();
    }

    setState(() {});
  }

  Widget buildSlipCard(Map<String, dynamic> karyawan) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 200,
        maxWidth: 250,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Tinggi mengikuti isi
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 40, color: Colors.white),
          const SizedBox(height: 8),
          const Text(
            'Slip Gaji',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
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
            softWrap: true,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text(
          'Slip Gaji PT. Naga Hytam',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1F2C2C),
              Color(0xFF3A4A4A),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: filteredData.length == 1
            ? Center(
                child: SizedBox(
                  width: 250,
                  child: buildSlipCard(filteredData[0]),
                ),
              )
            : GridView.builder(
                itemCount: filteredData.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  return buildSlipCard(filteredData[index]);
                },
              ),
      ),
    );
  }
}
