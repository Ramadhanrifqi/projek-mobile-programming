import 'dart:ui';
import 'package:flutter/material.dart';
import '../model/user.dart';
import '../service/user_service.dart';
import '../helpers/user_info.dart';
import '../widget/sidebar.dart';
import 'slip_gaji_detail_page.dart';

class SlipGajiPage extends StatefulWidget {
  const SlipGajiPage({super.key});

  @override
  State<SlipGajiPage> createState() => _SlipGajiPageState();
}

class _SlipGajiPageState extends State<SlipGajiPage> {
  List<User> _allUsers = [];
  List<User> _filteredKaryawan = [];
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedRoleFilter = "All";

  @override
  void initState() {
    super.initState();
    _loadKaryawan();
  }

  Future<void> _loadKaryawan() async {
    try {
      setState(() => _isLoading = true);
      final data = await UserService().getAllUsers();
      data.sort((a, b) => (a.name ?? "").toLowerCase().compareTo((b.name ?? "").toLowerCase()));

      setState(() {
        _allUsers = data;
        _filteredKaryawan = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Gagal memuat user: $e");
    }
  }

  void _applyFilter() {
    String keyword = _searchCtrl.text.toLowerCase();

    List<User> results = _allUsers.where((user) {
      final nameMatch = (user.name ?? "").toLowerCase().contains(keyword);

      bool roleMatch = true;
      if (_selectedRoleFilter == "Admin") {
        roleMatch = user.role?.toLowerCase() == 'admin';
      } else if (_selectedRoleFilter == "User") {
        roleMatch = user.role?.toLowerCase() == 'user';
      }

      return nameMatch && roleMatch;
    }).toList();

    setState(() => _filteredKaryawan = results);
  }

  Widget _buildFilterButton(String label) {
    bool isSelected = _selectedRoleFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRoleFilter = label;
          _applyFilter();
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD1EBDB) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD1EBDB) : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF192524) : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text(
          "Pilih Karyawan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF192524), Color(0xFF3C5759)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchField(),
              _buildFilterButtons(),
              const SizedBox(height: 10),
              Expanded(child: _buildKaryawanList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (value) => _applyFilter(),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Cari nama...",
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFD1EBDB)),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterButton("All"),
          _buildFilterButton("Admin"),
          _buildFilterButton("User"),
        ],
      ),
    );
  }

  Widget _buildKaryawanList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD1EBDB)),
      );
    }

    if (_filteredKaryawan.isEmpty) {
      return const Center(
        child: Text(
          "Karyawan tidak ditemukan.",
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _filteredKaryawan.length,
      itemBuilder: (context, index) => _buildKaryawanCard(_filteredKaryawan[index]),
    );
  }

  Widget _buildKaryawanCard(User user) {
    bool isAdminAccount = user.role?.toLowerCase() == 'admin';
    bool isMe = user.id.toString() == UserInfo.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: ListTile(
              leading: _buildAvatar(user),
              title: _buildTitle(user, isAdminAccount, isMe),
              subtitle: Text(user.email ?? "", style: const TextStyle(color: Colors.white70)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SlipGajiDetailPage(user: user)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(User user) {
    bool hasValidPhoto = user.photoUrl != null && user.photoUrl!.startsWith('http');

   return CircleAvatar(
      radius: 25, // Ukuran avatar di list
      backgroundColor: const Color(0xFFD1EBDB),
      // LOGIKA: Jika ada foto network pakai NetworkImage, jika tidak pakai AssetImage (foto_default)
      backgroundImage: hasValidPhoto
          ? NetworkImage("${user.photoUrl}?t=${DateTime.now().millisecondsSinceEpoch}")
          : const AssetImage('assets/images/foto_default.png') as ImageProvider,
      
      // PERBAIKAN: Hilangkan teks inisial agar tidak menumpuk di atas foto_default.png
      // Kita set child menjadi null karena foto_default sudah cukup mewakili identitas visual
      child: null, 
    );
  }

  Widget _buildTitle(User user, bool isAdminAccount, bool isMe) {
    return Row(
      children: [
        Flexible(
          child: Text(
            user.name ?? "",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        if (isAdminAccount) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 0.5),
            ),
            child: Text(
              isMe ? "ADMIN (SAYA)" : "ADMIN",
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}