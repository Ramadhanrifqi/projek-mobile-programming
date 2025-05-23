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

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3F51B5), Color(0xFF1A237E)], // Gradasi indigo
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              accountName: Text(
                user?.username ?? "Tidak diketahui",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user?.username ?? ""),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.indigo),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
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
                            destination: Beranda(username: '',),
                            
                          ),
                          _buildListTile(
                            context,
                            icon: Icons.accessible,
                            title: "Pengajuan Cuti",
                            destination: CutiPage(),
                          ),
                          _buildListTile(
                            context,
                            icon: Icons.people,
                            title: "Slip Gaji",
                            destination: SlipGajiPage(),
                          ),
                          _buildListTile(
                            context,
                            icon: Icons.calendar_month,
                            title: "Data Shift",
                            destination: DataShiftPage(),
                          ),
                          _buildListTile(
                            context,
                            icon: Icons.logout_rounded,
                            title: "Keluar",
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        "©2025 Naga Hytam Sejahtera Abadi\nAll Rights Reserved.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
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
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => destination),
                  );
                }
              },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.indigo),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(thickness: 1),
    );
  }
}
