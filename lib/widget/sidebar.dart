import 'package:flutter/material.dart';
import '../ui/beranda.dart';
import '../ui/login.dart'; // Pastikan nama file sesuai (LoginPage)
import '../ui/cuti_page.dart';
import '../helpers/user_info.dart';
import '../ui/slip_gaji_page.dart';
import '../ui/data_shift_page.dart';
import '../ui/changepasswordpage.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  // --- FUNGSI DIALOG KONFIRMASI KELUAR RATA TENGAH ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.orangeAccent, width: 2), // Border Oranye
        ),
        title: const Center(
          child: Icon(Icons.logout_rounded, color: Colors.orangeAccent, size: 50),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Konfirmasi Keluar",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "Apakah Anda yakin ingin keluar dari akun ini?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx), // Tutup dialog
                child: const Text("BATAL", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  // Logout dan hapus semua history halaman agar kembali ke Login
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text("KELUAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10), // Memberi sedikit ruang di bawah tombol
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserInfo.user;

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF192524), Color(0xFF3C5759)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Header Sidebar
            UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              decoration: const BoxDecoration(color: Colors.transparent),
              accountName: Text(
                user?.name ?? "Tidak diketahui",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEFECE9)),
              ),
              accountEmail: Text(
                user?.role ?? "",
                style: const TextStyle(color: Color(0xFFD0D5CE)),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: const Color(0xFFEFECE9),
                backgroundImage: AssetImage(
                  'assets/images/images/${user?.name?.isNotEmpty == true ? user!.name : 'Foto.default'}.png',
                ),
              ),
            ),

            // Konten Navigasi
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFEFECE9), // Latar belakang menu (Putih tulang)
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          _buildListTile(
                            context,
                            icon: Icons.home,
                            title: "Beranda",
                            destination: const Beranda(),
                          ),
                          _buildListTile(
                            context,
                            icon: Icons.calendar_today,
                            title: "Pengajuan Cuti",
                            destination: const CutiPage(),
                          ),
                          _buildListTile(
                            context,
                            icon: Icons.money,
                            title: "Slip Gaji",
                            destination: const SlipGajiPage(),
                          ),
                          _buildListTile(
                            context,
                            icon: Icons.calendar_month,
                            title: "Data Shift",
                            destination: const DataShiftPage(),
                          ),
                          _buildListTile(
                            context,
                            icon: Icons.lock_reset_rounded,
                            title: "Ganti Password",
                            destination: const ChangePasswordPage(),
                          ),
                          // --- MENU KELUAR ---
                          _buildListTile(
                            context,
                            icon: Icons.logout_rounded,
                            title: "Keluar",
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                    ),

                    // Footer Hak Cipta
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        "©2025 Naga Hytam Sejahtera Abadi\nAll Rights Reserved.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF3C5759),
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Pembuat ListTile Custom
  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? destination,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () {
            if (destination != null) {
              Navigator.pop(context); // Tutup Sidebar
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destination),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD1EBDB), // Background menu hijau pucat
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF192524).withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF192524)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF192524),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xFF3C5759),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}