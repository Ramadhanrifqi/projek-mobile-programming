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
  State<CutiPage> createState() => _CutiPageState(); // Pastikan satu underscore
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

      // Admin melihat semua data, User melihat data sendiri
      List<Cuti> rawList = isAdmin
          ? data
          : data.where((cuti) {
              return cuti.ajukanCuti?.toLowerCase().trim() ==
                  UserInfo.email?.toLowerCase().trim();
            }).toList();

      // LOGIKA SORTING: Pending (1), Ditolak (2), Disetujui (3)
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
        _applyFilter(); 
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Gagal memuat data: $e");
    }
  }

  // Fungsi Filter Terpadu (Nama + Tombol Status + My Leave)
  void _applyFilter() {
    String keyword = _searchCtrl.text.toLowerCase();
    String myEmail = UserInfo.email?.toLowerCase().trim() ?? "";

    List<Cuti> results = _allCutiList.where((cuti) {
      final emailPengaju = cuti.ajukanCuti?.toLowerCase().trim() ?? "";
      final nama = getNamaAsli(emailPengaju).toLowerCase();
      final statusCuti = cuti.status?.toLowerCase().trim() ?? "";

      // LOGIKA FILTER STATUS & MY LEAVE
      bool matchStatus = false;
      if (_selectedStatus == "All") {
        matchStatus = true;
      } else if (_selectedStatus == "Cuti Saya") {
        matchStatus = (emailPengaju == myEmail);
      } else {
        matchStatus = (statusCuti == _selectedStatus.toLowerCase());
      }

      final nameMatch = nama.contains(keyword);
      
      return matchStatus && nameMatch;
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
  Widget _buildFilterButton(String label) {
    bool isSelected = _selectedStatus == label;
    // Warna biru khusus untuk filter "Cuti Saya"
    Color activeColor = (label == "Cuti Saya") ? Colors.blueAccent : _getStatusColor(label);

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
          color: isSelected ? activeColor.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? activeColor : Colors.white24),
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildFilterButton("All"),
                      _buildFilterButton("Cuti Saya"), // Tombol filter baru
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                heroTag: "resetBtn",
                backgroundColor: Colors.orangeAccent,
                onPressed: () => _konfirmasiResetJatah(),
                icon: const Icon(Icons.refresh, color: Colors.black87),
                label: const Text("Reset Jatah", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              ),
            ),
          FloatingActionButton(
            heroTag: "addBtn",
            backgroundColor: const Color(0xFFD1EBDB),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CutiForm())).then((_) => getData()),
            child: const Icon(Icons.add, color: Color(0xFF192524)),
          ),
        ],
      ),
    );
  }

  Widget _buildCutiCard(Cuti cuti, bool isAdmin, String namaTampil) {
  final status = cuti.status?.toLowerCase().trim() ?? 'pending';
  bool isMyOwnCuti =
      cuti.ajukanCuti?.toLowerCase().trim() ==
      UserInfo.email?.toLowerCase().trim();

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ================= LEFT CONTENT =================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                namaTampil,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${cuti.tanggalMulai} s/d ${cuti.tanggalSelesai}",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                "Alasan: ${cuti.alasan ?? '-'}",
                style: const TextStyle(
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Status: ${cuti.status}",
                style: TextStyle(
                  color: _getStatusColor(cuti.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        /// ================= RIGHT CONTENT =================
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isMyOwnCuti)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: const Text(
                  "Pengajuan Cuti Saya",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMyOwnCuti &&
                    (status == 'pending' || status == 'ditolak'))
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.delete_rounded,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                    onPressed: () => _konfirmasiHapus(cuti),
                  ),

                if (isAdmin && status == 'pending' && !isMyOwnCuti)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.edit_note_rounded,
                      color: Colors.white70,
                      size: 24,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CutiUpdateFormPage(
                          cuti: cuti,
                          namaPengaju: namaTampil,
                        ),
                      ),
                    ).then((_) => getData()),
                  ),
              ],
            ),

            if (isAdmin && status == 'pending' && isMyOwnCuti)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: SizedBox(
                  width: 180,
                  child: Text(
                    "Tunggu Persetujuan Admin Lain",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
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