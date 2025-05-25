import 'dart:ui';
import 'package:flutter/material.dart';
import '../widget/sidebar.dart';

class Beranda extends StatelessWidget {
  final String username;
  final String role;

  const Beranda({super.key, required this.username, required this.role});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
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

      drawer: const Sidebar(),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1EBDB).withOpacity(0.25), // mint soft transparan
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: const Color(0xFFEFECE9).withOpacity(0.4)),
                      ),
                      child: Column(
                        children: [
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
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundImage: AssetImage('assets/images/images/Foto.default.png'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Hi 👋,\nSaya $username",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEFECE9), // Putih tulang
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "PT. Naga Hytam\nSejahtera Abadi",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFD0D5CE), // abu pucat
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
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
