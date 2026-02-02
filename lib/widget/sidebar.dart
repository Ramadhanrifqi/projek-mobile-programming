import 'package:flutter/material.dart';
import '../ui/beranda.dart';
import '../ui/login.dart'; 
import '../ui/cuti_page.dart';
import '../helpers/user_info.dart';
import '../ui/slip_gaji_page.dart';
import '../ui/slip_gaji_detail_page.dart';
import '../ui/data_shift_page.dart';
import '../ui/changepasswordpage.dart';
import '../model/user.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.orangeAccent, width: 1.5), 
        ),
        icon: const Icon(Icons.logout_rounded, color: Colors.orangeAccent, size: 50),
        title: const Text(
          "Konfirmasi Keluar",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari akun ini?",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Batal", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 30),
              TextButton(
                onPressed: () {
                  UserInfo.logout(); // Pastikan panggil logout helper
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text("Keluar", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // REVISI 1: Gunakan ValueListenableBuilder untuk Foto & Nama agar sinkron saat user di-update
            ValueListenableBuilder<User?>(
              valueListenable: UserInfo.userNotifier,
              builder: (context, user, child) {
                final activeUser = user ?? UserInfo.loginUser;
                return UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  accountName: Text(
                    activeUser?.name ?? "Tidak diketahui",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEFECE9)),
                  ),
                  accountEmail: Text(
                    activeUser?.email ?? "",
                    style: const TextStyle(color: Color(0xFFD0D5CE)),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: const Color(0xFFEFECE9),
                    backgroundImage: (activeUser?.photoUrl != null && 
                                      activeUser!.photoUrl!.isNotEmpty && 
                                      activeUser.photoUrl!.startsWith('http'))
                        ? NetworkImage(activeUser.photoUrl!)
                        : const AssetImage('assets/images/foto_default.png') as ImageProvider,
                  ),
                );
              },
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFEFECE9), 
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
                          ValueListenableBuilder<int>(
                            valueListenable: ValueNotifier<int>(UserInfo.pendingCutiCount ?? 0),
                            builder: (context, count, child) {
                              return _buildListTile(
                                context,
                                icon: Icons.calendar_today,
                                title: "Pengajuan Cuti",
                                destination: const CutiPage(),
                                badgeCount: UserInfo.pendingCutiCount ?? 0, 
                              );
                            }
                          ),
                          _buildListTile(
                            context,
                            icon: Icons.money,
                            title: "Slip Gaji",
                            onTap: () {
                              Navigator.pop(context);
                              if (UserInfo.role?.toLowerCase() == 'admin') {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const SlipGajiPage()));
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SlipGajiDetailPage(user: UserInfo.loginUser!)));
                              }
                            },
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
                          _buildListTile(
                            context,
                            icon: Icons.logout_rounded,
                            title: "Keluar",
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        "©2026 Naga Hytam Sejahtera Abadi",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Color(0xFF3C5759), fontStyle: FontStyle.italic),
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

  // Widget _buildListTile tetap sama seperti sebelumnya
  Widget _buildListTile(BuildContext context, {required IconData icon, required String title, Widget? destination, VoidCallback? onTap, int badgeCount = 0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () {
            if (destination != null) {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD1EBDB),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF192524)),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF192524)))),
                if (badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    child: Text("$badgeCount", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                else
                  const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF3C5759)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}