import 'package:flutter/material.dart';
import '../../model/cuti.dart';
import '../../service/cuti_service.dart';
import '../../helpers/user_info.dart';
import 'cuti_page.dart';

class CutiUpdateFormPage extends StatefulWidget {
  final Cuti cuti;

  const CutiUpdateFormPage({super.key, required this.cuti});

  @override
  State<CutiUpdateFormPage> createState() => _CutiUpdateFormPageState();
}

class _CutiUpdateFormPageState extends State<CutiUpdateFormPage> {
  final TextEditingController _ajukanCutiCtrl = TextEditingController();
  final TextEditingController _tanggalMulaiCtrl = TextEditingController();
  final TextEditingController _tanggalSelesaiCtrl = TextEditingController();
  final TextEditingController _alasanCtrl = TextEditingController();
  final TextEditingController _statusCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ajukanCutiCtrl.text = widget.cuti.ajukanCuti;
    _tanggalMulaiCtrl.text = widget.cuti.tanggalMulai;
    _tanggalSelesaiCtrl.text = widget.cuti.tanggalSelesai;
    _alasanCtrl.text = widget.cuti.alasan;
    _statusCtrl.text = widget.cuti.status;
  }

  Widget _fieldAjukanCuti() {
    return TextFormField(
      controller: _ajukanCutiCtrl,
      readOnly: UserInfo.role == 'admin',
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(labelText: "Ajukan Cuti"),
    );
  }

  Widget _fieldTanggalMulai() {
    return TextFormField(
      controller: _tanggalMulaiCtrl,
      readOnly: UserInfo.role == 'admin',
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(labelText: "Tanggal Mulai"),
    );
  }

  Widget _fieldTanggalSelesai() {
    return TextFormField(
      controller: _tanggalSelesaiCtrl,
      readOnly: UserInfo.role == 'admin',
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(labelText: "Tanggal Selesai"),
    );
  }

  Widget _fieldAlasan() {
    return TextFormField(
      controller: _alasanCtrl,
      readOnly: UserInfo.role == 'admin',
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(labelText: "Alasan"),
    );
  }

  Widget _fieldStatus() {
    if (UserInfo.role != 'admin') return const SizedBox();

    return DropdownButtonFormField<String>(
      value: _statusCtrl.text.isNotEmpty ? _statusCtrl.text : 'Pending',
      decoration: const InputDecoration(labelText: 'Status'),
      dropdownColor: const Color(0xFF203A43),
      style: const TextStyle(color: Colors.white),
      items: ['Pending', 'Disetujui', 'Ditolak'].map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _statusCtrl.text = value!;
        });
      },
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
        Cuti cuti = Cuti(
          ajukanCuti: _ajukanCutiCtrl.text,
          tanggalMulai: _tanggalMulaiCtrl.text,
          tanggalSelesai: _tanggalSelesaiCtrl.text,
          alasan: _alasanCtrl.text,
          status: (UserInfo.role == 'admin') ? _statusCtrl.text : widget.cuti.status,
          userId: widget.cuti.userId,
        );

        String id = widget.cuti.id.toString();

        await CutiService().ubah(cuti, id).then((value) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CutiPage(),
            ),
          );
        });
      },
      child: const Text("Simpan Perubahan", style: TextStyle(fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubah Cuti", style: TextStyle(color: Colors.white)),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0F2027),
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(Icons.edit_calendar, size: 40, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Ubah Pengajuan Cuti',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _styledField(_fieldAjukanCuti()),
                  const SizedBox(height: 16),
                  _styledField(_fieldTanggalMulai()),
                  const SizedBox(height: 16),
                  _styledField(_fieldTanggalSelesai()),
                  const SizedBox(height: 16),
                  _styledField(_fieldAlasan()),
                  const SizedBox(height: 16),
                  _styledField(_fieldStatus()),
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
}
