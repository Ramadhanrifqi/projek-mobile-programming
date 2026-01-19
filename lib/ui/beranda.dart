import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/sidebar.dart';
import '../service/user_service.dart';
import '../model/user.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  User? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFullProfile();
  }

  Future<void> _loadFullProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String userEmail = prefs.getString('email') ?? '';

    try {
      List<User> users = await UserService().getAllUsers();
      setState(() {
        _userData = users.firstWhere((u) => u.email == userEmail);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal load profil: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text("DASHBOARD", style: TextStyle(color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD1EBDB)))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 20),
                    _buildStatsGrid(),
                    const SizedBox(height: 20),
                    _buildBiodataSection(),
                    const SizedBox(height: 20),
                    if (_userData?.role?.toLowerCase() == 'admin') _buildAdminActions(),
                    const SizedBox(height: 40),
                    const Text("© 2025 PT Naga Hytam Sejahtera Abadi", style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  // 1. Kartu Utama (Avatar & Nama)
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFD1EBDB),
            backgroundImage: AssetImage('assets/images/images/${_userData?.email ?? 'Foto.default'}.png'),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_userData?.name ?? "User", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(_userData?.role?.toUpperCase() ?? "-", style: const TextStyle(color: Color(0xFFD1EBDB), letterSpacing: 1.5, fontSize: 12)),
                const SizedBox(height: 10),
                Text(_userData?.email ?? "", style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Grid Statistik (Jatah Cuti & Department)
  Widget _buildStatsGrid() {
    return Row(
      children: [
        _statItem("Jatah Cuti", "${_userData?.jatahCuti ?? 0} Hari", Icons.event_available, Colors.orangeAccent),
        const SizedBox(width: 15),
        _statItem("Departemen", _userData?.department ?? "-", Icons.business_center, Colors.blueAccent),
      ],
    );
  }

  Widget _statItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // 3. Detail Biodata (Modern List)
  Widget _buildBiodataSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("INFORMASI BIODATA", style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(color: Colors.white10, height: 30),
          _infoRow(Icons.phone_android, "Telepon", _userData?.phone ?? "-"),
          _infoRow(Icons.school_outlined, "Pendidikan", _userData?.education ?? "-"),
          _infoRow(Icons.workspace_premium_outlined, "Skill", _userData?.skills ?? "-"),
          _infoRow(Icons.location_on_outlined, "Alamat", _userData?.alamat ?? "-"),
          _infoRow(Icons.calendar_month_outlined, "Bergabung", _userData?.joinDate ?? "-"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Tombol Admin (Floating Style)
  Widget _buildAdminActions() {
    return Column(
      children: [
        _adminButton("TAMBAH KARYAWAN", Icons.person_add_alt_1, Colors.teal, () => Navigator.pushNamed(context, '/tambah-karyawan')),
        const SizedBox(height: 12),
        _adminButton("DATA KARYAWAN", Icons.analytics_outlined, Colors.indigoAccent, () => Navigator.pushNamed(context, '/data-karyawan')),
      ],
    );
  }

  Widget _adminButton(String label, IconData icon, Color color, VoidCallback action) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: action,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
      ),
    );
  }
}