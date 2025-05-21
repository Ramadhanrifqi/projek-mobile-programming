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
    decoration: const InputDecoration(labelText: "Ajukan Cuti"),
  );
}

 Widget _fieldTanggalMulai() {
  return TextFormField(
    controller: _tanggalMulaiCtrl,
    readOnly: UserInfo.role == 'admin',
    decoration: const InputDecoration(labelText: "Tanggal Mulai"),
  );
}

  Widget _fieldTanggalSelesai() {
  return TextFormField(
    controller: _tanggalSelesaiCtrl,
    readOnly: UserInfo.role == 'admin',
    decoration: const InputDecoration(labelText: "Tanggal Selesai"),
  );
}


  Widget _fieldAlasan() {
  return TextFormField(
    controller: _alasanCtrl,
    readOnly: UserInfo.role == 'admin',
    decoration: const InputDecoration(labelText: "Alasan"),
  );
}


  Widget _fieldStatus() {
    if (UserInfo.role != 'admin') return const SizedBox(); // disembunyikan untuk user biasa

    return DropdownButtonFormField<String>(
      value: _statusCtrl.text.isNotEmpty ? _statusCtrl.text : 'Pending',
      decoration: const InputDecoration(labelText: 'Status'),
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
        Navigator.pop(context); // tutup form jika ada dialog sebelumnya
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CutiPage(), 
          ),
        );
      });
    },
    child: const Text("Simpan Perubahan"),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubah Cuti"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _fieldAjukanCuti(),
              _fieldTanggalMulai(),
              _fieldTanggalSelesai(),
              _fieldAlasan(),
              _fieldStatus(),
              const SizedBox(height: 20),
              _tombolSimpan(),
            ],
          ),
        ),
      ),
    );
  }
}
