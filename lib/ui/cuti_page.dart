import 'dart:ui';
import 'package:flutter/material.dart';
import '../service/cuti_service.dart';
import '../service/user_service.dart';
import '../model/cuti.dart';
import '../model/user.dart';
import '../helpers/user_info.dart';
import '../widget/sidebar.dart';
import 'cuti_form.dart';
import 'cuti_update_form.dart';

class CutiPage extends StatefulWidget {
  const CutiPage({super.key});

  @override
  State<CutiPage> createState() => _CutiPageState();
}

class _CutiPageState extends State<CutiPage> {
  List<Cuti> _allCutiList = []; // Data mentah dari server
  List<Cuti> _filteredCutiList = []; // Data setelah filter & sort
  List<User> _allUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();
  
  // Status filter yang terpilih
  String _selectedStatus = "All"; 

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      setState(() => _isLoading = true);
      _allUsers = await UserService().getAllUsers();
      List<Cuti> data = await CutiService().listData();

      final isAdmin = UserInfo.role?.toLowerCase() == 'admin';

      // Pisahkan data milik user sendiri atau semua data jika admin
      List<Cuti> rawList = isAdmin
          ? data
          : data.where((cuti) {
              return cuti.ajukanCuti?.toLowerCase().trim() ==
                  UserInfo.email?.toLowerCase().trim();
            }).toList();

      // LOGIKA SORTING: Pending (1), Ditolak (2), Disetujui (3)
      // Ini memastikan status disetujui tenggelam ke bawah.
      rawList.sort((a, b) {
        int priority(String? s) {
          switch (s?.toLowerCase().trim()) {
            case 'pending': return 1;
            case 'ditolak': return 2;
            case 'disetujui': return 3;
            default: return 4;
          }
        }
        return priority(a.status).compareTo(priority(b.status));
      });

      setState(() {
        _allCutiList = rawList;
        _applyFilter(); // Terapkan filter awal
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Gagal memuat data: $e");
    }
  }

  // Fungsi Filter Terpadu (Nama + Tombol Status)
  void _applyFilter() {
    String keyword = _searchCtrl.text.toLowerCase();
    List<Cuti> results = _allCutiList.where((cuti) {
      final nama = getNamaAsli(cuti.ajukanCuti ?? '').toLowerCase();
      
      final statusMatch = (_selectedStatus == "All") || 
                          (cuti.status?.toLowerCase().trim() == _selectedStatus.toLowerCase());
      final nameMatch = nama.contains(keyword);
      
      return statusMatch && nameMatch;
    }).toList();

    setState(() {
      _filteredCutiList = results;
    });
  }

  String getNamaAsli(String email) {
    try {
      final user = _allUsers.firstWhere((u) => u.email == email);
      return user.name ?? email;
    } catch (e) {
      return email;
    }
  }

  // --- WIDGET DIALOGS ---

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.greenAccent, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 50),
            const SizedBox(height: 10),
            const Text("Berhasil",
                style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK", style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold))))
        ],
      ),
    );
  }

  void _konfirmasiResetJatah() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.orangeAccent, width: 2)),
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 50),
        title: const Text("Peringatan Reset!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text(
          "Tindakan ini akan mengembalikan jatah cuti semua karyawan ke 14 hari DAN MENGHAPUS SELURUH RIWAYAT. Anda yakin?",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.white54))),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  setState(() => _isLoading = true);
                  if (await CutiService().resetCutiSemua()) {
                    _showSuccessDialog("Jatah direset & riwayat dikosongkan!");
                    getData();
                  }
                  setState(() => _isLoading = false);
                },
                child: const Text("Ya, Reset", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapus(Cuti cuti) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.redAccent, width: 2)),
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 50),
        title: const Text("Hapus Pengajuan",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text("Apakah Anda yakin ingin menghapus data pengajuan ini?",
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.white54))),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () async {
                  if (cuti.id != null) {
                    Navigator.pop(ctx);
                    await CutiService().hapus(cuti.id!);
                    _showSuccessDialog("Data pengajuan berhasil dihapus.");
                    getData();
                  }
                },
                child: const Text("Hapus", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Tombol Filter di Header
  Widget _buildFilterButton(String label) {
    bool isSelected = _selectedStatus == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = label;
          _applyFilter();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _getStatusColor(label).withOpacity(0.3) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? _getStatusColor(label) : Colors.white24),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = UserInfo.role?.toLowerCase() == 'admin';

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text('Riwayat Cuti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0, centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (isAdmin) ...[
                // Kolom Pencarian
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (value) => _applyFilter(),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Cari nama pengaju...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFD1EBDB)),
                      filled: true, fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                // Barisan Tombol Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildFilterButton("All"),
                      _buildFilterButton("Pending"),
                      _buildFilterButton("Disetujui"),
                      _buildFilterButton("Ditolak"),
                    ],
                  ),
                ),
              ],
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD1EBDB)))
                    : RefreshIndicator(
                        onRefresh: getData,
                        color: const Color(0xFFD1EBDB),
                        child: _filteredCutiList.isEmpty
                            ? const Center(child: Text("Data tidak ditemukan.", style: TextStyle(color: Colors.white60)))
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredCutiList.length,
                                itemBuilder: (context, index) {
                                  final cuti = _filteredCutiList[index];
                                  final namaTampil = getNamaAsli(cuti.ajukanCuti ?? '');
                                  return _buildCutiCard(cuti, isAdmin, namaTampil);
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Colors.orangeAccent,
              onPressed: () => _konfirmasiResetJatah(),
              icon: const Icon(Icons.refresh, color: Colors.black87),
              label: const Text("Reset Jatah & Riwayat", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            )
          : FloatingActionButton(
              backgroundColor: const Color(0xFFD1EBDB),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CutiForm())).then((_) => getData()),
              child: const Icon(Icons.add, color: Color(0xFF192524)),
            ),
    );
  }

  Widget _buildCutiCard(Cuti cuti, bool isAdmin, String namaTampil) {
    final status = cuti.status?.toLowerCase().trim() ?? 'pending';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // Visual: Jika disetujui, card dibuat lebih pudar
        color: status == 'disetujui' ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status == 'disetujui' ? Colors.transparent : Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
            backgroundColor: _getStatusColor(cuti.status).withOpacity(0.2),
            child: Icon(Icons.calendar_today, color: _getStatusColor(cuti.status))),
        title: Text(namaTampil, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${cuti.tanggalMulai} - ${cuti.tanggalSelesai}", style: const TextStyle(color: Colors.white70)),
            Text("Alasan: ${cuti.alasan ?? '-'}", style: const TextStyle(color: Colors.white60, fontStyle: FontStyle.italic)),
            const SizedBox(height: 4),
            Text("Status: ${cuti.status}", style: TextStyle(color: _getStatusColor(cuti.status), fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: isAdmin
            ? (status == 'pending'
                ? IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white70),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CutiUpdateFormPage(cuti: cuti, namaPengaju: namaTampil))).then((_) => getData());
                    })
                : null)
            : (status == 'pending' || status == 'ditolak'
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _konfirmasiHapus(cuti))
                : null),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase().trim()) {
      case 'disetujui': return Colors.greenAccent;
      case 'ditolak': return Colors.redAccent;
      case 'pending': return Colors.orangeAccent;
      default: return Colors.white;
    }
  }
}