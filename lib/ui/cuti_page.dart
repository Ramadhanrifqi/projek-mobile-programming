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
  List<Cuti> _cutiList = [];
  List<User> _allUsers = []; 
  bool _isLoading = true;

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

      setState(() {
        _cutiList = isAdmin 
            ? data 
            : data.where((cuti) {
                return cuti.ajukanCuti?.toLowerCase().trim() == 
                       UserInfo.username?.toLowerCase().trim();
              }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Gagal memuat data: $e");
    }
  }

  void _konfirmasiResetJatah() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text("Peringatan Reset!", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
        content: const Text(
          "Tindakan ini akan mengembalikan jatah cuti semua karyawan ke 14 hari DAN MENGHAPUS SELURUH RIWAYAT pengajuan cuti. Anda yakin?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                bool success = await CutiService().resetCutiSemua(); 
                if (success) {
                  _showSnackBar("Jatah direset & riwayat dikosongkan!", Colors.green);
                  getData(); 
                } else {
                  _showSnackBar("Gagal mereset data", Colors.redAccent);
                }
              } catch (e) {
                _showSnackBar("Terjadi kesalahan: $e", Colors.redAccent);
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text("Ya, Reset & Hapus", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapus(Cuti cuti) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text("Hapus Pengajuan", style: TextStyle(color: Colors.white)),
        content: const Text("Apakah Anda yakin ingin menghapus data ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              if (cuti.id != null) {
                Navigator.pop(ctx);
                await CutiService().hapus(cuti.id!);
                _showSnackBar("Data berhasil dihapus", Colors.green);
                getData();
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }

  String getNamaAsli(String email) {
    try {
      final user = _allUsers.firstWhere((u) => u.email == email);
      return user.name ?? email;
    } catch (e) { return email; }
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
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD1EBDB)))
            : RefreshIndicator(
                onRefresh: getData,
                child: _cutiList.isEmpty
                  ? const Center(child: Text("Riwayat cuti kosong.", style: TextStyle(color: Colors.white60)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _cutiList.length,
                      itemBuilder: (context, index) {
                        final cuti = _cutiList[index];
                        final namaTampil = getNamaAsli(cuti.ajukanCuti ?? '');
                        return _buildCutiCard(cuti, isAdmin, namaTampil);
                      },
                    ),
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
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(backgroundColor: Color(0xFFD1EBDB), child: Icon(Icons.calendar_today, color: Colors.black87)),
        title: Text(namaTampil, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${cuti.tanggalMulai} - ${cuti.tanggalSelesai}", style: const TextStyle(color: Colors.white70)),
            // MENAMPILKAN ALASAN CUTI
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
    if (status?.toLowerCase() == 'disetujui') return Colors.greenAccent;
    if (status?.toLowerCase() == 'ditolak') return Colors.redAccent;
    return Colors.orangeAccent;
  }
}