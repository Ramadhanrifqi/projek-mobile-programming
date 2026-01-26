import 'dart:ui';
import 'package:flutter/material.dart';
import '../model/user.dart';
import '../service/user_service.dart';
import 'edit_karyawan_page.dart';

class DaftarKaryawanPage extends StatefulWidget {
  const DaftarKaryawanPage({super.key});

  @override
  State<DaftarKaryawanPage> createState() => _DaftarKaryawanPageState();
}

class _DaftarKaryawanPageState extends State<DaftarKaryawanPage> {
  List<User> _allUsers = []; // Data asli dari server
  List<User> _filteredUsers = []; // Data hasil filter & search
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();

  // Variabel Filter Departemen
  String _selectedDept = "All"; 

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => _isLoading = true);
    final data = await UserService().getAllUsers();
    
    // 1. Filter hanya karyawan (bukan admin)
    List<User> filtered = data.where((u) => u.role?.toLowerCase() != 'admin').toList();

    // 2. Urutkan berdasarkan Abjad (A-Z)
    filtered.sort((a, b) => (a.name ?? "").toLowerCase().compareTo((b.name ?? "").toLowerCase()));

    setState(() {
      _allUsers = filtered;
      _applyFilters(); 
      _isLoading = false;
    });
  }

  // Fungsi Filter Terpadu (Nama + Departemen)
  void _applyFilters() {
    String keyword = _searchCtrl.text.toLowerCase();
    
    List<User> results = _allUsers.where((user) {
      final nameMatch = (user.name ?? "").toLowerCase().contains(keyword);
      final deptMatch = (_selectedDept == "All") || 
                        (user.department?.toLowerCase() == _selectedDept.toLowerCase());
      
      return nameMatch && deptMatch;
    }).toList();

    setState(() {
      _filteredUsers = results;
    });
  }

  // LOGIKA WARNA BERDASARKAN LEVEL
  Color _getLevelColor(String? level) {
    switch (level?.toLowerCase().trim()) {
      case 'lead':
        return Colors.amberAccent; // Emas
      case 'senior':
        return Colors.lightBlueAccent; // Biru
      case 'middle':
        return Colors.lightGreenAccent; // Hijau
      case 'junior':
        return Colors.orangeAccent; // Oranye
      default:
        return Colors.tealAccent; // Default
    }
  }

  // Widget Tombol Filter Departemen
  Widget _buildFilterButton(String label) {
    bool isSelected = _selectedDept == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDept = label;
          _applyFilters();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD1EBDB) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFFD1EBDB) : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF192524) : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- DIALOGS (Success, Reset, Hapus, Detail) ---

  void _showResultDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSuccess ? Colors.greenAccent : Colors.redAccent, width: 2),
        ),
        title: Center(
          child: Icon(isSuccess ? Icons.check_circle : Icons.error_outline,
              color: isSuccess ? Colors.greenAccent : Colors.redAccent, size: 50),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(color: isSuccess ? Colors.greenAccent : Colors.redAccent, 
                fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK", style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  void _konfirmasiResetPassword(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.orangeAccent, width: 2)),
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 50),
        title: const Text("Reset Password?", textAlign: TextAlign.center,
            style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text("Password ${user.name} akan direset menjadi 'nagahytam123'.",
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.white54))),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (user.id != null) {
                    bool success = await UserService().resetPassword(user.id!);
                    _showResultDialog(success ? "Berhasil" : "Gagal", 
                        success ? "Password ${user.name} telah direset" : "Gagal reset password", success);
                  }
                },
                child: const Text("Ya, Reset", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapus(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.redAccent, width: 2)),
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 50),
        title: const Text('Konfirmasi Hapus', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Yakin ingin menghapus karyawan ${user.name}?', 
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.white54))),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (user.id != null) {
                    await UserService().hapusUser(user.id!);
                    _showResultDialog("Dihapus", "Data ${user.name} telah dihapus", true);
                    fetchUsers();
                  }
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void tampilkanDetail(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25),
            side: const BorderSide(color: Color(0xFFD1EBDB), width: 1)),
        title: Column(
          children: [
            CircleAvatar(radius: 40, backgroundColor: const Color(0xFFD1EBDB),
              child: Text(user.name?.substring(0, 1).toUpperCase() ?? "U",
                style: const TextStyle(fontSize: 30, color: Color(0xFF192524), fontWeight: FontWeight.bold))),
            const SizedBox(height: 15),
            Text(user.name ?? "Tanpa Nama", textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(user.email, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(color: Colors.white24, thickness: 1),
                _buildDetailRow(Icons.business, "Departemen", user.department),
                _buildDetailRow(Icons.trending_up, "Level", user.level),
                _buildDetailRow(Icons.phone, "Telepon", user.phone),
                _buildDetailRow(Icons.home_work_outlined, "Alamat", user.alamat),
                _buildDetailRow(Icons.calendar_month, "Tanggal Masuk", user.joinDate),
                _buildDetailRow(Icons.work_outline, "Jenis Pekerjaan", user.jobType),
                _buildDetailRow(Icons.school_outlined, "Pendidikan", user.education),
                _buildDetailRow(Icons.psychology_outlined, "Keahlian", user.skills),
                _buildDetailRow(Icons.emoji_events_outlined, "Penghargaan", user.awards),
                _buildDetailRow(Icons.notes, "Bio", user.bio),
              ],
            ),
          ),
        ),
        actions: [
          Center(child: TextButton(onPressed: () => Navigator.pop(context), 
              child: const Text("TUTUP", style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFD1EBDB)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                Text(value ?? "-", style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Data Karyawan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF192524), Color(0xFF3C5759)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (value) => _applyFilters(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Cari nama karyawan...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFD1EBDB)),
                    filled: true, fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
              ),

              // --- FILTER DEPARTEMEN ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  children: ["All", "Produksi", "Operator", "Gudang", "HR"].map((d) => _buildFilterButton(d)).toList(),
                ),
              ),
              
              const SizedBox(height: 10),

              // --- LIST CONTENT ---
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD1EBDB)))
                    : RefreshIndicator(
                        onRefresh: fetchUsers,
                        child: _filteredUsers.isEmpty 
                        ? const Center(child: Text("Karyawan tidak ditemukan", style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return InkWell(
                              onTap: () => tampilkanDetail(user),
                              borderRadius: BorderRadius.circular(20),
                              child: _buildEmployeeCard(user),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(User user) {
    Color lvlColor = _getLevelColor(user.level);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: const Color(0xFFD1EBDB),
                  child: Text(user.name?.substring(0, 1).toUpperCase() ?? "U",
                    style: const TextStyle(color: Color(0xFF192524), fontWeight: FontWeight.bold))),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(user.name ?? "Tanpa Nama", overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                          const SizedBox(width: 8),
                          // LABEL LEVEL DENGAN WARNA BERBEDA
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: lvlColor.withOpacity(0.15), 
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: lvlColor.withOpacity(0.5), width: 0.5),
                            ),
                            child: Text(
                              user.level?.toUpperCase() ?? "-", 
                              style: TextStyle(color: lvlColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                      Text(user.department ?? "Belum Diatur", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                    ],
                  ),
                ),
                _buildActionButton(Icons.lock_reset, Colors.orangeAccent, () => _konfirmasiResetPassword(user)),
                const SizedBox(width: 8),
                _buildActionButton(Icons.edit_note, Colors.amber, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EditKaryawanPage(user: user))).then((_) => fetchUsers());
                }),
                const SizedBox(width: 8),
                _buildActionButton(Icons.delete_outline, Colors.redAccent, () => _konfirmasiHapus(user)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}