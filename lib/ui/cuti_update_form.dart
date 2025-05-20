import 'package:flutter/material.dart';
import '../model/cuti.dart';
import '../service/cuti_service.dart';
import 'cuti_detail.dart';

class CutiUpdate extends StatefulWidget {
  final Cuti cuti;

  const CutiUpdate({Key? key, required this.cuti}) : super(key: key);

  @override
  _CutiUpdateState createState() => _CutiUpdateState();
}

class _CutiUpdateState extends State<CutiUpdate> {
  final _formKey = GlobalKey<FormState>();
  final _ajukanCutiCtrl = TextEditingController();
  final _tanggalMulaiCtrl = TextEditingController();
  final _tanggalSelesaiCtrl = TextEditingController();
  final _alasanCtrl = TextEditingController();

  Future<Cuti> getData() async {
    Cuti data = await CutiService().getById(widget.cuti.id.toString());
    setState(() {
      _ajukanCutiCtrl.text = data.ajukanCuti;
      _tanggalMulaiCtrl.text = data.tanggalMulai ?? '';
      _tanggalSelesaiCtrl.text = data.tanggalSelesai ?? '';
      _alasanCtrl.text = data.alasan ?? '';
    });
    return data;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ubah Cuti")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _fieldNama(),
              _fieldTanggalMulai(),
              _fieldTanggalSelesai(),
              _fieldAlasan(),
              const SizedBox(height: 20),
              _tombolSimpan(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldNama() {
    return TextFormField(
      controller: _ajukanCutiCtrl,
      decoration: const InputDecoration(labelText: "Nama Cuti"),
    );
  }

  Widget _fieldTanggalMulai() {
    return TextFormField(
      controller: _tanggalMulaiCtrl,
      decoration: const InputDecoration(labelText: "Tanggal Mulai (yyyy-mm-dd)"),
    );
  }

  Widget _fieldTanggalSelesai() {
    return TextFormField(
      controller: _tanggalSelesaiCtrl,
      decoration: const InputDecoration(labelText: "Tanggal Selesai (yyyy-mm-dd)"),
    );
  }

  Widget _fieldAlasan() {
    return TextFormField(
      controller: _alasanCtrl,
      decoration: const InputDecoration(labelText: "Alasan"),
    );
  }

  Widget _tombolSimpan() {
    return ElevatedButton(
      onPressed: () async {
        Cuti cuti = Cuti(
          ajukanCuti: _ajukanCutiCtrl.text,
          tanggalMulai: _tanggalMulaiCtrl.text,
          tanggalSelesai: _tanggalSelesaiCtrl.text,
          alasan: _alasanCtrl.text,
        );
        String id = widget.cuti.id.toString();
        await CutiService().ubah(cuti, id).then((value) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CutiDetail(cuti: value)),
          );
        });
      },
      child: const Text("Simpan Perubahan"),
    );
  }
}
