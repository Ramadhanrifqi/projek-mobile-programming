import 'dart:ui';
import 'dart:async'; // Tambahkan untuk Timer
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../widget/sidebar.dart';
import '../service/user_service.dart';
import '../model/user.dart';
import '../helpers/user_info.dart';
import '../service/cuti_service.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  User? _userData;
  bool _isLoading = true;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  
  // Variabel untuk Auto-Refresh
  Timer? _notifTimer;

  @override
  void initState() {
    super.initState();
    _loadFullProfile();
    

    _notifTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _refreshNotificationOnly();
    });
  }

  @override
  void dispose() {
    _notifTimer?.cancel(); // Hentikan timer saat keluar halaman
    super.dispose();
  }

  // Fungsi khusus untuk refresh angka notifikasi saja (tanpa loading screen)
  Future<void> _refreshNotificationOnly() async {
    if (_userData?.role?.toLowerCase() == 'admin' && mounted) {
      try {
        int count = await CutiService().getPendingCount();
        setState(() {
          UserInfo.pendingCutiCount = count;
        });
      } catch (e) {
        debugPrint("Auto-refresh notif failed: $e");
      }
    }
  }

  Future<void> _loadFullProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String userEmail = prefs.getString('email') ?? '';

    try {
      List<User> users = await UserService().getAllUsers();
      
      final foundUser = users.cast<User?>().firstWhere(
        (u) => u?.email == userEmail, 
        orElse: () => null
      );

      int count = 0;
      if (foundUser?.role?.toLowerCase() == 'admin') {
        count = await CutiService().getPendingCount();
      }

      if (mounted) {
        setState(() {
          _userData = foundUser;
          UserInfo.pendingCutiCount = count; 
          _isLoading = false;
        });
      }

    } catch (e) {
      debugPrint("Gagal load profil: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      setState(() => _isUploading = true);

      try {
        var result = await UserService().updateFoto(_userData!.id!, image);
        if (result['success']) {
          setState(() {
            _userData!.photoUrl = result['photo_url'];
            UserInfo.loginUser?.photoUrl = result['photo_url'];
          });

          _showNotification("Berhasil", "Foto profil Anda telah diperbarui!", const Color(0xFFD1EBDB));
        }
      } catch (e) {
        _showNotification("Error", "Gagal mengupload: $e", Colors.redAccent);
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showNotification(String title, String message, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color, width: 2),
        ),
        title: Center(
          child: Icon(
            title == "Berhasil" ? Icons.check_circle : Icons.error_outline,
            color: color,
            size: 50,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK",
                style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold)),
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
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text("DASHBOARD",
          style: TextStyle(color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.menu, color: Colors.white),
                  if (UserInfo.role?.toLowerCase() == 'admin' && (UserInfo.pendingCutiCount ?? 0) > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          "${UserInfo.pendingCutiCount}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD1EBDB)))
          : RefreshIndicator(
              onRefresh: _loadFullProfile, // Fungsi Tarik Layar ke Bawah
              color: const Color(0xFFD1EBDB),
              backgroundColor: const Color(0xFF192524),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // Wajib agar bisa di-swipe
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 20),
                      _buildStatsGrid(),
                      const SizedBox(height: 20),
                      _buildBiodataSection(),
                      const SizedBox(height: 20),
                      if (_userData?.role?.toLowerCase() == 'admin') _buildAdminActions(),
                      const SizedBox(height: 40),
                      const Text("© 2025 PT Naga Hytam Sejahtera Abadi",
                        style: TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }

  // --- Widget helper tetap sama dengan sedikit penyesuaian const ---
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: (_userData?.photoUrl != null && _userData!.photoUrl!.startsWith('http'))
                  ? NetworkImage("${_userData!.photoUrl!}?t=${DateTime.now().millisecondsSinceEpoch}")
                  : const AssetImage('assets/images/foto_default.png') as ImageProvider,
                child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUploading ? null : _changePhoto,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD1EBDB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 14, color: Color(0xFF0F2027)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_userData?.name ?? "User",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(_userData?.role?.toUpperCase() ?? "-",
                  style: const TextStyle(color: Color(0xFFD1EBDB), letterSpacing: 1.5, fontSize: 12)),
                const SizedBox(height: 10),
                Text(_userData?.email ?? "",
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _statItem("Jatah Cuti", "${_userData?.jatahCuti ?? 0} Hari", Icons.event_available, Colors.orangeAccent),
        const SizedBox(width: 15),
        _statItem("Departemen", _userData?.department ?? "-", Icons.business_center, Colors.blueAccent),
      ],
    );
  }

  Widget _statItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildBiodataSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("INFORMASI BIODATA",
            style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(color: Colors.white10, height: 30),
          _infoRow(Icons.phone_android, "Telepon", _userData?.phone ?? "-"),
          _infoRow(Icons.school_outlined, "Pendidikan", _userData?.education ?? "-"),
          _infoRow(Icons.workspace_premium_outlined, "Skill", _userData?.skills ?? "-"),
          _infoRow(Icons.location_on_outlined, "Alamat", _userData?.alamat ?? "-"),
          _infoRow(Icons.calendar_month_outlined, "Bergabung", _userData?.joinDate ?? "-"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
    return Column(
      children: [
        _adminButton("TAMBAH KARYAWAN", Icons.person_add_alt_1, Colors.teal,
          () => Navigator.pushNamed(context, '/tambah-karyawan')),
        const SizedBox(height: 12),
        _adminButton("DATA KARYAWAN", Icons.analytics_outlined, Colors.indigoAccent,
          () => Navigator.pushNamed(context, '/data-karyawan')),
      ],
    );
  }

  Widget _adminButton(String label, IconData icon, Color color, VoidCallback action) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: action,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
      ),
    );
  }
}