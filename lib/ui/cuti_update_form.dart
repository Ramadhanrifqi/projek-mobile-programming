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

  Future<Cuti> getData() async {
    Cuti data = await CutiService().getById(widget.cuti.id.toString());
    setState(() {
      _ajukanCutiCtrl.text = data.ajukanCuti;
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [_fieldNama(), SizedBox(height: 20), _tombolSimpan()],
          ),
        ),
      ),
    );
  }

  _fieldNama() {
    return TextField(
      decoration: const InputDecoration(labelText: "Nama Cuti"),
      controller: _ajukanCutiCtrl,
    );
  }

  _tombolSimpan() {
    return ElevatedButton(
      onPressed: () async {
        Cuti cuti = new Cuti(ajukanCuti: _ajukanCutiCtrl.text);
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
