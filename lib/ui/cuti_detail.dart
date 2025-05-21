import 'package:flutter/material.dart';
import '../model/cuti.dart';
import '../service/cuti_service.dart';
import '../global.dart';
import 'cuti_update_form.dart';

class CutiDetail extends StatelessWidget {
  final Cuti cuti;

  const CutiDetail({super.key, required this.cuti});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Cuti")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama: ${cuti.ajukanCuti}", style: const TextStyle(fontSize: 18)),
            Text("Mulai: ${cuti.tanggalMulai}"),
            Text("Selesai: ${cuti.tanggalSelesai}"),
            Text("Alasan: ${cuti.alasan}"),
            Text("Status: ${cuti.status ?? 'pending'}"),
            const SizedBox(height: 16),
            if (currentRole == "admin" && cuti.status == "pending") ...[
              ElevatedButton(
                onPressed: () async {
                  Cuti updatedCuti = cuti;
                  updatedCuti.status = "approved";
                  await CutiService().ubah(updatedCuti, updatedCuti.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cuti disetujui")),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Setujui Cuti"),
              )
            ],
            if (currentRole == "admin") ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CutiUpdateFormPage(cuti: cuti)),
                  );
                },
                child: const Text("Edit"),
              )
            ]
          ],
        ),
      ),
    );
  }
}
