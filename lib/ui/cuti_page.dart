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
  List<Cuti> _allCutiList = []; // Data asli dari server
  List<Cuti> _filteredCutiList = []; // Data hasil filter pencarian
  List<User> _allUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();

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

      // 1. Filter awal berdasarkan user yang login
      List<Cuti> rawList = isAdmin
          ? data
          : data.where((cuti) {
              return cuti.ajukanCuti?.toLowerCase().trim() ==
                  UserInfo.username?.toLowerCase().trim();
            }).toList();

      // 2. Urutkan: ID Terbesar (Paling Baru) di atas
      rawList.sort((a, b) {
        int idA = int.tryParse(a.id.toString()) ?? 0;
        int idB = int.tryParse(b.id.toString()) ?? 0;
        return idB.compareTo(idA);
      });

      setState(() {
        _allCutiList = rawList;
        _filteredCutiList = rawList; // Tampilkan semua saat pertama load
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Gagal memuat data: $e");
    }
  }

  // 3. Fungsi Pencarian berdasarkan Nama
  void _runFilter(String keyword) {
    List<Cuti> results = [];
    if (keyword.isEmpty) {
      results = _allCutiList;
    } else {
      results = _allCutiList.where((cuti) {
        final nama = getNamaAsli(cuti.ajukanCuti ?? '').toLowerCase();
        return nama.contains(keyword.toLowerCase());
      }).toList();
    }

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

  // --- DIALOG-DIALOG (Tetap Sama) ---
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.greenAccent, width: 2)),
        title: const Center(
            child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 50)),
        content: Text(message,
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        actions: [
          Center(
              child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("OK",
                      style: TextStyle(
                          color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold))))
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.redAccent, width: 2)),
        title: Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text(message,
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
        actions: [
          Center(
              child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("OK", style: TextStyle(color: Color(0xFFD1EBDB)))))
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
        title: const Text("Peringatan Reset!",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
        content: const Text(
          "Tindakan ini akan mengembalikan jatah cuti semua karyawan ke 14 hari DAN MENGHAPUS SELURUH RIWAYAT. Anda yakin?",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Batal", style: TextStyle(color: Colors.white54))),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  setState(() => _isLoading = true);
                  try {
                    bool success = await CutiService().resetCutiSemua();
                    if (success) {
                      _showSuccessDialog("Jatah direset & riwayat dikosongkan!");
                      getData();
                    } else {
                      _showErrorDialog("Gagal", "Sistem tidak dapat mereset data.");
                    }
                  } catch (e) {
                    _showErrorDialog("Error", e.toString());
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text("Ya, Reset",
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
        title: const Text("Hapus Pengajuan",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin menghapus data pengajuan ini?",
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Batal", style: TextStyle(color: Colors.white54))),
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
                child: const Text("Hapus",
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
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
        title: const Text('Riwayat Cuti',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (value) => _runFilter(value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Cari nama pengaju...",
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

              // --- LIST CONTENT ---
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFFD1EBDB)))
                    : RefreshIndicator(
                        onRefresh: getData,
                        color: const Color(0xFFD1EBDB),
                        child: _filteredCutiList.isEmpty
                            ? const Center(
                                child: Text("Data tidak ditemukan.",
                                    style: TextStyle(color: Colors.white60)))
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredCutiList.length,
                                itemBuilder: (context, index) {
                                  final cuti = _filteredCutiList[index];
                                  final namaTampil =
                                      getNamaAsli(cuti.ajukanCuti ?? '');
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
              label: const Text("Reset Jatah & Riwayat",
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.bold)),
            )
          : FloatingActionButton(
              backgroundColor: const Color(0xFFD1EBDB),
              onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const CutiForm()))
                  .then((_) => getData()),
              child: const Icon(Icons.add, color: Color(0xFF192524)),
            ),
    );
  }

  Widget _buildCutiCard(Cuti cuti, bool isAdmin, String namaTampil) {
    final status = cuti.status?.toLowerCase().trim() ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
            backgroundColor: Color(0xFFD1EBDB),
            child: Icon(Icons.calendar_today, color: Colors.black87)),
        title: Text(namaTampil,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${cuti.tanggalMulai} - ${cuti.tanggalSelesai}",
                style: const TextStyle(color: Colors.white70)),
            Text("Alasan: ${cuti.alasan ?? '-'}",
                style: const TextStyle(
                    color: Colors.white60, fontStyle: FontStyle.italic)),
            const SizedBox(height: 4),
            Text("Status: ${cuti.status}",
                style: TextStyle(
                    color: _getStatusColor(cuti.status), fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: isAdmin
            ? (status == 'pending'
                ? IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white70),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CutiUpdateFormPage(
                                  cuti: cuti,
                                  namaPengaju: namaTampil))).then((_) => getData());
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
    if (status?.toLowerCase() == 'disetujui') return Colors.greenAccent;
    if (status?.toLowerCase() == 'ditolak') return Colors.redAccent;
    return Colors.orangeAccent;
  }
}