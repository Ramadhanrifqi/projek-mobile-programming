import 'package:flutter/material.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import 'poli_detail.dart';

class PoliUpdate extends StatefulWidget {
  final Poli poli;

  const PoliUpdate({Key? key, required this.poli}) : super(key: key);

  @override
  _PoliUpdateState createState() => _PoliUpdateState();
}

class _PoliUpdateState extends State<PoliUpdate> {
  final _formKey = GlobalKey<FormState>();
  final _namaPoliCtrl = TextEditingController();

  Future<Poli> getData() async {
    Poli data = await PoliService().getById(widget.poli.id.toString());
    setState(() {
      _namaPoliCtrl.text = data.namaPoli;
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
      appBar: AppBar(title: const Text("Ubah Poli")),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [_fieldNamaPoli(), SizedBox(height: 20), _tombolSimpan()],
          ),
        ),
      ),
    );
  }

  _fieldNamaPoli() {
    return TextField(
      decoration: const InputDecoration(labelText: "Nama Poli"),
      controller: _namaPoliCtrl,
    );
  }

  _tombolSimpan() {
    return ElevatedButton(
      onPressed: () async {
        Poli poli = new Poli(namaPoli: _namaPoliCtrl.text);
        String id = widget.poli.id.toString();
        await PoliService().ubah(poli, id).then((value) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PoliDetail(poli: value)),
          );
        });
      },
      child: const Text("Simpan Perubahan"),
    );
  }
}
