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
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => _isLoading = true);
    final data = await UserService().getAllUsers();
    // Memfilter agar admin tidak muncul di daftar karyawan
    final filtered = data.where((u) => u.role?.toLowerCase() != 'admin').toList();

    setState(() {
      _users = filtered;
      _isLoading = false;
    });
  }

  Future<void> deleteUser(String id) async {
    await UserService().hapusUser(id);
    fetchUsers(); 
  }

  // --- FUNGSI RESET PASSWORD ---
  void _konfirmasiResetPassword(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Reset Password?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          "Password ${user.name} akan direset menjadi 'nagahytam123'. Lanjutkan?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("BATAL", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
            onPressed: () async {
              Navigator.pop(context);
              if (user.id != null) {
                bool success = await UserService().resetPassword(user.id!);
                if (!mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Password ${user.name} berhasil direset!"), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gagal mereset password"), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            child: const Text("YA, RESET", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI POP-UP DETAIL LENGKAP ---
  void tampilkanDetail(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFD1EBDB),
              child: Text(
                user.name?.substring(0, 1).toUpperCase() ?? "U",
                style: const TextStyle(fontSize: 30, color: Color(0xFF192524), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              user.name ?? "Tanpa Nama",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user.email,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            ),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("TUTUP", style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold)),
          ),
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
                Text(value == null || value.isEmpty ? "-" : value, 
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
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
            colors: [Color(0xFF192524), Color(0xFF3C5759)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFD1EBDB)))
              : RefreshIndicator(
                  onRefresh: fetchUsers,
                  color: const Color(0xFFD1EBDB),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return InkWell(
                        onTap: () => tampilkanDetail(user),
                        borderRadius: BorderRadius.circular(20),
                        child: _buildEmployeeCard(user),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(User user) {
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
                CircleAvatar(
                  backgroundColor: const Color(0xFFD1EBDB),
                  child: Text(
                    user.name?.substring(0, 1).toUpperCase() ?? "U",
                    style: const TextStyle(color: Color(0xFF192524), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? "Nama Tidak Tersedia",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.department ?? "Departemen Belum Diatur",
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // --- TOMBOL AKSI ---
                _buildActionButton(Icons.lock_reset, Colors.orangeAccent, () => _konfirmasiResetPassword(user)),
                const SizedBox(width: 8),
                _buildActionButton(Icons.edit, Colors.amber, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditKaryawanPage(user: user)),
                  ).then((_) => fetchUsers());
                }),
                const SizedBox(width: 8),
                _buildActionButton(Icons.delete, Colors.redAccent, () => _konfirmasiHapus(user)),
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
        decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _konfirmasiHapus(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3C5759),
        title: const Text('Konfirmasi Hapus', style: TextStyle(color: Colors.white)),
        content: Text('Yakin ingin menghapus ${user.name}?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              if (user.id != null) {
                await deleteUser(user.id!);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil menghapus ${user.name}')));
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}