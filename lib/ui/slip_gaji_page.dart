import 'dart:ui';
import 'package:flutter/material.dart';
import '../model/user.dart';
import '../service/user_service.dart';
import '../widget/sidebar.dart';
import 'slip_gaji_detail_page.dart';

class SlipGajiPage extends StatefulWidget {
  const SlipGajiPage({super.key});

  @override
  State<SlipGajiPage> createState() => _SlipGajiPageState();
}

class _SlipGajiPageState extends State<SlipGajiPage> {
  List<User> _allKaryawan = []; // List data asli
  List<User> _filteredKaryawan = []; // List untuk pencarian
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKaryawan();
  }

  Future<void> _loadKaryawan() async {
    setState(() => _isLoading = true);
    final data = await UserService().getAllUsers();
    
    // 1. Filter hanya karyawan (bukan admin)
    List<User> kars = data.where((u) => u.role?.toLowerCase() != 'admin').toList();
    
    // 2. Urutkan berdasarkan Abjad (A-Z)
    kars.sort((a, b) => (a.name ?? "").toLowerCase().compareTo((b.name ?? "").toLowerCase()));

    setState(() {
      _allKaryawan = kars;
      _filteredKaryawan = kars;
      _isLoading = false;
    });
  }

  // 3. Fungsi Pencarian
  void _runFilter(String keyword) {
    List<User> results = [];
    if (keyword.isEmpty) {
      results = _allKaryawan;
    } else {
      results = _allKaryawan
          .where((user) =>
              (user.name ?? "").toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredKaryawan = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text("Pilih Karyawan", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0, centerTitle: true, 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF192524), Color(0xFF3C5759)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 4. Input Pencarian
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (value) => _runFilter(value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Cari nama karyawan...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFD1EBDB)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              
              // List Karyawan
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD1EBDB)))
                    : _filteredKaryawan.isEmpty
                        ? const Center(child: Text("Karyawan tidak ditemukan.", style: TextStyle(color: Colors.white60)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: _filteredKaryawan.length,
                            itemBuilder: (context, index) => _buildKaryawanCard(_filteredKaryawan[index]),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKaryawanCard(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFD1EBDB),
                child: Icon(Icons.person, color: Color(0xFF192524)),
              ),
              title: Text(user.name ?? "", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(user.email ?? "", 
                style: const TextStyle(color: Colors.white70)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SlipGajiDetailPage(user: user)));
              },
            ),
          ),
        ),
      ),
    );
  }
}