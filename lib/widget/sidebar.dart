import 'package:flutter/material.dart';
import '../ui/beranda.dart';
import '../ui/login.dart';
import '../ui/cuti_page.dart';
import '../helpers/user_info.dart'; // Tambahkan ini
import '../ui/slip_gaji_page.dart';
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserInfo.user; // Ambil user dari UserInfo

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.username ?? "Tidak diketahui"),
            accountEmail: Text(user?.username ?? "-"),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Beranda"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Beranda()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.accessible),
            title: Text("Pengajuan cuti"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CutiPage()),
              );
            },
          ),
          ListTile(
              leading: Icon(Icons.people),
              title: Text("Slip Gaji"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SlipGajiPage()),
                );
              },
            ),

          ListTile(
            leading: Icon(Icons.account_box_sharp),
            title: Text("Data Shif"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text("Keluar"),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
