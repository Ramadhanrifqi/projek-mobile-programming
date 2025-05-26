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
      appBar: AppBar(
        title: const Text("Tambah Cuti"),
        backgroundColor: const Color(0xFF1E2C2F),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            width: 420,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, size: 40, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Formulir Pengajuan Cuti',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _styledField(_fieldNama()),
                  const SizedBox(height: 16),
                  _styledField(_fieldTanggalMulai()),
                  const SizedBox(height: 16),
                  _styledField(_fieldTanggalSelesai()),
                  const SizedBox(height: 16),
                  _styledField(_fieldAlasan()),
                  const SizedBox(height: 24),
                  _tombolSimpan(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _styledField(Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.tealAccent),
          ),
        ),
      ),
      child: child,
    );
  }

  Widget _fieldNama() {
    return TextFormField(
      controller: _namaCtrl,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(labelText: "Nama Pegawai"),
    );
  }

  Widget _fieldTanggalMulai() {
    return TextFormField(
      controller: _tanggalMulaiCtrl,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
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
      style: const TextStyle(color: Colors.white),
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
      maxLines: 3,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(labelText: "Alasan"),
      validator: (value) => value == null || value.isEmpty ? "Wajib diisi" : null,
    );
  }

  Widget _tombolSimpan() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.tealAccent[700],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
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
      child: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
