import 'package:flutter/material.dart';
import '../model/cuti.dart';
import 'cuti_update_form.dart';

class CutiDetail extends StatelessWidget {
  final Cuti cuti;

  const CutiDetail({super.key, required this.cuti});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Cuti")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama Cuti: ${cuti.ajukanCuti}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Tanggal Mulai: ${cuti.tanggalMulai ?? '-'}"),
            Text("Tanggal Selesai: ${cuti.tanggalSelesai ?? '-'}"),
            Text("Alasan: ${cuti.alasan ?? '-'}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CutiUpdate(cuti: cuti)),
                );
              },
              child: const Text("Edit"),
            ),
          ],
        ),
      ),
    );
  }
}
