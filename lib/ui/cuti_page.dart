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
        title: const Text('Data Cuti',style: TextStyle(color: Colors.white)),
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
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cuti.ajukanCuti,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Mulai: ${cuti.tanggalMulai}",
                              style: const TextStyle(color: Colors.white70)),
                          Text("Selesai: ${cuti.tanggalSelesai}",
                              style: const TextStyle(color: Colors.white70)),
                          Text("Alasan: ${cuti.alasan}",
                              style: const TextStyle(color: Colors.white70)),
                          Text("Status: ${cuti.status}",
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 10),
                          if (isAdmin)
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blueAccent),
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
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Konfirmasi"),
                                        content:
                                            const Text("Hapus data ini?"),
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
}
