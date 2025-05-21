import 'package:flutter/material.dart';
import '../model/cuti.dart';
import '../service/cuti_service.dart';
import 'cuti_page.dart'; // atau cuti_detail.dart jika langsung ingin menampilkan detail

class CutiForm extends StatefulWidget {
  const CutiForm({super.key});

  @override
  State<CutiForm> createState() => _CutiFormState();
}

class _CutiFormState extends State<CutiForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _tanggalMulaiCtrl = TextEditingController();
  final _tanggalSelesaiCtrl = TextEditingController();
  final _alasanCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Cuti")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
      controller: _namaCtrl,
      decoration: const InputDecoration(labelText: "Nama Cuti"),
      validator: (value) => value == null || value.isEmpty ? "Wajib diisi" : null,
    );
  }

  Widget _fieldTanggalMulai() {
    return TextFormField(
      controller: _tanggalMulaiCtrl,
      decoration: const InputDecoration(labelText: "Tanggal Mulai (yyyy-mm-dd)"),
      validator: (value) => value == null || value.isEmpty ? "Wajib diisi" : null,
    );
  }

  Widget _fieldTanggalSelesai() {
    return TextFormField(
      controller: _tanggalSelesaiCtrl,
      decoration: const InputDecoration(labelText: "Tanggal Selesai (yyyy-mm-dd)"),
      validator: (value) => value == null || value.isEmpty ? "Wajib diisi" : null,
    );
  }

  Widget _fieldAlasan() {
    return TextFormField(
      controller: _alasanCtrl,
      decoration: const InputDecoration(labelText: "Alasan"),
      validator: (value) => value == null || value.isEmpty ? "Wajib diisi" : null,
    );
  }

  Widget _tombolSimpan() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          Cuti cuti = Cuti(
  ajukanCuti: _namaCtrl.text,
  tanggalMulai: _tanggalMulaiCtrl.text,
  tanggalSelesai: _tanggalSelesaiCtrl.text,
  alasan: _alasanCtrl.text,
  status: 'Pending', // atau sesuai logika aplikasi
  userId: '123', // ambil dari user yang sedang login
);


          await CutiService().simpan(cuti).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data berhasil disimpan")),
            );
            Navigator.pop(context); // kembali ke halaman sebelumnya
            // atau gunakan:
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CutiPage()));
          });
        }
      },
      child: const Text("Simpan"),
    );
  }
}
