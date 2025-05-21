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
    setState(() {
      _cutiList = data;
    });
  }

  Future<void> _deleteCuti( id) async {
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
      appBar: AppBar(title: const Text('Data Cuti')),
      drawer: const Sidebar(),
      body: RefreshIndicator(
        onRefresh: getData,
        child: ListView.builder(
          itemCount: _cutiList.length,
          itemBuilder: (context, index) {
            final cuti = _cutiList[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(cuti.ajukanCuti),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Mulai: ${cuti.tanggalMulai}"),
                    Text("Selesai: ${cuti.tanggalSelesai}"),
                    Text("Alasan: ${cuti.alasan}"),
                    Text("Status: ${cuti.status}"),
                    const SizedBox(height: 8),
                    if (isAdmin)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
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
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Konfirmasi"),
                                  content: const Text("Hapus data ini?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
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
              ),
            );
          },
        ),
      ),
      floatingActionButton: UserInfo.role != 'admin'
          ? FloatingActionButton(
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
