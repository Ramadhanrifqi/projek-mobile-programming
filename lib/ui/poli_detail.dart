import 'package:flutter/material.dart';
import '../service/poli_service.dart';
import 'poli_page.dart';
import 'poli_update_form.dart';
import '../model/poli.dart';

class PoliDetail extends StatelessWidget {
  final Poli poli;

  const PoliDetail({Key? key, required this.poli}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Poli")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Nama Poli : ${poli.namaPoli}",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PoliUpdate(poli: poli),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Ubah"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showDeleteDialog(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Hapus"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await PoliService().hapus(poli).then((value) {
                Navigator.pop(context); // Tutup dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const PoliPage()),
                );
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("YA"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Tidak"),
          )
        ],
      ),
    );
  }
}
