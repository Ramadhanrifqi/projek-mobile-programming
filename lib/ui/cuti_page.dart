import 'package:flutter/material.dart';
import '../model/cuti.dart';
import '../service/cuti_service.dart';
import 'cuti_detail.dart';
import 'cuti_form.dart';

class CutiPage extends StatefulWidget {
  const CutiPage({super.key});

  @override
  State<CutiPage> createState() => _CutiPageState();
}

class _CutiPageState extends State<CutiPage> {
  List<Cuti> _cutiList = [];

  getData() async {
    _cutiList = await CutiService().listData();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Cuti")),
      body: ListView.builder(
        itemCount: _cutiList.length,
        itemBuilder: (context, index) {
          final cuti = _cutiList[index];
          return ListTile(
            title: Text(cuti.ajukanCuti),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Mulai: ${cuti.tanggalMulai ?? '-'}"),
                Text("Selesai: ${cuti.tanggalSelesai ?? '-'}"),
                Text("Alasan: ${cuti.alasan ?? '-'}"),
              ],
            ),
            isThreeLine: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CutiDetail(cuti: cuti)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CutiForm()),
          );
          getData(); // refresh setelah kembali
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
