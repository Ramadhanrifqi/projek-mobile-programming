import 'package:flutter/material.dart';
import '../ui/beranda.dart';
import '../ui/login.dart';
import '../ui/cuti_page.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("Admin"),
            accountEmail: Text("admin@admin.com"),
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
            onTap: () {},
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
