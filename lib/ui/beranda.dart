import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/sidebar.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  // Variabel untuk menyimpan username dan role dari SharedPreferences
  String username = '';
  String role = '';
  int userId = 0;

  @override
  void initState() {
    super.initState();
    // Memuat informasi pengguna saat widget diinisialisasi
    loadUserInfo();
  }

  // Fungsi untuk mengambil username dan role dari SharedPreferences
  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
      role = prefs.getString('role') ?? '';
      userId = prefs.getInt('user_id') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Logika pemilihan gambar profil
    String photoPath;
    if (userId == 1 || username == 'admin1') {
      photoPath = 'assets/images/images/martin.png';
    } else if (userId == 4 || username == 'Cantika Ayu') {
      photoPath = 'assets/images/images/cantika.jpg';
    } else {
      photoPath = 'assets/images/images/profil_operator.jpg';
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Beranda",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Menampilkan menu navigasi samping (drawer)
      drawer: const Sidebar(),

      // Tampilan utama halaman
      body: Container(
        width: double.infinity,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF192524),
              Color(0xFF3C5759),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Kartu sambutan pengguna
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1EBDB).withOpacity(0.25),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: const Color(0xFFEFECE9).withOpacity(0.4)),
                      ),
                      child: Column(
                        children: [
                          // Foto profil
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF192524).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: AssetImage(photoPath),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Teks sambutan pengguna
                          Text(
                            "Hi 👋,\nSelamat Datang $username",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEFECE9),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Nama perusahaan
                          const Text(
                            "PT. Naga Hytam Sejahtera Abadi",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFD0D5CE),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Spacer untuk mengisi ruang kosong
              const Spacer(),

              // Teks copyright di bagian bawah
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "© 2025 PT Naga Hytam Sejahtera Abadi. All Rights Reserved.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFD0D5CE).withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
