import 'dart:ui';
import 'package:flutter/material.dart';
import '../model/user.dart';
import '../service/user_service.dart';
import '../helpers/user_info.dart'; // Import UserInfo untuk cek ID login
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

    setState(() {
      _filteredKaryawan = results;
    });
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
        margin: const EdgeInsets.symmetric(horizontal: 5), // Spasi antar tombol
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD1EBDB) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFFD1EBDB) : Colors.white24),
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
        title: const Text("Pilih Karyawan", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0, centerTitle: true, 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF192524), Color(0xFF3C5759)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
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
                    fillColor: Colors.white.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // --- FILTER TOMBOL DI TENAH ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Membuat tombol di tengah
                  children: [
                    _buildFilterButton("All"),
                    _buildFilterButton("Admin"),
                    _buildFilterButton("User"),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD1EBDB)))
                    : _filteredKaryawan.isEmpty
                        ? const Center(child: Text("Karyawan tidak ditemukan.", style: TextStyle(color: Colors.white60)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: _filteredKaryawan.length,
                            itemBuilder: (context, index) => _buildKaryawanCard(_filteredKaryawan[index]),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKaryawanCard(User user) {
    bool isAdminAccount = user.role?.toLowerCase() == 'admin';
    // Cek apakah ID user ini sama dengan ID yang sedang login
    bool isMe = user.id.toString() == UserInfo.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFD1EBDB),
                child: Icon(Icons.person, color: Color(0xFF192524)),
              ),
              title: Row(
                children: [
                  Flexible(
                    child: Text(user.name ?? "", 
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  if (isAdminAccount) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 0.5),
                      ),
                      child: Text(
                        isMe ? "ADMIN (SAYA)" : "ADMIN", // Berikan label SAYA jika itu akun login
                        style: const TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ]
                ],
              ),
              subtitle: Text(user.email ?? "", 
                style: const TextStyle(color: Colors.white70)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SlipGajiDetailPage(user: user)));
              },
            ),
          ),
        ),
      ),
    );
  }
}