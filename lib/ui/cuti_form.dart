import 'package:flutter/material.dart';
import '../model/cuti.dart';
import '../service/cuti_service.dart';
import '../helpers/user_info.dart';

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

  String? _userId;

  @override
  void initState() {
    super.initState();
    final user = UserInfo.user;
    if (user != null) {
      _namaCtrl.text = user.username ?? '';
      _userId = user.id;
    }
  }

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
      readOnly: true,
    );
  }

  Widget _fieldTanggalMulai() {
    return TextFormField(
      controller: _tanggalMulaiCtrl,
      readOnly: true,
      decoration: const InputDecoration(labelText: "Tanggal Mulai"),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          _tanggalMulaiCtrl.text = picked.toIso8601String().split('T').first;
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) return 'Wajib diisi';
        try {
          DateTime.parse(value);
        } catch (_) {
          return 'Format tanggal salah (yyyy-mm-dd)';
        }
        return null;
      },
    );
  }

  Widget _fieldTanggalSelesai() {
    return TextFormField(
      controller: _tanggalSelesaiCtrl,
      readOnly: true,
      decoration: const InputDecoration(labelText: "Tanggal Selesai"),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          _tanggalSelesaiCtrl.text = picked.toIso8601String().split('T').first;
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) return 'Wajib diisi';
        try {
          DateTime.parse(value);
        } catch (_) {
          return 'Format tanggal salah (yyyy-mm-dd)';
        }
        return null;
      },
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
          // Validasi logika tanggal
          DateTime mulai = DateTime.parse(_tanggalMulaiCtrl.text);
          DateTime selesai = DateTime.parse(_tanggalSelesaiCtrl.text);

          if (selesai.isBefore(mulai)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tanggal selesai tidak boleh sebelum tanggal mulai")),
            );
            return;
          }

          Cuti cuti = Cuti(
            ajukanCuti: _namaCtrl.text,
            tanggalMulai: _tanggalMulaiCtrl.text,
            tanggalSelesai: _tanggalSelesaiCtrl.text,
            alasan: _alasanCtrl.text,
            status: 'Pending',
            userId: _userId ?? '',
          );

          await CutiService().simpan(cuti).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data berhasil disimpan")),
            );
            Navigator.pop(context);
          });
        }
      },
      child: const Text("Simpan"),
    );
  }
}
