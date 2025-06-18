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
  // Key untuk validasi form
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input field
  final _namaCtrl = TextEditingController();
  final _tanggalMulaiCtrl = TextEditingController();
  final _tanggalSelesaiCtrl = TextEditingController();
  final _alasanCtrl = TextEditingController();

  // Menyimpan ID user yang login
  String? _userId;

  @override
  void initState() {
    super.initState();

    // Ambil data user yang login dari UserInfo
    final user = UserInfo.user;
    if (user != null) {
      _namaCtrl.text = user.username ?? '';
      _userId = user.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text("Tambah Cuti", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
                  // Ikon dan judul form
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

                  // Input field
                  _styledField(_fieldNama()),
                  const SizedBox(height: 16),
                  _styledField(_fieldTanggalMulai()),
                  const SizedBox(height: 16),
                  _styledField(_fieldTanggalSelesai()),
                  const SizedBox(height: 16),
                  _styledField(_fieldAlasan()),

                  const SizedBox(height: 24),

                  // Tombol Simpan
                  _tombolSimpan(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget pembungkus untuk styling field
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

  // Field Nama Pegawai (readonly)
  Widget _fieldNama() {
    return TextFormField(
      controller: _namaCtrl,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(labelText: "Nama Pegawai"),
    );
  }

  // Field Tanggal Mulai (dengan date picker)
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

  // Field Tanggal Selesai (dengan date picker)
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

  // Field Alasan Cuti
  Widget _fieldAlasan() {
    return TextFormField(
      controller: _alasanCtrl,
      maxLines: 3,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(labelText: "Alasan"),
      validator: (value) => value == null || value.isEmpty ? "Wajib diisi" : null,
    );
  }

  // Tombol untuk menyimpan pengajuan cuti
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
          // Validasi tambahan: tanggal selesai tidak boleh sebelum tanggal mulai
          DateTime mulai = DateTime.parse(_tanggalMulaiCtrl.text);
          DateTime selesai = DateTime.parse(_tanggalSelesaiCtrl.text);

          if (selesai.isBefore(mulai)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tanggal selesai tidak boleh sebelum tanggal mulai")),
            );
            return;
          }

          // Membuat objek Cuti baru dan menyimpannya
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
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          });
        }
      },
      child: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
