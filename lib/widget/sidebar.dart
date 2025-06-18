import 'package:flutter/material.dart';
import '../ui/beranda.dart';
import '../ui/login.dart';
import '../ui/cuti_page.dart';
import '../helpers/user_info.dart';
import '../ui/slip_gaji_page.dart';
import '../ui/data_shift_page.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserInfo.user;

// Logika pemilihan gambar profil
final String photoPath = (user?.id == 1 || user?.username == 'admin1')
    ? 'assets/images/images/martin.png'
    : (user?.id == 4 || user?.username == 'Cantika Ayu')
        ? 'assets/images/images/cantika.jpg'
        : 'assets/images/images/profil_operator.jpg';


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
            // Header bagian atas dengan informasi akun
            UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              accountName: Text(
                user?.username ?? "Tidak diketahui",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEFECE9),
                ),
              ),
              accountEmail: Text(
                user?.role ?? "",
                style: const TextStyle(color: Color(0xFFD0D5CE)),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage(photoPath),
              ),
            ),

            // Konten navigasi
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFEFECE9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          // Navigasi ke halaman beranda
                          _buildListTile(
                            context,
                            icon: Icons.home,
                            title: "Beranda",
                            destination: const Beranda(),
                          ),
                          // Navigasi ke halaman cuti
                          _buildListTile(
                            context,
                            icon: Icons.calendar_today,
                            title: "Pengajuan Cuti",
                            destination: const CutiPage(),
                          ),
                          // Navigasi ke slip gaji
                          _buildListTile(
                            context,
                            icon: Icons.money,
                            title: "Slip Gaji",
                            destination: const SlipGajiPage(),
                          ),
                          // Navigasi ke data shift
                          _buildListTile(
                            context,
                            icon: Icons.calendar_month,
                            title: "Data Shift",
                            destination: const DataShiftPage(),
                          ),
                          // Logout
                          _buildListTile(
                            context,
                            icon: Icons.logout_rounded,
                            title: "Keluar",
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Footer hak cipta kita
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        //matap
                        "©2025 Naga Hytam Sejahtera Abadi\nAll Rights Reserved.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
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

  // Widget pembuat ListTile bergaya custom
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
          onTap: onTap ??
              () {
                if (destination != null) {
                  Navigator.pop(context); // Tutup drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => destination),
                  );
                }
              },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD1EBDB),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF192524),
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF3C5759)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
