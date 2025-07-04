import 'package:flutter/material.dart';
import '../service/cuti_service.dart';
import '../model/cuti.dart';
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

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    List<Cuti> data = await CutiService().listData();
    final isAdmin = UserInfo.role == 'admin';
    final username = UserInfo.username;

    setState(() {
      _cutiList = isAdmin
          ? data
          : data.where((cuti) => cuti.ajukanCuti == username).toList();
    });
  }

  Future<void> _deleteCuti(id) async {
    await CutiService().hapus(id);
    getData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = UserInfo.role == 'admin';

    return Scaffold(
      drawer: const Sidebar(),
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text('Data Cuti', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: getData,
          child: _cutiList.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada data cuti.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 12, bottom: 80),
                  itemCount: _cutiList.length,
                  itemBuilder: (context, index) {
                    final cuti = _cutiList[index];
                    final isPending = cuti.status == 'Pending';
                    final isOwner = cuti.ajukanCuti == UserInfo.username;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.white70),
                              const SizedBox(width: 8),
                              Text(
                                cuti.ajukanCuti,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 6,
                            children: [
                              _infoChip(Icons.date_range,
                                  "Mulai: ${cuti.tanggalMulai}"),
                              _infoChip(Icons.date_range,
                                  "Selesai: ${cuti.tanggalSelesai}"),
                              _infoChip(Icons.note, "Alasan: ${cuti.alasan}"),
                              _infoChip(Icons.info_outline,
                                  "Status: ${cuti.status}"),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Aksi tombol
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // ADMIN: edit hanya jika status masih Pending
                              if (isAdmin && isPending)
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.lightBlueAccent),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CutiUpdateFormPage(cuti: cuti),
                                      ),
                                    ).then((_) => getData());
                                  },
                                ),

                              // USER: bisa hapus jika bukan pending dan milik sendiri
                              if (!isAdmin && isOwner && !isPending)
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Konfirmasi"),
                                        content: const Text(
                                            "Hapus cuti yang sudah diproses?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx),
                                            child: const Text("Batal"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              _deleteCuti(cuti.id);
                                            },
                                            child: const Text("Hapus"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),

      // Tombol tambah cuti hanya untuk user
      floatingActionButton: UserInfo.role != 'admin'
          ? FloatingActionButton(
              backgroundColor: Colors.tealAccent[700],
              foregroundColor: Colors.black,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CutiForm()),
                );
                getData();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.tealAccent[100], size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
